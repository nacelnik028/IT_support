extends RefCounted

const Model = preload("res://scripts/network_lab/WorkshopNetwork.gd")
const MODES = {"learn":"Výuka","practice":"Procvičování","exam":"Zkouška","free":"Volný trénink"}
var catalog: Dictionary = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/network_lab/workshop.json"))
var network = Model.new()
var example = Model.new()
var task := {}
var mode := "practice"
var view := "home"
var selected := "pc04"
var selected_port := 4
var filter := "Vše"
var selected_frame := -1
var selected_history := -1
var attempts: Array = []
var undo_stack: Array = []
var result := {}
var before := {}
var hints := 0
var errors := 0
var submitted := false
var credited := false
var causes := {}
var evidence_summary := {}
var demo := false
var demo_step := 0
var persist := Callable()
# Local presentation state survives closing the panel during this visit only.
var panel_state := {}
var attempt_serial := 0
var variant_seed := 0
var generator_version := 1
var tester = preload("res://scripts/network_lab/CableTester.gd").new()
var dialogue = preload("res://scripts/english/SupportDialogue.gd").new()

func variant(id: String, seed_value := 0, version_value := 1) -> Dictionary:
	var base := definition(id).duplicate(true)
	if base.is_empty() or version_value!=1 or seed_value<0: return {}
	if seed_value>0: base = base.variants[posmod(seed_value-1,3)].duplicate(true)
	base.erase("variants")
	base.initial.seed = seed_value
	return base

func reset_attempt():
	start(str(task.get("id","")),variant_seed,generator_version)

func _init(): network.setup("")

func definition(id: String) -> Dictionary:
	for entry in catalog.tasks:
		if entry.id==id: return entry
	return {}

func start(id: String, seed_value := 0, version_value := 1):
	var next_task := variant(id,seed_value,version_value)
	if id!="" and next_task.is_empty(): return
	attempt_serial += 1
	panel_state.clear()
	task = next_task
	variant_seed = seed_value
	generator_version = version_value
	network.setup(id,task.get("initial",{}))
	view = "ticket" if not task.is_empty() else "measure"
	selected = "pc04"
	selected_port = int(network.ports.pc04) if int(network.ports.pc04)>0 else 4
	selected_frame = -1
	undo_stack = []
	result = {}
	before = network.snapshot()
	hints = 0
	errors = 0
	submitted = false
	credited = false
	causes = {}
	evidence_summary = {}
	demo = false
	demo_step = 0
	tester = preload("res://scripts/network_lab/CableTester.gd").new()
	dialogue = preload("res://scripts/english/SupportDialogue.gd").new()

func cancel():
	start("")
	view = "home"

func locked() -> bool: return submitted
func model(): return example if demo else network
func stale() -> bool: return not result.is_empty() and (result.revision!=network.revision or result.get("causes",{})!=causes or result.get("evidence_summary",{})!=evidence_summary)

func remember(state: Dictionary, title: String):
	undo_stack.append({"state":state,"title":title})
	if undo_stack.size()>30: undo_stack.pop_front()

func edit(kind: String, value = null):
	if locked() or demo: return
	var state: Dictionary = network.snapshot()
	if network.edit(kind,value):
		var titles := {"pool":"DHCP rozsah "+network.pool_label()+" / "+("uvolněn" if value else "vyčerpán"),"dns":"Záznam A → "+str(value),"flush":"Obnova DNS cache PC 04","arp":"Smazání souseda 192.168.10.1","tcp":"Služba HTTPS / "+("spuštěna" if value else "zastavena"),"https_rule":"Pravidlo HTTPS / "+("povoleno" if value else "blokováno"),"management":"Správa / "+("povolena" if value else "blokována"),"ap":"AP / "+("středový úchyt" if str(value)=="center" else "přední úchyt"),"static":"PC 04 / pevná IPv4 adresa"}
		remember(state,titles.get(kind,kind))

func vlan(port: int, value: int):
	if locked() or demo: return
	var state: Dictionary = network.snapshot()
	network.set_vlan(port,value)
	if state.revision!=network.revision: remember(state,"SW %02d / VLAN %d" % [port,value])

func select_cable(id: String):
	if not locked() and not demo: network.select_cable(id)

func connect_port(port: int):
	if locked() or demo: return
	var state: Dictionary = network.snapshot()
	network.connect_cable(port)
	if state.revision!=network.revision: remember(state,"Přepojení "+str(network.NAMES.get(state.cable,state.cable))+" → SW %02d" % port)

func unplug(device: String):
	if locked() or demo: return
	var state: Dictionary = network.snapshot()
	network.unplug(device)
	if state.revision!=network.revision: remember(state,"Odpojení "+network.NAMES[device])

func undo():
	if locked() or demo or undo_stack.is_empty(): return
	var revision: int = network.revision+1
	var state: Dictionary = undo_stack.pop_back()
	network.restore(state.state)
	network.revision = revision
	network.cable = ""
	network.last_message = "Vráceno: "+state.title+". Měření jsou zastaralá."

func hint():
	if mode=="exam" or submitted or task.is_empty(): return
	hints = 1

func measure(kind: String) -> Dictionary:
	if submitted: return {}
	return model().probe(kind,selected)

func measure_tester() -> Dictionary:
	if locked() or demo: return {}
	var observation: Dictionary = tester.measure(network)
	if observation.has("state"): network.physical_event.emit("tester",tester.source)
	return observation

func start_demo():
	if mode!="learn" or task.is_empty() or submitted: return
	example.setup(task.id,task.initial)
	demo = true
	demo_step = 0

func demo_next():
	if not demo: return
	# Each click performs a real operation against the isolated network.
	if demo_step==0: example.probe("link")
	elif demo_step==1: example.probe("dhcp")
	elif demo_step==2:
		if not example.link("pc04"):
			example.select_cable("pc04")
			for port in range(3,9):
				if example.occupant(port)=="" and port not in example.bad_ports and example.vlans[port]==10:
					example.connect_cable(port)
					break
		example.set_vlan(example.ports.pc04,10)
		example.edit("pool",true)
		example.edit("arp")
		example.edit("dns",example.WEB)
		example.edit("flush")
		example.edit("tcp",true)
		example.edit("https_rule",true)
		example.edit("ap","center")
	elif demo_step==3: example.probe("dhcp")
	elif demo_step==4: example.probe("https")
	else: return
	demo_step += 1

func assessment() -> Dictionary:
	var missing: Array = []
	for key in task.goals:
		if not network.fresh(key): missing.append("Změř znovu: "+str(key))
	for key in task.before:
		var observed := false
		for entry in network.journal:
			if entry.kind==key and entry.revision<network.revision: observed = true
		if not observed: missing.append("Chybí výchozí měření: "+str(key))
	if not network.reachable("pc02","router") or not network.reachable("printer","router") or int(network.vlans[5])!=20 or not network.rules.guest_isolated or network.rules.management: missing.append("Zachovej PC 02, tiskárnu, správu a oddělení hostovské VLAN 20.")
	if (task.id in ["B","C","H"] or task.get("require_dhcp",false)) and (network.lease.is_empty() or network.lease_source!="dhcp" or not network.dhcp_pool): missing.append("Požadován skutečný DHCP pronájem.")
	if task.id=="C" and (network.lease.get("mask")!="255.255.255.0" or network.lease.get("gateway")!=network.IPS.router or network.lease.get("dns")!=network.IPS.resolver): missing.append("Ověř úplnou IPv4 konfiguraci.")
	if task.id=="F" and (network.rules.management or not network.rules.guest_isolated): missing.append("Zachovej pravidla správy a izolace.")
	if task.id=="H":
		var expected: Array = task.get("required_causes",["vlan","dns"])
		for key in ["vlan","dns","cable","https"]:
			if causes.get(key,false)!=(key in expected): missing.append("Výběr příčin neodpovídá incidentu.")
	if task.id=="H" and (not evidence_summary.get("dhcp",false) or not evidence_summary.get("services",false) or evidence_summary.get("led_only",false)): missing.append("Vyber důkazy: úplný DHCP pronájem a HTTPS s tiskárnou i PC 02. Samotná LED nestačí.")
	if task.id=="H" and task.get("observe_old_dns",true):
		var observed_dns := false
		for proof in network.journal:
			if proof.kind=="dns" and proof.detail.contains("cache "+network.old_dns) and proof.revision<network.revision: observed_dns = true
		if not observed_dns: missing.append("Po zprovoznění sítě změř starou DNS odpověď před její opravou.")
	return {"passed":missing.is_empty(),"missing":missing}

func verify() -> Dictionary:
	if task.is_empty() or demo or submitted: return result
	result = assessment()
	result.revision = network.revision
	result.causes = causes.duplicate()
	result.evidence_summary = evidence_summary.duplicate()
	if not result.passed: errors += 1
	result.score = maxi(0,100-10*errors-5*hints) if result.passed else 0
	view = "review"
	return result

func submit() -> Dictionary:
	if task.is_empty() or mode=="free" or demo: return result
	if not submitted:
		verify()
		submitted = true
		var proof: Array = []
		for entry in network.journal:
			var summary: Dictionary = entry.duplicate(true)
			summary.erase("frames")
			proof.append(summary)
		var record := {"id":task.id,"mode":mode,"passed":result.passed,"score":result.score,"hints":hints,"errors":errors,"time":int(Time.get_unix_time_from_system()),"proof":proof,"causes":causes.duplicate(),"evidence_summary":evidence_summary.duplicate(),"changes":[]}
		record.variant = {"seed":variant_seed,"generator_version":generator_version}
		record.communication = dialogue.assessment(self)
		record.dialogue = dialogue.data.duplicate(true)
		for change in undo_stack: record.changes.append(change.title)
		attempts.append(record)
		if attempts.size()>100: attempts.pop_front()
		credited = true
	# Retry serializes the same record; it cannot append or grade twice.
	if persist.is_valid(): persist.call()
	return result

func review_text() -> String:
	if result.is_empty(): return "Nejdřív ověř řešení; ve zkoušce odevzdej ticket."
	if mode=="exam" and not submitted: return "Rozbor bude dostupný po odevzdání."
	var interventions: PackedStringArray = []
	for change in undo_stack: interventions.append(change.title)
	var initial = Model.new()
	initial.restore(before)
	var observations: PackedStringArray = [initial.overview(),initial.configuration()]
	for key in task.before:
		for proof in network.journal:
			if proof.kind==key:
				observations.append(proof.detail)
				break
	var lines: PackedStringArray = ["SYMPTOM / "+task.ticket,"DŮKAZ PŘED\n"+"\n".join(observations),"PŘÍČINA / "+task.cause,"ZÁSAH / "+"; ".join(interventions),"VYSVĚTLENÍ / "+task.review,"NOVÉ MĚŘENÍ"]
	for key in network.measurements:
		var entry: Dictionary = network.measurements[key]
		lines.append(entry.detail+(" / ZASTARALÉ" if entry.revision!=network.revision else " / OK" if entry.passed else " / NESPLNĚNO"))
	lines.append("Chybná ověření %d / nápověda %d / PC 02 %s / VLAN 20 %s" % [errors,hints,"OK" if network.reachable("pc02","router") else "výpadek","OK" if network.vlans[5]==20 else "porušena"])
	return "\n\n".join(lines)
