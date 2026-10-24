extends RefCounted

const Simulator = preload("res://scripts/simulation/InfrastructureSimulator.gd")
const Evaluator = preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
const Saves = preload("res://scripts/progression/SaveManager.gd")
const Tutorials=preload("res://scripts/training/TutorialManager.gd")
var tutorial=Tutorials.new()
var session_kind="campaign"
var suspended_campaign: Dictionary={}
var education: Dictionary={"lessons":{},"attempts":[],"sessions":{},"random":{}}
const Profile=preload("res://scripts/training/KnowledgeProfile.gd")
var missions: Array = []
var actions: Array = []
var sim = Simulator.new()
var current: Dictionary = {}
var progress: Dictionary = {"xp":0,"scores":{},"mistakes":{},"achievements":[],"last_mission":1}
var training = false
var active = false
var hints_used = 0
var finished = false
var undo_states: Array = []

func _init():
	missions = JSON.parse_string(FileAccess.get_file_as_string("res://data/missions/campaign.json"))
	for definition in missions: definition.id=int(definition.id)
	actions = JSON.parse_string(FileAccess.get_file_as_string("res://data/actions.json"))
	var saved = Saves.load_game()
	if not saved.is_empty():
		progress.merge(saved.get("progress",{}),true)
		var normalized_scores={}
		for key in progress.scores:
			var canonical=str(int(float(key)))
			normalized_scores[canonical]=maxi(int(normalized_scores.get(canonical,0)),int(progress.scores[key]))
		progress.scores=normalized_scores
		education.merge(saved.get("education",{}),true)
		suspended_campaign=saved.get("suspended_campaign",{})
		if saved.has("session") and not saved.session.is_empty():
			restore_session(saved.session)

func start_mission(index: int, practice: bool = false):
	cache_lesson()
	session_kind="campaign"
	suspended_campaign={}
	tutorial.lesson={}
	tutorial.session={}
	current = missions[index]
	training = practice
	active = true
	finished = false
	undo_states.clear()
	hints_used = 0
	progress.last_mission = index+1
	sim.reset(current.initial_state)
	save()

func unlocked(index: int) -> bool:
	return index == 0 or progress.scores.has(str(index))

func goals() -> Array:
	return Evaluator.evaluate(sim.state,current.get("objectives",[]))

func complete() -> Dictionary:
	for goal in goals():
		if not goal.passed: return {"ok":false,"text":"Požadovaný stav není splněn: " + goal.label}
	if finished: return {"ok":false,"text":"Ticket je již uzavřený. Misi lze zopakovat."}
	if session_kind=="lesson" and tutorial.guided() and int(tutorial.session.step)<tutorial.lesson.steps.size(): return {"ok":false,"text":"Nejprve dokonči ověřované kroky vedené lekce."}
	var score = clampi(100 - hints_used * 4 - int(sim.state.errors) * 8 - int(sim.state.risks) * 15,0,100)
	if session_kind=="lesson": score=mini(score,clampi(100-hints_used*4-tutorial.session.mistakes.size()*8,0,100))
	if not sim.state.get("diagnostic",{}).get("viewed",false): score = mini(score,75)
	finished = true
	if session_kind=="lesson":
		tutorial.session.complete=true
		var mastered=tutorial.session.mode!="learn" and hints_used==0 and sim.state.errors==0 and tutorial.session.mistakes.is_empty() and score>=90
		var old_lesson=education.lessons.get(str(current.id),{})
		education.lessons[str(current.id)]={"status":"Zvládnuto bez nápovědy" if mastered or old_lesson.get("status","")=="Zvládnuto bez nápovědy" else "Dokončeno","best":maxi(score,int(old_lesson.get("best",0))),"mode":tutorial.session.mode}
		cache_lesson()
	if not training and session_kind=="campaign":
		var key = str(current.id)
		var old = int(progress.scores.get(key,0))
		progress.xp += maxi(score-old,0) * 3
		progress.scores[key] = maxi(old,score)
		if score >= 90 and not "Bezpečné ruce" in progress.achievements: progress.achievements.append("Bezpečné ruce")
		if progress.scores.size() >= 8 and not "První směna" in progress.achievements: progress.achievements.append("První směna")
		if progress.scores.size() >= 24 and not "Správce infrastruktury" in progress.achievements: progress.achievements.append("Správce infrastruktury")
	var attempt={"id":current.id,"title":current.title,"kind":session_kind,"mode":tutorial.session.get("mode","practice" if training else "campaign"),"score":score,"hints":hints_used,"errors":int(sim.state.errors),"risks":int(sim.state.risks),"tags":current.get("tags",[current.category]),"time":Time.get_unix_time_from_system(),"mistakes":tutorial.session.get("mistakes",[]).duplicate(true),"journal":sim.state.journal.duplicate()}
	education.attempts.append(attempt)
	if session_kind=="random": education.random.results.append(attempt)
	if education.attempts.size()>200: education.attempts.pop_front()
	save()
	return {"ok":true,"score":score,"text":current.explanations}

func apply(action: String, params: Dictionary) -> Dictionary:
	if training:
		undo_states.append(sim.state.duplicate(true))
		if undo_states.size()>20: undo_states.pop_front()
	var previous_risks=int(sim.state.risks)
	var result = sim.act(action,params)
	if not result.ok:
		var topic = current.get("topic","diagnostika")
		progress.mistakes[topic] = int(progress.mistakes.get(topic,0)) + 1
	if session_kind=="lesson":
		if not result.ok:
			var risk="Riziková změna" if int(sim.state.risks)>previous_risks else "Nesprávný, ale bezpečný krok"
			for descriptor in actions:
				if descriptor.id==action and descriptor.get("danger",false): risk="Destruktivní operace"; break
			tutorial.session.mistakes.append({"action":action,"kind":risk,"text":result.text})
			tutorial.last_feedback=risk+": "+result.text
		else:
			var before=int(tutorial.session.step)
			tutorial.observe(sim.state,{"type":"action_applied","action":action})
			var step=tutorial.current_step()
			if before==int(tutorial.session.step) and step.get("event",{}).get("action","")==action and not step.get("checks",[]).is_empty():
				tutorial.last_feedback=step.get("error","Konfigurace je bezpečná, ale ještě neodpovídá cíli. "+step.get("text",""))
				tutorial.session.mistakes.append({"action":action,"kind":"Nesprávný, ale bezpečný krok","text":tutorial.last_feedback})
			if action=="switch" and params.get("type","") in ["Private","Internal"]:
				for goal in current.objectives:
					if goal.path=="network.switches."+params.name+".type" and goal.value=="External":
						tutorial.last_feedback="Nesprávný, ale bezpečný krok: %s switch %s. Tento úkol potřebuje External switch nad správnou fyzickou NIC." % [params.type,"propojí jen VM na tomto hostiteli" if params.type=="Private" else "propojí VM s hostitelem, ale nemá automaticky LAN ani NAT"]
						if tutorial.session.mistakes.is_empty() or tutorial.session.mistakes.back().text!=tutorial.last_feedback: tutorial.session.mistakes.append({"action":action,"kind":"Nesprávný, ale bezpečný krok","text":tutorial.last_feedback})
	save()
	return result

func undo():
	if training and not undo_states.is_empty():
		sim.state=undo_states.pop_back()
		finished=false
		save()

func save():
	cache_lesson()
	if active and session_kind=="random": education.random.session=snapshot()
	return Saves.save_game({"progress":progress,"session":snapshot(),"education":education,"suspended_campaign":suspended_campaign})

func snapshot() -> Dictionary:
	if not active: return {}
	return {"id":current.id,"definition":current if session_kind!="campaign" else {},"state":sim.state.duplicate(true),"hints":hints_used,"training":training,"finished":finished,"kind":session_kind,"tutorial":tutorial.dump() if session_kind=="lesson" else {}}

func restore_session(data: Dictionary):
	session_kind=data.get("kind","campaign")
	var index=int(data.get("id",1))-1
	if session_kind!="campaign" and not data.get("definition",{}).is_empty(): current=data.definition
	elif index>=0 and index<missions.size(): current=missions[index]
	else: return
	current.id=int(current.id)
	sim.reset(current.initial_state)
	if data.get("state") is Dictionary: Simulator.merge(sim.state,data.state)
	sim.refresh_incidents()
	training=data.get("training",false)
	hints_used=int(data.get("hints",0))
	finished=data.get("finished",false)
	active=true
	if session_kind=="lesson": tutorial.restore(data.get("tutorial",{}))
	else: tutorial.lesson={}; tutorial.session={}

func cache_lesson():
	if active and session_kind=="lesson" and tutorial.active():
		education.sessions[str(current.id)+":"+str(tutorial.session.mode)]=snapshot()
		if not education.lessons.has(str(current.id)): education.lessons[str(current.id)]={"status":"Rozpracováno","best":0}

func start_lesson(id: int,mode: String,resume: bool=true) -> bool:
	if not mode in ["learn","practice","exam"]: return false
	var definition={}
	for l in tutorial.lessons:
		if int(l.id)==id: definition=l; break
	if definition.is_empty(): return false
	if session_kind=="campaign" and active: suspended_campaign=snapshot()
	cache_lesson()
	var cached=education.sessions.get(str(id)+":"+mode,education.sessions.get(str(id),{}))
	if resume and not cached.is_empty() and not cached.get("finished",false) and cached.get("tutorial",{}).get("mode","")==mode:
		restore_session(cached)
	else:
		session_kind="lesson"
		current=definition.duplicate(true)
		training=mode!="exam"
		active=true
		finished=false
		hints_used=0
		undo_states.clear()
		sim.reset(current.initial_state)
		tutorial.start(definition,mode)
		education.lessons[str(id)]=education.lessons.get(str(id),{"status":"Rozpracováno","best":0})
	save()
	return true

func resume_campaign():
	cache_lesson()
	if not suspended_campaign.is_empty():
		var data=suspended_campaign.duplicate(true)
		suspended_campaign={}
		restore_session(data)
	else: start_mission(clampi(int(progress.last_mission)-1,0,missions.size()-1),false)
	save()

func notify_event(event: Dictionary) -> bool:
	if session_kind!="lesson": return false
	if event.get("type","")=="node_selected": sim.state.diagnostic.viewed=true
	var advanced=tutorial.observe(sim.state,event)
	save()
	return advanced

func lesson_hint() -> String:
	var text=tutorial.hint()
	hints_used=int(tutorial.session.get("hints",0))
	save()
	return text

func start_random(area: String,difficulty: String,count: int,hints_allowed: bool,seed_value: int=0) -> bool:
	var generator=preload("res://scripts/training/PracticeGenerator.gd").new()
	var queue=generator.generate(area,difficulty,count,seed_value)
	if queue.size()!=clampi(count,1,20): return false
	if session_kind=="campaign" and active: suspended_campaign=snapshot()
	cache_lesson()
	education.random={"queue":queue,"position":0,"hints_allowed":hints_allowed,"results":[],"area":area,"difficulty":difficulty}
	load_random_task()
	return true

func load_random_task():
	session_kind="random"
	tutorial.lesson={}
	tutorial.session={}
	current=education.random.queue[int(education.random.position)].duplicate(true)
	current.id=int(current.id)
	training=true
	active=true
	finished=false
	hints_used=0
	undo_states.clear()
	sim.reset(current.initial_state)
	save()

func next_random() -> bool:
	if session_kind!="random" or not finished: return false
	if int(education.random.position)+1>=education.random.queue.size(): return false
	education.random.position+=1
	load_random_task()
	return true

func assessment() -> String:
	var lines=["Zvládnuto:"]
	for goal in goals():
		if goal.passed: lines.append("✓ "+goal.label)
	lines.append("\nChyby a rizika:")
	var errors=tutorial.session.get("mistakes",[])
	if errors.is_empty():
		for line in sim.state.journal:
			if line.begins_with("ODMÍTNUTO"): lines.append(line)
		if sim.state.errors==0: lines.append("Bez odmítnutých nebo rizikových zásahů.")
	else:
		for mistake in errors: lines.append(mistake.kind+": "+mistake.text)
	lines.append("\nDoporučené lekce:")
	for lesson in Profile.recommendations(self,current.get("tags",[current.category])): lines.append(lesson.title)
	return "\n".join(lines)
