extends Node

# Graphical companion to ui_design.gd: the actual entry scene, 3D room and HUD.
const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var shell
var checks=0
var failures=0
var suffix=""

func _ready():
	Saves.path_override="user://academy_test_design_world.json"
	Settings.path_override="user://academy_test_design_world.cfg"
	Saves.save_game({},true)
	var settings=Settings.new(); settings.resolution=Vector2i(1280,720); settings.save_settings()
	shell=load("res://scenes/world/Game.tscn").instantiate(); add_child(shell)
	await capture("menu-720",true)
	await click(shell.ui.ui_targets["menu:primary"])
	check(shell.mode in ["introduction","world"],"Main menu click starts the 3D game")
	shell.finish_introduction()
	var player=shell.world.player
	var initial_position=player.position
	var initial_rotation=player.rotation
	var initial_camera=player.camera.rotation
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for text_scale in [1.0,1.3]:
			suffix=str(resolution.x)+"-"+str(roundi(text_scale*100))
			shell.enter_world("Hlavní serverovna")
			shell.ui.game.start_mission(0,false)
			shell.ui.apply_display_settings(resolution,false)
			shell.ui.save_preference("text_scale",text_scale)
			shell.enter_world()
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
			player.position=initial_position; player.rotation=initial_rotation; player.camera.rotation=initial_camera
			await frames()
			check(get_viewport().get_visible_rect().encloses(shell.status_label.get_global_rect()),"Campaign HUD fits the framebuffer")
			check("Další cíl:" in shell.status_label.text,"HUD shows an actual unfinished objective")
			check(get_viewport().get_visible_rect().encloses(shell.controls_label.get_global_rect()),"Control legend fits at the selected text size")
			await capture("hud")
			shell.open_app("Proxmox"); shell.ui.open_action("management"); await frames()
			check(visible(shell.ui.form_buttons.management),"Primary action remains visible above the 3D return bar")
			await capture("console")
			shell.ui.open_settings(); await capture("settings")
			shell.ui.close_settings()
			shell.enter_world("Trénink"); shell.open_app("Trénink")
			await capture("lessons")
			shell.ui.begin_lesson(1002,"learn",false)
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
			await frames()
			check(visible(shell.instruction),"Instructor HUD fits at the selected text size")
			await capture("training-hud")
			if resolution.x==1280 and text_scale==1.0:
				for screen in ["hud","console","settings","lessons"]:
					var source="res://test-output/design-world-"+screen+"-"+suffix+".png"
					DirAccess.copy_absolute(ProjectSettings.globalize_path(source),ProjectSettings.globalize_path("res://test-output/design-after-"+screen+"-720.png"))
	print("WORLD DESIGN MATRIX: %d checks, %d failures" % [checks,failures])
	if "--quit-after-design" in OS.get_cmdline_user_args():
		shell.queue_free(); await get_tree().process_frame; await get_tree().create_timer(0.15).timeout
		get_tree().quit(0 if failures==0 else 1)

func check(ok,message):
	checks+=1
	if not ok: failures+=1; push_error(message+" "+suffix)

func visible(control):
	return control.is_visible_in_tree() and get_viewport().get_visible_rect().encloses(control.get_global_rect())

func frames():
	for i in 8: await get_tree().process_frame
	shell.update_time=1; shell._process(0.01)
	await RenderingServer.frame_post_draw

func capture(title, comparable=false):
	await frames()
	var path="res://test-output/design-after-"+title+".png" if comparable else "res://test-output/design-world-"+title+"-"+suffix+".png"
	get_viewport().get_texture().get_image().save_png(path)

func click(control):
	var at=control.get_global_rect().get_center()
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down
		get_viewport().push_input(event,true); await get_tree().process_frame
	await frames()
