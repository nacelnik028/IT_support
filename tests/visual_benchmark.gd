extends SceneTree

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_visual_benchmark.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_visual_benchmark.cfg"
	call_deferred("run")

func run():
	var shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	shell.ui.game.start_mission(0,true)
	shell.enter_world()
	shell.world.player.position = Vector3(6.6,0.02,4.2)
	shell.world.player.camera.look_at(Vector3(-0.7,1.45,-3))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var results = []
	for resolution in [Vector2i(1920,1080),Vector2i(3840,2160)]:
		shell.ui.apply_display_settings(resolution,false)
		for i in 60: await process_frame
		var begin = Time.get_ticks_usec()
		for i in 120: await process_frame
		var ms = (Time.get_ticks_usec()-begin)/120000.0
		var result = {"resolution":str(resolution),"mean_ms":ms,"fps":1000.0/ms,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"visible_objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),"vram_mb":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0}
		results.append(result)
		print("VISUAL BENCHMARK: "+JSON.stringify(result))
	var file = FileAccess.open("res://test-output/visual-benchmark.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t"))
	file.close()
	shell.queue_free()
	await process_frame
	quit()
