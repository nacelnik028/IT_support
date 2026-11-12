extends "res://tests/network_workshop.gd"

func reply_button(id: String):
	for b in shell.overlay.find_children("*","Button",true,false):
		if b.is_visible_in_tree() and b.get_meta("workshop_id","")=="customer:"+id: return b
	check(false,"Support button "+id)
	return null

func run():
	capture_directory = "res://docs/ui-review/2026-11-12-service-missions/"
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await frames()
	shell.ui.save_preference("introduction_seen",true)
	shell.enter_world("Počítačové sítě")
	shell.world.player.position = Vector3(5.7,0.02,-30.2)
	await frames()
	var s = shell.ui.game.network_workshop
	s.mode = "practice"
	s.start("F",3)
	for kind in s.task.before: s.measure(kind)
	s.edit("tcp",true)
	s.edit("flush")
	for kind in s.task.goals: s.measure(kind)
	shell.open_network_workshop("customer")
	await frames()
	for id in ["ask:what","ask:since","ask:services"]: await click(reply_button(id))
	check(s.hints==0,"Real question buttons are no hints")
	await click(reply_button("handover"))
	for id in ["cause:dns","cause:https","action:dns","action:https","verify","confirm"]: await click(reply_button(id))
	check(s.dialogue.assessment(s).passed,"Actual UI handover")
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for scale_value in [1.0,1.3]:
			suffix = "support-%d-%d" % [resolution.x,roundi(scale_value*100)]
			shell.ui.apply_display_settings(resolution,false)
			shell.ui.save_preference("text_scale",scale_value)
			shell.open_network_workshop("customer")
			await frames()
			check(root.get_visible_rect().encloses(button("Zpět do 3D  [Esc]").get_global_rect()),"Support persistent footer "+suffix)
			await capture("customer")
	await escape()
	await prepare_xr()
	for scale_value in [1.0,1.3]:
		shell.ui.save_preference("text_scale",scale_value)
		shell.open_network_workshop("customer")
		await frames()
		for hand in [0,1]: await click(reply_button("ask:others"),hand)
		check(rig.monitor.viewport.size==Vector2i(1600,1200),"Support true VR viewport")
		suffix = "support-vr-%d" % roundi(scale_value*100)
		await capture("customer",rig.monitor.viewport)
	rig.deactivate()
	shell.vr_active = false
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.queue_free()
	await frames()
	print("SUPPORT UI: %d checks, %d failures; PC and synthetic XR" % [checks,failures])
	quit(1 if failures else 0)
