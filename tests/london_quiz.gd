extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
const Game=preload("res://scripts/core/GameManager.gd")
const ANSWERS=["The main bell","The Palace of Westminster","Elizabeth II's Diamond Jubilee","Four","A 135-metre observation wheel","30 minutes","32","You may share with other visitors","The South Bank","The Thames","South Bank","County Hall","They are different bridges","To let tall vessels pass","The nineteenth century","With the same phone","Touch in only","Pay as you go","Trafalgar Square","Some special exhibitions may cost extra"]
var checks=0
var failures=0

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_quiz_"+tag+".json"
	Settings.path_override="user://academy_test_quiz_"+tag+".cfg"
	Comfort.path_override="user://academy_test_quiz_"+tag+"_vr.cfg"
	Saves.save_game({},true); call_deferred("run")

func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; push_error(text)

func run():
	var game=Game.new(); game.enter_english()
	var quiz=game.english.quiz
	check(quiz.catalog.questions.size()==20,"20 dostupných otázek")
	var ids=[]; var positions={}; var orders={}
	for i in 20:
		var q=quiz.catalog.questions[i]
		check(q.id=="LONQ%02d" % [i+1] and not q.id in ids,"Stabilní unikátní ID"); ids.append(q.id)
		var texts=[]
		for o in q.options: texts.append(o.text)
		check(texts.size()==4 and texts.count(ANSWERS[i])==1,"Jednoznačná autorská odpověď "+q.id)
		check(q.options.filter(func(o): return o.text==ANSWERS[i])[0].id==q.answer,"Správný význam "+q.id)
		check(q.source.begins_with("https://") and q.verified=="2026-11-02" and q.explanation!="" and q.explanation_cs!="","Zdroj a vysvětlení "+q.id)
	for mode in ["learn","practice","exam"]:
		check(quiz.start(mode,20,71),"Start "+mode); orders[mode]=quiz.session.queue.duplicate()
		for i in 20:
			var q=quiz.definition(); var correct=q.options.filter(func(o): return o.text==ANSWERS[ids.find(q.id)])[0].id
			var options=quiz.choices(); positions[options.find(options.filter(func(o): return o.id==correct)[0])]=true
			check(quiz.choices()==options,"Stabilní pořadí při vykreslení")
			check(not quiz.answer("unknown",quiz.revision) and not quiz.answer(correct,quiz.revision-1),"Neplatné ID / token")
			if mode=="exam": check(quiz.help()=="" and not quiz.session.help,"Zkouška bez pomoci")
			else: check(quiz.help()!="" and quiz.session.help,"Překlad na vyžádání")
			var token=quiz.revision
			check(quiz.answer("o1",token),"Chybná odpověď zaznamenána")
			check(not quiz.answer(correct,token),"Opakovaný trigger neprojde")
			if mode=="learn": check(quiz.answer(correct,quiz.revision) and quiz.session.current.corrected,"Oprava v Učím se")
			else: check(not quiz.answer(correct,quiz.revision),"První odpověď nelze přepsat")
			check(quiz.next(quiz.revision),"Další / odevzdat")
		check(quiz.session.completed and quiz.session.score==0,"Opravy nefalšují první skóre")
		check(game.save()==OK,"Skutečný save "+mode)
	check(positions.size()>1 and orders.learn!=orders.practice,"Promíchané otázky i správné pozice")
	check(quiz.progress.results.size()==20 and quiz.progress.attempts.size()==3,"Výsledky podle 20 ID")
	quiz.start("exam",20,99)
	for i in 20: quiz.answer(quiz.definition().answer,quiz.revision); quiz.next(quiz.revision)
	check(quiz.session.score==100 and quiz.progress.best==100,"Celá správná série")
	var saved=Saves.load_game(); check(Saves.rules().valid(saved),"Validovaný skutečný save")
	for bad in [{"results":{"LONQ99":{"best":100,"attempts":1,"practiced":true,"corrected":false}}},{"best":101},{"best":1.5},{"attempts":[{"mode":"exam","score":100,"answers":[]}]}]:
		var invalid=saved.duplicate(true); invalid.english.quiz=bad
		check(not Saves.rules().valid(invalid),"Poškozená větev odmítnuta")
	var altered=saved.duplicate(true); altered.english.quiz.attempts[0].answers[0].correct=true
	check(not Saves.rules().valid(altered),"Nepravdivá správnost odmítnuta")
	var restored=Game.new()
	check(restored.english.quiz.progress.results.size()==20 and restored.english.quiz.session.is_empty(),"Restart uchová výsledky, zruší pokus")
	var original=Saves.path_override
	quiz.start("practice",5,99)
	for i in 4: quiz.answer(quiz.definition().answer,quiz.revision); quiz.next(quiz.revision)
	quiz.answer(quiz.definition().answer,quiz.revision)
	Saves.path_override="user://missing_quiz_%d/save.json" % OS.get_process_id()
	check(quiz.next(quiz.revision) and game.unsaved,"Pravdivé selhání uložení série")
	Saves.path_override=original; check(game.save()==OK and not game.unsaved,"Opakování zápisu")
	var attempts=quiz.progress.attempts.size(); quiz.start("learn",20); quiz.answer("o0",quiz.revision); game.leave_training()
	check(quiz.session.is_empty() and quiz.progress.attempts.size()==attempts,"Odchod neodevzdá pokus")
	var legacy=Saves.load_game(); legacy.english={"results":{"LON01":{"best":100,"completed":2,"hints":0}},"attempts":[],"phrases":["I'd like a ticket, please."],"intro_seen":true}
	check(Saves.save_game(legacy)==OK,"Starý A1–A2 save zůstává validní")
	var migrated=Game.new()
	check(migrated.english.progress.results.is_empty() and JSON.parse_string(JSON.stringify(migrated.english.progress.archive))==JSON.parse_string(JSON.stringify(legacy.english)),"Archiv nepřizná B1–B2 za starý obsah")
	check(migrated.save()==OK,"Migrace se skutečně uloží")
	var again=Game.new(); check(again.english.progress.archive.results.LON01.best==100 and again.english.progress.results.is_empty(),"Archiv přežije další restart")
	game=null; restored=null; migrated=null; again=null
	print("LONDON QUIZ: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
