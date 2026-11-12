extends SceneTree

func _init():
	var tag := "user://academy_test_service_audio_benchmark_"+str(OS.get_process_id())
	preload("res://scripts/progression/SaveManager.gd").path_override = tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override = tag+"_vr.cfg"
	call_deferred("run")

func run():
	var shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	shell.ui.save_preference("introduction_seen",true)
	shell.enter_world("Hlavní serverovna")
	shell.ui.apply_display_settings(Vector2i(1920,1080),false)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	shell.world.player.position = Vector3(2,0.02,1)
	shell.world.player.camera.look_at(Vector3(0,1.4,-3))
	for frame in 90: await process_frame
	var start := Time.get_ticks_usec()
	for frame in 240: await process_frame
	var ms := (Time.get_ticks_usec()-start)/240000.0
	print("SERVICE AUDIO BENCHMARK "+JSON.stringify({"mean_ms":ms,"renderer":RenderingServer.get_current_rendering_method(),"camera":[2,0.02,1],"target":[0,1.4,-3],"resolution":"1920x1080","draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}))
	var output := OS.get_cmdline_user_args()
	if not output.is_empty():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output[0])
	shell.queue_free()
	await process_frame
	quit()
