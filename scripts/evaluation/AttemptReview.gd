extends RefCounted

const Network=preload("res://scripts/simulation/NetworkSimulator.gd")
const MAX_EVENTS=40
const MAX_REVIEWS=20

static func values(state: Dictionary) -> Dictionary:
	var result={}
	for id in state.vms:
		var vm=state.vms[id]
		if not vm.get("exists",false): continue
		for field in ["host","status","cpu","ram","minimum","maximum","dynamic","bridge","vlan","ip","prefix","gateway","dns","firewall","disk_present","agent","vss","boot","data"]:
			if vm.has(field): result["vms."+id+"."+field]=vm[field]
	for id in state.world.devices:
		for field in ["cable_connected","power_connected","port"]: result["world.devices."+id+"."+field]=state.world.devices[id][field]
	for id in state.disks:
		for field in ["health","serial","capacity"]: result["disks."+id+"."+field]=state.disks[id][field]
	for id in state.world.stock: result["world.stock."+id+".available"]=state.world.stock[id].available
	result["world.held"]=state.world.held
	for field in ["health","progress","cache","cache_policy"]:
		if state.raid.has(field): result["raid."+field]=state.raid[field]
	for field in ["health","progress"]: result["zfs."+field]=state.zfs[field]
	for field in ["configured","verified","target"]: result["backup."+field]=state.backup[field]
	for id in state.backup.records:
		for field in ["ram","vlan","gateway","vss","data"]:
			if state.backup.records[id].has(field): result["backup.records."+id+"."+field]=state.backup.records[id][field]
	return result

static func probes(state: Dictionary) -> Dictionary:
	var result={}
	for id in state.vms:
		if state.vms[id].get("exists",false): result[id]=Network.probe(state,id)
	return result

static func mode(game) -> String:
	return game.tutorial.session.get("mode","practice" if game.training else "campaign")

static func begin(game, partial: bool = false):
	game.sim.state._trace={"version":1,"session":game.attempt_id,"partial":partial,"initial":values(game.sim.state),"probes":probes(game.sim.state),"events":[]}

static func proof(state: Dictionary) -> Dictionary:
	var result={}
	for key in ["service_pve","service_hv","raid","zfs","restore","capacity"]: result[key]=state.verified.get(key,false)
	return result

static func record(game, action: String, params: Dictionary, result: Dictionary, before: Dictionary, forced_kind: String = ""):
	var state=game.sim.state
	if not state.has("_trace") or state._trace.session!=game.attempt_id: begin(game,true)
	var after=values(state)
	var paths=before.keys()
	for path in after:
		if not path in paths: paths.append(path)
	paths.sort()
	var changes=[]
	if result.ok:
		for path in paths:
			var previous=before.get(path,"<nenastaveno>")
			var current=after.get(path,"<nenastaveno>")
			if not preload("res://scripts/evaluation/ObjectiveEvaluator.gd").equal_values(previous,current): changes.append({"path":path,"before":previous,"after":current})
	var kind=forced_kind
	if kind=="":
		kind="rejected" if not result.ok else "verification" if action in ["verify","probe","backup_verify"] else "diagnostic" if action in ["inspect","physical_inspect","physical_monitor","physical_identify"] else "change"
	var target=str(params.get("vm",params.get("device",params.get("pool",params.get("id","infrastruktura")))))
	if params.has("slot"): target+=" / slot "+str(params.slot)
	var vm=game.sim.get_vm(str(params.get("vm","")))
	if not vm.is_empty(): target+=" / "+str(vm.host)
	state._trace.events.append({"session":game.attempt_id,"revision":int(state.revision),"kind":kind,"action":action,"target":target,"ok":result.ok,"changes":changes.slice(0,32),"omitted":maxi(0,changes.size()-32),"checks":proof(state) if kind=="verification" else {},"text":str(result.get("text","")).left(2000)})
	if state._trace.events.size()>MAX_EVENTS: state._trace.events.pop_front()

static func finish(game, score: int, xp: int) -> Dictionary:
	if not game.sim.state.has("_trace"): begin(game,true)
	record(game,"submit",{}, {"ok":true,"text":"Ticket předán podle skutečných cílů."},values(game.sim.state),"submitted")
	var trace=game.sim.state._trace
	var question="storage" if trace.initial.get("raid.health","")!="Healthy" else "verification"
	var record_data={"version":1,"id":game.attempt_id+":"+str(game.current.id),"session":game.attempt_id,"title":game.current.title,"kind":game.session_kind,"mode":mode(game),"score":score,"xp":xp,"time":int(Time.get_unix_time_from_system()),"partial":trace.partial,"initial":trace.initial.duplicate(true),"initial_probes":trace.probes.duplicate(true),"events":trace.events.duplicate(true),"final":values(game.sim.state),"probes":probes(game.sim.state),"revision":int(game.sim.state.revision),"verified":proof(game.sim.state),"question":question,"answer":""}
	var tags=game.current.get("tags",[game.current.category]).duplicate()
	for event in trace.events:
		var domain="Sítě" if event.action in ["network","probe","physical_cable"] else "RAID" if event.action in ["rebuild","physical_remove","physical_insert"] else "Zálohy" if event.action in ["backup","backup_verify"] else ""
		if domain!="" and not domain in tags: tags.append(domain)
	record_data.recommendations=[]
	for lesson in game.Profile.recommendations(game,tags): record_data.recommendations.append({"id":int(lesson.id),"title":lesson.title,"mode":"practice"})
	var records=game.work.data.reviews
	for old in records:
		if old.id==record_data.id: return old
	records.append(record_data)
	if records.size()>MAX_REVIEWS: records.pop_front()
	return record_data

static func explanation(record_data: Dictionary) -> String:
	var lines=[record_data.title,"Zaznamenaný výsledek: %d / 100 · přidané XP: %d" % [int(record_data.score),int(record_data.xp)],"\nPŘÍČINA / původní model" ]
	if record_data.partial: lines.append("Záznam začal až během pokusu; dřívější příčina není doložená.")
	for id in record_data.initial_probes:
		var probe=record_data.initial_probes[id]
		if not probe.app: lines.append("VM%s / %s: %s" % [id,record_data.initial.get("vms."+id+".host",""),probe.reason])
	for path in record_data.initial:
		if path.ends_with(".vlan") and not path.begins_with("backup.") and int(record_data.initial[path])!=20: lines.append(path+" = "+str(record_data.initial[path])+"; laboratorní síť vyžaduje VLAN20.")
		if path.begins_with("disks.") and path.ends_with(".health") and record_data.initial[path]!="Healthy": lines.append(path+" = "+str(record_data.initial[path]))
	lines.append("\nPROVEDENÉ ZÁSAHY / skutečné hodnoty před → po")
	for event in record_data.events:
		lines.append("%s · %s · %s · revize %d" % [{"change":"Použito","rejected":"Odmítnuto / bez opravy","diagnostic":"Diagnostika","verification":"Ověření","planned":"Plánovaná porucha","submitted":"Předáno","undo":"Vrácení zásahu"}.get(event.kind,event.kind),event.action,event.target,int(event.revision)])
		if event.kind=="rejected": lines.append(event.text.split("\n")[0])
		for change in event.changes: lines.append("  "+change.path+": "+str(change.before)+" → "+str(change.after))
		if int(event.omitted)>0: lines.append("Další změněné položky mimo omezený výpis: "+str(int(event.omitted)))
	lines.append("\nSOUČASNÝ VÝSLEDEK A DŮKAZY")
	for id in record_data.probes:
		var key="service_hv" if str(record_data.final.get("vms."+id+".host","")).begins_with("HV") else "service_pve"
		lines.append("VM%s: %s. %s" % [id,"model nyní dovoluje HTTPS a data" if record_data.probes[id].app else record_data.probes[id].reason,"Aktuální ověření této revize je zaznamenané." if record_data.verified.get(key,false) else "Aktuální ověření po poslední změně chybí; starší kontrola není důkaz."])
	lines.append("Záloha / Verify uložených bodů: "+("provedeno" if record_data.final.get("backup.verified",false) else "neprovedeno")+". Záloha a ověření živé aplikace jsou samostatné kontroly.")
	lines.append("\nDOPORUČENÁ KONKRÉTNÍ VÝUKA")
	for lesson in record_data.get("recommendations",[]): lines.append("%d / %s / Procvičování" % [int(lesson.id),lesson.title])
	return "\n".join(lines)

static func question(record_data: Dictionary) -> Dictionary:
	if record_data.question=="storage": return {"text":"Dokazuje stav RAID Healthy také existenci nové nezávislé ověřené zálohy?","options":[["separate_backup","Ne. Záloha a její Verify vyžadují samostatné ověření."],["raid_enough","Ano. Healthy automaticky znamená platnou PBS zálohu."]],"answer":"separate_backup","explanation":"Redundance pole a nezávislý bod obnovy řeší odlišné poruchy. Zdravé pole samo novou zálohu nevytvoří."}
	return {"text":"Po změně konfigurace VM stačí staré zelené ověření z předchozí revize?","options":[["verify_current","Ne. Ověř znovu dostupnost HTTPS a aplikační data."],["old_check","Ano. Jednou provedená kontrola platí po všech dalších změnách."]],"answer":"verify_current","explanation":"Změna může znovu přerušit cestu nebo aplikaci. Důkaz musí odpovídat současné revizi."}

static func valid_values(data) -> bool:
	if not data is Dictionary or data.size()>512: return false
	for path in data:
		if not path is String or path.length()>160: return false
		var value=data[path]
		if value is String:
			if value.length()>1000: return false
		elif not typeof(value) in [TYPE_BOOL,TYPE_INT,TYPE_FLOAT]: return false
		elif typeof(value) in [TYPE_INT,TYPE_FLOAT] and not is_finite(value): return false
	return true

static func valid_probes(data) -> bool:
	if not data is Dictionary or data.size()>32: return false
	for id in data:
		if not id is String or not id.is_valid_int() or not data[id] is Dictionary: return false
		var probe=data[id]
		for key in ["link","ip","dns","app"]:
			if not probe.get(key) is bool: return false
		if not probe.get("reason") is String or probe.reason.length()>1000: return false
	return true

static func valid_proof(data) -> bool:
	if not data is Dictionary or data.size()>6: return false
	for key in data:
		if not key in ["service_pve","service_hv","raid","zfs","restore","capacity"] or not data[key] is bool: return false
	return true

static func valid_events(events, session: String, revision: int) -> bool:
	if not events is Array or events.size()>MAX_EVENTS: return false
	for event in events:
		if not event is Dictionary or event.get("session")!=session or not event.get("ok") is bool or not event.get("changes") is Array: return false
		if not event.get("kind") in ["change","rejected","diagnostic","verification","planned","submitted","undo"] or not valid_proof(event.get("checks")): return false
		if not preload("res://scripts/programming/CodeDrafts.gd").number(event.get("revision"),0,revision) or not preload("res://scripts/programming/CodeDrafts.gd").number(event.get("omitted"),0): return false
		for key in ["action","target","text"]:
			if not event.get(key) is String or event[key].length()>2000: return false
		if event.changes.size()>32 or (not event.ok and not event.changes.is_empty()): return false
		for change in event.changes:
			if not change is Dictionary or not change.get("path") is String or not valid_values({change.path:change.get("before"),"after":change.get("after")}): return false
	return true

static func valid_live(trace, revision: int) -> bool:
	return trace is Dictionary and trace.get("version")==1 and trace.get("session") is String and trace.session.length()<=160 and trace.get("partial") is bool and valid_values(trace.get("initial")) and valid_probes(trace.get("probes")) and valid_events(trace.get("events"),trace.session,revision)

static func valid_review(data) -> bool:
	if not data is Dictionary or data.get("version")!=1 or not data.get("id") is String or not data.get("session") is String or not data.get("title") is String: return false
	if data.id.length()>200 or data.session.length()>160 or data.title.length()>1000 or not data.get("partial") is bool or not valid_proof(data.get("verified")): return false
	var rules=preload("res://scripts/programming/CodeDrafts.gd")
	for pair in [["score",100],["xp",1000000],["revision",2147483647],["time",9007199254740991]]:
		if not rules.number(data.get(pair[0]),0,pair[1]): return false
	if not data.get("kind") in ["campaign","lesson","random","shift"] or not data.get("mode") in ["campaign","learn","practice","exam"] or not data.get("question") in ["storage","verification"]: return false
	if not valid_values(data.get("initial")) or not valid_values(data.get("final")) or not valid_probes(data.get("probes")) or not valid_probes(data.get("initial_probes")) or not valid_events(data.get("events"),data.session,int(data.revision)): return false
	if not data.get("recommendations",[]) is Array or data.get("recommendations",[]).size()>3: return false
	for lesson in data.get("recommendations",[]):
		if not lesson is Dictionary or not rules.number(lesson.get("id"),1001,1021) or not lesson.get("title") is String or lesson.title.length()>300 or lesson.get("mode")!="practice": return false
	var options=question(data).options.map(func(option): return option[0])
	return data.get("answer")=="" or data.get("answer") in options
