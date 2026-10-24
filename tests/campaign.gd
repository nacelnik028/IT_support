extends SceneTree

var failures = 0

func check(ok, text):
	if not ok:
		failures += 1
		push_error(text)

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override="user://academy_test_campaign.json"
	var Sim = preload("res://scripts/simulation/InfrastructureSimulator.gd")
	var Eval = preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
	var missions = JSON.parse_string(FileAccess.get_file_as_string("res://data/missions/campaign.json"))
	var solutions = JSON.parse_string(FileAccess.get_file_as_string("res://tests/solutions.json"))
	check(missions.size()>=48,"Musí existovat alespoň48 misí")
	var legacy=JSON.parse_string(FileAccess.get_file_as_string("res://data/missions/legacy_campaign.json"))
	for index in legacy.size(): check(missions[index]==legacy[index],"Původní mise musí zůstat beze změny: "+str(index+1))
	for i in missions.size():
		var sim = Sim.new()
		sim.reset(missions[i].initial_state)
		var initially_complete = true
		for goal in Eval.evaluate(sim.state,missions[i].objectives):
			if not goal.passed: initially_complete=false
		check(not initially_complete,"Mise %d už je splněna při startu" % (i+1))
		for step in solutions[i]:
			var result = sim.act(step[0],step[1])
			check(result.ok,"Mise %d, krok %s: %s" % [i+1,step[0],result.text])
		var complete = true
		for goal in Eval.evaluate(sim.state,missions[i].objectives):
			check(goal.passed,"Mise %d: %s (actual %s)" % [i+1,goal.label,str(goal.actual)])
			complete = complete and goal.passed
		if complete: print("MISSION %02d PASS: %s" % [i+1,missions[i].title])
	print("CAMPAIGN: %d missions, %d failures" % [missions.size(),failures])
	quit(0 if failures==0 else 1)
