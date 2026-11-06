extends Node

const FOLDER="res://docs/ui-review/2026-11-06-usability/mcp/"
var shell

func capture(title: String):
	for i in 20: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(FOLDER+title+".png")

func _ready():
	var tag="user://academy_test_usability_mcp_"+str(OS.get_process_id())
	preload("res://scripts/progression/SaveManager.gd").path_override=tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override=tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override=tag+"_vr.cfg"
	preload("res://scripts/progression/SaveManager.gd").save_game({},true)
	DirAccess.make_dir_recursive_absolute(FOLDER)
	shell=load("res://scenes/world/Game.tscn").instantiate(); add_child(shell)
	await get_tree().process_frame
	shell.ui.apply_display_settings(Vector2i(1280,720),false); shell.ui.save_preference("text_scale",1.3)
	await capture("menu")
	shell.practical_intro.start(); shell.practical_intro.finish(false)
	print("USABILITY MCP introduction_returned=",shell.mode=="menu"," no_session=",not shell.ui.game.active)
	shell.ui.save_preference("introduction_seen",true)
	shell.enter_world("Rozcestník akademie"); shell.world.player.camera.look_at(Vector3(4,2,-7)); await capture("hub")
	shell.enter_world("Programming Academy"); shell.ui.game.programming.start("PY01","practice"); shell.open_programming("python")
	shell.code_editor.editor.text="print('Ahoj, světe!')"; shell.code_editor.test_code(); shell.code_editor.toggle_sidebar(); await capture("editor")
	print("USABILITY MCP collapsed=",not shell.code_editor.sidebar.visible," verified=",shell.ui.game.programming.last_result.ok)
	shell.enter_world("Hlavní serverovna"); shell.ui.game.start_mission(3); shell.world.player.position=Vector3(6.6,0.02,4.2); shell.world.player.camera.look_at(Vector3(-0.7,1.45,-3)); await capture("hud")
	print("USABILITY MCP ready; isolated save and settings")
