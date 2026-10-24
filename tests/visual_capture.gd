extends SceneTree

var shell

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_visual_capture.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_visual_capture.cfg"
	call_deferred("run")

func capture(title: String, at: Vector3, target: Vector3):
	var p = shell.world.player
	p.position = at
	p.rotation = Vector3.ZERO
	p.camera.rotation = Vector3.ZERO
	p.camera.look_at(target)
	for i in 45: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/visual-"+title+".png")
	print("VISUAL CAPTURE: "+title)

func run():
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	shell.ui.apply_display_settings(Vector2i(1600,900),false)
	shell.ui.game.start_mission(52,true)
	shell.enter_world()
	shell.world.visuals.sync(shell.ui.game)
	await capture("server-room",Vector3(6.6,0.02,4.2),Vector3(-0.7,1.45,-3))
	await capture("rack-close",Vector3(1.2,0.02,-0.6),Vector3(0,1.35,-3))
	await capture("glass-office",Vector3(0.2,0.02,4.2),Vector3(-4.7,1.7,8.5))
	await capture("door-controls",Vector3(6.1,0.02,3.8),Vector3(9,1.7,2.7))
	shell.enter_world("Trénink")
	await capture("academy",Vector3(15.5,0.02,5.5),Vector3(14.8,1.5,-3.5))
	print("VISUAL RENDERER: "+RenderingServer.get_current_rendering_method())
	shell.queue_free()
	await process_frame
	quit()
