extends RefCounted

const Validator=preload("res://scripts/training/TutorialValidator.gd")
var lessons: Array=[]
var lesson: Dictionary={}
var session: Dictionary={}
var last_feedback=""

func _init():
	if FileAccess.file_exists("res://data/training/lessons.json"):
		lessons=JSON.parse_string(FileAccess.get_file_as_string("res://data/training/lessons.json"))
		for definition in lessons: definition.id=int(definition.id)

func start(definition: Dictionary,mode: String):
	lesson=definition
	session={"lesson_id":lesson.id,"mode":mode,"step":0,"hints":0,"mistakes":[],"complete":false,"page":"Serverovna","tab":"","host":lesson.server}
	last_feedback=""

func active() -> bool:
	return not lesson.is_empty() and not session.is_empty()

func guided() -> bool:
	return active() and session.mode=="learn" and not session.complete

func current_step() -> Dictionary:
	if not active() or int(session.step)>=lesson.steps.size(): return {}
	return lesson.steps[int(session.step)]

func observe(state: Dictionary,event: Dictionary) -> bool:
	if not guided(): return false
	var step=current_step()
	if Validator.accepts(step,state,event):
		session.step+=1
		last_feedback=""
		return true
	return false

func hint() -> String:
	if not active(): return ""
	if session.mode=="exam": return "Ve zkoušce není přímá nápověda dostupná."
	session.hints+=1
	if session.mode=="learn": return current_step().get("hint",current_step().get("text",""))
	return lesson.hints[mini(int(session.hints)-1,lesson.hints.size()-1)]

func target(state: Dictionary) -> String:
	var step=current_step()
	for alternative in step.get("targets",[]):
		if not Validator.accepts({"checks":alternative.checks},state,{}): return alternative.target
	return step.get("target","")

func dump() -> Dictionary:
	return session.duplicate(true)

func restore(data: Dictionary):
	session=data.duplicate(true)
	lesson={}
	for candidate in lessons:
		if candidate.id==session.get("lesson_id",-1): lesson=candidate; break
	if lesson.is_empty(): session={}
	else: session.step=clampi(int(session.get("step",0)),0,lesson.steps.size())
