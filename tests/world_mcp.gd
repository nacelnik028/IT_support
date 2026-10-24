extends Node

func _ready():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_mcp.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_mcp.cfg"
	var shell = preload("res://scenes/world/Game.tscn").instantiate()
	add_child(shell)
	shell.ui.game.start_mission(0,true)
	shell.enter_world()
	print("MCP: 3D world ready; isolated save; %d interactables" % shell.world.devices.size())
	var p = shell.world.player
	p.position = Vector3(0,0.02,-0.9)
	p.camera.rotation.x = -0.1
	for i in 3: await get_tree().physics_frame
	p.poll_target()
	assert(p.target == shell.world.devices["PVE-01"],"MCP raycast target")
	var key = InputEventKey.new()
	key.physical_keycode = KEY_E
	key.keycode = KEY_E
	key.pressed = true
	get_viewport().push_input(key,true)
	await get_tree().process_frame
	assert(shell.mode=="detail" and not p.enabled,"MCP interaction and mouse handoff")
	shell.open_app("Proxmox")
	await get_tree().process_frame
	assert(shell.ui.form_controls.size()>0,"MCP original console")
	assert(shell.ui.game.apply("prepare",{"vt":true,"mode":"HBA","ups":true,"console":true}).saved,"MCP isolated save")
	shell.return_to_world()
	assert(p.enabled and not shell.ui.visible,"MCP return from console")
	print("MCP: raycast, E, server detail, Proxmox forms, simulated change, save and return PASS")
