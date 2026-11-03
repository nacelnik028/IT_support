extends RefCounted

const NAMES=["Proxmox","Hyper-V","RAID","Sítě","Zálohy","Diagnostika","Python","HTML","CSS","JavaScript","Anglické situace","London Quiz","Anglický poslech"]
const STATUS=["Nezkoušeno","Procvičeno","Dokončeno s pomocí","Doloženo bez pomoci"]

static func add(rows: Dictionary, skill: String, score: int, source: String, id: String, mode: String, help: String, known: bool, passed: bool, errors: int, time: int, independent: bool):
	if not rows.has(skill): return
	var row=rows[skill]
	var rank=3 if independent else 2 if passed and known and help!="bez pomoci" else 1
	row.rank=maxi(int(row.rank),rank); row.count+=1
	var meta={"source":source,"id":id,"mode":mode,"help":help,"known":known,"score":score,"time":time,"failed":not passed or errors>0,"passed":passed}
	if score>int(row.best): row.best=score; row.best_source=meta
	if row.latest.is_empty() or time>=int(row.latest.time): row.latest=meta

static func programming_skills(task: Dictionary) -> Array:
	var category=task.get("category","")
	if category=="python": return ["Python"]
	if category=="css": return ["CSS"]
	if category=="javascript": return ["JavaScript"]
	var result=["HTML"]
	var kinds=task.get("tests",[]).map(func(test): return test.get("kind",""))
	if "css" in kinds: result.append("CSS")
	if "click" in kinds: result.append("JavaScript")
	return result

static func program_task(game, id: String) -> Dictionary:
	for task in game.programming.catalog.missions+game.programming.catalog.debugging:
		if task.id==id: return task
	return {}

static func summarize(game) -> Array:
	var rows={}
	for name in NAMES: rows[name]={"skill":name,"rank":0,"count":0,"best":-1,"latest":{},"best_source":{}}
	var attempted=[]
	for attempt in game.education.attempts:
		attempted.append(str(int(attempt.id)))
		var support=int(attempt.hints)>0 or attempt.mode=="learn"
		var tags=attempt.tags.duplicate()
		if attempt.kind=="campaign" and int(attempt.id)>=1 and int(attempt.id)<=game.missions.size():
			for domain in preload("res://scripts/training/PracticeGenerator.gd").domains(game.missions[int(attempt.id)-1]):
				if not domain in tags: tags.append(domain)
		for raw in tags:
			var skill="RAID" if raw=="Storage" else raw
			add(rows,skill,int(attempt.score),"IT / "+attempt.kind,str(int(attempt.id)),attempt.mode,"nápovědy %d%s" % [int(attempt.hints)," / vedená výuka" if attempt.mode=="learn" else ""] if support else "bez pomoci",true,true,int(attempt.errors)+int(attempt.risks),int(attempt.get("time",0)),not support and int(attempt.errors)==0 and int(attempt.risks)==0 and int(attempt.score)>=90)
	for mission in game.missions:
		var id=str(int(mission.id))
		if id in attempted or not game.progress.scores.has(id): continue
		for skill in preload("res://scripts/training/PracticeGenerator.gd").domains(mission): add(rows,skill,int(game.progress.scores[id]),"Historická kampaň",id,"nezaznamenán","nezaznamenaná pomoc",false,true,0,0,false)
	for id in game.education.lessons:
		if str(id) in attempted: continue
		var definition=game.Saves.rules().lesson_by_id(int(id))
		var result=game.education.lessons[id]
		if not result.status in ["Dokončeno","Zvládnuto bez nápovědy"]: continue
		for raw in definition.get("tags",[definition.module]):
			add(rows,"RAID" if raw=="Storage" else raw,int(result.best),"Historická IT lekce",str(id),result.get("mode","nezaznamenán"),"historické zvládnutí bez nápovědy" if result.status=="Zvládnuto bez nápovědy" else "nezaznamenaná pomoc",result.status=="Zvládnuto bez nápovědy",true,0,0,result.status=="Zvládnuto bez nápovědy")
	for history in game.shifts.data.history:
		var definition=game.shifts.definition(history.id)
		var skills=[]; var known=true; var hints=0; var errors=0; var time=0
		for result in history.results:
			if not result.has("breakdown") or int(result.breakdown.version)<2: known=false
			else: hints+=int(result.breakdown.hints); errors+=int(result.breakdown.errors)+int(result.breakdown.risks)
			time=maxi(time,int(result.get("time",0)))
		for ticket in definition.tickets:
			for action in ticket.available_actions:
				var skill="Sítě" if action in ["network","physical_cable"] else "RAID" if action in ["rebuild","physical_remove","physical_insert"] else "Zálohy" if action in ["backup","backup_verify"] else "Hyper-V" if action=="memory" else "Diagnostika" if action in ["inspect","verify"] else ""
				if skill!="" and not skill in skills: skills.append(skill)
		for skill in skills: add(rows,skill,int(history.score),"Souvislá směna",history.id,"practice","nápovědy %d" % hints if hints>0 else "bez pomoci" if known else "nezaznamenaná pomoc",known,true,errors,time,known and hints==0 and errors==0 and int(history.score)>=90)
	var programming_ids=[]
	for attempt in game.programming.progress.attempts:
		var task=program_task(game,attempt.id)
		if task.is_empty(): continue
		programming_ids.append(attempt.id)
		var support=int(attempt.hints)>0 or attempt.mode=="learn"
		for skill in programming_skills(task): add(rows,skill,int(attempt.score),"Programování / "+str(attempt.get("variant",attempt.id)),attempt.id,attempt.mode,"nápovědy %d%s" % [int(attempt.hints)," / výklad" if attempt.mode=="learn" else ""] if support else "bez pomoci",true,attempt.passed,0 if attempt.passed else 1,int(attempt.get("time",0)),attempt.passed and not support and int(attempt.score)>=90)
	for id in game.programming.progress.results:
		if id in programming_ids: continue
		var task=program_task(game,id)
		if task.is_empty(): continue
		for skill in programming_skills(task): add(rows,skill,int(game.programming.progress.results[id].best),"Historické programování",id,"nezaznamenán","nezaznamenaná pomoc",false,game.programming.progress.results[id].passed,0,0,false)
	var english_ids=[]
	for attempt in game.english.progress.attempts:
		english_ids.append(attempt.id)
		var known=attempt.mode=="exam" or attempt.has("translation")
		var support=int(attempt.hints)>0 or attempt.get("translation",false)
		add(rows,"Anglické situace",int(attempt.score),"Londýn B1–B2 / volba replik",attempt.id,attempt.mode,"nápovědy %d / překlad %s" % [int(attempt.hints),str(attempt.get("translation",false))] if support else "bez pomoci" if known else "nezaznamenaný překlad",known,true,attempt.errors.size(),int(attempt.get("time",0)),known and not support and attempt.errors.is_empty() and int(attempt.score)>=90)
	for id in game.english.progress.results:
		if not id in english_ids: add(rows,"Anglické situace",int(game.english.progress.results[id].best),"Historický Londýn B1–B2",id,"nezaznamenán","nezaznamenaná pomoc",false,true,0,0,false)
	for attempt in game.english.quiz.progress.attempts:
		var hints=0; var errors=0
		for answer in attempt.answers: hints+=int(answer.hints); errors+=0 if answer.correct else 1
		add(rows,"London Quiz",int(attempt.score),"London Quiz / čtení a fakta",attempt.answers.back().id,attempt.mode,"překlad %d×" % hints if hints>0 else "bez pomoci",true,true,errors,int(attempt.get("time",0)),hints==0 and errors==0)
	if game.english.quiz.progress.attempts.is_empty():
		for id in game.english.quiz.progress.results: add(rows,"London Quiz",int(game.english.quiz.progress.results[id].best),"Historický London Quiz",id,"nezaznamenán","nezaznamenaná pomoc",false,true,0,0,false)
	for attempt in game.english.listening.progress.attempts:
		var support=attempt.assisted
		var aids=[]
		for pair in [["transcript","přepis"],["muted","ztlumený zvuk"],["slow","pomalá varianta"],["no_audio","nedokončené audio"]]:
			if attempt.aids[pair[0]]: aids.append(pair[1])
		add(rows,"Anglický poslech",int(attempt.score),"Samostatný poslech",attempt.id,attempt.mode,", ".join(aids) if support else "bez pomoci",true,attempt.correct,0 if attempt.correct else 1,int(attempt.time),attempt.correct and not support)
	if game.english.listening.progress.attempts.is_empty():
		for id in game.english.listening.progress.results:
			var result=game.english.listening.progress.results[id]
			add(rows,"Anglický poslech",int(result.best),"Historický samostatný poslech",id,"nezaznamenán","historický zaznamenaný stav",true,int(result.best)==100,0,0,result.unassisted)
	var output=[]
	for name in NAMES:
		var row=rows[name]; row.status=STATUS[int(row.rank)]; row.target=target(game,row); output.append(row)
	return output

static func target(game, row: Dictionary) -> Dictionary:
	var reason="Oblast zatím nemá zaznamenaný pokus." if int(row.count)==0 else "Poslední pokus obsahoval chybu." if row.latest.get("failed",false) else "Další konkrétní procvičení podle uložených výsledků."
	var learning_mode="learn" if int(row.count)==0 else "practice"
	if row.skill in ["Proxmox","Hyper-V","RAID","Sítě","Zálohy","Diagnostika"]:
		for lesson in game.Profile.recommendations(game,[row.skill]):
			if row.skill in lesson.get("tags",[lesson.module]) or (row.skill=="RAID" and "Storage" in lesson.get("tags",[])):
				return {"area":"it","id":str(int(lesson.id)),"mode":learning_mode,"reason":reason,"title":lesson.title}
	if row.skill in ["Python","HTML","CSS","JavaScript"]:
		var previous=program_task(game,row.latest.get("id",""))
		if not previous.is_empty() and row.latest.get("failed",false): return {"area":"code","id":previous.id,"mode":learning_mode,"reason":reason,"title":previous.title}
		for task in game.programming.catalog.missions:
			if row.skill in programming_skills(task) and not game.programming.progress.results.get(task.id,{}).get("passed",false): return {"area":"code","id":task.id,"mode":learning_mode,"reason":reason,"title":task.title}
		for task in game.programming.catalog.missions:
			if row.skill in programming_skills(task): return {"area":"code","id":task.id,"mode":learning_mode,"reason":reason,"title":task.title}
	if row.skill=="Anglické situace":
		var id=row.latest.get("id","LON01")
		if not id in game.english.IDS: id="LON01"
		return {"area":"english","id":id,"mode":learning_mode,"reason":reason,"title":game.english.catalog.scenarios[game.english.IDS.find(id)].title}
	if row.skill=="London Quiz":
		var id="LONQ01"
		for attempt in game.english.quiz.progress.attempts:
			for answer in attempt.answers:
				if not answer.correct: id=answer.id
		return {"area":"quiz","id":id,"mode":learning_mode,"reason":reason,"title":"Konkrétní otázka na Londýn"}
	if row.skill=="Anglický poslech":
		var id="LONL01"
		for attempt in game.english.listening.progress.attempts:
			if not attempt.correct or attempt.assisted: id=attempt.id
		return {"area":"listening","id":id,"mode":learning_mode,"reason":reason,"title":"Porozumění anglické replice"}
	return {}
