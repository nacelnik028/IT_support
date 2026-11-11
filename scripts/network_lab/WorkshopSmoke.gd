extends RefCounted

# Used by the opt-in EXE-only check; GameShell isolates save and both configs
# before constructing GameManager. This code never runs during ordinary play.
static func walk(shell, point: Vector3) -> bool:
	var p = shell.world.player
	for step in 360:
		if shell.mode=="pause": shell.return_to_world()
		var d: Vector3 = point-p.position
		d.y = 0
		if d.length()<0.14: break
		p.rotation.y = atan2(-d.x,-d.z)
		Input.action_press("walk_forward",minf(1,d.length()*3))
		Input.action_press("walk_fast")
		await shell.get_tree().physics_frame
	Input.action_release("walk_forward")
	Input.action_release("walk_fast")
	return Vector2(p.position.x-point.x,p.position.z-point.z).length()<0.4

static func run(shell):
	var game = shell.ui.game
	shell.enter_world("Hlavní serverovna")
	game.shifts.start("SHIFT-NET")
	game.sim.state.hosts["PVE-01"].hostname = "EXE-workshop-return"
	game.save()
	shell.enter_world("Rozcestník akademie")
	var okay := true
	for point in [Vector3(4,0.02,-17.5),Vector3(4,0.02,-24),Vector3(6.5,0.02,-27.5),Vector3(8,0.02,-27.5)]: okay = await walk(shell,point) and okay
	shell.interact_network_workshop("door_1")
	for frame in 90: await shell.get_tree().physics_frame
	okay = await walk(shell,Vector3(8,0.02,-30.4)) and okay
	okay = await walk(shell,Vector3(5.7,0.02,-30.2)) and okay
	var s = game.network_workshop
	okay = game.game_mode.is_network_lab() and shell.world.network_room.workshop.in_workshop and s.catalog.tasks.size()==8 and okay
	s.mode = "practice"
	s.start("H")
	s.measure("dhcp")
	s.measure("dns")
	s.vlan(4,10)
	s.measure("dhcp")
	s.measure("dns")
	s.edit("dns",s.network.WEB)
	s.edit("flush")
	s.measure("dhcp")
	for kind in s.task.goals:
		if kind!="dhcp": s.measure(kind)
	s.causes = {"vlan":true,"dns":true}
	s.evidence_summary = {"dhcp":true,"services":true}
	s.submit()
	shell.open_network_workshop("review")
	okay = s.result.passed and s.submitted and game.last_save_error==OK and okay
	if DisplayServer.get_name()!="headless":
		for frame in 12: await shell.get_tree().process_frame
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--workshop-shot="):
				await RenderingServer.frame_post_draw
				shell.get_viewport().get_texture().get_image().save_png(argument.trim_prefix("--workshop-shot="))
	shell.return_to_world()
	for point in [Vector3(8,0.02,-30.4),Vector3(8,0.02,-27.5),Vector3(6,0.02,-27.5),Vector3(4,0.02,-24),Vector3(4,0.02,-14)]: okay = await walk(shell,point) and okay
	shell.enter_world("Hlavní serverovna")
	okay = s.task.is_empty() and game.session_kind=="shift" and game.sim.state.hosts["PVE-01"].hostname=="EXE-workshop-return" and okay
	print("EXPORT_SMOKE workshop=",okay," tickets=",s.catalog.tasks.size()," history=",s.attempts.size()," physical_route=true H=true shift_restored=",game.session_kind=="shift")
