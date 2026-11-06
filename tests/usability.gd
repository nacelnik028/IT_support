extends "res://tests/pause_repair.gd"

const Continue=preload("res://scripts/ui/ContinuationPresentation.gd")
const Game=preload("res://scripts/core/GameManager.gd")

func hud_settle():
	await create_timer(0.3).timeout; await frames()

func menu():
	shell.ui.page="menu"; shell.ui.draw_ui(); shell.set_mode("menu"); await frames()

func verify_menu():
	for control in shell.ui.root_box.find_children("*","Button",true,false):
		check(control.get_viewport().get_visible_rect().encloses(control.get_global_rect()),"Základní nabídka bez ořezu: "+control.text)
	check(not shell.practical_intro.active,"Pouhé zobrazení nabídky nespustilo úvod")

func intro_roundtrip(hand: int = -1):
	var g=shell.ui.game
	var before={"session":g.snapshot(),"campaign":g.suspended_campaign.duplicate(true),"shift":g.shifts.data.duplicate(true),"work":g.work.data.duplicate(true),"code":g.programming.progress.duplicate(true),"xp":g.progress.xp,"sim":g.sim.state.duplicate(true)}
	var origin=shell.mode
	await click(shell.ui.ui_targets["menu:intro"],hand)
	check(shell.practical_intro.active and g.introduction_active,"Skutečný klik spustí dočasný úvod")
	shell.practical_intro.pause(); await click(button("Zrušit / přeskočit úvod"),hand)
	check(shell.mode==origin and not shell.practical_intro.active,"Zrušení vrátí původní nabídku")
	check(g.snapshot()==before.session and g.sim.state==before.sim and g.shifts.data==before.shift and g.work.data==before.work and g.programming.progress==before.code and g.progress.xp==before.xp,"Úvod zachová relace, koncepty, výsledky i XP")
	check(Saves.rules().valid(Saves.load_game()),"Po úvodu je save stále validní")

func hud_checks():
	var ui=shell.ui; var g=ui.game
	shell.enter_world("Hlavní serverovna"); shell.return_to_world()
	ui.save_preference("introduction_seen",false); await hud_settle()
	var training_size=shell.controls_label.text.length()
	ui.save_preference("introduction_seen",true); await hud_settle()
	check(shell.controls_label.text.length()<training_size/2 and shell.controls_plate.size.x<800,"Po zaučení je ovládání krátké a nemá celoplošný pruh")
	var p=shell.world.player; p.position=Vector3(7.5,0.02,1.65); p.camera.look_at(shell.world.devices["DOOR-CONTROL-OPS"].global_position); p.poll_target(); await hud_settle()
	check(p.target==shell.world.devices["DOOR-CONTROL-OPS"] and "Ovládat dveře" in shell.prompt.text,"Skutečný raycast zobrazí smysluplnou kontextovou akci")
	var keys=ui.display_settings.bindings.duplicate(); var remapped=keys.duplicate(); remapped.interact=KEY_G
	ui.save_preference("bindings",remapped); await hud_settle()
	check(shell.prompt.text.begins_with("G ·") and "G: interakce" in shell.controls_help_text(),"Kontext i nápověda respektují skutečnou předvolbu PC")
	ui.save_preference("bindings",keys)
	var help_event=InputEventKey.new(); help_event.keycode=KEY_F1; help_event.pressed=true; root.push_input(help_event,true); await frames()
	check(shell.mode=="pause" and shell.pause_page=="help" and not shell.hud.visible,"Ovládání je na vyžádání přes skutečnou klávesu")
	await escape(); check(shell.pause_page=="main","Esc z rychlé nápovědy vrátí pauzu"); shell.return_to_world()
	check(g.apply("physical_spare",{"spare":"SPARE-2T"}).ok,"Skutečný nesený díl pro HUD")
	await hud_settle(); check("Neseš:" in shell.status_label.text,"Nesený předmět zůstává vždy viditelný")
	g.apply("physical_return_spare",{})
	shell.world.move_door(true); await create_timer(0.8).timeout
	p.position=Vector3(9,0.02,3.5); await physics_frame
	check(not shell.world.toggle_door(),"Skutečné čidlo odmítne zavření obsazených dveří")
	p.camera.look_at(Vector3(9,2,-5)); p.poll_target(); shell.room_notice.text="Běžný tip"; shell.notice_time=5; await hud_settle()
	check("PRŮCHOD OBSAZENÝ" in shell.status_label.text,"Běžný tip ani změna zaměření nepřepíší blokovanou akci")
	Saves.path_override="user://missing-usability-"+str(OS.get_process_id())+"/save.json"; g.save(); await hud_settle()
	check("NEJSOU ULOŽENÉ" in shell.status_label.text,"Chyba zápisu zůstane čitelná vedle běžného tipu")
	var original=g.snapshot(); shell.practical_intro.start(); await frames()
	check(not shell.practical_intro.active and g.snapshot()==original,"Úvod při selhání zápisu nezmění rozpracovanou relaci")
	for window in ui.get_children():
		if window is AcceptDialog and window.visible: await click(window.get_ok_button())
	Saves.path_override=save_path; g.save(); shell.world.move_door(false); p.position=Vector3(7.5,0.02,1.65)
	for sign_node in shell.world.hub.find_children("PortalDirectory","Node3D",true,false):
		var labels=sign_node.find_children("*","Label3D",true,false)
		check(labels[0].font_size*labels[0].pixel_size>=0.16,"Názvy portálů mají čitelnou skutečnou výšku znaků")
	check(shell.world.find_children("*","Light3D",true,false).size()==34,"Orientace nepřidala žádná světla")

func run():
	capture_directory="res://docs/ui-review/2026-11-06-usability/after/"; DirAccess.make_dir_recursive_absolute(capture_directory)
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var ui=shell.ui; var g=ui.game
	check(Continue.available(g).is_empty() and ui.ui_targets["menu:resume"].disabled,"Nový profil nemá falešné pokračování")
	var bytes=FileAccess.get_file_as_bytes(save_path)
	ui.draw_ui(); ui.navigate("Pokračování"); await frames()
	check(not g.active and FileAccess.get_file_as_bytes(save_path)==bytes,"Prohlížení prázdného pokračování nezahájí ani neuloží misi")
	await escape(); check(ui.page=="menu" and shell.mode=="menu","Esc z pokračování vrátí menu")
	await click(ui.ui_targets["menu:skip_intro"])
	check(ui.display_settings.introduction_seen and not ui.ui_targets.has("menu:skip_intro") and not g.active and FileAccess.get_file_as_bytes(save_path)==bytes,"Přeskočení mění jen předvolbu, nikoli hráčovu práci")
	await intro_roundtrip()
	shell.enter_world("Hlavní serverovna"); g.start_mission(3)
	g.apply("management",{"hostname":"usability-campaign","ip":"192.168.10.10","gateway":"192.168.10.1","dns":"192.168.10.2"})
	await menu()
	check(Continue.available(g).size()==1 and not ui.ui_targets["menu:resume"].disabled,"Jeden rozpracovaný ticket nabízí pokračování")
	await click(ui.ui_targets["menu:resume"])
	check(g.current.id==4 and ui.page=="Pokračování","Otevření výběru neobnovuje jinou relaci")
	await click(ui.ui_targets["resume:campaign:"])
	check(shell.mode=="tasks" and g.sim.state.hosts["PVE-01"].hostname=="usability-campaign","Skutečný klik obnoví přesnou kampaň")
	shell.return_to_world(); g.shifts.start("SHIFT-NET"); g.sim.state.hosts["PVE-01"].hostname="usability-shift"; g.save()
	shell.enter_world("Trénink"); g.start_lesson(1002,"practice",false); g.sim.state.hosts["PVE-01"].hostname="usability-lesson"; g.save()
	shell.enter_world("Programming Academy"); g.programming.start("PY01","practice"); g.programming.edit("main.py","print('vlastní koncept')"); g.save()
	await menu()
	check(Continue.available(g).size()==4,"Přehled rozlišuje kampaň, směnu, IT výuku a kód")
	await intro_roundtrip()
	var persisted=Saves.load_game()
	var reloaded=Game.new()
	check(Continue.available(reloaded).size()==4,"Existující profil nabízí všechny čtyři práce také po restartu")
	check(not ui.ui_targets.has("menu:skip_intro"),"Existující profil není nucen do úvodu")
	reloaded=null
	for kind in ["shift","lesson","code","campaign"]:
		await menu(); await click(ui.ui_targets["menu:resume"])
		var target=""
		for key in ui.ui_targets:
			if key.begins_with("resume:"+kind+":"): target=key; break
		check(target!="","Dostupná konkrétní činnost "+kind)
		if target=="": continue
		await click(ui.ui_targets[target])
		if kind=="shift": check(g.session_kind=="shift" and g.sim.state.hosts["PVE-01"].hostname=="usability-shift","Směna obnoví vlastní infrastrukturu")
		elif kind=="lesson": check(g.session_kind=="lesson" and g.tutorial.session.mode=="practice" and g.sim.state.hosts["PVE-01"].hostname=="usability-lesson","Výuka obnoví vlastní režim a infrastrukturu")
		elif kind=="code": check(shell.mode=="coding" and shell.code_editor.editor.text=="print('vlastní koncept')" and g.programming.files["main.py"]=="print('vlastní koncept')" and g.programming.last_run.is_empty() and g.programming.last_result.is_empty(),"Koncept obnoví přesný kód v editoru bez běhu/hodnocení")
		else: check(g.session_kind=="campaign" and g.sim.state.hosts["PVE-01"].hostname=="usability-campaign","Přepínání zachovalo původní kampaň")
		if kind=="code":
			var key=g.programming.drafts.key(g.programming.draft_record())
			g.programming.start("PY02","practice"); shell.code_editor.load_current(); shell.code_editor.editor.text="print('druhý koncept')"; g.save()
			shell.open_app("Pokračování"); await frames(); await click(ui.ui_targets["resume:code:"+key])
			check(shell.code_editor.editor.text=="print('vlastní koncept')" and g.programming.current.id=="PY01","Obnova v již otevřené učebně obnoví i skutečný buffer editoru")
	for lesson_mode in ["learn","practice","exam"]:
		shell.enter_world("Trénink"); g.start_lesson(1002,lesson_mode,false)
		var snapshot=g.snapshot(); var tutorial=g.tutorial.session.duplicate(true); var campaign=g.suspended_campaign.duplicate(true); var shift=g.shifts.data.duplicate(true)
		var stored=FileAccess.get_file_as_bytes(save_path)
		ui.navigate("Pokračování"); await frames()
		check(g.snapshot()==snapshot and FileAccess.get_file_as_bytes(save_path)==stored,"Prohlížení pokračování nepřepíše živou výuku "+lesson_mode)
		shell.return_to_world()
		shell.practical_intro.start(); shell.practical_intro.finish(false)
		check(g.snapshot()==snapshot and g.tutorial.session==tutorial and g.suspended_campaign==campaign and g.shifts.data==shift,"Živá výuka "+lesson_mode+" i odložená kampaň/směna přežijí úvod")
	await hud_checks()
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for scale_value in [1.0,1.3]:
			ui.apply_display_settings(resolution,false); ui.save_preference("text_scale",scale_value); suffix="%d-%d" % [resolution.x,roundi(scale_value*100)]
			await menu(); verify_menu(); await capture("menu-multiple")
			shell.enter_world("Hlavní serverovna"); shell.world.player.position=Vector3(7.5,0.02,1.65); shell.world.player.camera.look_at(shell.world.devices["DOOR-CONTROL-OPS"].global_position); await hud_settle()
			check(not shell.context_plate.get_global_rect().intersects(shell.controls_plate.get_global_rect()),"Kontext nepřekrývá ovládání při každé velikosti")
			await capture("hud-context")
			shell.show_tasks(); await frames(); check(not shell.hud.visible,"HUD nepřekrývá zadání nebo dialog"); shell.return_to_world()
	ui.apply_display_settings(Vector2i(1600,900),false)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; shell.xr_rig=rig; shell.world.player.add_child(rig)
	var head=XRPositionalTracker.new(); head.name="head"; head.type=XRServer.TRACKER_HEAD; head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(head); trackers.append(head)
	for name_value in ["left_hand","right_hand"]:
		var tracker=XRControllerTracker.new(); tracker.name=name_value; tracker.type=XRServer.TRACKER_CONTROLLER; tracker.set_input("primary",Vector2.ZERO); tracker.set_input("trigger_click",false)
		tracker.set_pose("aim",Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(tracker); trackers.append(tracker)
	shell.vr_active=true; rig.activate(false); await frames()
	for text_value in [1.0,1.3]:
		ui.save_preference("text_scale",text_value); suffix="vr-%d" % roundi(text_value*100)
		for hand in [0,1]:
			await menu(); verify_menu(); await capture("menu-vr",rig.monitor.viewport)
			await click(ui.ui_targets["menu:resume"],hand)
			check(ui.page=="Pokračování","Oba VR paprsky otevřou skutečný výběr práce")
			var controller=rig.left if hand==0 else rig.right
			rig.pressed(controller,"by_button"); rig.released(controller,"by_button"); await frames()
			check(ui.page=="menu" and shell.mode=="menu","VR B/Y vrací z výběru práce do menu jako Esc")
			await click(ui.ui_targets["menu:resume"],hand)
			await click(ui.ui_targets["resume:campaign:"],hand)
			check(g.session_kind=="campaign" and g.sim.state.hosts["PVE-01"].hostname=="usability-campaign","Oba paprsky obnoví chráněnou kampaň")
			await menu(); await intro_roundtrip(hand)
			shell.enter_world("Hlavní serverovna"); var target=shell.world.devices["DOOR-CONTROL-OPS"]
			for index in [0,1]:
				var origin=Vector3(7.5,1.35,1.65) if index==hand else Vector3(7,1.3,1)
				var pose=Transform3D(Basis().looking_at(target.global_position-origin),origin) if index==hand else Transform3D(Basis(Vector3.UP,PI),origin)
				trackers[index+1].set_pose("aim",rig.global_transform.affine_inverse()*pose,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
			await hud_settle()
			check(shell.world.player.target==target and shell.prompt.text.begins_with("Trigger"),"Kontext funguje se skutečným zaměřením obou XR paprsků")
			check("Trigger" in rig.wrist.text and not "Stiskni E" in rig.wrist.text,"VR HUD používá odpovídající pokyny")
	rig.deactivate(); shell.vr_active=false
	for tracker in trackers: XRServer.remove_tracker(tracker)
	# Old schema2 profiles without the newer work/last-saved keys remain readable.
	for key in ["work","saved_at"]: persisted.erase(key)
	check(Saves.save_game(persisted,true)==OK,"Zpětně kompatibilní starý profil")
	var legacy=Game.new(); check(Continue.has_history(legacy) and not Continue.available(legacy).is_empty(),"Starý postup se nepovažuje za nový účet"); legacy=null
	shell.queue_free(); await frames()
	print("USABILITY: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
