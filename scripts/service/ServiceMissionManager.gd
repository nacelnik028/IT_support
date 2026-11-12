extends RefCounted

const Session = preload("res://scripts/network_lab/WorkshopSession.gd")
var catalog: Dictionary = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/service_missions.json"))
var data := {"version":1,"drafts":{},"history":[],"best":{}}
var session = Session.new()
var programming = preload("res://scripts/service/ServiceCodeManager.gd").new()
var owner_ref: WeakRef
var active := false
var id := ""
var attempt_id := ""
var input := {}
var analysis := {}
var prior_changes: Array = []

func _init():
	programming.owner_ref = weakref(self)
	var self_ref: WeakRef = weakref(self)
	programming.available = func(): return self_ref.get_ref()!=null and self_ref.get_ref().available() and self_ref.get_ref().active and not self_ref.get_ref().session.submitted
	programming.persist = func(): return self_ref.get_ref().persist() if self_ref.get_ref()!=null else ERR_UNAVAILABLE
	programming.changed = func():
		var service = self_ref.get_ref()
		if service!=null and service.owner_ref!=null and service.owner_ref.get_ref()!=null: service.owner_ref.get_ref().mark_work_dirty()

func definition(mission_id: String) -> Dictionary:
	for entry in catalog.missions:
		if entry.id==mission_id: return entry
	return {}

func persist() -> Error:
	return owner_ref.get_ref().save() if owner_ref!=null and owner_ref.get_ref()!=null else OK

func available() -> bool:
	if owner_ref==null or owner_ref.get_ref()==null: return false
	var game = owner_ref.get_ref()
	return game.game_mode.is_network_lab() and (not game.network_lab_probe.is_valid() or game.network_lab_probe.call())

func configure_task():
	var d := definition(id)
	session.task.id = id
	session.task.title = d.title
	session.task.cause = d.cause
	session.task.review = d.review
	session.task.ticket = d.symptom
	session.task.goals = d.required.duplicate()
	session.task.before = ["link","dns"] if id=="SERVICE-PORTAL" else ["link"]
	session.task.require_dhcp = true
	session.task.service = "portál, tisk a kontrolní PC + virtuální Python analýza + zákaznické předání"

func start(mission_id: String, mode_value: String) -> bool:
	var d := definition(mission_id)
	if not available() or d.is_empty() or mode_value not in ["learn","practice","exam"] or checkpoint()!=OK: return false
	id = mission_id
	attempt_id = str(OS.get_process_id())+"-"+str(Time.get_ticks_usec())
	active = true
	session.mode = mode_value
	session.start(d.ticket,int(d.seed))
	for port in d.vlans:
		session.network.vlans[int(port)] = int(d.vlans[port])
		session.task.initial.vlans[str(port)] = int(d.vlans[port])
	session.before = session.network.snapshot()
	configure_task()
	prior_changes = []
	input = {}
	analysis = {}
	programming.current = {}
	programming.files = {"main.py":starter()}
	programming.views = {}
	programming.mode = mode_value
	programming.hints = 0
	programming.step = 0
	programming.last_result = {}
	programming.last_run = {}
	programming.draft_dirty = false
	refresh_input()
	persist()
	return true

static func content_hash(value) -> String:
	# Canonical JSON numeric roundtrip is stable across save/load int/float types.
	return JSON.stringify(JSON.parse_string(JSON.stringify(value))).sha256_text()

func starter() -> String:
	var function_name: String = definition(id).function
	return "def "+function_name+"(rows):\n    result = []\n    # Projdi dodané záznamy a vrať ID neúspěšných kontrol / klientů.\n    return result\n\nprint("+function_name+"("+str(definition(id).dataset)+"))\n"

func reference_code() -> String:
	if id=="SERVICE-PORTAL": return "def failed_checks(rows):\n    result = []\n    for row in rows:\n        if not row['ok']:\n            result.append(row['check'])\n    return result\n\nprint(failed_checks(logs))\n"
	return "def affected_clients(rows):\n    result = []\n    for row in rows:\n        if not row['link'] or row['vlan'] != 10:\n            result.append(row['id'])\n    return result\n\nprint(affected_clients(clients))\n"

func records(state: Dictionary = {}) -> Array:
	var n = session.dialogue.copy_network(session.network.snapshot() if state.is_empty() else state)
	var rows: Array = []
	if id=="SERVICE-PORTAL":
		n.probe("dhcp")
		for key in ["link","gateway","dns","tcp","https","printer","control"]:
			var observation: Dictionary = n.probe(key)
			rows.append({"check":key,"ok":observation.passed,"source":observation.source,"detail":observation.detail})
	else:
		for device in n.CLIENTS: rows.append({"id":device,"link":n.link(device),"port":int(n.ports[device]),"vlan":n.segment(device)})
	return rows

func expected(rows: Array) -> Array:
	var result: Array = []
	for row in rows:
		if id=="SERVICE-PORTAL":
			if not row.ok: result.append(row.check)
		elif not row.link or int(row.vlan)!=10: result.append(row.id)
	return result

func refresh_input():
	if not active or session.submitted: return
	var rows := records()
	input = {"attempt":attempt_id,"revision":session.network.revision,"records":rows,"hash":content_hash(rows)}
	configure_program()
	programming.last_result = {}
	programming.last_run = {}
	persist()

func configure_program():
	var d := definition(id)
	var rows: Array = input.records
	var reversed: Array = rows.duplicate(true)
	reversed.reverse()
	var passing: Array = rows.duplicate(true)
	for row in passing:
		if id=="SERVICE-PORTAL": row.ok = true
		else:
			row.link = true
			row.vlan = 10
	var tests: Array = []
	var historical := records(session.before)
	for dataset in [rows,reversed,passing,historical]:
		tests.append({"globals":{d.dataset:rows,"initial_"+str(d.dataset):historical},"call":{"name":d.function,"args":[dataset],"value":expected(dataset)},"label":"Analýza virtuálních dat incidentu"})
	var instruction := "Vrať ve vstupním pořadí seznam check u záznamů s ok == False." if id=="SERVICE-PORTAL" else "Vrať ve vstupním pořadí id klientů, kteří nemají linku nebo nejsou ve VLAN 10."
	programming.current = {"id":id,"title":d.title+" / Python","category":"python","topic":"Python","difficulty":"practical","description":instruction+"\nData "+d.dataset+" jsou virtuální snímek tohoto incidentu. Funkce "+d.function+"(rows) dostává seznam slovníků; žádná skutečná síť ani soubory zařízení.","starter":{"main.py":starter()},"tests":tests,"constructs":[],"explanation":"Procházej vstupní seznam a podle skutečných hodnot přidávej ID do výsledku. Testy používají aktuální a výchozí data tohoto incidentu, obrácené pořadí a bezchybnou kontrolní sadu.","errors":"Pevně zapsaná odpověď nefunguje pro jiné vstupy. Starší revizi dat je třeba výslovně obnovit.","hints":["Použij for row in rows a podmínku nad hodnotami slovníku; výsledek vrať pomocí return."],"example":{"main.py":reference_code()},"reward":0}
	programming.mode = session.mode

func analysis_input_current() -> bool:
	return active and not input.is_empty() and input.attempt==attempt_id and int(input.revision)==session.network.revision and input.hash==content_hash(records())

func analysis_current() -> bool:
	return analysis_input_current() and analysis.get("passed",false) and analysis.get("attempt")==attempt_id and analysis.get("hash")==input.hash and int(analysis.get("revision",-1))==session.network.revision and analysis.get("source_hash")==content_hash(programming.files)

func record_analysis(result: Dictionary):
	var runtime = preload("res://scripts/programming/PythonRuntime.gd").new()
	var run: Dictionary = runtime.run(programming.files.get("main.py",""),[],programming.current.tests[0].globals)
	var value = runtime.invoke(definition(id).function,[input.records]) if run.ok else null
	analysis = {"attempt":attempt_id,"revision":input.revision,"hash":input.hash,"source_hash":content_hash(programming.files),"passed":result.ok and analysis_input_current(),"output":str(value).left(4000) if run.ok and runtime.error=="" else str(run.get("error",runtime.error)).left(4000),"score":int(result.score),"diagnostics":result.get("diagnostics",[]).duplicate(true)}
	analysis.input = input.records.duplicate(true)
	analysis.initial_input = records(session.before)
	result.saved = persist()==OK

func technical() -> Dictionary:
	var report: Dictionary = session.assessment()
	if not analysis_current(): report.missing.append("Chybí úspěšná analýza aktuálních virtuálních dat v Pythonu.")
	if id=="SERVICE-MOVE":
		var proof: Dictionary = session.network.measurements.get("tester",{})
		if not proof.get("passed",false) or int(proof.get("revision",-1))!=session.network.revision or proof.get("source")!="pc04" or proof.get("target")!="SW %02d" % int(session.network.ports.pc04): report.missing.append("Změř aktuální fyzickou trasu PC 04 testerem.")
		var initial_test := false
		for entry in session.network.journal:
			if entry.kind=="tester" and entry.source=="pc04" and not entry.passed and int(entry.revision)<session.network.revision: initial_test = true
		if not initial_test: report.missing.append("Chybí výchozí dohledání vadné fyzické trasy testerem.")
	report.passed = report.missing.is_empty()
	report.score = maxi(0,100-session.errors*10-session.hints*5-mini(20,programming.hints*5)) if report.passed else 0
	return report

func verify() -> Dictionary:
	if not active or session.submitted: return session.result
	var tech := technical()
	if not tech.passed: session.errors += 1
	tech.errors = session.errors
	var communication: Dictionary = session.dialogue.assessment(session)
	var missing: Array = tech.missing.duplicate()
	if not communication.passed: missing.append("Dokonči přesné zákaznické předání a skutečné potvrzení služby.")
	session.result = {"passed":tech.passed and communication.passed,"score":tech.score,"missing":missing,"revision":session.network.revision,"causes":session.causes.duplicate(),"evidence_summary":session.evidence_summary.duplicate(),"technical":tech,"communication":communication}
	session.result.communication_hash = content_hash(session.dialogue.data)
	session.result.analysis_hash = analysis.get("source_hash","")
	session.result.help_count = session.hints+programming.hints
	session.view = "review"
	return session.result

func stale() -> bool:
	if session.submitted or session.result.is_empty(): return false
	return session.stale() or not analysis_current() or session.result.get("analysis_hash")!=analysis.get("source_hash","") or session.result.get("communication_hash")!=content_hash(session.dialogue.data) or int(session.result.get("help_count",-1))!=session.hints+programming.hints

func changes() -> Array:
	var result: Array = prior_changes.duplicate()
	for change in session.undo_stack: result.append(change.title)
	return result.slice(maxi(0,result.size()-30))

func submit() -> Dictionary:
	if not active: return {}
	if session.submitted:
		persist()
		return session.result
	verify()
	session.submitted = true
	var gained := 0
	if session.result.passed:
		var old := int(data.best.get(id,0))
		gained = maxi(0,int(session.result.score)-old)*2
		data.best[id] = maxi(old,int(session.result.score))
		if owner_ref!=null and owner_ref.get_ref()!=null: owner_ref.get_ref().progress.xp += gained
	var proof: Array = []
	for entry in session.network.journal:
		var observation: Dictionary = entry.duplicate(true)
		observation.erase("frames")
		proof.append(observation)
	var record := {"id":id,"attempt":attempt_id,"version":1,"mode":session.mode,"variant":{"seed":session.variant_seed,"generator_version":session.generator_version},"time":int(Time.get_unix_time_from_system()),"passed":session.result.passed,"score":session.result.score,"technical":session.result.technical.duplicate(true),"communication":session.result.communication.duplicate(true),"analysis":analysis.duplicate(true),"proof":proof,"changes":changes(),"dialogue":session.dialogue.data.duplicate(true),"cause":session.task.cause,"symptom":session.task.ticket,"hints":session.hints+programming.hints,"xp":gained}
	data.history.append(record)
	if data.history.size()>50: data.history.pop_front()
	data.drafts.erase(id)
	persist()
	return session.result

func stripped(state: Dictionary) -> Dictionary:
	var value := state.duplicate(true)
	for entry in value.journal: entry.erase("frames")
	for entry in value.measurements.values(): entry.erase("frames")
	return value

func checkpoint() -> Error:
	if not active or session.submitted: return OK
	if programming.checkpoint()!=OK: return ERR_INVALID_DATA
	data.drafts[id] = {"id":id,"version":1,"attempt":attempt_id,"mode":session.mode,"seed":session.variant_seed,"generator_version":session.generator_version,"network":stripped(session.network.snapshot()),"initial":stripped(session.before),"hints":session.hints,"errors":session.errors,"dialogue":session.dialogue.data.duplicate(true),"changes":changes(),"program":{"files":programming.files.duplicate(),"views":programming.views.duplicate(true),"active":programming.active_file,"hints":programming.hints,"font_size":int(programming.progress.settings.font_size)},"input":input.duplicate(true),"analysis":analysis.duplicate(true)}
	programming.draft_dirty = false
	return OK

func suspend() -> bool:
	if checkpoint()!=OK: return false
	session.tester.put_back()
	active = false
	return true

func resume(mission_id: String) -> bool:
	if not available() or not data.drafts.has(mission_id) or checkpoint()!=OK: return false
	var draft: Dictionary = data.drafts[mission_id].duplicate(true)
	var d := definition(mission_id)
	id = mission_id
	attempt_id = draft.attempt
	session.mode = draft.mode
	session.start(d.ticket,int(draft.seed),int(draft.generator_version))
	configure_task()
	session.network.restore(draft.network)
	session.before = draft.initial.duplicate(true)
	session.dialogue.data = draft.dialogue.duplicate(true)
	session.hints = int(draft.hints)
	session.errors = int(draft.errors)
	prior_changes = draft.changes.duplicate()
	programming.files = draft.program.files.duplicate()
	programming.views = draft.program.views.duplicate(true)
	programming.active_file = draft.program.active
	programming.hints = int(draft.program.hints)
	programming.progress.settings.font_size = int(draft.program.font_size)
	programming.last_result = {}
	programming.last_run = {}
	programming.draft_dirty = false
	input = draft.input.duplicate(true)
	analysis = draft.analysis.duplicate(true)
	active = true
	configure_program()
	return true
