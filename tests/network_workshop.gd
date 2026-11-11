extends "res://tests/network_lab.gd"

const Workshop = preload("res://scripts/network_lab/WorkshopSession.gd")

func differences(expected, actual, path_value := "") -> Array:
	var changes: Array = []
	# JSON may round the last binary digit of a world coordinate. Keep strict
	# values for gameplay fields while allowing <1e-12 on numeric roundtrips.
	if typeof(expected) in [TYPE_FLOAT,TYPE_INT] and typeof(actual) in [TYPE_FLOAT,TYPE_INT]:
		if absf(float(expected)-float(actual))<=0.000000000001: return changes
	if expected is Dictionary and actual is Dictionary:
		for key in expected:
			if not actual.has(key): changes.append(path_value+str(key)+" missing")
			else: changes.append_array(differences(expected[key],actual[key],path_value+str(key)+"."))
		for key in actual:
			if not expected.has(key): changes.append(path_value+str(key)+" added")
	elif expected!=actual: changes.append(path_value+str(expected)+" → "+str(actual))
	return changes

func click(b, hand: int = -1):
	if b==null: return
	# Wait for deferred focus/layout after a rebuilt diagnostic page, then use
	# the real pointer/trigger helper. Focus also scrolls the full hit target.
	await frames(3)
	if not is_instance_valid(b) or not b.is_inside_tree():
		check(false,"Ovládací prvek zůstal dostupný do kliku")
		return
	b.grab_focus()
	await frames(3)
	var activation := {"pressed":false}
	b.pressed.connect(func(): activation.pressed = true,CONNECT_ONE_SHOT)
	if hand>=0:
		await super.click(b,hand)
	else:
		var viewport = b.get_viewport()
		var parent = b.get_parent()
		while parent!=null:
			if parent is ScrollContainer: parent.ensure_control_visible(b)
			parent = parent.get_parent()
		await frames(4)
		var at: Vector2 = b.get_global_rect().get_center()
		var title: String = b.text
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var move := InputEventMouseMotion.new()
		move.position = at
		viewport.push_input(move,true)
		await frames(2)
		var hovered = viewport.gui_get_hovered_control()
		check(hovered==b,"Skutečný kurzor zasahuje tlačítko "+title+" / "+str(hovered))
		for down in [true,false]:
			var event := InputEventMouseButton.new()
			event.position = at
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = down
			event.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
			viewport.push_input(event,true)
			await frames(2)
		await frames()
		check(activation.pressed,"Skutečný klik aktivoval "+title)

func aim_pc(id: String):
	if shell.mode=="pause":
		print("WORKSHOP TEST: continuing after desktop focus loss")
		shell.return_to_world()
	shell.world.player.camera.rotation.y = 0
	shell.world.player.camera.rotation.z = 0
	await super.aim_pc(id)

func walk_to(point: Vector3):
	var player = shell.world.player
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for step in 360:
		if shell.mode=="pause":
			print("WORKSHOP TEST: continuing after desktop focus loss during walk")
			shell.return_to_world()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var difference: Vector3 = point-player.position
		difference.y = 0
		if difference.length()<0.14: break
		player.rotation.y = atan2(-difference.x,-difference.z)
		Input.action_press("walk_forward",minf(1,difference.length()*3))
		Input.action_press("walk_fast")
		await physics_frame
	Input.action_release("walk_forward")
	Input.action_release("walk_fast")
	await frames()
	check(Vector2(player.position.x-point.x,player.position.z-point.z).length()<0.4,"Fyzická chůze "+str(point)+" → "+str(player.position)+" / "+shell.mode)

func measure_goals(session):
	if session.network.lease.is_empty(): session.measure("dhcp")
	for key in session.task.goals: session.measure(key)

func prepare(session, id: String, mode_value := "practice"):
	session.mode = mode_value
	session.start(id)
	for key in session.task.before: session.measure(key)

func repair(session):
	match session.task.id:
		"A":
			session.select_cable("pc04")
			session.connect_port(6)
		"B": session.vlan(4,10)
		"C": session.edit("pool",true)
		"D": session.edit("arp")
		"E": session.edit("flush")
		"F": session.edit("tcp",true)
		"G": session.edit("ap","center")
		"H":
			session.vlan(4,10)
			session.measure("dhcp")
			session.measure("dns")
			session.edit("dns",session.network.WEB)
			session.edit("flush")
			session.causes = {"vlan":true,"dns":true}
			session.evidence_summary = {"dhcp":true,"services":true}
	measure_goals(session)

func model_checks():
	var s = Workshop.new()
	check(s.catalog.tasks.size()==8,"Osm stabilních datových ticketů")
	for mode_value in ["learn","practice","exam"]:
		for id in ["A","B","C","D","E","F","G","H"]:
			prepare(s,id,mode_value)
			check(not s.assessment().passed,"Neopravený ticket neprojde "+id+mode_value)
			s.hint()
			check(s.hints==(0 if mode_value=="exam" else 1),"Zkouška bez nápovědy "+id)
			repair(s)
			check(s.assessment().passed,"Referenční oprava "+id+mode_value+str(s.assessment()))
			var count: int = s.attempts.size()
			s.submit()
			check(s.submitted and s.attempts.size()==count+1 and s.result.passed,"Odevzdání "+id)
			var state: Dictionary = s.network.snapshot()
			s.submit()
			s.edit("tcp",false)
			check(s.attempts.size()==count+1 and s.network.snapshot()==state,"Jednou zapsaný uzavřený pokus "+id)
	for id in ["A","B","C","D","E","F","G","H"]:
		prepare(s,id)
		match id:
			"A":
				s.select_cable("pc04")
				s.connect_port(8)
			"B":
				for port in range(3,9): s.vlan(port,10)
			"C": s.edit("static")
			"D": s.edit("flush")
			"E": s.edit("dns",s.network.WEB)
			"F": s.edit("management",true)
			"G": s.edit("ap","front")
			"H": s.vlan(4,10)
		measure_goals(s)
		check(not s.assessment().passed,"Přesvědčivá chybná zkratka odmítnuta "+id)
	prepare(s,"A")
	var previous: Dictionary = s.network.ports.duplicate()
	s.select_cable("pc04")
	s.connect_port(3)
	check(s.network.ports==previous and s.network.cable=="pc04" and s.network.last_message.contains("obsazený"),"Obsazený port zachová kabel i předchozí trasu")
	s.connect_port(6)
	s.undo()
	check(s.network.ports==previous and s.network.cable=="","Krok zpět vrátí trasu a odloží konektor")
	prepare(s,"E")
	s.mode = "learn"
	var state: Dictionary = s.network.snapshot()
	s.start_demo()
	for step in 5: s.demo_next()
	s.demo = false
	check(s.network.snapshot()==state and s.example.web_test(),"Ukázka izoluje všechny zásahy a měření")
	repair(s)
	s.verify()
	s.edit("dns","203.0.113.19")
	check(s.stale() and not s.network.fresh("https"),"Změna označí důkaz i ověření za zastaralé")
	prepare(s,"B")
	s.select_cable("pc04")
	s.connect_port(6)
	measure_goals(s)
	check(s.assessment().passed,"Alternativní řešení B / volný port ve VLAN 10")
	s.mode = "free"
	s.start("")
	var count: int = s.attempts.size()
	s.submit()
	check(s.attempts.size()==count,"Volný trénink neplní hodnocenou historii")
	var unchanged: Dictionary = s.network.snapshot()
	s.vlan(99,999)
	s.edit("pool","neplatné")
	check(s.network.ports==unchanged.ports and s.network.vlans==unchanged.vlans and s.network.dhcp_pool==unchanged.dhcp_pool,"Neplatná konfigurace zachová původní síť")
	prepare(s,"H")
	repair(s)
	s.evidence_summary = {"led_only":true}
	check(not s.assessment().passed,"Závěrečný ticket vyžaduje volbu skutečných důkazů, samotná LED nestačí")
	prepare(s,"D")
	repair(s)
	var matching_reply := false
	for frame in s.network.capture:
		if frame.title=="ARP Reply" and frame.application.contains(s.network.gateway_mac):
			matching_reply = frame.frame.begins_with(s.network.gateway_mac)
	check(matching_reply and s.network.learned[10].has(s.network.gateway_mac),"Nová MAC brány souhlasí v ARP payloadu, ethernetovém rámci i MAC tabulce")
	s.network.probe("tcp")
	var syn: Dictionary = s.network.capture.filter(func(frame): return frame.title=="TCP SYN")[-1]
	check(syn.frame.contains(s.network.gateway_mac) and syn.path==["pc04","switch","router"],"TCP po obnově ARP používá novou MAC a známý port brány bez floodingu")

func safety_checks(game):
	var s = game.network_workshop
	prepare(s,"F")
	repair(s)
	var count: int = s.attempts.size()
	Saves.path_override = "user://missing-workshop-"+str(OS.get_process_id())+"/save.json"
	s.submit()
	check(game.unsaved and game.last_save_error!=OK and s.attempts.size()==count+1,"Skutečné selhání zápisu má viditelný neuložený stav")
	s.submit()
	check(s.attempts.size()==count+1,"Opakování neúspěšného zápisu neduplikuje ticket")
	Saves.path_override = save_path
	check(game.save()==OK and not game.unsaved and Saves.load_game().network_workshop.size()==count+1,"Bezpečné opakování uloží právě jeden výsledek")
	var saved := Saves.load_game()
	saved.erase("network_workshop")
	var f := FileAccess.open(save_path,FileAccess.WRITE)
	f.store_string(JSON.stringify(saved))
	f.close()
	var old = Game.new()
	check(old.network_workshop.attempts.is_empty() and old.network_lab.attempts==game.network_lab.attempts,"Starší profil bez nové větve se načte s prázdnou dílnou")
	game.save()
	var invalid := Saves.load_game()
	invalid.network_workshop[0].proof = "poškozeno"
	check(not Saves.rules().valid(invalid),"Poškozený důkaz neprojde validací")

func physical_chain():
	var s = shell.ui.game.network_workshop
	prepare(s,"A")
	shell.return_to_world()
	await walk_to(Vector3(2,0.02,-30.2))
	await walk_to(Vector3(2,0.02,-29.7))
	await walk_to(Vector3(-2.35,0.02,-29.7))
	await walk_to(Vector3(-2.35,0.02,-33.4))
	await aim_pc("work:socket_pc04")
	check(s.network.cable=="pc04","Zásuvka vybere kabel správné trasy Z04 / PP04")
	await walk_to(Vector3(-2.35,0.02,-29.7))
	await walk_to(Vector3(2,0.02,-29.7))
	await walk_to(Vector3(1.6,0.02,-31.2))
	var player = shell.world.player
	var patch = shell.world.network_room.targets["work:patch_pc04"]
	player.camera.look_at(patch.global_position)
	player.poll_target()
	check(player.target==patch,"Dohledatelný správný patch port PP04 z pracovní uličky")
	await walk_to(Vector3(1.6,0.02,-31.92))
	await aim_pc("work:6")
	check(s.network.ports.pc04==6 and s.network.ports.pc02==3,"PC fyzicky přepojí správnou trasu bez zásahu do PC 02")
	await walk_to(Vector3(2,0.02,-30.2))
	await walk_to(Vector3(5.7,0.02,-30.2))

func door_safety():
	var w = shell.world.network_room.workshop
	shell.return_to_world()
	# Both controls use the same action; closing waits for the entire sweep.
	shell.world.player.position = Vector3(8,0.02,-30.4)
	w.opened = false
	for frame in 12: await physics_frame
	check(absf(w.angle+PI/2)<0.01,"Zavření počká, když hráč stojí v dráze křídla")
	w.toggle()
	check(w.opened,"Opětovné otevření během zavírání")
	shell.world.player.position = Vector3(9.7,0.02,-30.6)
	await aim_pc("work:door_-1")
	for frame in 85: await physics_frame
	check(absf(w.angle)<0.01,"Vratný ovladač zavře dveře po uvolnění dráhy")
	await aim_pc("work:door_-1")
	for frame in 85: await physics_frame
	check(absf(w.angle+PI/2)<0.01,"Vratný ovladač otevře celý průchozí profil")
	await walk_to(Vector3(9.7,0.02,-32.1))
	await walk_to(Vector3(8,0.02,-32.1))
	await walk_to(Vector3(8,0.02,-30.4))
	await walk_to(Vector3(5.7,0.02,-30.2))

func ui_all_tickets():
	var s = shell.ui.game.network_workshop
	for id in (["D"] if "--ticket-D" in OS.get_cmdline_user_args() else ["A","B","C","D","E","F","G"]):
		shell.open_network_workshop("home")
		await frames()
		await click(button(id+" / "+s.definition(id).title))
		check(s.task.get("id")==id,"Výslovný výběr ticketu "+id)
		await click(button("Změřit"))
		for key in s.task.before:
			var names := {"link":"Změřit linku","dhcp":"Obnovit a změřit DHCP","gateway":"Změřit bránu","arp":"Porovnat ARP","dns":"Změřit DNS","tcp":"Změřit TCP 443","near":"Změřit W1","far":"Změřit W2"}
			await click(button(names[key]))
		match id:
			"A":
				await click(button("Konektor / PC 04"))
				await click(button("SW 06 / VLAN 10"))
			"B": await click(button("Port 04 → VLAN 10"))
			"C": await click(button("DHCP / uvolnit rozsah"))
			"D": await click(button("Smazat souseda 192.168.10.1"))
			"E": await click(button("Obnovit DNS cache"))
			"F": await click(button("HTTPS / spustit službu"))
			"G": await click(button("AP / středový úchyt"))
		if s.network.lease.is_empty(): await click(button("Obnovit a změřit DHCP"))
		var names := {"link":"Změřit linku","dhcp":"Obnovit a změřit DHCP","gateway":"Změřit bránu","arp":"Porovnat ARP","dns":"Změřit DNS","tcp":"Změřit TCP 443","near":"Změřit W1","far":"Změřit W2","https":"Otevřít HTTPS","control":"Změřit PC 02","printer":"Změřit tiskárnu"}
		for key in s.task.goals: await click(button(names[key]))
		await click(button("Ověřit řešení"))
		check(s.result.get("passed",false),"Celý ticket přes skutečné ovládací prvky "+id+str(s.result)+" / "+str(s.network.journal))
		await capture("ticket-"+id+"-review")
		await click(button("Odevzdat ticket"))

func graphics_matrix():
	var s = shell.ui.game.network_workshop
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for scale_value in [1.0,1.3]:
			suffix = "%d-%d" % [resolution.x,roundi(scale_value*100)]
			shell.ui.apply_display_settings(resolution,false)
			shell.ui.save_preference("text_scale",scale_value)
			await frames()
			for shot in [["portal",Vector3(4,0.02,-14),Vector3(4,2,-21)], ["classroom-rack",Vector3(2.25,0.02,-21),Vector3(0.65,1.65,-21)], ["terminal",Vector3(4,0.02,-24.7),Vector3(4,1.8,-28)], ["demonstrations",Vector3(6.8,0.02,-22),Vector3(9,1.5,-23)], ["workshop-door",Vector3(7.6,0.02,-27),Vector3(8,2.5,-29)], ["workshop-rack",Vector3(2.1,0.02,-31.7),Vector3(0.65,1.6,-31.6)]]:
				shell.return_to_world()
				shell.world.player.position = shot[1]
				shell.world.player.camera.look_at(shot[2])
				await capture(shot[0])
			prepare(s,"H")
			repair(s)
			s.verify()
			shell.open_network_workshop("measure")
			await frames()
			check(root.get_visible_rect().encloses(button("Zpět do 3D  [Esc]").get_global_rect()),"Základní akce se vejde do PC viewportu")
			await capture("workshop-diagnostics")
			shell.open_network_workshop("review")
			await capture("workshop-review")
			shell.return_to_world()
	shell.world.player.position = Vector3(5.7,0.02,-30.2)
	prepare(s,"F")
	repair(s)
	s.submit()

func xr_workshop():
	var s = shell.ui.game.network_workshop
	await prepare_xr()
	check(rig.can_teleport(Vector3(5.5,0,-34)) and not rig.can_teleport(Vector3(0,0,-31.6)) and not rig.can_teleport(Vector3(-1.1,0,-33.4)),"VR teleport respektuje rack, stoly a pracovní uličku dílny")
	check(rig.teleport_to(Vector3(5.7,0,-30.2)),"VR příchod k servisnímu stolu")
	shell.open_network_workshop("home")
	await frames()
	await click(button("A / PC 04 bez linky"),0)
	await click(button("Změřit"),1)
	await click(button("Změřit linku"),0)
	await escape()
	check(rig.teleport_to(Vector3(1.15,0,-33.4)),"VR teleport ke konektoru PC 04")
	await aim_xr("work:pc04",0)
	check(s.network.cable=="pc04","Levý paprsek uchopí dílenský kabel")
	check(rig.teleport_to(Vector3(1.6,0,-31.92)),"VR teleport k očíslovaným portům")
	await aim_xr("work:6",1)
	check(s.network.ports.pc04==6,"Pravý paprsek přepojí konkrétní sousední port")
	shell.open_network_workshop("measure")
	await frames()
	await click(button("Obnovit a změřit DHCP"),1)
	for title in ["Změřit linku","Změřit bránu","Změřit PC 02"]: await click(button(title),0)
	await click(button("Ověřit řešení"),1)
	check(s.result.passed,"VR oprava i nové důkazy jsou plně ovladatelné tlačítky")
	for scale_value in [1.0,1.3]:
		shell.ui.save_preference("text_scale",scale_value)
		suffix = "vr-1600x1200-%d" % roundi(scale_value*100)
		shell.open_network_workshop("measure")
		check(shell.overlay.get_viewport()==rig.monitor.viewport and rig.monitor.viewport.size==Vector2i(1600,1200),"Skutečný VR viewport dílny")
		await click(button("Aktuální ticket"),0)
		await click(button("Diagnostika"),1)
		await capture("workshop-vr-diagnostics",rig.monitor.viewport)
		await click(button("Rozbor"),0)
		await capture("workshop-vr-review",rig.monitor.viewport)
	await escape()
	check(rig.teleport_to(Vector3(4,0,-14)) and s.task.is_empty(),"Teleport z pavilonu ukončí dočasnou dílnu")
	rig.deactivate()
	shell.vr_active = false
	for tracker in trackers: XRServer.remove_tracker(tracker)

func remaining_boundaries():
	var game = shell.ui.game
	var s = game.network_workshop
	shell.enter_world("Hlavní serverovna")
	check(game.shifts.start("SHIFT-NET"),"Samostatná směna pro všechny hranice dílny")
	shell.enter_world("Hlavní serverovna")
	game.sim.state.hosts["PVE-01"].hostname = "workshop-boundary-shift"
	shell.world.player.position = Vector3(3.5,0.02,4.1)
	shell.store_pose()
	var state: Dictionary = game.sim.state.duplicate(true)
	var session: Dictionary = game.shifts.data.session.duplicate(true)
	shell.enter_world("Počítačové sítě")
	prepare(s,"H")
	repair(s)
	shell.pause_menu()
	await click(button("Kam jít"))
	await click(button("Serverovna"))
	check(s.task.is_empty() and game.session_kind=="shift" and game.sim.state==state and game.shifts.data.session==session,"Pauza obnoví přesný stav směny včetně polohy, zásahů a výsledků / "+str(differences(state,game.sim.state))+" / "+str(differences(session,game.shifts.data.session)))
	check(Vector2(shell.world.player.position.x-state.world.player.x,shell.world.player.position.z-state.world.player.z).length()<0.05,"Pauza obnoví také skutečnou polohu hráče")
	shell.enter_world("Počítačové sítě")
	prepare(s,"H")
	shell.pause_menu()
	await click(button("Uložit a hlavní menu"))
	check(shell.mode=="menu" and s.task.is_empty() and game.sim.state==state,"Menu obnoví přesnou směnu a ukončí dočasnou dílnu")
	shell.enter_world("Počítačové sítě")
	prepare(s,"A")
	return state

func run():
	capture_directory = "res://docs/ui-review/2026-11-11-network-workshop/after/"
	model_checks()
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await frames()
	shell.ui.save_preference("introduction_seen",true)
	shell.enter_world("Hlavní serverovna")
	shell.ui.game.start_mission(6)
	shell.ui.game.sim.state.hosts["PVE-01"].hostname = "workshop-protected"
	shell.enter_world("Počítačové sítě")
	var game = shell.ui.game
	var s = game.network_workshop
	var campaign: Dictionary = game.suspended_campaign.duplicate(true)
	game.network_lab.start(definition("cable"))
	var lesson: Dictionary = game.network_lab.network.ports.duplicate()
	await walk_to(Vector3(4,0.02,-24))
	await walk_to(Vector3(6.5,0.02,-27.5))
	await walk_to(Vector3(8,0.02,-27.5))
	shell.world.player.rotation.y = 0
	shell.world.player.camera.rotation.x = 0.2
	await capture("entry")
	await aim_pc("work:door_1")
	for tick in 85: await physics_frame
	check(shell.world.network_room.workshop.opened,"Skutečný ovladač otevře dílnu")
	await walk_to(Vector3(8,0.02,-30.4))
	check(shell.world.network_room.workshop.in_workshop and game.game_mode.is_network_lab(),"Práh dílny zachová pavilon a kampaň")
	await walk_to(Vector3(5.7,0.02,-30.2))
	await aim_pc("work:desk")
	await click(button("H / Závěrečná servisní směna"))
	check(s.task.id=="H" and not shell.world.player.enabled,"Ticket přes skutečné UI zastaví pohyb")
	await click(button("Změřit"))
	await click(button("Obnovit a změřit DHCP"))
	await click(button("Změřit DNS"))
	await capture("diagnostics-before")
	await click(button("Port 04 → VLAN 10"))
	await click(button("Obnovit a změřit DHCP"))
	await click(button("Změřit DNS"))
	await click(button("DNS A / 203.0.113.20"))
	await click(button("Obnovit DNS cache"))
	for title in ["Obnovit a změřit DHCP","Změřit linku","Změřit DNS","Změřit TCP 443","Otevřít HTTPS","Změřit tiskárnu","Změřit PC 02"]: await click(button(title))
	await click(button("Aktuální ticket"))
	await click(button("○ Nesprávná VLAN"))
	await click(button("○ Starý DNS záznam"))
	await click(button("○ Úplný DHCP pronájem"))
	await click(button("○ HTTPS, tiskárna a PC 02"))
	await click(button("Ověřit řešení"))
	check(s.result.passed,"Závěrečný ticket opraven s důkazy i kontrolními zařízeními")
	await click(button("Odevzdat ticket"))
	check(s.attempts.size()==1,"Samostatná dílenská historie")
	await capture("review")
	check(game.network_lab.task.get("id")=="cable" and game.network_lab.network.ports==lesson,"Dílna zachovala přesný učební pokus během návštěvy")
	await physical_chain()
	await door_safety()
	await ui_all_tickets()
	safety_checks(game)
	if DisplayServer.get_name()!="headless": await graphics_matrix()
	if shell.mode!="world": await escape()
	await walk_to(Vector3(8,0.02,-30.4))
	await walk_to(Vector3(8,0.02,-27.5))
	check(not shell.world.network_room.workshop.in_workshop and s.submitted and game.network_lab.network.ports==lesson,"Návrat drží dílenský i původní učební pokus")
	await walk_to(Vector3(6,0.02,-27.5))
	await walk_to(Vector3(4,0.02,-24))
	await walk_to(Vector3(4,0.02,-14))
	check(game.suspended_campaign==campaign and s.task.is_empty(),"Odchod z pavilonu ukončí pouze dočasný pokus")
	shell.enter_world("Hlavní serverovna")
	check(game.sim.state.hosts["PVE-01"].hostname=="workshop-protected","Kampaň obnovena po dokončeném ticketu H")
	var saved := Saves.load_game()
	check(Saves.rules().valid(saved) and saved.network_workshop.size()==s.attempts.size() and saved.network_workshop.size()>=9,"Validní oddělená historie na disku")
	var restored = Game.new()
	check(restored.network_workshop.attempts.size()==s.attempts.size() and restored.network_workshop.task.is_empty(),"Restart zachová jen odevzdané výsledky")
	shell.enter_world("Počítačové sítě")
	await xr_workshop()
	check(game.suspended_campaign==campaign,"VR zachová stejnou odloženou kampaň")
	var shift_state: Dictionary = await remaining_boundaries()
	shell.queue_free()
	await frames()
	var after_exit = Game.new()
	check(after_exit.network_workshop.task.is_empty() and after_exit.session_kind=="shift" and differences(shift_state,after_exit.sim.state).is_empty(),"Zánik scény a restart zachová přesnou směnu a odstraní dočasný pokus / "+str(differences(shift_state,after_exit.sim.state))+" kind="+after_exit.session_kind)
	print("NETWORK WORKSHOP: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
