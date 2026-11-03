extends RefCounted

var catalog: Dictionary=JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/english/london_quiz.json"))
var progress: Dictionary={"results":{},"attempts":[],"best":0}
var session: Dictionary={}
var revision=0
var available=Callable()
var persist=Callable()
var rng=RandomNumberGenerator.new()

func cancel():
	session={}; revision+=1

func allowed() -> bool:
	return not available.is_valid() or available.call()

func start(mode: String, count: int = 20, seed_value: int = 0) -> bool:
	if not allowed() or not mode in ["learn","practice","exam"] or not count in [5,20]: return false
	var ids=[]
	for q in catalog.questions: ids.append(q.id)
	rng.seed=seed_value if seed_value!=0 else Time.get_ticks_usec()
	if mode!="learn": shuffle(ids)
	session={"mode":mode,"queue":ids.slice(0,count),"position":0,"answers":[],"current":{},"completed":false,"help":false}
	revision+=1
	return true

func shuffle(list: Array):
	for i in range(list.size()-1,0,-1):
		var j=rng.randi_range(0,i); var tmp=list[i]; list[i]=list[j]; list[j]=tmp

func definition(id: String = "") -> Dictionary:
	if id=="":
		if session.is_empty() or session.completed: return {}
		id=session.queue[session.position]
	for q in catalog.questions:
		if q.id==id: return q
	return {}

func choices() -> Array:
	var list=definition().get("options",[]).duplicate(true)
	var saved_seed=rng.state
	rng.seed=hash(str(revision)+str(session.get("queue",[])))
	shuffle(list); rng.state=saved_seed
	return list

func answer(id: String, token: int) -> bool:
	if not allowed() or session.is_empty() or session.completed or token!=revision: return false
	var q=definition()
	if q.options.filter(func(o): return o.id==id).is_empty(): return false
	var current=session.current
	if not current.is_empty() and (current.correct or session.mode!="learn" or current.corrected): return false
	if current.is_empty():
		session.current={"id":q.id,"selected":id,"correct":id==q.answer,"corrected":false,"hints":1 if session.help else 0}
	elif id==q.answer: session.current.corrected=true
	revision+=1
	return true

func help() -> String:
	if session.is_empty() or session.completed or session.mode=="exam": return ""
	session.help=true
	if not session.current.is_empty(): session.current.hints=1
	return definition().translation

func next(token: int) -> bool:
	if not allowed() or session.is_empty() or session.completed or token!=revision or session.current.is_empty(): return false
	session.answers.append(session.current.duplicate(true)); session.current={}; session.help=false
	session.position+=1; revision+=1
	if session.position<session.queue.size(): return true
	session.completed=true
	var correct=session.answers.filter(func(a): return a.correct).size()
	session.score=roundi(100.0*correct/session.queue.size())
	var record={"mode":session.mode,"score":session.score,"answers":session.answers.duplicate(true)}
	progress.best=maxi(int(progress.best),int(session.score))
	progress.attempts.append(record)
	if progress.attempts.size()>100: progress.attempts.pop_front()
	for a in session.answers:
		var old=progress.results.get(a.id,{"best":0,"attempts":0,"practiced":false,"corrected":false})
		progress.results[a.id]={"best":maxi(int(old.best),100 if a.correct else 0),"attempts":int(old.attempts)+1,"practiced":true,"corrected":old.corrected or a.corrected}
	if persist.is_valid(): persist.call()
	return true
