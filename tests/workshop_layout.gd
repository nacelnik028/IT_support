extends "res://tests/network_workshop.gd"

const REVIEW_DIR = "res://docs/ui-review/2026-11-11-workshop-layout/"

func panel():
	return shell.overlay.get_child(0)

func identified(id: String):
	for b in panel().actions:
		if b.get_meta("workshop_id","")==id: return b
	check(false,"Stabilní identita ovládání "+id)
	return null

func key_press(key: Key):
	for down in [true,false]:
		var event := InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		event.pressed = down
		panel().get_viewport().push_input(event,true)
		await frames(2)

func ui_checks():
	var s = shell.ui.game.network_workshop
	s.mode = "practice"
	s.start("H")
	shell.open_network_workshop("ticket")
	await frames()
	check(s.causes.is_empty() and s.evidence_summary.is_empty(),"H nemá předvybrané příčiny ani důkazy")
	var snapshot: Dictionary = s.network.snapshot()
	for page in ["history","home","ticket","measure","repair","capture","review"]:
		await click(identified("nav:"+page))
	check(s.network.snapshot()==snapshot and s.task.id=="H" and s.mode=="practice" and s.result.is_empty() and s.attempts.is_empty(),"Prohlížení všech stránek neměří, nehodnotí a nemění síť")
	await click(identified("nav:measure"))
	await click(identified("device:printer"))
	for kind in ["link","gateway","dhcp","arp","printer","control","dns","tcp","https","near","far"]:
		await click(identified("probe:"+kind))
		var expected: String = "printer" if kind in ["link","gateway"] else "pc02" if kind=="control" else "pc04"
		check(s.network.measurements[kind].source==expected,"Skutečný zdroj měření "+kind)
		check(panel().probe_route(kind).begins_with("Wi-Fi klient" if kind in ["near","far"] else s.network.NAMES[expected]),"Viditelný zdroj souhlasí s modelem "+kind)
	check(panel().measurement_status("dhcp").begins_with("×"),"Neúspěšné měření je aktuální důkaz bez hodnocení ticketu")
	await click(identified("detail:probe:far"))
	await click(identified("probe:far"))
	var offset: int = panel().scroll.scroll_vertical
	await click(identified("probe:far"))
	check(panel().get_viewport().gui_get_focus_owner().get_meta("workshop_id","")=="probe:far" and absi(panel().scroll.scroll_vertical-offset)<3,"Měření zachová fokus podle identity a posun stránky")
	await click(identified("nav:repair"))
	await click(identified("cable:pc04"))
	await click(identified("port:3"))
	check(s.network.cable=="pc04" and s.network.ports.pc02==3 and s.network.last_message.contains("obsazený"),"UI odmítne obsazený port a zachová držený konektor")
	await click(identified("nav:capture"))
	await click(button("DHCP"))
	if not s.network.capture.is_empty():
		s.selected_frame = 0
		panel().draw()
	await frames()
	var selected_frame: int = s.selected_frame
	await click(identified("nav:ticket"))
	await click(identified("nav:repair"))
	check(s.network.cable=="pc04" and s.selected_port==3 and s.filter=="DHCP" and s.selected_frame==selected_frame,"Navigace zachová kabel, port, filtr a vybraný rámec")
	await click(identified("group:vlan"))
	await click(identified("port:4"))
	await click(identified("vlan:10"))
	check(panel().get_viewport().gui_get_focus_owner().get_meta("workshop_id","")=="vlan:10","Změna textu ovládání neztratí jeho fokus")
	await click(identified("nav:measure"))
	check(panel().measurement_status("dhcp").begins_with("!"),"Změna sítě označí starý výsledek textem jako zastaralý")
	check(panel().expanded.get("probe:far",false),"Rozbalené detaily přežijí navigaci a zásah")
	shell.return_to_world()
	shell.open_network_workshop()
	await frames()
	check(panel().expanded.get("probe:far",false) and s.selected=="printer" and s.network.cable=="pc04","Návrat do 3D a otevření zachová rozpracovanou práci a detaily")
	await click(identified("nav:capture"))
	var frame_path: Array = s.network.capture[s.selected_frame].path.duplicate()
	await click(identified("capture:show-path"))
	check(shell.mode=="world" and s.network.last_path==frame_path,"Ukázat cestu po dalším zásahu zvýrazní právě zachovaný vybraný rámec")
	shell.open_network_workshop()
	await frames()
	await click(identified("nav:repair"))
	var before_reset: Dictionary = s.network.snapshot()
	await click(identified("attempt:reset"))
	check(s.network.snapshot()==before_reset,"Žádost o reset sama neodstraní práci")
	await click(button("Zachovat rozpracovaný pokus"))
	check(s.network.snapshot()==before_reset,"Odmítnutí resetu zachová přesný stav")
	await click(identified("attempt:reset"))
	await click(identified("attempt:confirm-reset"))
	check(s.network.revision==0 and s.network.measurements.is_empty() and s.causes.is_empty() and s.selected_frame==-1,"Teprve potvrzení obnoví výchozí pokus a vyčistí neplatný výběr rámce")
	# Keyboard activation uses the actual input path and stable focus neighbors.
	identified("nav:ticket").grab_focus()
	await key_press(KEY_TAB)
	check(panel().get_viewport().gui_get_focus_owner()==identified("nav:measure"),"Tab přejde na další pracovní záložku")
	await key_press(KEY_RIGHT)
	await key_press(KEY_ENTER)
	check(s.view=="repair","Šipka a Enter otevřou Opravy bez zásahu")
	await key_press(KEY_ESCAPE)
	check(shell.mode=="world","Esc vrátí do 3D")
	for mode_value in ["learn","practice","exam","free"]:
		prepare(s,"F",mode_value)
		shell.open_network_workshop("ticket")
		await frames()
		var available: Array = panel().actions.map(func(b): return b.get_meta("workshop_id",""))
		check(available.has("attempt:verify")== (mode_value!="exam") and available.has("attempt:submit")== (mode_value!="free"),"Spodní akce respektují režim "+mode_value)
		if mode_value=="exam":
			check(not panel().actions.any(func(b): return b.text.contains("Nápověda") or b.text.contains("ukázka")),"Zkouška nenabízí nápovědu ani ukázku")
			repair(s)
			s.submit()
			shell.open_network_workshop("measure")
			await frames()
			check(panel().actions.filter(func(b): return str(b.get_meta("workshop_id","")).begins_with("probe:")).all(func(b): return b.disabled),"Odevzdaný pokus má měření uzavřená")
	var free_count: int = s.attempts.size()
	for id in ["A","B","C","D","E","F","G","H"]:
		prepare(s,id,"free")
		repair(s)
		check(s.assessment().passed,"Referenční oprava ve volném tréninku "+id)
		s.submit()
	check(s.attempts.size()==free_count,"Volný trénink A–H nevytvoří hodnocenou historii")
	# Actual write failure and retry, including its persistent footer.
	prepare(s,"F")
	repair(s)
	var count: int = s.attempts.size()
	Saves.path_override = "user://missing-layout-"+str(OS.get_process_id())+"/save.json"
	s.submit()
	shell.open_network_workshop("review")
	await frames()
	check(shell.ui.game.unsaved and identified("save:retry")!=null,"Skutečná chyba zápisu má viditelnou možnost opakování")
	Saves.path_override = save_path
	await click(identified("save:retry"))
	check(not shell.ui.game.unsaved and s.attempts.size()==count+1,"Opakování zápisu přes UI neduplikuje výsledek")
	s.mode = "free"
	s.start("")
	var route_state: Dictionary = s.network.snapshot()
	shell.return_to_world()
	shell.interact_network_workshop("ap")
	await frames()
	check(panel().repair_group=="wifi" and panel().scroll.scroll_vertical==0 and button("AP / středový úchyt")!=null,"Oslovení fyzického AP směruje na začátek jeho skupiny Oprav")
	shell.return_to_world()
	shell.interact_network_workshop("6")
	await frames()
	check(s.selected_port==6 and panel().repair_group=="vlan" and panel().scroll.scroll_vertical==0 and button("Port 06 → VLAN 20")!=null,"Oslovení konkrétního portu bez kabelu otevře jeho nastavení VLAN")
	check(s.network.snapshot()==route_state,"Kontextové otevření AP a portu samo neprovede zásah")

func geometry_checks():
	var room = shell.world.network_room
	var board = room.get_node("TopologyBoard")
	for node in board.find_children("*","GeometryInstance3D",true,false):
		var bounds: AABB = node.transform*node.get_aabb()
		if node.get_parent()!=board: bounds = board.global_transform.affine_inverse()*node.global_transform*node.get_aabb()
		check(bounds.position.x>= -2.91 and bounds.end.x<=2.91 and bounds.position.y>= -1.21 and bounds.end.y<=1.21,"Prvek topologie zůstává uvnitř tabule / "+str(node))
	check(board.position.x+2.9<6.53,"Celá tabule má odstup od levé obložky dveří")
	var station = room.get_node("GSMStation")
	for id in ["gsm","sim_a","sim_b"]: check(station.is_ancestor_of(room.targets[id]),"GSM cíl i jeho kolize patří do posunuté sestavy "+id)
	shell.return_to_world()
	shell.world.player.position = Vector3(9.7,0.02,-27.5)
	await aim_pc("work:door_1")
	var leaf_shape = room.workshop.door.get_child(0)
	for frame in 90:
		await physics_frame
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = leaf_shape.shape
		query.transform = leaf_shape.global_transform
		query.collision_mask = 1
		query.exclude = [room.workshop.door.get_rid(),shell.world.player.get_rid()]
		var hits: Array = shell.world.get_world_3d().direct_space_state.intersect_shape(query,4)
		check(hits.is_empty(),"Celý pohyb křídla bez kolize / úhel %.3f / %s" % [room.workshop.angle,str(hits.map(func(hit): return str(hit.collider.get_path())+str(hit.collider.global_position)))])
	await aim_pc("work:door_1")
	for frame in 90: await physics_frame
	check(not room.workshop.opened and absf(room.workshop.angle)<0.01,"Přední ovladač je dosažitelný u otevřených i zavřených dveří")
	await aim_pc("work:door_1")
	for frame in 90: await physics_frame
	await walk_to(Vector3(8,0.02,-27.5))
	await walk_to(Vector3(8,0.02,-30.4))
	await door_safety()
	await walk_to(Vector3(8,0.02,-30.4))
	await walk_to(Vector3(8,0.02,-27.5))
	# Test both physical SIMs and the call/handover after moving their entire unit.
	shell.ui.game.network_lab.start(definition("sim"))
	await walk_to(Vector3(7.65,0.02,-26.35))
	await aim_pc("sim_a")
	check(shell.ui.game.network_lab.network.sim_slot==-1,"Přesunutý telefon A vydá fyzickou SIM")
	await aim_pc("sim_b")
	check(shell.ui.game.network_lab.network.sim_slot==1,"Přesunutý telefon B přijme fyzickou SIM")
	var lab = shell.ui.game.network_lab
	lab.mode = "learn"
	lab.start(definition("handover"))
	lab.start_demo()
	for step in lab.demo_limit(): lab.next_demo()
	room.sync()
	check(lab.example.cell==1 and lab.example.call_step==2 and room.handover.text.contains("PŘEDÁNO"),"Přesunutá sestava zachová hovor a předání BTS")

func room_shots():
	shell.return_to_world()
	var w = shell.world.network_room.workshop
	for shot in [["door-approach",Vector3(7.1,0.02,-25.1),Vector3(7.9,2.3,-29)], ["topology-gsm",Vector3(5,0.02,-24.3),Vector3(6.6,2.3,-28.8)], ["topology-full",Vector3(5.9,0.02,-23.3),Vector3(3.25,2.35,-28.72)], ["gsm-workplace",Vector3(7.0,0.02,-25.1),Vector3(9.45,1.35,-25.1)], ["door-open-control",Vector3(8,0.02,-27.0),Vector3(9.5,1.6,-29)], ["return-classroom",Vector3(7.8,0.02,-31.5),Vector3(8,2.1,-29)]]:
		w.opened = shot[0] in ["door-open-control","return-classroom"]
		shell.world.player.position = shot[1]
		shell.world.player.camera.rotation = Vector3.ZERO
		shell.world.player.rotation = Vector3.ZERO
		for frame in 90: await physics_frame
		shell.world.player.camera.look_at(shot[2])
		await capture(shot[0])

func layout_shots(baseline: bool):
	var s = shell.ui.game.network_workshop
	var compact := "--compact" in OS.get_cmdline_user_args()
	for resolution in ([Vector2i(1280,720)] if compact else [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]):
		for scale_value in ([1.3] if compact else [1.0,1.3]):
			shell.ui.apply_display_settings(resolution,false)
			shell.ui.save_preference("text_scale",scale_value)
			suffix = "%d-%d" % [resolution.x,roundi(scale_value*100)]
			prepare(s,"H")
			shell.open_network_workshop("measure")
			await frames()
			if not baseline: await viewport_checks()
			panel().scroll.scroll_vertical = 0
			await frames()
			await capture("diagnostics")
			if baseline:
				panel().scroll.scroll_vertical = 1000
				await capture("repairs")
			else:
				await click(button("Opravy"))
				await viewport_checks(false)
				panel().scroll.scroll_vertical = 0
				await frames()
				await capture("repairs")
			await room_shots()
	await prepare_xr()
	for scale_value in ([1.3] if compact else [1.0,1.3]):
		shell.ui.save_preference("text_scale",scale_value)
		suffix = "vr-1600x1200-%d" % roundi(scale_value*100)
		prepare(s,"H")
		shell.open_network_workshop("measure")
		await frames()
		await capture("vr-diagnostics",rig.monitor.viewport)
		if not baseline:
			await viewport_checks()
			for hand in [0,1]:
				await click(identified("probe:link"),hand)
				await scroll_page(hand)
			await click(button("Opravy"),0)
			await capture("vr-repairs",rig.monitor.viewport)
			for hand in [rig.left,rig.right]:
				rig.pressed(hand,"by_button")
				await frames()
				check(shell.mode=="world","B/Y vrátí z panelu do 3D oběma ovladači")
				shell.open_network_workshop("repair")
				await frames()
	rig.deactivate()
	shell.vr_active = false
	for tracker in trackers: XRServer.remove_tracker(tracker)

func scroll_page(hand: int = -1):
	panel().scroll.scroll_vertical = 0
	await frames()
	var area: Rect2 = panel().scroll.get_global_rect()
	var at := area.get_center()
	if hand>=0:
		for index in [1-hand,hand]:
			var point := Vector2(-200,-200) if index!=hand else at
			var monitor = rig.monitor
			var pixel := Vector3((point.x/1600-0.5)*monitor.dimensions.x,(0.5-point.y/1200)*monitor.dimensions.y,0)
			var pose: Transform3D = rig.global_transform.affine_inverse()*Transform3D(monitor.global_basis,monitor.to_global(pixel)+monitor.global_basis.z*0.8)
			trackers[index+1].set_pose("aim",pose,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		trackers[2].set_input("primary",Vector2(0,-1))
		for tick in 25: await physics_frame
		trackers[2].set_input("primary",Vector2.ZERO)
	else:
		for tick in 4:
			for down in [true,false]:
				var event := InputEventMouseButton.new()
				event.position = at
				event.button_index = MOUSE_BUTTON_WHEEL_DOWN
				event.pressed = down
				panel().get_viewport().push_input(event,true)
	await frames()
	check(panel().scroll.scroll_vertical>0,"Skutečné posouvání obsahu / paprsek "+str(hand))

func viewport_checks(diagnostic := true):
	var bounds: Rect2 = panel().get_global_rect()
	var footer = panel().find_child("WorkFooter",true,false)
	var tabs = panel().find_child("WorkTabs",true,false)
	check(bounds.encloses(footer.get_global_rect()) and bounds.encloses(tabs.get_global_rect()),"Navigace i stálé spodní akce jsou celé ve viewportu")
	check(not panel().scroll.get_h_scroll_bar().visible,"Pracovní plocha nemá vodorovné posouvání")
	var first_y: float = tabs.get_child(0).global_position.y
	for b in tabs.get_children(): check(b.global_position.y==first_y and bounds.encloses(b.get_global_rect()),"Pracovní záložka se vejde do jediného řádku / "+b.text)
	for b in footer.find_children("*","Button",true,false): check(bounds.encloses(b.get_global_rect()),"Spodní tlačítko je celé dostupné / "+b.text)
	var footer_y: float = footer.global_position.y
	if diagnostic: await scroll_page()
	else:
		panel().scroll.scroll_vertical = 100000
		await frames()
		check(panel().scroll.get_global_rect().encloses(identified("attempt:reset").get_global_rect()),"Poslední akce Oprav je dostupná nad spodní lištou")
	for b in panel().actions:
		if panel().scroll.is_ancestor_of(b):
			check(b.get_global_rect().position.x>=bounds.position.x and b.get_global_rect().end.x<=bounds.end.x,"Obsahové tlačítko není vodorovně oříznuté / "+b.text)
	check(footer.global_position.y==footer_y and panel().scroll.get_global_rect().end.y<=footer_y,"Posouvání nezmění spodní lištu a obsah ji nepřekrývá")
	var status = shell.status_label
	check(shell.hud.get_global_rect().encloses(status.get_global_rect()),"Levý horní HUD je celý uvnitř podporovaného viewportu")

func run():
	var baseline := "--baseline" in OS.get_cmdline_user_args()
	capture_directory = REVIEW_DIR+("before/" if baseline else "after/")
	DirAccess.make_dir_recursive_absolute(capture_directory)
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await frames()
	shell.ui.save_preference("introduction_seen",true)
	shell.ui.save_preference("vsync",false)
	shell.enter_world("Počítačové sítě")
	if not baseline:
		await ui_checks()
		await geometry_checks()
	if DisplayServer.get_name()!="headless" or baseline:
		shell.ui.game.network_lab.cancel()
		await layout_shots(baseline)
	shell.queue_free()
	await frames()
	print("WORKSHOP LAYOUT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
