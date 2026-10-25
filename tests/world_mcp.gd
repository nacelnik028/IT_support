extends Node

func _ready():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_mcp.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_mcp.cfg"
	var shell = preload("res://scenes/world/Game.tscn").instantiate()
	add_child(shell)
	shell.ui.game.start_mission(0,true)
	shell.enter_world()
	# Automated raycasts use a fixed camera; desktop pointer recentering when
	# another verification window opens must not rotate that camera.
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
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
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	assert(p.enabled and not shell.ui.visible,"MCP return from console")
	print("MCP: raycast, E, server detail, Proxmox forms, simulated change, save and return PASS")
	p.position = Vector3(7.4,0.02,1.65)
	p.rotation = Vector3.ZERO
	p.camera.rotation = Vector3.ZERO
	p.camera.look_at(shell.world.devices["DOOR-CONTROL-OPS"].global_position)
	for i in 3: await get_tree().physics_frame
	p.poll_target()
	assert(p.target==shell.world.devices["DOOR-CONTROL-OPS"],"MCP fixed door control")
	get_viewport().push_input(key,true)
	for i in 50: await get_tree().physics_frame
	assert(shell.world.door_open,"MCP door opened")
	p.poll_target()
	assert(p.target==shell.world.devices["DOOR-CONTROL-OPS"],"MCP control stays accessible after opening")
	get_viewport().push_input(key,true)
	for i in 50: await get_tree().physics_frame
	assert(not shell.world.door_open,"MCP door closed from fixed control")
	print("MCP: repeated E on reachable wall control opens and closes the academy door PASS")
	# Exercise the actual 3D training entry and the previously broken UI path.
	shell.enter_world("Trénink")
	shell.ui.begin_lesson(1002,"learn",false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	p.position=Vector3(11.5,0.02,-1.6)
	p.camera.look_at(shell.world.devices["PVE-TRAIN-01"].global_position)
	for i in 3: await get_tree().physics_frame
	shell.update_guidance()
	p.poll_target()
	assert(p.target==shell.world.devices["PVE-TRAIN-01"],"MCP training server raycast")
	get_viewport().push_input(key,true)
	await get_tree().process_frame
	assert(shell.ui.game.tutorial.session.step==1,"MCP physical server confirms the lesson step")
	await click(find_button(shell.overlay,"Otevřít management"))
	shell.ui.apply_display_settings(Vector2i(1280,720),false)
	for i in 4: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var tree=shell.ui.ui_targets["tree:PVE-01"]
	var row=tree.get_root().get_first_child()
	await pointer(tree.get_global_transform()*tree.get_item_area_rect(row,0).get_center())
	assert(shell.ui.game.tutorial.session.step==2,"MCP clicking the already selected host confirms it")
	await click(shell.ui.ui_targets["wizard:create_vm"])
	await click(shell.ui.ui_targets["context:toggle"])
	await click(find_button(shell.ui,"Zobrazit potřebný panel"))
	assert(not shell.ui.context_open and shell.ui.form_controls.has("vm_identity"),"MCP recovery opens the visible wizard form")
	assert(shell.ui.ui_targets["tutorial:instruction"].is_visible_in_tree(),"MCP instructions stay beside the form")
	get_viewport().get_texture().get_image().save_png("res://test-output/tutorial-world-recovered-720.png")
	print("MCP: training raycast/E, selected host click, instructor recovery and visible wizard PASS")

func find_button(node: Node,caption: String):
	if node is Button and node.text.begins_with(caption): return node
	for child in node.get_children():
		var found=find_button(child,caption)
		if found: return found
	return null

func pointer(at: Vector2):
	var motion=InputEventMouseMotion.new(); motion.position=at; get_viewport().push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; event.position=at
		get_viewport().push_input(event,true)
		await get_tree().process_frame
	for i in 4: await get_tree().process_frame

func click(control: Control):
	assert(is_instance_valid(control),"MCP visible tutorial control exists")
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor is ScrollContainer:
			var content=ancestor.get_child(0)
			var rect=content.get_global_transform().affine_inverse()*control.get_global_rect()
			ancestor.scroll_vertical=maxi(0,roundi(rect.end.y-ancestor.size.y+8))
		ancestor=ancestor.get_parent()
	for i in 3: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	await pointer(control.get_global_rect().get_center())
