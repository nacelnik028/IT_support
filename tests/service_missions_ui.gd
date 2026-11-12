extends "res://tests/network_workshop.gd"

func click(b, hand: int = -1):
	if b!=null and hand<0 and DisplayServer.get_name()!="headless":
		# Keep queued native cursor events aligned with the injected mouse path.
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.warp_mouse(b.get_global_rect().get_center()*Vector2(root.size)/root.get_visible_rect().size)
		await frames(4)
	await super.click(b,hand)

func reply(id: String):
	for b in shell.overlay.find_children("*","Button",true,false):
		if b.is_visible_in_tree() and b.get_meta("workshop_id","")=="customer:"+id: return b
	check(false,"Missing support reply "+id)
	return null

func use_button(title: String, hand := -1):
	await click(button(title),hand)

func program(service, hand: int):
	await use_button("Ticket",hand)
	var state: Dictionary = service.session.network.snapshot()
	await use_button("Python / analyzovat virtuální data incidentu",hand)
	check(shell.mode=="coding" and shell.code_editor.manager==service.programming,"Existing editor opens same incident")
	check(service.session.network.snapshot()==state,"Editor never resets incident")
	await use_button("Aktualizovat virtuální data",hand)
	var editor = shell.code_editor.editor
	editor.grab_focus()
	editor.select_all()
	editor.insert_text_at_caret(service.reference_code())
	await frames()
	await use_button("Spustit kód",hand)
	await use_button("Ověřit řešení",hand)
	check(service.analysis_current(),"Actual CodeEdit program evaluates real incident input")
	await capture("mission-python",rig.monitor.viewport if hand>=0 else null)
	await use_button("Zpět k incidentu",hand)
	check(service.session.network.snapshot()==state,"Return retains network and current evidence")

func customer(service, hand: int):
	await use_button("Ticket",hand)
	await use_button("Zákazník / English support",hand)
	for id in ["ask:what","ask:since","ask:services"]: await click(reply(id),hand)
	await click(reply("handover"),hand)
	for key in (["vlan","dns"] if service.id=="SERVICE-PORTAL" else ["cable","vlan"]):
		await click(reply("cause:"+key),hand)
		await click(reply("action:"+key),hand)
	await click(reply("verify"),hand)
	await click(reply("confirm"),hand)
	check(service.session.dialogue.assessment(service.session).passed,"Actual customer handover")
	await capture("mission-customer",rig.monitor.viewport if hand>=0 else null)

func repair_incident(service, hand: int):
	await use_button("Změřit",hand)
	await use_button("Změřit linku",hand)
	if service.id=="SERVICE-PORTAL": await use_button("Změřit DNS",hand)
	else:
		await use_button("Přenosný tester trasy",hand)
		for title in ["Vzít tester","Tester / PC 04","Tester → SW 04","Spustit měření testeru","Vrátit tester"]: await use_button(title,hand)
		check(service.session.network.measurements.tester.state=="unavailable","Mission tester traces actual fault")
	await use_button("Opravy",hand)
	if service.id=="SERVICE-PORTAL":
		await use_button("VLAN",hand)
		await use_button("Port 06 → VLAN 10",hand)
		await use_button("Diagnostika",hand)
		await use_button("Obnovit a změřit DHCP",hand)
		await use_button("Změřit DNS",hand)
		await use_button("Opravy",hand)
		await use_button("DNS",hand)
		await use_button("DNS A / 203.0.113.20",hand)
		await use_button("Obnovit DNS cache",hand)
	else:
		await use_button("Kabeláž a porty",hand)
		await use_button("Konektor / PC 04",hand)
		await use_button("SW 06 / VLAN 10",hand)
		await use_button("VLAN",hand)
		await use_button("SW 07 / VLAN 20",hand)
		await use_button("Port 07 → VLAN 10",hand)
	await use_button("Diagnostika",hand)
	var labels := {"dhcp":"Obnovit a změřit DHCP","link":"Změřit linku","dns":"Změřit DNS","tcp":"Změřit TCP 443","https":"Otevřít HTTPS","printer":"Změřit tiskárnu","control":"Změřit PC 02"}
	for key in service.session.task.goals: await use_button(labels[key],hand)
	if service.id=="SERVICE-MOVE":
		await use_button("Přenosný tester trasy",hand)
		for title in ["Vzít tester","Tester / PC 04","Tester → SW 06","Spustit měření testeru"]: await use_button(title,hand)
		check(service.session.network.fresh("link"),"Mission tester supplies fresh final proof")

func matrix(service):
	if DisplayServer.get_name()=="headless": return
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for scale_value in [1.0,1.3]:
			suffix = "mission-%d-%d" % [resolution.x,roundi(scale_value*100)]
			shell.ui.apply_display_settings(resolution,false)
			shell.ui.save_preference("text_scale",scale_value)
			shell.open_network_workshop("ticket")
			await frames()
			check(root.get_visible_rect().encloses(button("Odevzdat servisní misi").get_global_rect()),"Mission footer fits "+suffix)
			await capture("mission-ticket")
			shell.open_service_editor()
			await frames()
			check(shell.code_editor.editor.size.y>=shell.code_editor.editor.get_line_height()*5,"Five visible source lines "+suffix)
			await capture("mission-editor")
			shell.open_network_workshop("customer")
			await frames()
			await capture("mission-dialog")

func run():
	capture_directory = "res://docs/ui-review/2026-11-12-service-missions/"
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await frames()
	shell.ui.save_preference("introduction_seen",true)
	shell.ui.save_preference("vsync",false)
	shell.enter_world("Hlavní serverovna")
	var game = shell.ui.game
	game.start_mission(0)
	game.sim.state.hosts["PVE-01"].hostname = "mission-ui-protected"
	shell.enter_world("Počítačové sítě")
	shell.world.player.position = Vector3(5.7,0.02,-30.2)
	await frames()
	var service = game.service_missions
	for mode_value in ["learn","practice","exam"]:
		for d in service.catalog.missions:
			suffix = d.id+"-"+mode_value
			shell.open_network_workshop("home")
			await frames()
			await use_button(service.session.MODES[mode_value])
			await use_button("Zahájit misi / "+d.title)
			check(service.active and service.id==d.id and service.session.mode==mode_value,"Start mission from service desk UI")
			await repair_incident(service,-1)
			await program(service,-1)
			await customer(service,-1)
			if mode_value=="exam" and d.id=="SERVICE-MOVE": await matrix(service)
			await use_button("Odevzdat servisní misi")
			check(service.session.result.get("passed",false),"Full real UI mission "+suffix+str(service.session.result))
			await capture("mission-result")
	check(game.network_workshop.attempts.is_empty() and game.programming.progress.attempts.is_empty(),"Mission never creates duplicate workshop/programming reward")
	service.suspend()
	shell.enter_world("Hlavní serverovna")
	check(game.sim.state.hosts["PVE-01"].hostname=="mission-ui-protected","Full UI playthrough restores original campaign")
	shell.enter_world("Počítačové sítě")
	shell.world.player.position = Vector3(5.7,0.02,-30.2)
	await prepare_xr()
	service.start("SERVICE-MOVE","practice")
	shell.open_network_workshop("ticket")
	await frames()
	await repair_incident(service,0)
	await program(service,1)
	await customer(service,0)
	for scale_value in [1.0,1.3]:
		shell.ui.save_preference("text_scale",scale_value)
		shell.open_network_workshop("ticket")
		await frames()
		check(rig.monitor.viewport.size==Vector2i(1600,1200),"Mission actual VR viewport")
		suffix = "mission-vr-%d" % roundi(scale_value*100)
		await capture("mission-ticket",rig.monitor.viewport)
		shell.open_service_editor()
		await frames()
		shell.code_editor.editor.grab_focus()
		await frames()
		await capture("mission-editor-keyboard",rig.monitor.viewport)
		shell.open_network_workshop("customer")
		await frames()
		await capture("mission-dialog",rig.monitor.viewport)
	await use_button("Odevzdat servisní misi",1)
	check(service.session.result.passed,"Full synthetic XR mission with both rays")
	await capture("mission-result",rig.monitor.viewport)
	rig.deactivate()
	shell.vr_active = false
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.queue_free()
	await frames()
	print("SERVICE MISSIONS UI: %d checks, %d failures; six PC mode playthroughs and synthetic XR" % [checks,failures])
	quit(1 if failures else 0)
