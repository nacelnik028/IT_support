extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
var checks=0
var failures=0
func _init(): call_deferred("run")
func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; print("FAIL ",text)

func run():
	Saves.path_override="user://programming_academy_test.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://programming_academy_test.cfg"
	for suffix in ["",".tmp",".last-good.bak"]:
		if FileAccess.file_exists(Saves.save_path()+suffix): DirAccess.remove_absolute(Saves.save_path()+suffix)
	var shell=preload("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell)
	await process_frame
	shell.enter_world(); var game=shell.ui.game
	game.apply("inspect",{"scope":"Events"})
	var campaign=game.snapshot().duplicate(true)
	check(shell.world.devices.has("PYTHON-PC"),"3D station exists")
	shell.enter_world("Programming Academy"); await process_frame
	check(game.game_mode.is_programming(),"Programming room mode")
	check(not game.start_lesson(1001,"learn"),"No IT lessons in programming room")
	check(not game.start_mission(0),"No work missions in programming room")
	shell.interact(shell.world.devices["PYTHON-PC"]); await process_frame
	check(shell.mode=="coding" and is_instance_valid(shell.code_editor),"Actual station opens CodeEdit")
	var ui=shell.code_editor
	ui.launch("PY01",true)
	ui.editor.text="print('Ahoj, světe!')"
	await process_frame
	ui.run_code(); check(ui.console.text=="Ahoj, světe!\n","Real code output: "+ui.console.text+" files="+str(game.programming.files))
	ui.editor.text="print('Vlastni pozdrav')"; await process_frame; ui.run_code()
	check(ui.console.text=="Vlastni pozdrav\n","Own edits change output: "+ui.console.text)
	ui.editor.text="print('Ahoj, světe!')"; await process_frame; ui.test_code()
	check(game.programming.last_result.ok,"First complete interactive lesson")
	check(game.programming.progress.lessons.has("PYL01"),"Lesson saved")
	var xp=game.progress.xp
	ui.test_code(); check(game.progress.xp==xp,"No farming repetition XP")
	check(Saves.load_game().programming.results.PY01.passed,"Compatible save")
	for mode in ["learn","practice","exam"]:
		check(game.programming.start("PY01",mode),"Start "+mode)
		game.programming.edit("main.py","while True:\n    pass")
		check(not game.programming.run_program().ok,"Infinite loop stopped")
		if mode=="exam": check(game.programming.hint().contains("není"),"Exam blocks help")
		shell.world.player.position=Vector3(0,0.02,3); game.reconcile_room(); await process_frame
		check(game.game_mode.current==game.Modes.Mode.MAIN and game.programming.current.is_empty(),"Teleport cancels "+mode)
		check(shell.mode=="world","Editor closed at boundary")
		check(game.current.id==campaign.id and game.sim.state==campaign.state,"Campaign preserved")
		shell.enter_world("Programming Academy"); await process_frame
		check(game.programming.current.is_empty(),"No automatic unfinished restart")
	shell.enter_world("Trénink"); await process_frame
	check(game.game_mode.is_training() and not game.programming.start("PY01","learn"),"Server training isolation")
	shell.enter_world("Hlavní serverovna"); await process_frame
	var restored=game.sim.state.duplicate(true); restored.world.player=campaign.state.world.player
	for key in restored:
		check(restored[key]==campaign.state[key],"Both rooms preserve campaign "+key+" "+(str(restored[key]) if restored[key]!=campaign.state[key] else ""))
	shell.queue_free(); await process_frame
	print("PROGRAMMING ACADEMY ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
