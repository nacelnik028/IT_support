extends "res://tests/pause_repair.gd"

var m

func choose(id: String, hand: int = -1):
	var choices=m.choices().filter(func(c): return c.id==id)
	check(not choices.is_empty(),"Sémantická volba existuje: "+id)
	if choices.is_empty(): return
	var revision=m.revision
	var b=null
	for candidate in shell.english_dialog.buttons:
		if candidate.text.ends_with(choices[0].text): b=candidate; break
	await create_timer(0.23).timeout; await click(b,hand)
	check(m.revision==revision+1,"Skutečný klik zaznamená právě jednu volbu "+id)

func model_choice(id: String):
	check(m.act(id,m.revision),"Modelový přípravný krok "+id)

func ask(topic: String):
	check(m.open_questions(m.revision,m.Questions.TOPICS.find(topic)/3),"Otevřít dotaz "+topic)
	model_choice("q_"+topic); model_choice("understood")

func complete_ui(hand: int):
	for topic in ["options","included"]:
		await click(button("Zeptat se na nabídku…"),hand)
		for page in 3:
			if m.choices().any(func(c): return c.id=="q_"+topic): break
			await choose("questions_next",hand)
		await choose("q_"+topic,hand); await choose("understood",hand)
	for id in ["order_alt","product_standard","time_15:00","confirm"]: await choose(id,hand)
	var run_id=m.session.run_id
	shell.world.player.position=Vector3(10,0.02,8.7); shell.open_english("terminal"); await frames()
	await click(button("Přiložit CVIČNOU KARTU — zaplatit "+m.money(m.total())),hand)
	check(m.session.paid and m.session.payments==1,"Skutečné UI zaplatí právě jednou v "+m.session.mode)
	shell.world.player.position=Vector3(12,0.02,8.8); shell.open_english("tickets"); await frames(); await choose("thanks",hand)
	shell.world.player.position=Vector3(17,0.02,16.6); shell.open_english("gate"); await frames(); await click(button("Předložit vstupenku z peněženky"),hand)
	check(m.session.completed and m.session.run_id==run_id and m.session.result.score==100,"Celé UI dokončí stejnou relaci ve všech režimech")
	check(m.goal_status().all(func(goal): return goal.met),"Výsledek potvrzuje jen skutečně splněné cíle")
	await capture("london-complete-"+m.session.mode,rig.monitor.viewport if hand>=0 else null)

func exercise(hand: int = -1):
	var p=shell.world.player
	for mode in ["learn","practice","exam"]:
		var results_before=m.progress.results.duplicate(true)
		m.cancel(); m.start("LON01",mode,0); p.position=Vector3(12,0.02,8.8); shell.open_english("tickets"); await frames()
		check(m.current_step()!="" and m.goal_status().size()==7,"Postup vychází z konkrétního scénáře")
		await click(button("Celé zadání / podmínky"),hand)
		check(shell.english_dialog.find_children("*","Label",true,false).any(func(n): return n.visible and n.text==m.task()),"Úplné parametry jsou dostupné i ve zkoušce")
		await click(button("Celé zadání / podmínky"),hand)
		var replies=shell.english_dialog.find_child("PlayerReplies",true,false)
		check(replies.get_children().filter(func(n): return n is Button).size()==m.choices().size(),"Odpovědi jsou souvislá skupina bez audia")
		check(replies.find_children("*","HBoxContainer",true,false).is_empty(),"Poslech nerozděluje odpovědi")
		await choose("child",hand)
		check(m.session.cart.adult==0 and m.session.cart.child==1,"Chybná zdvořilá volba se neopraví automaticky")
		check(m.session.errors.size()==1 and m.session.errors[0].language_ok,"Chyba je věcná, ne jazyková")
		if mode=="learn": check("počet" in m.visible_feedback() and "oprav" in m.visible_feedback(),"Výuka vysvětlí chybu i pokračování")
		elif mode=="practice": check(m.visible_feedback()=="! Zkontroluj volbu podle zadání.","Procvičování má stručnou odezvu")
		else: check(m.visible_feedback().begins_with("• Volba zaznamenána") and not "chyba" in m.visible_feedback(),"Zkouška neodhalí správnost")
		await capture("london-dialog-"+mode,rig.monitor.viewport if hand>=0 else null)
		await click(button("Ukončit a vyhodnotit zkoušku" if mode=="exam" else "Zhodnotit dosavadní pokus"),hand)
		check(not m.session.completed and m.attempt_score()<100,"Nesplněný pokus není dokončení ani plné skóre")
		check(shell.english_dialog.find_children("*","Label",true,false).any(func(n): return "NESPLNĚNO" in n.text),"Výsledek obsahuje textový stav")
		await capture("london-result-"+mode,rig.monitor.viewport if hand>=0 else null)
		if mode=="exam":
			check(m.session.exam_ended and not m.act("product_standard",m.revision),"Vyhodnocená zkouška neumožní pokračovat s odhalenými odpověďmi")
			check(not m.progress.attempts[-1].passed and m.progress.results==results_before,"Neúspěšný výsledek neudělí dokončení")
		else:
			await click(button("Pokračovat ve stejné situaci"),hand); check(m.session.cart.child==1,"Návrat zachová skutečnou objednávku")
		await click(button("Opakovat situaci") if mode=="exam" else button("Zhodnotit dosavadní pokus"),hand)
		if mode!="exam": await click(button("Opakovat situaci"),hand)
		check(m.session.cart.adult==0 and m.session.cart.child==0 and m.session.errors.is_empty(),"Výslovné opakování vytvoří nový pokus")
		if suffix in ["1280-100","vr-100"]: await complete_ui(hand)

func walk_route(destination: String):
	var nav=shell.london_navigation; var p=shell.world.player
	var names={"tickets":"Ukázat cestu k Samovi","info":"Ukázat cestu k Alexovi","terminal":"Ukázat cestu k terminálu","gate":"Ukázat cestu ke kontrole","tower":"Ukázat cestu k věži přes most"}
	shell.open_english("info" if destination in ["info","tower"] else "tickets"); await frames(); await click(button(names[destination])); await frames()
	check(nav.target==destination and not nav.route.is_empty(),"Skutečná trasa k "+destination)
	check(shell.mode=="world" and "m po cestě" in shell.direction.text,"Tlačítko zavře panel a ukáže trvalý cíl se vzdáleností")
	await capture("london-route-"+destination)
	var run_id=m.session.run_id; var visited=[]
	for tick in 2200:
		if shell.mode=="pause":
			await click(button("Pokračovat")); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		nav.update()
		if nav.arrived or nav.target=="": break
		var point=nav.route[0]; var offset=point-p.global_position; offset.y=0
		p.rotation.y=atan2(-offset.x,-offset.z); p.camera.rotation.x=0
		Input.action_press("walk_forward",minf(1,offset.length()*3))
		visited.append(p.global_position)
		await physics_frame
	Input.action_release("walk_forward"); await frames()
	check(nav.arrived and not is_instance_valid(nav.marker),"Příchod odstraní prostorovou značku "+destination)
	check(m.session.run_id==run_id and shell.world.english_room.near(destination),"Dojití zachová relaci a fyzický dosah")
	for point in visited:
		check(shell.world.english_room.walkable_point(point),"Trasa nepřejde řeku mimo most")
	await capture("london-navigation-"+destination)
	var ids={"tickets":"LONDON-TICKETS","info":"LONDON-INFO","terminal":"LONDON-TERMINAL","gate":"LONDON-GATE","tower":"LONDON-TOWER"}
	p.camera.look_at(shell.world.devices[ids[destination]].global_position); p.poll_target()
	check(p.target==shell.world.devices[ids[destination]],"Skutečný raycast cíle "+destination)
	var e=InputEventKey.new(); e.keycode=KEY_E; e.physical_keycode=KEY_E; e.pressed=true; root.push_input(e,true); e=e.duplicate(); e.pressed=false; root.push_input(e,true); await frames()
	check(shell.mode=="english" and nav.target=="" and m.session.run_id==run_id,"Interakce pokračuje ve stejné relaci a uklidí navigaci")

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	m=shell.ui.game.english; m.progress.intro_seen=true
	shell.ui.game.start_mission(0)
	var campaign=shell.ui.game.snapshot().duplicate(true)
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for text_scale in [1.0,1.3]:
			suffix="%d-%d" % [resolution.x,roundi(text_scale*100)]
			shell.ui.apply_display_settings(resolution,false); shell.ui.save_preference("text_scale",text_scale); shell.enter_world("English in London"); await frames(); await exercise()
	# Physical navigation follows every waypoint with actual CharacterBody input.
	shell.ui.apply_display_settings(Vector2i(1280,720),false); shell.ui.save_preference("text_scale",1.0); suffix="walk"
	m.cancel(); m.start("LON01","learn",0); shell.world.player.position=Vector3(5,0.02,8.5); shell.return_to_world(); await frames()
	await walk_route("tickets")
	ask("options"); ask("included")
	for id in ["order","product_standard","time_15:00","confirm"]: model_choice(id)
	await walk_route("terminal"); await click(button("Přiložit CVIČNOU KARTU — zaplatit "+m.money(m.total()))); await choose("thanks")
	await walk_route("gate"); await click(button("Předložit vstupenku z peněženky")); check(m.session.completed,"Pěší nákup skutečně dokončený u kontroly")
	m.cancel(); m.start("LON06","learn",0); await walk_route("info"); model_choice("directions"); ask("repeat"); model_choice("route")
	await walk_route("tower"); check(m.session.completed,"Fyzický příchod a interakce skutečně dokončí cestu")
	m.cancel(); m.start("LON01","learn",0); shell.return_to_world(); shell.london_navigation.start("tickets"); await frames()
	check(shell.london_navigation.target=="tickets","Před změnou situace skutečně existuje aktivní značka")
	m.cancel(); m.start("LON06","practice",0); shell.update_guidance(); check(shell.london_navigation.target=="","Změna situace uklidí starou navigaci")
	shell.london_navigation.start("info"); m.cancel(); shell.update_guidance(); check(shell.london_navigation.target=="","Zrušení situace uklidí navigaci")
	m.start("LON06","exam",0); shell.london_navigation.start("info"); check(shell.london_navigation.target=="info","Zkouška má fyzickou navigaci")
	m.review_attempt(); shell.update_guidance(); check(shell.london_navigation.target=="","Ukončení zkoušky uklidí navigaci")
	shell.enter_world("Hlavní serverovna")
	var restored=shell.ui.game.snapshot().duplicate(true)
	restored.state.world.player=campaign.state.world.player
	check(restored==campaign,"Londýn zachoval odloženou kampaň kromě aktuální fyzické pozice")
	shell.ui.apply_display_settings(Vector2i(1600,900),false)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; shell.xr_rig=rig; shell.world.player.add_child(rig)
	var head=XRPositionalTracker.new(); head.name="head"; head.type=XRServer.TRACKER_HEAD; head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(head); trackers.append(head)
	for name_value in ["left_hand","right_hand"]:
		var tracker=XRControllerTracker.new(); tracker.name=name_value; tracker.type=XRServer.TRACKER_CONTROLLER; tracker.set_input("primary",Vector2.ZERO); tracker.set_input("trigger_click",false); tracker.set_pose("aim",Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(tracker); trackers.append(tracker)
	shell.vr_active=true; rig.activate(false); await frames()
	for text_scale in [1.0,1.3]:
		shell.ui.save_preference("text_scale",text_scale); suffix="vr-%d" % roundi(text_scale*100)
		for hand in [0,1]: shell.enter_world("English in London"); await frames(); await exercise(hand)
	rig.deactivate(); shell.vr_active=false
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.queue_free(); await frames(); print("LONDON REPAIR: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
