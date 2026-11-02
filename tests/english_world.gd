extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
var shell
var m
var rig
var trackers=[]
var checks=0
var failures=0
var shots=false

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_english_world_"+tag+".json"
	Settings.path_override="user://academy_test_english_world_"+tag+".cfg"
	Comfort.path_override="user://academy_test_english_world_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	var settings=Settings.new(); settings.quality="Úsporná"; settings.vsync=false; settings.introduction_seen=true; settings.save_settings()
	Comfort.new().save_settings()
	call_deferred("run")

func check(ok: bool, caption: String):
	checks+=1
	if not ok: failures+=1; push_error(caption)

func frames(count: int = 8):
	for i in count: await process_frame

func key(code: int):
	for down in [true,false]:
		var event=InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=down
		root.push_input(event,true)
	await frames()

func capture(name: String):
	if not shots: return
	await frames()
	await RenderingServer.frame_post_draw
	var folder="res://test-output/london-review"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	check(root.get_texture().get_image().save_png(folder+"/"+name+".png")==OK,"Snímek "+name)

func visible_button(button: Button) -> bool:
	return button.is_visible_in_tree() and root.get_visible_rect().encloses(button.get_global_rect())

func click_button(button: Button, hand_index: int = -1):
	check(is_instance_valid(button),"Skutečné tlačítko existuje")
	if not is_instance_valid(button): return
	await create_timer(0.23).timeout
	if hand_index<0:
		check(visible_button(button),"Celé tlačítko viditelné: "+button.text)
		var at=button.get_global_rect().get_center()
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		var motion=InputEventMouseMotion.new(); motion.position=at; root.push_input(motion,true)
		for down in [true,false]:
			var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; root.push_input(event,true)
	else:
		var at=button.get_global_rect().get_center()
		var monitor=rig.monitor
		var local=Vector3((at.x/1600.0-0.5)*monitor.DIMENSIONS.x,(0.5-at.y/1200.0)*monitor.DIMENSIONS.y,0)
		var transform=Transform3D(monitor.global_basis,monitor.to_global(local)+monitor.global_basis.z*0.8)
		trackers[hand_index].set_pose("aim",rig.global_transform.affine_inverse()*transform,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		await frames()
		var hand=rig.left if hand_index==0 else rig.right
		rig.pressed(hand,"trigger_click")
		# Another hand cannot steal a held press. Repeated down is also ignored.
		rig.pressed(hand,"trigger_click")
		rig.pressed(rig.right if hand_index==0 else rig.left,"trigger_click")
		rig.released(hand,"trigger_click")
	await frames()

func find_button(text: String):
	for b in shell.english_dialog.buttons:
		if b.text.ends_with(text): return b
	return null

func choice(id: String, hand_index: int = -1):
	var option={}
	for c in m.choices():
		if c.id==id: option=c; break
	check(not option.is_empty(),"Dostupný záměr "+id)
	if option.is_empty(): return
	var revision=m.revision
	await click_button(find_button(option.text),hand_index)
	check(m.revision==revision+1,"Právě jedna replika přes skutečné UI: "+id)

func walk_to(point: Vector3):
	shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var p=shell.world.player
	for i in 500:
		if not p.enabled: break
		var offset=point-p.global_position; offset.y=0
		if offset.length()<0.14: break
		p.rotation.y=atan2(-offset.x,-offset.z); p.camera.rotation.x=0
		Input.action_press("walk_forward",minf(1,offset.length()*2))
		await physics_frame
	Input.action_release("walk_forward")
	for i in 12: await physics_frame
	check(Vector2(p.position.x-point.x,p.position.z-point.z).length()<0.35,"Průchozí fyzická cesta %s, skutečně %s, režim %s" % [point,p.position,shell.mode])

func use(id: String, at: Vector3):
	shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var p=shell.world.player
	p.position=at; p.rotation=Vector3.ZERO; p.camera.rotation=Vector3.ZERO
	p.camera.look_at(shell.world.devices[id].global_position+Vector3(0,0.12,0))
	for i in 4: await physics_frame
	p.poll_target()
	check(p.target==shell.world.devices[id],"Skutečný raycast před E: "+id)
	await key(KEY_E)
	check(shell.mode=="english","E otevře anglické UI: "+id)

func run_scenario(id: String, hand_index: int = -1):
	m.cancel(); check(m.start(id,"learn",0),"Start UI scénáře "+id)
	var p=shell.world.player
	p.position=Vector3(6,0.02,11.4) if id=="LON06" else Vector3(12,0.02,8.8)
	shell.open_english("info" if id=="LON06" else "tickets")
	await frames()
	if id=="LON06":
		await choice("directions",hand_index); await choice("route",hand_index)
		check(not m.arrive_tower(),"Nestačí kliknout směr")
		if hand_index<0:
			shell.return_to_world(); await walk_to(Vector3(8,0.02,11.4)); await walk_to(Vector3(8,0.02,18.5)); await walk_to(Vector3(8,0.02,24)); await walk_to(Vector3(4,0.02,24))
		else: check(rig.teleport_to(Vector3(4,0,24)),"Teleport k věži")
		check(m.arrive_tower(),"Světová poloha dokončí směr")
	else:
		if id=="LON05": await choice("change",hand_index)
		if id=="LON03": await choice("price",hand_index)
		await choice("order_alt",hand_index)
		if id=="LON04": await choice("time_14:00",hand_index); await choice("next",hand_index)
		else: await choice("time_"+m.session.goal.time,hand_index)
		await choice("confirm",hand_index)
		p.position=Vector3(10,0.02,8.7); shell.open_english("terminal"); await frames()
		await click_button(shell.english_dialog.buttons[0],hand_index)
		check(m.session.paid and m.session.payments==1,"Jedna skutečná platba přes UI")
		await choice("thanks",hand_index)
		p.position=Vector3(17,0.02,16.6); shell.open_english("gate"); await frames()
		await click_button(shell.english_dialog.buttons[0],hand_index)
		check(m.session.ticket.used,"Konkrétní lístek z peněženky spotřebován")
	check(m.session.completed,"Celý UI scénář "+id+" / hand "+str(hand_index))

func run():
	shots=DisplayServer.get_name()!="headless" and "--screenshots" in OS.get_cmdline_user_args()
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	m=shell.ui.game.english
	shell.ui.game.start_mission(3)
	var campaign=shell.ui.game.sim.state.duplicate(true)
	shell.enter_world("Hlavní serverovna")
	shell.world.player.position=Vector3(5,0.02,5)
	await walk_to(Vector3(5,0.02,7.45))
	check(shell.ui.game.game_mode.is_english(),"Fyzický vstup do čtvrté oblasti")
	await frames(); check(shell.mode=="english" and shell.english_dialog.page=="intro","První přeskočitelné seznámení")
	await click_button(shell.english_dialog.buttons[0])
	check(m.progress.intro_seen,"Seznámení uložené")
	await walk_to(Vector3(5,0.02,8.5))
	await use("LONDON-TICKETS",Vector3(12,0.02,8.8))
	var p=shell.world.player; var before=p.position
	Input.action_press("walk_forward")
	for i in 8: await physics_frame
	Input.action_release("walk_forward")
	check(not p.enabled and p.position.distance_to(before)<0.01,"Dialog blokuje chůzi")
	await key(KEY_ESCAPE); check(shell.mode=="world" and p.enabled,"Esc obnoví pohyb")
	# Actual keyboard focus and Enter, followed by number shortcuts.
	m.start("LON01","learn",0); shell.open_english(); await frames()
	var option=m.choices()[0]; var button=find_button(option.text); button.grab_focus(); await key(KEY_DOWN)
	check(shell.get_viewport().gui_get_focus_owner()!=button,"Šipky mění fokus")
	button.grab_focus(); await key(KEY_ENTER); check(m.session.node=="time","Enter odešle zaměřenou repliku")
	await create_timer(0.23).timeout
	await key(KEY_1); check(m.session.node=="confirm","Číslo volí skutečnou repliku")
	for id in m.IDS: await run_scenario(id)
	# All UI stages and help must fit every supported size with larger text too.
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for scale_value in [1.0,1.3]:
			shell.ui.apply_display_settings(resolution,false); shell.ui.save_preference("text_scale",scale_value)
			shell.enter_world("English in London")
			p.position=Vector3(12,0.02,8.8)
			m.cancel(); m.start("LON02","learn",0); shell.open_english(); await frames()
			shell.english_dialog.request_hint(); shell.english_dialog.toggle_translation(); await frames()
			for b in shell.english_dialog.buttons: check(visible_button(b),"Rozhraní %s/%s: %s" % [resolution,scale_value,b.text])
			await capture("dialog-%d-%d" % [resolution.x,roundi(scale_value*100)])
			shell.english_dialog.page="home"; shell.english_dialog.draw(); await frames()
			for b in shell.english_dialog.buttons: check(visible_button(b),"Výběr situací bez ořezu")
			shell.ui.page="menu"; shell.ui.draw_ui(); shell.set_mode("menu"); await frames()
			check(visible_button(shell.ui.ui_targets["menu:english"]),"Londýn v menu")
	# World overview and both landmark meshes are captured on the GPU.
	shell.ui.apply_display_settings(Vector2i(1920,1080),false); shell.ui.save_preference("text_scale",1.0)
	shell.enter_world("English in London"); p.position=Vector3(8,0.02,8.8); p.camera.look_at(Vector3(10,4,23)); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	await capture("pavilion")
	p.position=Vector3(8,0.02,24); p.camera.look_at(Vector3(4,5,27)); await capture("tower")
	# Room transitions with an open dialog cancel only temporary English state.
	for destination in ["Programming Academy","Trénink","Hlavní serverovna"]:
		shell.enter_world("English in London"); m.cancel(); m.start("LON01","learn",0); shell.open_english()
		shell.enter_world(destination); await frames()
		check(m.session.is_empty() and shell.mode=="world","Odchod s otevřeným dialogem: "+destination)
	shell.enter_world("English in London"); m.start("LON01","learn",0); shell.open_english()
	p.position=Vector3(5,0.02,6.5); await frames()
	check(m.session.is_empty() and not shell.ui.game.game_mode.is_education() and shell.mode=="world","Fyzické opuštění zóny zavře otevřený dialog")
	shell.enter_world("English in London"); m.start("LON01","learn",0); shell.open_english(); shell.set_mode("menu")
	check(m.session.is_empty() and not shell.ui.game.game_mode.is_education(),"Hlavní menu zruší nákup")
	shell.enter_world("Hlavní serverovna")
	check(shell.ui.game.sim.state.vms==campaign.vms and shell.ui.game.sim.state.hosts==campaign.hosts,"Kampaň po přechodech nezměněná")
	# Synthetic tracked controllers send real ray events to the same SubViewport.
	shell.ui.apply_display_settings(Vector2i(1600,900),false)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; shell.xr_rig=rig; p.add_child(rig); rig.head.position.y=1.68; shell.vr_active=true; rig.activate(false)
	var head=XRPositionalTracker.new(); head.name="head"; head.type=XRServer.TRACKER_HEAD; head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(head)
	for name in ["left_hand","right_hand"]:
		var tracker=XRControllerTracker.new(); tracker.name=name; tracker.type=XRServer.TRACKER_CONTROLLER; tracker.set_input("primary",Vector2.ZERO); tracker.set_pose("aim",Transform3D(Basis(),Vector3(0.2,1.2,-0.2)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); tracker.set_pose("grip",Transform3D(Basis(),Vector3(0.2,1.2,-0.2)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(tracker); trackers.append(tracker)
	shell.enter_world("English in London"); await frames()
	check(rig.can_teleport(Vector3(8,0,21.5)) and not rig.can_teleport(Vector3(14,0,21.5)),"Teleport na most, nikoli do řeky")
	for i in 6: await run_scenario(m.IDS[i],i%2)
	check(m.progress.results.size()==6,"PC a XR sdílejí skutečné výsledky")
	p.position=Vector3(12,0.02,8.8); m.cancel(); m.start("LON01","learn",0); shell.open_english(); await frames()
	var anchored=rig.monitor.global_transform; rig.head.position.x+=0.1; await frames()
	check(rig.monitor.global_transform.is_equal_approx(anchored),"Panel nepřilepený k hlavě")
	rig.head.position.x=0
	check(rig.teleport_to(Vector3(5,0,5.5)),"Teleport z pavilonu")
	check(m.session.is_empty() and shell.mode=="world" and not rig.monitor.visible,"Teleport odchodu zruší dialog a lístek")
	XRServer.remove_tracker(head)
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.queue_free(); await frames()
	print("ENGLISH WORLD: %d checks, %d failures (synthetic XR, no headset)" % [checks,failures])
	quit(1 if failures else 0)
