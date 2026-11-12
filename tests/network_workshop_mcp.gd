extends Node

func _ready():
	var tag := "user://academy_test_workshop_mcp_"+str(OS.get_process_id())
	preload("res://scripts/progression/SaveManager.gd").path_override = tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override = tag+"_vr.cfg"
	var shell = load("res://scenes/world/Game.tscn").instantiate()
	add_child(shell)
	await get_tree().process_frame
	shell.ui.save_preference("introduction_seen",true)
	await preload("res://scripts/network_lab/WorkshopSmoke.gd").run(shell)
	shell.enter_world("Počítačové sítě")
	shell.world.player.position = Vector3(5.7,0.02,-30.2)
	var s = shell.ui.game.network_workshop
	s.mode = "practice"
	s.start("H")
	s.measure("dhcp")
	s.measure("dns")
	s.vlan(4,10)
	s.measure("dhcp")
	s.measure("dns")
	s.edit("dns",s.network.WEB)
	s.edit("flush")
	for kind in s.task.goals: s.measure(kind)
	s.causes = {"vlan":true,"dns":true}
	s.evidence_summary = {"dhcp":true,"services":true}
	s.submit()
	shell.open_network_workshop("review")
	for frame in 20: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/ui-review/2026-11-11-workshop-layout/after/mcp-workshop-review.png")
	print("WORKSHOP MCP current-source H=",s.result.passed," isolated=true; physical portal, door and shift return checked")
