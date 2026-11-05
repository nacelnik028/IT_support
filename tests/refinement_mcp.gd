extends Node

# Opt-in graphical fixture for Godot MCP. All persistent state is isolated.
var shell
const FOLDER="res://docs/ui-review/2026-11-05-alex-portals-editor/"

func frames(count: int = 12):
	for i in count: await get_tree().process_frame

func capture(title: String):
	await frames(); await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(FOLDER+"mcp-"+title+".png")

func _ready():
	var tag="user://academy_test_refinement_mcp_"+str(OS.get_process_id())
	preload("res://scripts/progression/SaveManager.gd").path_override=tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override=tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override=tag+"_vr.cfg"
	preload("res://scripts/progression/SaveManager.gd").save_game({},true)
	DirAccess.make_dir_recursive_absolute(FOLDER)
	shell=load("res://scenes/world/Game.tscn").instantiate(); add_child(shell); await frames()
	shell.ui.game.english.progress.intro_seen=true
	shell.ui.apply_display_settings(Vector2i(1280,720),false); shell.ui.save_preference("text_scale",1.3)
	shell.enter_world("English in London"); shell.world.player.position=Vector3(6,0.02,10); shell.return_to_world()
	shell.world.player.camera.look_at(Vector3(6.65,1.55,12.8)); shell.world.player.enabled=false
	await capture("alex-sign")
	shell.open_english("info"); await capture("alex-menu")
	shell.enter_world("Programming Academy"); shell.open_programming("python"); await frames()
	shell.code_editor.launch("PY01",false); await frames()
	shell.code_editor.editor.text="print('wrong')"; shell.code_editor.test_code()
	shell.code_editor.verification_details.button_pressed=true
	await capture("editor-verification")
	var node=shell.code_editor.verification
	while node is Control:
		print("MCP LAYOUT ",node.name," size=",node.size," min=",node.get_combined_minimum_size()," global=",node.get_global_rect())
		node=node.get_parent()
	print("REFINEMENT MCP: Alex sign/menu and editor captured at 720p / 130%; isolated save/CFG")
