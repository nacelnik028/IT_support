extends "res://tests/pause_repair.gd"

const Game = preload("res://scripts/core/GameManager.gd")
const Session = preload("res://scripts/network_lab/LabSession.gd")

func definition(id: String) -> Dictionary:
	for task in shell.ui.game.network_lab.catalog.tasks:
		if task.id==id: return task
	return {}

func start_task(id: String):
	shell.ui.game.network_lab.start(definition(id))
	shell.open_network_lab("task")
	await frames()

func plug(model, device: String, port: int):
	model.select_cable(device)
	model.connect_cable(port)

func complete_model(lab):
	match lab.task.id:
		"cable": plug(lab.network,"pc04",6)
		"vlan":
			lab.network.set_vlan(4,10)
			lab.network.renew()
		"journey":
			plug(lab.network,"pc04",6)
			plug(lab.network,"printer",5)
			lab.network.renew()
			lab.network.arp("printer",lab.network.IPS.printer,true)
			lab.network.arp("router",lab.network.WEB,true)
			lab.network.set_dns(lab.network.WEB)
		"sim":
			lab.network.move_sim(0)
			lab.network.move_sim(1)
	if lab.task.has("answer"):
		var answer = lab.task.answer
		for index in lab.answer.size():
			lab.set_answer(index,int(answer[index] if answer is Array else answer))

func catalog_checks():
	var lab := Session.new()
	var ids := {}
	var stations := {}
	var kinds := {}
	for task in lab.catalog.tasks:
		check(not ids.has(task.id),"Jedinečné ID "+task.id)
		ids[task.id] = true
		stations[int(task.station)] = true
		kinds[task.kind] = true
		check(not task.sources.is_empty(),"Úloha má zdroj "+task.id)
		for key in task.sources:
			var chapter: Dictionary = lab.catalog.chapters[key]
			check(not chapter.title.is_empty() and chapter.url.begins_with("https://app.notion.com/p/"),"Přímý zdroj "+task.id)
		for mode in lab.MODES:
			lab.mode = mode
			lab.start(task)
			var count: int = lab.attempts.size()
			if mode=="learn":
				var snapshot: Dictionary = lab.network.ports.duplicate()
				lab.start_demo()
				for step in lab.demo_limit(): lab.next_demo()
				check(lab.demo_step==lab.demo_limit() and not lab.demo_comment.is_empty() and lab.network.ports==snapshot,"Dokončitelná izolovaná ukázka "+task.id)
				lab.demo_step = -1
			check(lab.hint()==(mode!="exam"),"Dostupnost nápovědy "+task.id+" "+mode)
			if mode!="exam":
				check(not lab.verify().passed,"Nedokončené řešení neprojde "+task.id)
				check(lab.attempts.size()==count,"Chyba se nepřičte jako úspěch "+task.id)
			complete_model(lab)
			var result: Dictionary = lab.verify()
			check(result.passed and result.score==(100 if mode=="exam" else 85),"Správné řešení "+task.id+" "+mode+" "+str(result))
			var recent: Dictionary = lab.attempts[-1].duplicate()
			lab.verify()
			check(lab.attempts[-1]==recent and lab.attempts.size()==mini(count+1,100),"Výsledek pokusu se zapíše jednou "+task.id)
	check(ids.size()>=40 and stations.size()==6 and kinds.size()==5,"Rozšířený katalog a pět formátů")
	lab.mode = "exam"
	lab.start(definition("arp"))
	lab.set_answer(0,2)
	var failed_exam: Dictionary = lab.verify()
	lab.set_answer(0,1)
	check(not failed_exam.passed and failed_exam.score==0 and lab.locked() and lab.verify()==failed_exam,"Odevzdaná chybná zkouška je vyhodnocená a uzavřená")
	lab.start(definition("cable"))
	check(not lab.network.renew() and lab.network.capture.is_empty(),"Kabel: žádný DHCP provoz nedorazí na switch")
	lab.start(definition("vlan"))
	check(not lab.network.renew() and lab.network.link("pc04") and lab.network.capture.size()==1 and lab.network.capture[0].title=="DHCP Discover","VLAN: linka aktivní, DHCP pouze Discover")
	lab.start(definition("dns"))
	check(lab.network.dns_test()=="" and lab.network.last_message.ends_with("NXDOMAIN") and lab.network.tcp_test(),"DNS: TCP na známou IP projde")
	lab.start(definition("transport"))
	check(lab.network.dns_test()==lab.network.WEB and not lab.network.tcp_test(),"Transport: DNS správně, TCP selže")

func walk_to(point: Vector3):
	var player = shell.world.player
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for step in 330:
		var difference: Vector3 = point-player.position
		difference.y = 0
		if difference.length()<0.14: break
		player.rotation.y = atan2(-difference.x,-difference.z)
		Input.action_press("walk_forward",minf(1.0,difference.length()*3.0))
		Input.action_press("walk_fast")
		await physics_frame
	Input.action_release("walk_forward")
	Input.action_release("walk_fast")
	await frames()
	check(Vector2(player.position.x-point.x,player.position.z-point.z).length()<0.4,"Fyzická chůze "+str(point)+" → "+str(player.position))

func aim_pc(id: String):
	var target = shell.world.network_room.targets[id]
	var player = shell.world.player
	var direction: Vector3 = target.global_position-player.camera.global_position
	player.rotation.y = atan2(-direction.x,-direction.z)
	player.camera.rotation.x = atan2(direction.y,Vector2(direction.x,direction.z).length())
	player.poll_target()
	check(player.target==target,"PC zaměří "+id)
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	root.push_input(event,true)
	await frames()

func prepare_xr():
	rig = load("res://scenes/xr/XRPlayer.tscn").instantiate()
	rig.shell = shell
	shell.xr_rig = rig
	shell.world.player.add_child(rig)
	var head := XRPositionalTracker.new()
	head.name = "head"
	head.type = XRServer.TRACKER_HEAD
	head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	XRServer.add_tracker(head)
	trackers.append(head)
	for name_value in ["left_hand","right_hand"]:
		var tracker := XRControllerTracker.new()
		tracker.name = name_value
		tracker.type = XRServer.TRACKER_CONTROLLER
		tracker.set_input("primary",Vector2.ZERO)
		tracker.set_input("trigger_click",false)
		tracker.set_pose("aim",Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		XRServer.add_tracker(tracker)
		trackers.append(tracker)
	shell.vr_active = true
	rig.activate(false)
	await frames()

func aim_xr(id: String, hand_index: int):
	var hand: XRController3D = rig.left if hand_index==0 else rig.right
	var target = shell.world.network_room.targets[id]
	var position: Vector3 = rig.global_position+Vector3(0,1.35,0)
	var basis := Basis.looking_at(target.global_position-position)
	trackers[hand_index+1].set_pose("aim",rig.global_transform.affine_inverse()*Transform3D(basis,position),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	for tick in 2: await physics_frame
	await frames()
	check(rig.ray_hit(hand).get("collider")==target,"VR paprsek dosáhne na "+id)
	rig.pressed(hand,"trigger_click")
	rig.released(hand,"trigger_click")
	await frames()

func extra_stations():
	var lab = shell.ui.game.network_lab
	var model = lab.network
	await start_task("vlan")
	await click(button("Měření a nastavení"))
	await click(button("Obnovit DHCP"))
	check(model.last_message.contains("Discover bez Offer"),"Terminál ukáže chybu VLAN při zachované lince")
	await click(button("04 · VLAN 20"))
	await click(button("Nastavit VLAN 10"))
	await click(button("Obnovit DHCP"))
	await click(button("Úloha"))
	await click(button("Ověřit řešení"))
	check(lab.result.passed and lab.result.measurement.contains("VLAN 20") and lab.result.measurement.contains("VLAN 10"),"Oprava VLAN má měření před a po")
	await start_task("dora")
	await click(button("2 · Discover"))
	await click(button("↑ Posunout nahoru"))
	await click(button("4 · Offer"))
	await click(button("↑ Posunout nahoru"))
	await click(button("↑ Posunout nahoru"))
	await click(button("Ověřit řešení"))
	check(lab.result.passed,"DORA seřazena posunem bez psaní")
	lab.mode = "exam"
	await start_task("arp")
	var panel = shell.overlay.get_child(0)
	var shown: Array = panel.find_children("*","Label",true,false)
	check(not shown.any(func(label): return lab.task.why in label.text),"Zkouška neukazuje rozbor před odevzdáním")
	await click(button("192.168.10.1"))
	await click(button("Odevzdat zkoušku"))
	check(lab.result.passed and lab.locked() and lab.view=="review","Skutečná zkouška ARP zobrazí rozbor až po odevzdání")
	lab.mode = "practice"
	await start_task("access")
	await click(button("Měření a nastavení"))
	await click(button("DSL"))
	check(model.last_message.contains("synchronizováno"),"Stanoviště změří DSL")
	await click(button("IP notebooku"))
	check(model.last_message.contains("169.254.10.23"),"Stanoviště změří IP bezdrátového klienta")
	await click(button("Úloha"))
	await click(button("Přidělení IP pro WLAN"))
	await click(button("C"))
	await click(button("Ověřit řešení"))
	check(lab.result.passed,"Diagnóza DSL/WLAN vyžaduje oblast i důkaz")
	lab.mode = "learn"
	await start_task("roles")
	await click(button("Router · —"))
	check(lab.guide_targets()==["router"] and shell.world.network_room.targets.router.guide.visible,"Přiřazení zvýrazní konkrétní 3D prvek")

func run():
	capture_directory = "res://test-output/"
	suffix = "720p-130"
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await frames()
	var game = shell.ui.game
	var lab = game.network_lab
	var model = lab.network
	catalog_checks()
	shell.ui.apply_display_settings(Vector2i(1280,720),false)
	shell.ui.save_preference("text_scale",1.3)
	shell.ui.save_preference("introduction_seen",true)
	shell.enter_world("Hlavní serverovna")
	game.start_mission(6)
	game.sim.state.hosts["PVE-01"].hostname = "network-campaign"
	shell.pause_menu()
	await click(button("Kam jít"))
	await click(button("Rozcestník akademie"))
	var campaign: Dictionary = game.suspended_campaign.duplicate(true)
	check(not campaign.is_empty(),"Odložená kampaň v rozcestníku")
	await capture("network-hub")
	await walk_to(Vector3(4,0.02,-17.5))
	check(game.game_mode.is_network_lab() and lab.task.is_empty() and lab.attempts.is_empty(),"Fyzický vstup je neutrální")
	var p = shell.world.player
	p.rotation.y = 0
	p.camera.rotation.x = 0
	await capture("network-room")
	await walk_to(Vector3(4,0.02,-25.5))
	await aim_pc("terminal")
	check(shell.mode=="network_lab","Přemapovatelná interakce otevře skutečný terminál")
	await capture("network-home")
	await click(button("2. ročník"))
	if shell.mode!="network_lab" or lab.year!=2:
		check(false,"Po výběru ročníku: "+shell.mode+" / "+str(lab.year)+" / "+lab.view+" / "+str(shell.overlay.get_children()))
		quit(1)
		return
	await click(button("Procvičování"))
	await click(button("Od zásuvky až k webu"))
	check(lab.task.id=="journey","Výběr ročníku, režimu a úlohy přes UI")
	await capture("network-task")
	await click(button("Nápověda"))
	check(lab.hints==1,"Dobrovolná nápověda")
	await click(button("Ověřit řešení"))
	check(lab.view=="review","Vyhodnocení otevře čitelný rozbor")
	check(not lab.result.passed and lab.attempts.is_empty(),"Před opravou nelze získat výsledek")
	await click(button("Úloha"))
	await click(button("Jít k 3D konektorům"))
	await walk_to(Vector3(1.3,0.02,-22.2))
	await aim_pc("pc04")
	await walk_to(Vector3(1.65,0.02,-21.17))
	await aim_pc("5")
	check(model.link("pc04") and model.ports.pc04==5 and lab.stale(),"Skutečné zapojení obnoví linku a zneplatní ověření")
	await walk_to(Vector3(1.3,0.02,-25.94))
	await aim_pc("printer")
	await walk_to(Vector3(1.65,0.02,-21.4))
	await aim_pc("6")
	check(model.ports.printer==6 and model.ports.pc02==3,"Síť zapojena ve 3D")
	shell.open_current_task()
	await click(button("Měření a nastavení"))
	await click(button("Obnovit DHCP"))
	check(model.lease.ip==model.IPS.pc04 and model.capture[-1].title=="DHCP ACK","DHCP měření naplnilo konfiguraci")
	await click(button("ARP · tiskárna"))
	await click(button("ARP · vzdálený web"))
	await click(button("Změřit DNS"))
	check(model.last_message.ends_with("NXDOMAIN"),"Měření odlišilo DNS")
	await click(button("Změřit TCP na 443"))
	check(model.last_message.contains("navázáno"),"Známá IP má funkční TCP")
	await click(button("203.0.113.20"))
	await click(button("Otevřít HTTPS"))
	check(model.cache.size()==3 and model.last_message.contains("HTTP 200"),"DNS oprava a end-to-end web")
	await click(button("Analyzátor"))
	check(not model.learned[10].is_empty(),"Analyzátor zobrazuje skutečně naučené zdroje")
	await click(button("%02d    HTTPS odpověď" % model.capture.size()))
	await capture("network-capture")
	await click(button("Úloha"))
	await click(button("Ověřit řešení"))
	await click(button("Úloha"))
	await click(button("Ověřit řešení"))
	check(lab.result.passed and lab.result.measurement.contains("HTTP 200") and lab.attempts.size()==1,"Oprava doložena měřením a hodnocena jednou")
	await capture("network-verified")
	await click(button("Úloha"))
	await click(button("Resetovat pokus"))
	check(not model.link("pc04") and lab.result.is_empty() and lab.attempts.size()==1,"Reset pouze aktuálního cvičení")
	await extra_stations()
	await escape()
	await walk_to(Vector3(4,0.02,-20.5))
	await walk_to(Vector3(4,0.02,-14.0))
	check(game.game_mode.is_hub() and lab.task.is_empty() and game.suspended_campaign==campaign,"Fyzický odchod ruší pokus a zachová odloženou kampaň")
	await walk_to(Vector3(-6,0.02,-10.0))
	await walk_to(Vector3(-6,0.02,-5.4))
	check(game.current.id==7 and game.sim.state.hosts["PVE-01"].hostname=="network-campaign","Průchod 01 obnoví původní práci")
	check(game.shifts.start("SHIFT-NET"),"Připravená samostatná směna")
	game.sim.state.hosts["PVE-01"].hostname = "network-shift"
	game.save()
	shell.pause_menu()
	await click(button("Kam jít"))
	await click(button("Počítačové sítě"))
	check(game.game_mode.is_network_lab() and game.shifts.data.selected=="shift","Pauza vede do učebny a odloží směnu")
	lab.mode = "learn"
	await start_task("handover")
	await click(button("Komentovaná ukázka"))
	for step in 3: await click(button("Další krok"))
	check(lab.example.cell==1 and shell.world.network_room.handover.text.contains("PŘEDÁNO"),"GSM ukázka mění buňku ve skutečné scéně")
	await escape()
	await prepare_xr()
	var center := Vector3(4,0,-22)
	check(rig.can_teleport(center) and not rig.can_teleport(Vector3(0.18,0,-21.0)) and not rig.can_teleport(Vector3(4,0,-42)),"Teleport respektuje uličku, rack a rozšířené hranice pavilonu")
	check(rig.teleport_to(Vector3(4,0,-14)) and game.game_mode.is_hub(),"Syntetický teleport do hubu ruší ukázku")
	rig.left.global_transform = Transform3D(Basis().looking_at(Vector3(0,-0.28,-1)),Vector3(4,1.35,-14.5))
	rig.update_teleport()
	check(rig.teleport_valid and rig.teleport_point.z< -16,"Teleportovací oblouk projde prahem")
	check(rig.teleport_to(center) and game.game_mode.is_network_lab(),"Teleport do laboratoře")
	lab.mode = "practice"
	await start_task("cable")
	suffix = "vr-1600x1200-130"
	check(shell.overlay.get_viewport()==rig.monitor.viewport and rig.monitor.viewport.size==Vector2i(1600,1200),"Síťový panel v původním VR viewportu")
	await capture("network-task",rig.monitor.viewport)
	await click(button("Nápověda"),0)
	await click(button("Jít k 3D konektorům"),1)
	check(lab.hints==1 and shell.mode=="world","Oběma paprsky lze kliknout do panelu")
	check(rig.teleport_to(Vector3(1.3,0,-22.2)),"Teleport k pracovnímu stolu")
	await aim_xr("pc04",0)
	check(model.cable=="pc04","Levý trigger drží konektor")
	check(rig.teleport_to(Vector3(1.65,0,-21.17)),"Teleport před rack")
	await aim_xr("5",1)
	check(model.ports.pc04==5,"Pravý trigger zapojí port")
	shell.open_current_task()
	await click(button("Ověřit řešení"),1)
	check(lab.result.passed and lab.attempts.size()==6,"VR oprava funguje bez psaní")
	await start_task("sim")
	await click(button("Jít k telefonům A a B"),0)
	check(rig.teleport_to(Vector3(6.7,0,-26.95)),"Teleport k mobilnímu modelu")
	await aim_xr("sim_a",1)
	await aim_xr("sim_b",0)
	check(model.sim_slot==1,"Fyzická SIM byla přemístěna oběma paprsky")
	shell.open_current_task()
	await click(button("IMEI"),0)
	await click(button("Ověřit řešení"),1)
	check(lab.result.passed and lab.result.measurement.contains(model.IMSI),"Pokus ověřil přesun a identitu")
	rig.deactivate()
	shell.vr_active = false
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.enter_world("Hlavní serverovna")
	check(game.session_kind=="shift" and game.sim.state.hosts["PVE-01"].hostname=="network-shift","Pauza a VR zachovaly směnu")
	game.resume_campaign()
	check(game.sim.state.hosts["PVE-01"].hostname=="network-campaign","Odložená kampaň zůstala obnovitelná vedle směny")
	var saved := Saves.load_game()
	check(Saves.rules().valid(saved) and saved.network_lab.size()==7,"Výsledky se ukládají odděleně")
	var restored := Game.new()
	check(restored.network_lab.attempts.size()==7 and restored.network_lab.task.is_empty(),"Po restartu výsledky přetrvají a pokus je prázdný")
	saved.erase("network_lab")
	var file := FileAccess.open(save_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(saved))
	file.close()
	var old := Game.new()
	check(old.active and old.sim.state.hosts["PVE-01"].hostname=="network-campaign" and old.network_lab.attempts.is_empty(),"Starý save bez větve laboratoře se načte")
	shell.queue_free()
	await frames()
	print("NETWORK LAB: %d checks, %d failures; PC and synthetic XR" % [checks,failures])
	quit(1 if failures else 0)
