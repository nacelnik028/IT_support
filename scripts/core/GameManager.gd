extends RefCounted

signal persistence_changed
signal room_changed(training_room: bool)

const Simulator = preload("res://scripts/simulation/InfrastructureSimulator.gd")
const Evaluator = preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
const Saves = preload("res://scripts/progression/SaveManager.gd")
const Terminal = preload("res://scripts/simulation/TerminalParser.gd")
const Tutorials=preload("res://scripts/training/TutorialManager.gd")
var tutorial=Tutorials.new()
var shifts=preload("res://scripts/shifts/ShiftManager.gd").new()
var session_kind="campaign"
var suspended_campaign: Dictionary={}
var education: Dictionary={"lessons":{},"attempts":[],"sessions":{},"random":{}}
const Profile=preload("res://scripts/training/KnowledgeProfile.gd")
var missions: Array = []
var actions: Array = []
const Modes = preload("res://scripts/core/GameModeManager.gd")
var game_mode = Modes.new()
var room_probe = Callable()
var programming_probe = Callable()
var english_probe = Callable()
var hub_probe = Callable()
var reconciling_room=false
var programming = preload("res://scripts/programming/AcademyManager.gd").new()
var english = preload("res://scripts/english/EnglishManager.gd").new()
var main_sim = Simulator.new()
var training_sim = Simulator.new()
var sim = main_sim
var current: Dictionary = {}
var progress: Dictionary = {"xp":0,"scores":{},"mistakes":{},"achievements":[],"last_mission":1}
var training = false
var active = false
var hints_used = 0
var finished = false
var undo_states: Array = []
var session_revision = 0
var last_save_error: Error = OK
var save_message = ""
var load_warning = ""
var unsaved = false
var introduction_active=false
var work=preload("res://scripts/progression/WorkArchive.gd").new()
var attempt_id=""
var pending_work_at=-1
var last_saved_at=0.0

func new_attempt():
	attempt_id=str(OS.get_process_id())+"-"+str(Time.get_ticks_usec())

func mark_work_dirty():
	pending_work_at=Time.get_ticks_msec()
	persistence_changed.emit()

func flush_work():
	if pending_work_at>=0 and Time.get_ticks_msec()-pending_work_at>=1000: save()

func persistence_caption() -> String:
	if unsaved: return "Neuloženo / "+save_message
	if pending_work_at>=0: return "Ukládám rozepsanou práci…"
	return "Uloženo / "+Time.get_time_string_from_unix_time(int(last_saved_at)) if last_saved_at>0 else "Dosud neuloženo"

func resume_lesson(id: int, mode: String) -> bool:
	if not training_available(): return false
	var record=work.data.lessons.get(str(id)+":"+mode,{})
	if record.is_empty() or record.content!=JSON.stringify(Saves.rules().lesson_by_id(id)).sha256_text(): return false
	if not restore_session(record.snapshot): return false
	save()
	return true


func _init():
	var owner_ref=weakref(self)
	shifts.owner_ref=owner_ref
	programming.changed=func():
		if owner_ref.get_ref()!=null: owner_ref.get_ref().mark_work_dirty()
	english.available=func():
		var owner_game=owner_ref.get_ref()
		return owner_game!=null and owner_game.game_mode.is_english() and (not owner_game.english_probe.is_valid() or owner_game.english_probe.call())
	english.persist=func(): return owner_ref.get_ref().save() if owner_ref.get_ref()!=null else ERR_UNAVAILABLE
	programming.available=func():
		var owner_game=owner_ref.get_ref()
		return owner_game!=null and owner_game.game_mode.is_programming() and (not owner_game.programming_probe.is_valid() or owner_game.programming_probe.call())
	programming.persist=func(): return owner_ref.get_ref().save() if owner_ref.get_ref()!=null else ERR_UNAVAILABLE
	programming.reward=func(amount):
		if owner_ref.get_ref()!=null: owner_ref.get_ref().progress.xp+=amount
	main_sim.reset({})
	training_sim.reset({})
	missions = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/missions/campaign.json"))
	for definition in missions: definition.id=int(definition.id)
	actions = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/actions.json"))
	var saved = Saves.load_game()
	load_warning = Saves.last_message
	if not saved.is_empty():
		shifts.data.merge(saved.get("shifts",{}),true)
		work.data.merge(saved.get("work",{}),true)
		last_saved_at=float(saved.get("saved_at",0))
		english.load_progress(saved.get("english",{}))
		programming.progress.merge(saved.get("programming",{}),true)
		progress.merge(saved.get("progress",{}),true)
		var normalized_scores={}
		for key in progress.scores:
			var canonical=str(int(float(key)))
			normalized_scores[canonical]=maxi(int(normalized_scores.get(canonical,0)),int(progress.scores[key]))
		progress.scores=normalized_scores
		education.merge(saved.get("education",{}),true)
		var normalized_lessons={}
		for key in education.lessons:
			var canonical=str(int(float(key)))
			if int(education.lessons[key].best)>=int(normalized_lessons.get(canonical,{}).get("best",-1)): normalized_lessons[canonical]=education.lessons[key]
		education.lessons=normalized_lessons
		var normalized_sessions={}
		for key in education.sessions:
			var data=education.sessions[key]
			var canonical=str(int(data.id))+":"+data.tutorial.mode
			if not normalized_sessions.has(canonical) or str(key)==canonical: normalized_sessions[canonical]=data
		education.sessions=normalized_sessions
		suspended_campaign=saved.get("suspended_campaign",{})
		# Temporary exercises never restart at application/scene entry. Old schema2
		# lesson saves are accepted, but only their permanent results are retained.
		var session = saved.get("session",{})
		if session.get("kind","campaign") != "campaign": session = suspended_campaign
		elif session.is_empty(): session = suspended_campaign
		clear_training_sessions()
		if shifts.data.selected=="shift" and not shifts.data.session.is_empty():
			suspended_campaign=session.duplicate(true)
			shifts.resume()
		else:
			if not session.is_empty(): restore_session(session)
			suspended_campaign = {}

func reconcile_room():
	if introduction_active: return
	if reconciling_room: return
	reconciling_room=true
	if english_probe.is_valid() and english_probe.call(): enter_english()
	elif programming_probe.is_valid() and programming_probe.call(): enter_programming()
	elif hub_probe.is_valid() and hub_probe.call(): enter_hub()
	elif room_probe.is_valid():
		if room_probe.call(): enter_training()
		else: leave_training()
	reconciling_room=false

func training_available() -> bool:
	if introduction_active: return false
	reconcile_room()
	return game_mode.is_training()

func main_available() -> bool:
	if introduction_active: return false
	reconcile_room()
	return game_mode.current==Modes.Mode.MAIN

func enter_hub() -> bool:
	if hub_probe.is_valid() and not hub_probe.call(): return false
	if game_mode.is_hub(): return true
	if game_mode.is_away(): leave_training()
	suspend_session()
	game_mode.switch_to(Modes.Mode.HUB)
	active=false; current={}; training=false; session_kind="campaign"; finished=false
	tutorial.cancel(); undo_states.clear(); training_sim.reset({}); sim=training_sim
	session_revision+=1
	save(); room_changed.emit(false)
	return true

func enter_programming() -> bool:
	if programming_probe.is_valid() and not programming_probe.call(): return false
	if game_mode.is_programming(): return true
	if game_mode.is_away(): leave_training()
	suspend_session()
	game_mode.switch_to(Modes.Mode.PROGRAMMING_ACADEMY)
	programming.cancel()
	active=false; current={}; finished=false; training=true; session_kind="lesson"
	tutorial.cancel(); undo_states.clear(); training_sim.reset({}); sim=training_sim
	session_revision+=1
	save(); room_changed.emit(false)
	return true

func enter_english() -> bool:
	if english_probe.is_valid() and not english_probe.call(): return false
	if game_mode.is_english(): return true
	if game_mode.is_away(): leave_training()
	suspend_session()
	game_mode.switch_to(Modes.Mode.ENGLISH_LONDON)
	english.cancel()
	active=false; current={}; finished=false; training=true; session_kind="lesson"
	tutorial.cancel(); undo_states.clear(); training_sim.reset({}); sim=training_sim
	session_revision+=1
	save(); room_changed.emit(false)
	return true

func enter_training() -> bool:
	if room_probe.is_valid() and not room_probe.call(): return false
	if game_mode.is_programming() or game_mode.is_english() or game_mode.is_hub(): leave_training()
	if game_mode.is_training(): return true
	suspend_session()
	game_mode.switch_to(Modes.Mode.TRAINING)
	training_sim.reset({})
	sim = training_sim
	active = false
	current = {}
	session_kind = "lesson"
	training = true
	finished = false
	hints_used = 0
	tutorial.cancel()
	undo_states.clear()
	session_revision += 1
	save()
	room_changed.emit(true)
	return true

func clear_training_sessions():
	education.sessions.clear()
	education.random.erase("session")
	for key in education.lessons.keys():
		if education.lessons[key].status == "Rozpracováno": education.lessons.erase(key)

func leave_training() -> bool:
	if not game_mode.is_away(): return false
	var previous_reconciling=reconciling_room
	reconciling_room=true
	cache_lesson()
	programming.cancel()
	english.cancel()
	game_mode.switch_to(Modes.Mode.MAIN)
	active = false
	current = {}
	session_kind = "campaign"
	training = false
	finished = false
	hints_used = 0
	tutorial.cancel()
	clear_training_sessions()
	undo_states.clear()
	training_sim.reset({})
	sim = main_sim
	session_revision += 1
	if shifts.data.selected=="shift" and not shifts.data.session.is_empty():
		shifts.resume()
		save(); room_changed.emit(false)
		reconciling_room=previous_reconciling
		return true
	var campaign = suspended_campaign.duplicate(true)
	suspended_campaign = {}
	if not campaign.is_empty() and not restore_session(campaign): suspended_campaign=campaign
	save()
	room_changed.emit(false)
	reconciling_room=previous_reconciling
	return true

func start_mission(index: int, practice: bool = false) -> bool:
	# Reject IDs mistaken for indices before touching any session or save.
	if index < 0 or index >= missions.size(): return false
	if not main_available(): return false
	suspend_session()
	session_kind="campaign"
	shifts.data.selected="campaign"
	suspended_campaign={}
	tutorial.lesson={}
	tutorial.session={}
	current = missions[index]
	training = practice
	active = true
	finished = false
	undo_states.clear()
	session_revision += 1
	hints_used = 0
	new_attempt()
	progress.last_mission = index+1
	sim.reset(current.initial_state)
	save()
	return true

func unlocked(index: int) -> bool:
	return index == 0 or progress.scores.has(str(index))

func set_campaign_mode(practice: bool):
	if not main_available(): return
	if session_kind!="campaign": resume_campaign()
	if training!=practice:
		training=practice
		undo_states.clear()
		session_revision += 1
	save()

func goals() -> Array:
	if not active: return []
	return Evaluator.evaluate(sim.state,current.get("objectives",[]))

func complete(expected_revision: int = -1) -> Dictionary:
	if expected_revision>=0 and expected_revision!=session_revision: return {"ok":false,"text":"Tento ticket již není aktuální."}
	if session_kind=="shift":
		if not active or not main_available(): return {"ok":false,"text":"Směna není aktivní v serverovně."}
		return shifts.complete()
	if not active or (session_kind in ["campaign","shift"] and not main_available()) or (not session_kind in ["campaign","shift"] and not training_available()):
		return {"ok":false,"text":"Úkol není aktivní v této místnosti."}
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
	var error = save()
	return {"ok":true,"score":score,"text":current.explanations,"saved":error==OK,"save_error":error}

func apply(action: String, params: Dictionary) -> Dictionary:
	if not active or (session_kind in ["campaign","shift"] and not main_available()) or (not session_kind in ["campaign","shift"] and not training_available()):
		return {"ok":false,"text":"V této místnosti není aktivní odpovídající úkol.","saved":not unsaved,"save_error":last_save_error}
	if training:
		undo_states.append(sim.state.duplicate(true))
		if undo_states.size()>20: undo_states.pop_front()
	if session_kind=="shift":
		var issue=shifts.action_error(action,params)
		if issue!="": return sim.reject(issue)
	var previous_risks=int(sim.state.risks)
	var result = sim.act(action,params)
	if result.ok and action in ["probe","verify"]:
		if not sim.state.diagnostic.has("network_checks"): sim.state.diagnostic.network_checks={}
		if action=="verify":
			for id in sim.state.vms: sim.state.diagnostic.network_checks[id]=sim.state.revision
		else: sim.state.diagnostic.network_checks[str(params.get("vm",""))]=sim.state.revision
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
	var error = save()
	result.saved = error==OK
	result.save_error = error
	return result

func execute_terminal(command: String, host: String) -> String:
	if not active or (session_kind in ["campaign","shift"] and not main_available()) or (not session_kind in ["campaign","shift"] and not training_available()):
		return "V této místnosti není aktivní odpovídající úkol."
	var execution={"applied":false}
	var dispatch=func(action: String, params: Dictionary):
		execution.applied=true
		return apply(action,params)
	var output=Terminal.execute(sim,command,host,dispatch)
	# apply() already records undo, tutorial events, errors and persistence.
	# Queries only persist their diagnostic/journal evidence, without undo.
	if not execution.applied: save()
	return output

func undo() -> bool:
	if training and not undo_states.is_empty():
		sim.state=undo_states.pop_back()
		finished=false
		session_revision += 1
		save()
		return true
	return false

func save(recover_invalid: bool = false) -> Error:
	if introduction_active: return OK
	if programming.checkpoint()!=OK:
		last_save_error=ERR_INVALID_DATA; unsaved=true; pending_work_at=-1; save_message=programming.draft_error; persistence_changed.emit(); return last_save_error
	cache_lesson()
	shifts.checkpoint()
	if active and session_kind=="random": education.random.session=snapshot()
	last_save_error = Saves.save_game({"progress":progress,"session":snapshot(),"education":education,"programming":programming.progress,"english":english.progress,"suspended_campaign":suspended_campaign,"shifts":shifts.data,"work":work.data,"saved_at":Time.get_unix_time_from_system()},recover_invalid)
	pending_work_at=-1
	unsaved = last_save_error != OK
	if not unsaved: last_saved_at=Time.get_unix_time_from_system()
	save_message = Saves.last_message
	if not unsaved: load_warning = ""
	persistence_changed.emit()
	return last_save_error

func snapshot() -> Dictionary:
	if not active or session_kind=="shift": return {}
	return {"id":current.id,"definition":current if session_kind!="campaign" else {},"state":sim.state.duplicate(true),"hints":hints_used,"training":training,"finished":finished,"kind":session_kind,"attempt_id":attempt_id,"tutorial":tutorial.dump() if session_kind=="lesson" else {}}

func restore_session(data: Dictionary) -> bool:
	# Startup has no active source; live restores always preserve it first.
	if not Saves.valid_session(data) or data.is_empty(): return false
	if data.get("kind","campaign") != "campaign":
		if not training_available(): return false
	elif not main_available(): return false
	suspend_session()
	var kind=data.get("kind","campaign")
	var index=int(data.get("id",1))-1
	var definition={}
	if kind=="lesson":
		for candidate in tutorial.lessons:
			if int(candidate.id)==int(data.id): definition=candidate.duplicate(true); break
	elif kind=="random": definition=data.definition.duplicate(true)
	else: definition=missions[index]
	current=definition
	session_kind=kind
	attempt_id=data.get("attempt_id","legacy-"+kind+"-"+str(data.id))
	undo_states.clear()
	session_revision += 1
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
	tutorial.last_feedback=""
	return true

func suspend_session():
	if not active: return
	match session_kind:
		"shift": shifts.checkpoint()
		"campaign": suspended_campaign=snapshot()
		"lesson": cache_lesson()
		"random": education.random.session=snapshot()

func resume_random() -> bool:
	if not training_available(): return false
	var data=education.random.get("session",{}).duplicate(true)
	if data.is_empty() or not Saves.valid_session(data): return false
	suspend_session()
	restore_session(data)
	save()
	return true

func restart_current() -> bool:
	if not active: return false
	match session_kind:
		"shift": return shifts.start(shifts.data.session.id)
		"campaign": return start_mission(int(current.id)-1,training)
		"lesson": return start_lesson(int(current.id),tutorial.session.mode,false)
		"random": return load_random_task()
	return false

func cache_lesson():
	if active and session_kind=="lesson" and tutorial.active():
		education.sessions[str(current.id)+":"+str(tutorial.session.mode)]=snapshot()
		var key=str(current.id)+":"+str(tutorial.session.mode)
		if finished: work.data.lessons.erase(key)
		else: work.data.lessons[key]={"content":JSON.stringify(Saves.rules().lesson_by_id(int(current.id))).sha256_text(),"snapshot":snapshot()}
		if not education.lessons.has(str(current.id)): education.lessons[str(current.id)]={"status":"Rozpracováno","best":0}

func start_lesson(id: int,mode: String,resume: bool=true) -> bool:
	if not mode in ["learn","practice","exam"]: return false
	var definition={}
	for l in tutorial.lessons:
		if int(l.id)==id: definition=l; break
	if definition.is_empty(): return false
	if not training_available(): return false
	suspend_session()
	var cached=education.sessions.get(str(id)+":"+mode,education.sessions.get(str(id),{}))
	if resume and not cached.is_empty() and not cached.get("finished",false) and cached.get("tutorial",{}).get("mode","")==mode:
		restore_session(cached)
	else:
		var player_pose = sim.state.world.player.duplicate(true)
		session_kind="lesson"
		current=definition.duplicate(true)
		training=mode!="exam"
		active=true
		finished=false
		hints_used=0
		undo_states.clear()
		session_revision += 1
		sim.reset(current.initial_state)
		sim.state.world.player = player_pose
		new_attempt()
		tutorial.start(definition,mode)
		education.lessons[str(id)]=education.lessons.get(str(id),{"status":"Rozpracováno","best":0})
	save()
	return true

func resume_campaign():
	shifts.data.selected="campaign"
	if game_mode.is_away():
		if hub_probe.is_valid() and hub_probe.call(): return
		if english_probe.is_valid() and english_probe.call(): return
		if programming_probe.is_valid() and programming_probe.call(): return
		if room_probe.is_valid() and room_probe.call(): return
		leave_training()
	# Returning while already in the campaign must never restart it.
	if active and session_kind=="campaign": return
	suspend_session()
	if not suspended_campaign.is_empty():
		var data=suspended_campaign.duplicate(true)
		suspended_campaign={}
		restore_session(data)
	else: start_mission(clampi(int(progress.last_mission)-1,0,missions.size()-1),false)
	save()

func notify_event(event: Dictionary) -> bool:
	if not active or session_kind!="lesson" or not training_available(): return false
	if event.get("type","")=="node_selected": sim.state.diagnostic.viewed=true
	var advanced=tutorial.observe(sim.state,event)
	save()
	return advanced

func lesson_hint() -> String:
	if not active or session_kind!="lesson" or not training_available(): return ""
	var text=tutorial.hint()
	hints_used=int(tutorial.session.get("hints",0))
	save()
	return text

func start_random(area: String,difficulty: String,count: int,hints_allowed: bool,seed_value: int=0) -> bool:
	if not training_available(): return false
	var generator=preload("res://scripts/training/PracticeGenerator.gd").new()
	var queue=generator.generate(area,difficulty,count,seed_value)
	if queue.size()!=clampi(count,1,20): return false
	suspend_session()
	education.random={"queue":queue,"position":0,"hints_allowed":hints_allowed,"results":[],"area":area,"difficulty":difficulty}
	load_random_task()
	return true

func load_random_task() -> bool:
	if not training_available(): return false
	var batch=education.random
	if not batch.get("queue") is Array or not Saves.Validator.integer(batch.get("position"),0): return false
	if batch.position < 0 or batch.position >= batch.queue.size(): return false
	session_kind="random"
	new_attempt()
	tutorial.lesson={}
	tutorial.session={}
	current=education.random.queue[int(education.random.position)].duplicate(true)
	current.id=int(current.id)
	training=true
	active=true
	finished=false
	hints_used=0
	undo_states.clear()
	session_revision += 1
	var player_pose = sim.state.world.player.duplicate(true)
	sim.reset(current.initial_state)
	sim.state.world.player = player_pose
	save()
	return true

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
