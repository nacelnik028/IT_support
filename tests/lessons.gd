extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
var failures=0
var checks=0

func check(ok,message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override="user://academy_test_lessons.json"
	var game=Game.new()
	game.enter_training()
	var solutions=JSON.parse_string(FileAccess.get_file_as_string("res://tests/lesson_solutions.json"))
	check(game.tutorial.lessons.size()>=18,"Alespoň18 lekcí")
	for mode in ["learn","practice","exam"]:
		for definition in game.tutorial.lessons:
			var id=int(definition.id)
			check(game.start_lesson(id,mode,false),"Spuštění lekce")
			check(not game.unsaved,"Uložení výchozí lekce%d %s: %s" % [id,mode,game.save_message])
			check(not game.complete().ok,"Výchozí stav nesplňuje lekci%d" % id)
			for entry in solutions[str(id)]:
				if entry is Dictionary:
					game.notify_event(entry.event)
				else:
					var result=game.apply(entry[0],entry[1])
					check(result.ok and result.saved,"Lekce%d %s krok%s: %s / %s" % [id,mode,entry[0],result.text,game.save_message])
			if mode=="learn": check(int(game.tutorial.session.step)==definition.steps.size(),"Všechny kroky lekce%d: %s/%s" % [id,game.tutorial.session.step,definition.steps.size()])
			for goal in game.goals(): check(goal.passed,"Lekce%d %s: %s / %s" % [id,mode,goal.label,str(goal.actual)])
			check(game.complete().ok,"Dokončení lekce%d %s" % [id,mode])
			check(not game.unsaved,"Uložení výsledku lekce%d %s: %s" % [id,mode,game.save_message])
			if mode=="exam":
				var before=game.hints_used
				game.lesson_hint()
				check(game.hints_used==before,"Zkouška neposkytne nápovědu")
			print("LESSON %d %s PASS" % [id,mode])
	print("LESSONS: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
