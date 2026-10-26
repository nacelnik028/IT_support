extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Evaluation=preload("res://scripts/programming/CodeEvaluator.gd")
var checks=0
var failures=0
func _init():
	Saves.path_override="user://programming_integration_test.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://programming_integration_test.cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override="user://programming_integration_vr.cfg"
	Saves.save_game({},true)
	call_deferred("run")
func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; print("FAIL ",text)
func frames():
	for i in 4: await process_frame
func capture(name: String):
	if "--screenshots" in OS.get_cmdline_user_args():
		await frames()
		root.get_texture().get_image().save_png("res://test-output/programming-"+name+".png")

func run():
	var shell=preload("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	shell.enter_world()
	var game=shell.ui.game; var player=shell.world.player
	player.position=Vector3(-6.5,0.02,-6.5); player.rotation.y=0; player.camera.rotation.x=0
	for i in 4: await physics_frame
	player.poll_target()
	check(player.target==shell.world.programming_room.door,"Ray reaches programming door")
	shell.interact(player.target)
	await create_timer(0.5).timeout
	Input.action_press("walk_forward")
	for i in 50: await physics_frame
	Input.action_release("walk_forward")
	check(game.game_mode.is_programming(),"Walk through real doorway activates academy")
	player.position=Vector3(0,0.02,-9); player.rotation.y=0
	await capture("room")
	shell.open_programming(); await frames()
	var ui=shell.code_editor
	for lesson in game.programming.catalog.lessons:
		for index in 3:
			ui.mode_picker.select(index); ui.launch(lesson.mission,true); await frames()
			var task=game.programming.current
			check(not task.is_empty(),lesson.id+" starts")
			check(ui.hint_button.disabled==(index==2) and ui.example_button.disabled==(index!=0),lesson.id+" help modes")
			for filename in task.example: game.programming.edit(filename,task.example[filename])
			ui.switch_file("main.py" if task.category=="python" else "index.html")
			ui.run_code()
			check(game.programming.last_run.ok,lesson.id+" runs: "+game.programming.last_run.get("error",""))
			if index==0:
				ui.editor.insert_text_at_caret("# Zkouším změnu\n" if task.category=="python" else "<!-- Zkouším změnu -->\n")
				ui.run_code()
			ui.test_code()
			check(game.programming.last_result.ok,lesson.id+" mode "+str(index)+": "+game.programming.last_result.text)
	check(game.programming.progress.lessons.size()==28,"All lessons completed interactively in three modes")
	ui.mode_picker.select(0); ui.launch("WEB28",true)
	for filename in game.programming.current.example: game.programming.edit(filename,game.programming.current.example[filename])
	ui.switch_file("index.html"); ui.run_code(); await frames()
	var doc=ui.preview.document; var target=doc.query("#vysledek")[0]
	var button_nodes=ui.preview.find_children("*","Button",true,false)
	check(not button_nodes.is_empty(),"Preview creates a real button")
	button_nodes[0].pressed.emit(); await frames()
	check(doc.text_content(target)=="Ahoj!","Actual preview click mutates DOM and rendered content")
	await capture("web")
	# CSS changes must affect Godot controls, not just validator metadata.
	ui.launch("WEB21",false)
	for filename in game.programming.current.example: game.programming.edit(filename,game.programming.current.example[filename])
	ui.switch_file("style.css"); ui.editor.text="h1 { color: red; font-size: 32px; } body { background-color: blue; }"; ui.run_code(); await frames()
	var heading=ui.preview.document.query("h1")[0]
	var heading_control=ui.preview.controls[heading].find_children("*","Label",true,false)[0]
	check(heading_control.get_theme_color("font_color")==Color.RED,"Changed CSS changes rendered text color")
	ui.launch("PY30",true)
	game.programming.edit("main.py",game.programming.current.example["main.py"]); ui.switch_file("main.py"); ui.run_code()
	await capture("python")
	# Every generator filter and all generated references are tested.
	var fingerprints={}
	for category in ["python","html","css","javascript","mixed"]:
		for difficulty in ["beginner","advanced","exam"]:
			for seed_value in [101,203,307]:
				var generated=preload("res://scripts/programming/PracticeGenerator.gd").new().generate(game.programming.catalog,category,difficulty,8,seed_value)
				check(generated.size()==8,"Generator "+category+" "+difficulty)
				for task in generated:
					fingerprints[JSON.stringify(task.tests)]=true
					check(Evaluation.new().evaluate(task,task.example).ok,"Generated solvable "+task.id)
	check(fingerprints.size()>35,"Generator varies actual test data and requirements")
	check(game.programming.generate_series("mixed","exam",3,42),"Start exam series")
	for i in 3:
		for filename in game.programming.current.example: game.programming.edit(filename,game.programming.current.example[filename])
		check(game.programming.test_program().ok,"Complete series item")
		if i<2: check(game.programming.next_generated(),"Advance series")
	# Synthetic XR rendering/input exercises the same editor on the VR viewport.
	var rig=preload("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; player.add_child(rig)
	shell.xr_rig=rig; shell.vr_active=true; rig.activate(false)
	shell.open_programming(); ui=shell.code_editor; ui.launch("PY01",false); await frames()
	check(shell.ui_layer.get_parent()==rig.monitor.viewport,"Editor is inside VR SubViewport")
	ui.editor.grab_focus(); rig.monitor.keyboard.track_focus()
	rig.monitor.keyboard.type_text("print('Ahoj, světe!')\n"); ui.run_code()
	check(ui.console.text.contains("Ahoj, světe!"),"VR keyboard writes executable code")
	var keys=[]
	for key in rig.monitor.keyboard.find_children("*","Button",true,false): keys.append(key.text)
	check(Array("{}[]():;\"'=+-*/<>#.,_".split("")).all(func(c): return c in keys),"VR programming punctuation")
	var original_font=ui.editor.get_theme_font_size("font_size"); ui.zoom(4)
	check(ui.editor.get_theme_font_size("font_size")==original_font+4,"VR code zoom")
	ui.launch("WEB28",false); ui.file_picker.select(2); ui.switch_file("script.js")
	check(ui.file_name=="script.js","VR file switching")
	shell.world.player.position=Vector3(0,0.02,3); game.reconcile_room(); await frames()
	check(game.programming.current.is_empty() and not rig.monitor.visible,"VR boundary closes editor")
	rig.deactivate(); shell.vr_active=false
	game.save(); var saved=Saves.load_game()
	check(saved.programming.lessons.size()==28 and saved.programming.xp>0,"All results persist compatibly")
	shell.queue_free(); await frames()
	print("PROGRAMMING INTEGRATION ",checks," checks, ",failures," failures; ",fingerprints.size()," generated variants")
	quit(1 if failures else 0)
