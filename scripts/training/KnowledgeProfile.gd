extends RefCounted

const DOMAINS=["Proxmox","Hyper-V","RAID","Sítě","Zálohy","Diagnostika"]

static func summarize(game) -> Dictionary:
	var domains={}
	for domain in DOMAINS: domains[domain]={"total":0,"count":0,"errors":0,"average":0}
	var without_help=0
	var exams=[]
	var recorded_missions={}
	for attempt in game.education.attempts:
		if attempt.kind=="campaign": recorded_missions[str(int(attempt.id))]=true
		if attempt.mode!="learn" and int(attempt.hints)==0 and int(attempt.errors)==0 and int(attempt.score)>=90: without_help+=1
		if attempt.mode=="exam": exams.append(attempt)
		for raw_tag in attempt.tags:
			var tag="RAID" if raw_tag=="Storage" else raw_tag
			if not domains.has(tag): continue
			domains[tag].total+=int(attempt.score)
			domains[tag].count+=1
			domains[tag].errors+=int(attempt.errors)
	# Imported v1 best scores are useful evidence, but do not imply zero hints.
	for mission in game.missions:
		var key=str(int(mission.id))
		if recorded_missions.has(key) or not game.progress.scores.has(key): continue
		for tag in preload("res://scripts/training/PracticeGenerator.gd").domains(mission):
			if domains.has(tag):
				domains[tag].total+=int(game.progress.scores[key])
				domains[tag].count+=1
	for domain in domains:
		var item=domains[domain]
		if item.count>0: item.average=int(float(item.total)/item.count)
	var completed=0
	for item in game.education.lessons.values():
		if item.status in ["Dokončeno","Zvládnuto bez nápovědy"]: completed+=1
	return {"domains":domains,"completed":completed,"without_help":without_help,"exams":exams.slice(maxi(0,exams.size()-8)),"attempts":game.education.attempts.size()}

static func recommendations(game,tags: Array=[]) -> Array:
	var profile=summarize(game)
	var ranked=[]
	for lesson in game.tutorial.lessons:
		var priority=0
		var primary=lesson.get("primary_domain",lesson.module)
		if primary in tags: priority+=60
		var primary_result=profile.domains.get(primary,{"count":0,"average":0})
		if primary_result.count>0 and primary_result.average<70: priority+=70
		for topic in game.progress.mistakes:
			if topic.to_lower()==lesson.get("topic","").to_lower(): priority+=int(game.progress.mistakes[topic])*20
		for tag in lesson.get("tags",[lesson.module]):
			if tag in tags: priority+=50
			var item=profile.domains.get(tag,{"count":0,"average":0,"errors":0})
			priority+=20 if item.count==0 else maxi(0,85-int(item.average))+int(item.errors)*3
		var status=game.education.lessons.get(str(lesson.id),{}).get("status","Nedokončeno")
		if status=="Nedokončeno": priority+=10
		ranked.append({"lesson":lesson,"priority":priority})
	ranked.sort_custom(func(a,b): return a.priority>b.priority)
	var result=[]
	for item in ranked.slice(0,3): result.append(item.lesson)
	return result
