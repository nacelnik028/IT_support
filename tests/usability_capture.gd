extends "res://tests/pause_repair.gd"

func run():
	capture_directory="res://docs/ui-review/2026-11-06-usability/"+("before/" if "--baseline" in OS.get_cmdline_user_args() else "after/")
	DirAccess.make_dir_recursive_absolute(capture_directory)
	suffix="1280-130"
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	shell.ui.apply_display_settings(Vector2i(1280,720),false); shell.ui.save_preference("text_scale",1.3)
	shell.ui.game.english.progress.intro_seen=true
	shell.ui.page="menu"; shell.ui.draw_ui(); shell.set_mode("menu"); await capture("menu-new")
	shell.ui.save_preference("introduction_seen",true)
	shell.enter_world("Hlavní serverovna"); shell.ui.game.start_mission(3)
	shell.ui.page="menu"; shell.ui.draw_ui(); shell.set_mode("menu"); await capture("menu-returning")
	shell.enter_world("Rozcestník akademie")
	for target in [["hub",Vector3(4,0.02,-11),Vector3(4,2,-7)],["hub-server",Vector3(1,0.02,-12),Vector3(-6,2,-7)],["hub-training",Vector3(10,0.02,-12),Vector3(16,2,-7)],["hub-code",Vector3(-4,0.02,-12),Vector3(-9,2,-12)],["hub-london",Vector3(15,0.02,-11.5),Vector3(21,2,-11.5)]]:
		shell.world.player.position=target[1]; shell.world.player.camera.look_at(target[2]); await capture(target[0])
	shell.enter_world("Programming Academy"); shell.ui.game.programming.start("PY01","practice"); shell.open_programming("python"); await frames()
	var code=shell.code_editor; code.editor.text="print('Ahoj, světe!')"; code.test_code(); await capture("editor")
	if code.has_method("toggle_sidebar"): code.toggle_sidebar(); await capture("editor-collapsed")
	shell.enter_world("Hlavní serverovna")
	shell.world.player.position=Vector3(6.6,0.02,4.2); shell.world.player.camera.look_at(Vector3(-0.7,1.45,-3)); await capture("hud")
	shell.ui.apply_display_settings(Vector2i(1920,1080),false)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	for i in 60: await process_frame
	var samples=[]
	for batch in 3:
		var begin=Time.get_ticks_usec()
		for i in 90: await process_frame
		samples.append((Time.get_ticks_usec()-begin)/90000.0)
	var benchmark={"renderer":RenderingServer.get_current_rendering_method(),"ms":samples,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),"lights":shell.world.find_children("*","Light3D",true,false).size()}
	FileAccess.open(capture_directory+"benchmark-"+RenderingServer.get_current_rendering_method()+".json",FileAccess.WRITE).store_string(JSON.stringify(benchmark,"\t"))
	print("USABILITY CAPTURE: ",JSON.stringify(benchmark))
	shell.queue_free(); await frames(); quit(1 if failures else 0)
