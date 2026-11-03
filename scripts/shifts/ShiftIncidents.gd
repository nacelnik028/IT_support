extends RefCounted

static func observe(game, definition: Dictionary, action: String, params: Dictionary, result: Dictionary):
	if not definition.get("advanced",false) or not result.ok: return
	var state=game.sim.state
	var runtime=state.shift_runtime
	if action=="backup": runtime.fresh_backups[str(params.vm)]=true
	if action=="physical_monitor": runtime.monitor_revision=int(state.revision)
	for incident in definition.get("triggers",[]):
		if incident.id in runtime.fired: continue
		if not game.Evaluator.evaluate(state,incident.checks).all(func(goal): return goal.passed): continue
		var before=game.Review.values(state)
		game.Simulator.merge(state,incident.patch)
		runtime.fired.append(incident.id)
		game.sim.success("PLÁNOVANÝ INCIDENT / "+incident.id+": "+incident.title+". Dosavadní konfigurace a servisní inventář zůstaly zachované.")
		game.Review.record(game,"incident:"+incident.id,{}, {"ok":true,"text":incident.title},before,"planned")
		runtime.events.append({"id":incident.id,"revision":int(state.revision),"clock":int(runtime.clock)})

static func advance(game, params: Dictionary) -> Dictionary:
	var minutes=params.get("minutes",1)
	if not preload("res://scripts/programming/CodeDrafts.gd").number(minutes,1,60): return game.sim.reject("Simulovaný čas musí být celé číslo 1–60 minut.")
	var runtime=game.sim.state.shift_runtime
	runtime.clock+=int(minutes)
	if not game.sim.Network.probe(game.sim.state,"100").app or not game.sim.Network.probe(game.sim.state,"200").app: runtime.outage_minutes+=int(minutes)
	return game.sim.success("Simulovaný čas: %d min; explicitně sledovaná doba výpadku alespoň jedné služby: %d min. Pauza ani FPS čas neposouvají." % [int(runtime.clock),int(runtime.outage_minutes)],false)

static func valid(runtime, definition: Dictionary) -> bool:
	if not runtime is Dictionary or not runtime.get("fired") is Array or not runtime.get("events") is Array or not runtime.get("fresh_backups") is Dictionary: return false
	var rules=preload("res://scripts/programming/CodeDrafts.gd")
	if not rules.number(runtime.get("monitor_revision"),0): return false
	if not rules.number(runtime.get("clock"),0) or not rules.number(runtime.get("outage_minutes"),0,int(runtime.clock)): return false
	var ids=[]
	for incident in definition.get("triggers",[]): ids.append(incident.id)
	if runtime.events.size()!=runtime.fired.size() or runtime.fired.size()>ids.size(): return false
	var seen=[]
	for index in runtime.fired.size():
		var id=runtime.fired[index]
		if not id in ids or id in seen: return false
		seen.append(id)
		var event=runtime.events[index]
		if not event is Dictionary or event.get("id")!=id or not rules.number(event.get("revision"),0) or not rules.number(event.get("clock"),0,int(runtime.clock)): return false
	for id in runtime.fresh_backups:
		if not id in ["100","200"] or not runtime.fresh_backups[id] is bool or runtime.fresh_backups[id]!=true: return false
	return true
