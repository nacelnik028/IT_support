extends Node

func _ready():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_mcp.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_mcp.cfg"
	var shell = preload("res://scenes/world/Game.tscn").instantiate()
	add_child(shell)
	shell.ui.game.start_mission(0,true)
	shell.enter_world()
	print("MCP: 3D world ready; isolated save; %d interactables" % shell.world.devices.size())
