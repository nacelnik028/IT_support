extends RefCounted

var owner_ref
const Scoring=preload("res://scripts/evaluation/ScoreRules.gd")
var catalog=JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/shifts/catalog.json"))
var data={"selected":"campaign","session":{},"history":[],"best":{}}

func definition(id: String) -> Dictionary:
	for item in catalog:
		if item.id==id: return item
	return {}

func checkpoint():
	var game=owner_ref.get_ref()
	if game.active and game.session_kind=="shift":
		data.session.state=game.sim.state.duplicate(true)
		data.session.hints=game.hints_used

func start(id: String) -> bool:
	var game=owner_ref.get_ref()
	var d=definition(id)
	if d.is_empty() or not game.main_available(): return false
	game.suspend_session()
	game.new_attempt()
	data.selected="shift"
	data.session={"id":id,"version":d.version,"index":0,"finished":false,"results":[],"state":{},"attempt_id":game.attempt_id,"score_version":2,"hints":0,"error_base":0,"risk_base":0}
	game.sim=game.main_sim
	game.sim.reset(d.initial_state)
	game.sim.state.world.player={"x":7.0,"z":3.5,"yaw":0.0,"pitch":0.0}
	# Baseline carries an old backup for safe hardware service. New backup tasks
	# require a fresh point, never that pre-existing maintenance copy.
	if id!="SHIFT-DISK": game.sim.state.backup.records={}; game.sim.state.backup.completed=false; game.sim.state.backup.verified=false
	activate()
	game.save()
	return true

func activate():
	var game=owner_ref.get_ref()
	var d=definition(data.session.id)
	var ticket=d.tickets[int(data.session.index)]
	game.current={"id":30000+catalog.find(d)*3+int(data.session.index),"title":d.title+" / "+ticket.title,"category":d.category,"server":d.server,"topic":"směna","priority":"Souvislá směna","description":ticket.description,"symptoms":ticket.description,"objectives":ticket.objectives,"available_actions":ticket.available_actions,"initial_state":d.initial_state,"hints":[ticket.description,ticket.description,ticket.description],"explanations":"Směna zachovala infrastrukturu mezi všemi tickety. Zkontroluj níže skutečné podmínky a deník.","tags":[d.category]}
	game.attempt_id=data.session.get("attempt_id","legacy-shift-"+data.session.id)
	game.session_kind="shift"; game.active=true; game.training=true
	game.finished=data.session.finished; game.hints_used=int(data.session.get("hints",0))
	game.tutorial.cancel(); game.undo_states.clear(); game.session_revision+=1

func resume() -> bool:
	var game=owner_ref.get_ref()
	if data.session.is_empty() or not game.main_available(): return false
	if game.active and game.session_kind=="shift": return true
	game.suspend_session()
	data.selected="shift"
	game.sim=game.main_sim
	game.sim.reset(definition(data.session.id).initial_state)
	game.Simulator.merge(game.sim.state,data.session.state)
	game.sim.refresh_incidents()
	activate(); game.save()
	return true

func complete() -> Dictionary:
	var game=owner_ref.get_ref()
	if data.session.is_empty() or data.session.finished: return {"ok":false,"text":"Směna již skončila."}
	for goal in game.goals():
		if not goal.passed: return {"ok":false,"text":"Předání odmítnuto: "+goal.label+". Stav lze opravit; při ztrátě dat použij restart směny."}
	var version=int(data.session.get("score_version",1))
	var errors=maxi(0,int(game.sim.state.errors)-int(data.session.get("error_base",0))) if version>=2 else int(game.sim.state.errors)
	var risks=maxi(0,int(game.sim.state.risks)-int(data.session.get("risk_base",0))) if version>=2 else int(game.sim.state.risks)
	var breakdown=Scoring.calculate(game.hints_used,errors,risks,version)
	var score=int(breakdown.score)
	var gained=0
	data.session.results.append({"ticket":int(data.session.index),"score":score,"breakdown":breakdown,"time":int(Time.get_unix_time_from_system())})
	var d=definition(data.session.id)
	if int(data.session.index)<d.tickets.size()-1:
		data.session.index+=1
		data.session.hints=0
		if version>=2:
			data.session.error_base=int(game.sim.state.errors); data.session.risk_base=int(game.sim.state.risks)
		# Only verification evidence expires; infrastructure, inventory and all
		# previous repairs remain. No new baseline or hidden incident is loaded.
		game.sim.state.verified.clear()
		activate()
	else:
		data.session.finished=true; game.finished=true
		var average=0
		for record in data.session.results: average+=int(record.score)
		average=roundi(float(average)/d.tickets.size())
		var old=int(data.best.get(d.id,0))
		gained=maxi(average-old,0)*3
		game.progress.xp+=gained
		data.best[d.id]=maxi(old,average)
		data.history.append({"id":d.id,"version":d.version,"score":average,"score_version":version,"xp":gained,"results":data.session.results.duplicate(true)})
		if data.history.size()>50: data.history.pop_front()
	var error=game.save()
	return {"ok":true,"score":score,"xp":gained,"breakdown":breakdown,"text":("Směna dokončena. Výsledky jsou v přehledu směn." if data.session.finished else "Ticket předán. Pokračuj navazujícím ticketem nad stejným stavem.")+"\n\n"+Scoring.describe(breakdown,gained),"saved":error==OK,"save_error":error}

func action_error(action: String, params: Dictionary) -> String:
	if action!="backup": return ""
	var game=owner_ref.get_ref()
	if not game.sim.Network.probe(game.sim.state,str(params.get("vm",""))).app:
		return "Záloha v této směně vyžaduje dostupnou službu včetně platné fyzické sítě, VLAN, IP a DNS. Oprav a ověř ji."
	return ""
