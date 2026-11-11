extends "res://tests/network_lab.gd"

const Workshop = preload("res://scripts/network_lab/WorkshopSession.gd")

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
			session.edit("dns",session.network.WEB)
			session.edit("flush")
			session.causes = {"vlan":true,"dns":true}
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
	await click(button("DNS A / 203.0.113.20"))
	await click(button("Obnovit DNS cache"))
	for title in ["Obnovit a změřit DHCP","Změřit linku","Změřit DNS","Změřit TCP 443","Otevřít HTTPS","Změřit tiskárnu","Změřit PC 02"]: await click(button(title))
	await click(button("Aktuální ticket"))
	await click(button("○ Nesprávná VLAN"))
	await click(button("○ Starý DNS záznam"))
	await click(button("Ověřit řešení"))
	check(s.result.passed,"Závěrečný ticket opraven s důkazy i kontrolními zařízeními")
	await click(button("Odevzdat ticket"))
	check(s.attempts.size()==1,"Samostatná dílenská historie")
	await capture("review")
	await escape()
	await walk_to(Vector3(8,0.02,-30.4))
	await walk_to(Vector3(8,0.02,-27.5))
	check(not shell.world.network_room.workshop.in_workshop and s.submitted,"Návrat drží dílenský pokus")
	await walk_to(Vector3(6,0.02,-27.5))
	await walk_to(Vector3(4,0.02,-24))
	await walk_to(Vector3(4,0.02,-14))
	check(game.suspended_campaign==campaign and s.task.is_empty(),"Odchod z pavilonu ukončí pouze dočasný pokus")
	shell.enter_world("Hlavní serverovna")
	check(game.sim.state.hosts["PVE-01"].hostname=="workshop-protected","Kampaň obnovena po dokončeném ticketu H")
	var saved := Saves.load_game()
	check(Saves.rules().valid(saved) and saved.network_workshop.size()==1,"Validní oddělená historie na disku")
	var restored = Game.new()
	check(restored.network_workshop.attempts.size()==1 and restored.network_workshop.task.is_empty(),"Restart zachová jen odevzdané výsledky")
	shell.queue_free()
	await frames()
	print("NETWORK WORKSHOP: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
