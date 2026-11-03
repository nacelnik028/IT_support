extends RefCounted

var catalog=JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/english/listening.json"))
var progress={"content_version":1,"results":{},"attempts":[],"pending":{}}
var session={}
var revision=0
var available=Callable()
var persist=Callable()

func allowed() -> bool: return not available.is_valid() or available.call()

func definition(id: String = "") -> Dictionary:
	if id=="": id=session.get("id","")
	for task in catalog.tasks:
		if task.id==id: return task
	return {}

func checkpoint():
	if session.is_empty(): return
	progress.pending={} if session.completed else session.duplicate(true)

func store():
	checkpoint()
	if persist.is_valid(): persist.call()

func cancel():
	checkpoint(); session={}; revision+=1

func start(id: String, mode: String, seed_value: int = 0) -> bool:
	var task=definition(id)
	if not allowed() or task.is_empty() or not mode in ["learn","practice","exam"]: return false
	var order=task.options.map(func(option): return option.id)
	var rng=RandomNumberGenerator.new(); rng.seed=seed_value if seed_value!=0 else Time.get_ticks_usec()
	for i in range(order.size()-1,0,-1):
		var j=rng.randi_range(0,i); var previous=order[i]; order[i]=order[j]; order[j]=previous
	session={"version":1,"id":id,"mode":mode,"order":order,"transcript_allowed":mode!="exam","transcript":false,"heard":false,"plays":0,"slow":false,"muted":false,"completed":false,"answer":"","auto_played":false}
	revision+=1; store(); return true

func resume() -> bool:
	if not allowed() or not valid_session(progress.pending): return false
	session=progress.pending.duplicate(true); revision+=1; return true

func choices() -> Array:
	var result=[]
	for id in session.get("order",[]):
		for option in definition().options:
			if option.id==id: result.append(option)
	return result

func transcript(token: int) -> bool:
	if not allowed() or session.is_empty() or session.completed or token!=revision or not session.transcript_allowed: return false
	session.transcript=true; revision+=1; store(); return true

func played(token: int, slow: bool, muted: bool) -> bool:
	if not allowed() or session.is_empty() or session.completed or token!=revision: return false
	session.plays+=1; session.slow=session.slow or slow; session.muted=session.muted or muted
	store(); return true

func completed_clip(token: int):
	if not allowed() or session.is_empty() or session.completed or token!=revision or session.plays<1: return
	session.heard=true; store()

func answer(id: String, token: int) -> bool:
	if not allowed() or session.is_empty() or session.completed or token!=revision or not id in session.order: return false
	var task=definition()
	for bus in ["Master","Speech"]:
		var index=AudioServer.get_bus_index(bus)
		if index>=0 and (AudioServer.is_bus_mute(index) or AudioServer.get_bus_volume_db(index)<=-75): session.muted=true
	var aids={"transcript":session.transcript,"muted":session.muted,"slow":session.slow,"no_audio":not session.heard}
	var assisted=aids.values().any(func(value): return value)
	var correct=id==task.answer
	var record={"id":task.id,"mode":session.mode,"selected":id,"correct":correct,"score":100 if correct else 0,"aids":aids,"assisted":assisted,"plays":session.plays,"time":int(Time.get_unix_time_from_system())}
	var previous=progress.results.get(task.id,{"best":0,"attempts":0,"unassisted":false,"helped":false})
	progress.results[task.id]={"best":maxi(int(previous.best),int(record.score)),"attempts":int(previous.attempts)+1,"unassisted":previous.unassisted or (correct and not assisted),"helped":previous.helped or (correct and assisted)}
	progress.attempts.append(record)
	if progress.attempts.size()>100: progress.attempts.pop_front()
	session.answer=id; session.completed=true; revision+=1; store(); return true

func valid_session(data) -> bool:
	if not data is Dictionary or data.is_empty(): return false
	if data.get("version")!=1 or not data.get("id") is String or not data.get("mode") in ["learn","practice","exam"]: return false
	var task=definition(data.id)
	if task.is_empty() or not data.get("order") is Array or data.order.size()!=task.options.size(): return false
	var seen=[]
	for id in data.order:
		if not id is String or id in seen or not task.options.any(func(option): return option.id==id): return false
		seen.append(id)
	for flag in ["transcript_allowed","transcript","heard","slow","muted","completed","auto_played"]:
		if not data.get(flag) is bool: return false
	if data.transcript_allowed!=(data.mode!="exam") or (data.mode=="exam" and data.transcript): return false
	if not preload("res://scripts/programming/CodeDrafts.gd").number(data.get("plays"),0,1000000) or (data.heard and data.plays<1): return false
	return data.get("answer")=="" and not data.completed

func valid_progress(data) -> bool:
	if not data is Dictionary: return false
	if data.is_empty(): return true
	if data.get("content_version")!=1 or not data.get("results") is Dictionary or not data.get("attempts") is Array or not data.get("pending") is Dictionary: return false
	if data.results.size()>catalog.tasks.size() or data.attempts.size()>100 or (not data.pending.is_empty() and not valid_session(data.pending)): return false
	var numbers=preload("res://scripts/programming/CodeDrafts.gd")
	for id in data.results:
		var record=data.results[id]
		if definition(id).is_empty() or not record is Dictionary or not numbers.number(record.get("best"),0,100) or not numbers.number(record.get("attempts"),1): return false
		if not record.get("unassisted") is bool or not record.get("helped") is bool: return false
	for record in data.attempts:
		if not record is Dictionary or not record.get("id") is String or not record.get("selected") is String or not record.get("mode") in ["learn","practice","exam"]: return false
		var task=definition(record.id)
		if task.is_empty() or not task.options.any(func(option): return option.id==record.selected): return false
		if not record.get("correct") is bool or record.correct!=(record.selected==task.answer) or record.get("score")!=(100 if record.correct else 0): return false
		if not record.get("aids") is Dictionary or record.aids.size()!=4: return false
		for flag in ["transcript","muted","slow","no_audio"]:
			if not record.aids.get(flag) is bool: return false
		if not record.get("assisted") is bool or record.assisted!=record.aids.values().any(func(value): return value): return false
		if record.mode=="exam" and record.aids.transcript: return false
		if not numbers.number(record.get("plays"),0,1000000) or (not record.aids.no_audio and record.plays<1) or not numbers.number(record.get("time"),0): return false
	return true
