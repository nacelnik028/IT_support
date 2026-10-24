extends RefCounted

const Simulator = preload("res://scripts/simulation/InfrastructureSimulator.gd")
const Evaluator = preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
const Saves = preload("res://scripts/progression/SaveManager.gd")
var missions: Array = []
var actions: Array = []
var sim = Simulator.new()
var current: Dictionary = {}
var progress: Dictionary = {"xp":0,"scores":{},"mistakes":{},"achievements":[],"last_mission":1}
var training = false
var active = false
var hints_used = 0
var finished = false

func _init():
	missions = JSON.parse_string(FileAccess.get_file_as_string("res://data/missions/campaign.json"))
	actions = JSON.parse_string(FileAccess.get_file_as_string("res://data/actions.json"))
	var saved = Saves.load_game()
	if not saved.is_empty():
		progress.merge(saved.get("progress",{}),true)
		if saved.has("session") and not saved.session.is_empty():
			var session = saved.session
			var index = int(session.get("id",1))-1
			if index >= 0 and index < missions.size():
				current = missions[index]
				sim.state = session.state
				training = session.get("training",false)
				hints_used = int(session.get("hints",0))
				finished = session.get("finished",false)
				active = true

func start_mission(index: int, practice: bool = false):
	current = missions[index]
	training = practice
	active = true
	finished = false
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
	var score = clampi(100 - hints_used * 4 - int(sim.state.errors) * 8 - int(sim.state.risks) * 15,0,100)
	if not sim.state.get("diagnostic",{}).get("viewed",false): score = mini(score,75)
	finished = true
	if not training:
		var key = str(current.id)
		var old = int(progress.scores.get(key,0))
		progress.xp += maxi(score-old,0) * 3
		progress.scores[key] = maxi(old,score)
		if score >= 90 and not "Bezpečné ruce" in progress.achievements: progress.achievements.append("Bezpečné ruce")
		if progress.scores.size() >= 8 and not "První směna" in progress.achievements: progress.achievements.append("První směna")
		if progress.scores.size() >= 24 and not "Správce infrastruktury" in progress.achievements: progress.achievements.append("Správce infrastruktury")
	save()
	return {"ok":true,"score":score,"text":current.explanations}

func apply(action: String, params: Dictionary) -> Dictionary:
	var result = sim.act(action,params)
	if not result.ok:
		var topic = current.get("topic","diagnostika")
		progress.mistakes[topic] = int(progress.mistakes.get(topic,0)) + 1
	save()
	return result

func save():
	var session = {}
	if active: session = {"id":current.id,"state":sim.state,"hints":hints_used,"training":training,"finished":finished}
	return Saves.save_game({"progress":progress,"session":session})
