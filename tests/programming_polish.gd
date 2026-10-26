extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
var checks=0
var failures=0
var shell

func _init():
	Saves.path_override="user://programming_polish_test.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://programming_polish_test.cfg"
	Saves.save_game({},true)
	call_deferred("run")

func check(ok: bool, message: String):
	checks+=1
	if not ok: failures+=1; print("FAIL ",message)

func walk_to(target: Vector3, frames: int = 220) -> bool:
	for i in frames:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		shell.world.player.rotation=Vector3.ZERO
		var delta=target-shell.world.player.position
		for action in ["walk_left","walk_right","walk_forward","walk_back"]: Input.action_release(action)
		if Vector2(delta.x,delta.z).length()<0.12: return true
		if absf(delta.x)>0.06: Input.action_press("walk_right" if delta.x>0 else "walk_left")
		if absf(delta.z)>0.06: Input.action_press("walk_back" if delta.z>0 else "walk_forward")
		await physics_frame
	for action in ["walk_left","walk_right","walk_forward","walk_back"]: Input.action_release(action)
	print("Walk blocked at ",shell.world.player.position," trying to reach ",target)
	return false

func run():
	shell=preload("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell)
	await process_frame
	shell.enter_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	shell.world.player.rotation=Vector3.ZERO; shell.world.player.camera.rotation=Vector3.ZERO
	check(await walk_to(Vector3(0,0.02,4.4)),"Leave administration desks through rear aisle")
	check(await walk_to(Vector3(-6.5,0.02,4.4)),"Reach main aisle from ordinary spawn")
	check(await walk_to(Vector3(-6.5,0.02,-5.1)),"Reach programming entrance from main aisle")
	shell.world.player.poll_target()
	check(shell.world.player.target==shell.world.programming_room.door,"Door is visible and reachable from main aisle; hit="+str(shell.world.player.target))
	if shell.world.player.target==shell.world.programming_room.door:
		shell.interact(shell.world.player.target)
		await create_timer(0.5).timeout
		check(await walk_to(Vector3(-6.5,0.02,-9)),"Walk into Academy from main room")
		check(shell.ui.game.game_mode.is_programming(),"Walking activates Programming Academy")
		check(await walk_to(Vector3(-6.5,0.02,-5.1)),"Walk back through the same entrance")
		check(not shell.ui.game.game_mode.is_education(),"Walking restores MAIN")
	var academy=shell.world.programming_room
	shell.world.player.position=Vector3(-6.5,0.02,-7); shell.ui.game.reconcile_room()
	check(not academy.toggle_door() and academy.door_open,"Door cannot close through the player")
	shell.world.player.position=Vector3(-6.5,0.02,-9); shell.ui.game.reconcile_room()
	check(academy.toggle_door(),"Door closes when the threshold is clear")
	check(not academy.toggle_door(),"Repeated trigger cannot start competing door tweens")
	await create_timer(0.4).timeout
	check(academy.toggle_door(),"Door reopens from the classroom")
	shell.open_programming("python"); await process_frame
	var ui=shell.code_editor; var manager=shell.ui.game.programming
	check(ui.run_button.disabled and ui.test_button.disabled,"No code actions without an active task")
	ui.launch("PY01",true); ui.editor.text="print('Ahoj, světe!')"; ui.run_code()
	check(manager.step==2,"Guided lesson reaches the real edit step")
	ui.run_code(); check(manager.step==2,"Repeated Run cannot pretend the source was edited")
	ui.editor.insert_text_at_caret("# Moje změna\n"); ui.run_code(); check(manager.step==3,"An actual source edit advances learning")
	ui.launch("WEB21",false)
	ui.editor.insert_text_at_caret("<p>Moje změna</p>\n"); manager.edit("index.html",ui.editor.text)
	var html_editor=ui.editor; var caret=html_editor.get_caret_column()
	ui.switch_file("style.css"); ui.editor.insert_text_at_caret("p { color: red; }\n"); manager.edit("style.css",ui.editor.text)
	ui.switch_file("index.html")
	check(ui.editor==html_editor and ui.editor.get_caret_column()==caret,"Each file retains its own editor and caret")
	ui.editor.undo(); check(not ui.editor.text.contains("Moje změna"),"Native undo survives changing files")
	ui.editor.redo(); check(ui.editor.text.contains("Moje změna"),"Native redo survives changing files")
	ui.run_code(); check(ui.preview.document!=null,"Run creates an actual preview document")
	ui.launch("WEB28",false); check(ui.preview.document==null,"A new exercise cannot show the previous exercise's page")
	check(manager.generate_series("python","beginner",2,17),"Generate practice series")
	ui.load_current(); ui.mode_picker.select(2); ui.change_mode(2)
	check(manager.mode=="exam" and ui.hint_button.disabled and ui.example_button.disabled,"Mode changes also work for generated tasks")
	shell.return_to_world(); shell.open_programming("web")
	check(ui.selected_category=="web" and manager.current.is_empty(),"Changing stations updates the filter and cancels unrelated exercise")
	check(ui.console.get_theme_color("font_readonly_color")==shell.ui.Design.TEXT,"Readable output matches the common theme")
	shell.ui.display_settings.text_scale=1.3; shell.ui.theme=shell.ui.make_theme(); shell.apply_ui_preferences()
	ui.launch("WEB30",true)
	for i in 8: await process_frame
	check(ui.get_global_rect().end.x<=root.size.x and ui.get_global_rect().end.y<=root.size.y,"Editor fits the viewport at 130% text size")
	check(ui.test_button.get_global_rect().end.y<ui.console.get_global_rect().position.y,"Primary actions remain above the console")
	if "--screenshots" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-output/programming-polish-130.png")
	print("PROGRAMMING POLISH ",checks," checks, ",failures," failures")
	shell.queue_free(); await process_frame
	quit(1 if failures else 0)
