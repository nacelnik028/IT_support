extends Node

func _ready():
	var tag := "user://academy_test_service_mcp_"+str(OS.get_process_id())
	preload("res://scripts/progression/SaveManager.gd").path_override = tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override = tag+"_vr.cfg"
	var shell = load("res://scenes/world/Game.tscn").instantiate()
	add_child(shell)
	await get_tree().process_frame
	shell.ui.save_preference("introduction_seen",true)
	await preload("res://scripts/service/ServiceSmoke.gd").run(shell)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/ui-review/2026-11-12-service-missions/mcp-service-review.png")
