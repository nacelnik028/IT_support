extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Display=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
var shell
var rig
var checks=0
var failures=0
var trackers=[]

func _init():
	Saves.path_override="user://academy_test_xr_modes.json"
	Display.path_override="user://academy_test_xr_modes.cfg"
	Comfort.path_override="user://academy_test_xr_comfort.cfg"
	Comfort.new().save_settings()
	Saves.save_game({},true)
	call_deferred("run")

func check(ok: bool, caption: String):
	checks+=1
	if not ok: failures+=1; push_error(caption)

func frames():
	for i in 8: await process_frame

func physics():
	for i in 4: await physics_frame

func controller(name: String):
	var tracker=XRControllerTracker.new()
	tracker.name=name
	tracker.type=XRServer.TRACKER_CONTROLLER
	tracker.set_input("primary",Vector2.ZERO)
	tracker.set_input("trigger_click",false)
	tracker.set_input("grip_click",false)
	tracker.set_input("by_button",false)
	tracker.set_pose("aim",Transform3D(Basis(),Vector3(0.25,1.2,-0.2)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	tracker.set_pose("grip",Transform3D(Basis(),Vector3(0.25,1.2,-0.2)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	XRServer.add_tracker(tracker)
	trackers.append(tracker)
	return tracker

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await frames()
	check(shell.ui.ui_targets.has("menu:vr"),"Menu nabízí VR")
	check(shell.ui.ui_targets["menu:primary"].text.contains("KLASICKÉM 3D"),"Menu nabízí desktop")
	shell.start_vr()
	check(not shell.vr_active and shell.mode=="menu","Chybějící OpenXR vrací menu")
	for child in shell.ui.get_children():
		if child is Window: child.hide(); child.queue_free()
	shell.ui.game.start_mission(50,true)
	shell.enter_world()
	var initial=shell.ui.game.sim.state.duplicate(true)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate()
	rig.shell=shell
	shell.xr_rig=rig
	shell.world.player.add_child(rig)
	rig.head.position.y=1.68
	shell.vr_active=true
	# Synthetic rig: tests UI/physics/state without claiming hardware tracking.
	rig.activate(false)
	shell.set_mode("world")
	await frames()
	check(not shell.world.player.enabled,"VR vypne desktop vstup")
	check(rig.left.tracker==&"left_hand" and rig.right.tracker==&"right_hand","Standardní 6DoF ovladače")
	var actions=load("res://scenes/xr/academy_actions.tres")
	var pico=false
	for profile in actions.interaction_profiles:
		if profile.interaction_profile_path=="/interaction_profiles/bytedance/pico4_controller": pico=true
	check(pico,"Akční mapa obsahuje běžný PICO 4")
	rig.interact_target(shell.world.devices["PVE-01"],false,rig.right)
	check(shell.mode=="detail" and shell.ui.game.sim.state.world.inspected.get("PVE-01",false),"VR prohlídka sdílí infrastrukturu")
	shell.open_app("Proxmox","PVE-01")
	await frames()
	check(shell.ui.get_viewport()==rig.monitor.viewport,"Původní konzole je v SubViewport")
	check(rig.monitor.visible and rig.monitor.viewport.gui_embed_subwindows,"Prostorový monitor a vložené dialogy")
	shell.ui.open_action("management")
	await frames()
	var field=shell.ui.form_controls.management.hostname
	field.text=""
	field.grab_focus()
	rig.monitor.keyboard.track_focus()
	rig.monitor.keyboard.type_text("pve-vr.lab.example")
	check(field.text=="pve-vr.lab.example","Virtuální klávesnice edituje skutečný formulář")
	rig.monitor.keyboard.send_key(KEY_BACKSPACE)
	check(field.text=="pve-vr.lab.exampl","Backspace funguje v SubViewport")
	if "--screenshots" in OS.get_cmdline_user_args() and DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		rig.monitor.viewport.get_texture().get_image().save_png("res://test-output/xr-monitor-console.png")
	# Ray projection and actual button events, rather than invoking button callbacks.
	var button=Button.new()
	button.text="Ray test"
	button.position=Vector2(1250,800)
	button.size=Vector2(200,70)
	var pressed=[false]
	button.pressed.connect(func(): pressed[0]=true)
	rig.monitor.keyboard.hide()
	rig.monitor.keyboard.get_parent().add_child(button)
	await frames()
	rig.monitor.point(Vector2(1300,830))
	rig.monitor.click(true)
	rig.monitor.click(false)
	await frames()
	check(pressed[0],"Controller ray odesílá skutečný UI klik")
	button.queue_free()
	var pixel=rig.monitor.pixel_at(rig.monitor.global_position+rig.monitor.global_basis.z,-rig.monitor.global_basis.z)
	check(pixel.distance_to(Vector2(800,600))<0.01,"3D paprsek se mapuje do středu monitoru")
	check(rig.monitor.pixel_at(rig.monitor.global_position+rig.monitor.global_basis.z,rig.monitor.global_basis.z).x<0,"Paprsek opačným směrem odmítnut")
	shell.return_to_world()
	check(not rig.monitor.visible,"Monitor po návratu nepřekrývá svět")
	var yaw=shell.world.player.rotation.y
	rig.snap_turn(1.0)
	rig.snap_turn(1.0)
	check(is_equal_approx(shell.world.player.rotation.y,yaw-deg_to_rad(30)),"Snap turn jednou na vychýlení")
	rig.snap_turn(0)
	rig.snap_turn(-1)
	check(is_equal_approx(shell.world.player.rotation.y,yaw),"Snap turn po návratu joysticku")
	check(not rig.can_teleport(Vector3(0,1.4,-3)),"Teleport na rack odmítnut")
	check(not rig.can_teleport(Vector3(30,0,0)),"Teleport mimo budovu odmítnut")
	check(not rig.can_teleport(Vector3(-9,0,0)),"Teleport do zdi odmítnut")
	var head_tracker=XRPositionalTracker.new()
	head_tracker.name="head"
	head_tracker.type=XRServer.TRACKER_HEAD
	head_tracker.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	XRServer.add_tracker(head_tracker)
	trackers.append(head_tracker)
	var left_tracker=controller("left_hand")
	var right_tracker=controller("right_hand")
	await physics()
	check(rig.left.get_has_tracking_data() and rig.right.get_has_tracking_data(),"Syntetické controller poses se připojí k XR uzlům")
	right_tracker.set_input("by_button",true)
	await frames()
	check(shell.mode=="pause","Skutečný XR input B otevře menu")
	right_tracker.set_input("by_button",false)
	right_tracker.set_input("by_button",true)
	await frames()
	check(shell.mode=="world","Skutečný XR input B vrátí svět")
	right_tracker.set_input("by_button",false)
	rig.settings.locomotion="smooth"
	var before_move=shell.world.player.position
	left_tracker.set_input("primary",Vector2(0,1))
	for i in 12: await physics_frame
	left_tracker.set_input("primary",Vector2.ZERO)
	check(shell.world.player.position.distance_to(before_move)>0.1,"Levý joystick skutečně pohybuje kolizním tělem")
	rig.lose_focus()
	check(shell.mode=="pause" and not rig.focused,"Ztráta OpenXR focus pozastaví interakce")
	rig.focused=true
	shell.return_to_world()
	var spare=rig.spare_objects[0]
	var grip_pose=Transform3D(Basis(),rig.to_local(spare.global_position+Vector3(0,0,0.3)))
	right_tracker.set_pose("grip",grip_pose,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	right_tracker.set_pose("aim",grip_pose,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await physics()
	right_tracker.set_input("grip_click",true)
	await physics()
	check(shell.ui.game.sim.state.world.held==spare.get_meta("spare"),"Grip vezme fyzický náhradní disk přes sdílený model")
	check(shell.world.carried_disk.get_parent()==rig.grip_nodes[rig.right],"Nesený disk sleduje grip pose ovladače")
	right_tracker.set_input("grip_click",false)
	shell.ui.game.apply("physical_return_spare",{})
	for tracker in trackers: XRServer.remove_tracker(tracker)
	trackers.clear()
	# Room-scale boundary checks continue even while the console is open.
	check(rig.teleport_to(Vector3(9.6,0,3.5)),"Příprava hranice místnosti")
	shell.world.move_door(true)
	for i in 55: await physics_frame
	shell.open_app("Trénink")
	head_tracker.set_pose("default",Transform3D(Basis(),Vector3(-1.3,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	XRServer.add_tracker(head_tracker)
	await physics()
	check(not shell.ui.game.game_mode.is_training() and shell.mode=="world","Fyzický odchod při otevřeném monitoru zruší TRAINING")
	XRServer.remove_tracker(head_tracker)
	head_tracker.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	rig.head.position.x=0
	rig.position.x=0
	for mode in ["learn","practice","exam"]:
		check(rig.teleport_to(Vector3(15,0,5.5)),"Teleport do akademie")
		await frames()
		check(shell.ui.game.game_mode.is_training(),"VR vstup aktivuje TRAINING")
		check(shell.ui.game.start_lesson(1002,mode,false),"Spuštění lekce "+mode)
		shell.enter_world()
		await frames()
		shell.ui.game.training_sim.state.hosts["PVE-01"].hostname="temporary-vr"
		check(rig.teleport_to(Vector3(7,0,3.5)),"Odchod z akademie")
		await frames()
		check(not shell.ui.game.game_mode.is_training() and shell.ui.game.session_kind=="campaign","VR odchod obnoví pracovní relaci")
		check(shell.ui.game.education.sessions.is_empty() and shell.ui.game.tutorial.session.is_empty(),"Nedokončená lekce a panely resetovány")
		check(shell.ui.game.training_sim.state.hosts["PVE-01"].hostname!="temporary-vr","Cvičná infrastruktura resetována")
		check(shell.ui.game.sim.state.hosts==initial.hosts,"Kampaň zachována v režimu "+mode)
	shell.request_play_mode("desktop")
	shell.enter_world()
	check(not shell.vr_active and shell.world.player.enabled and not root.use_xr,"Přepnutí zpět na desktop")
	check(shell.ui.get_viewport()==root,"UI se vrátí do desktopového viewportu")
	check(shell.ui.game.sim.state.hosts==initial.hosts,"Přepnutí zachová infrastrukturu")
	var settings=Comfort.new()
	settings.locomotion="smooth"; settings.seated=true; settings.snap_degrees=45
	check(settings.save_settings()==OK,"Uložení VR komfortu")
	var restored=Comfort.new(); restored.load_settings()
	check(restored.locomotion=="smooth" and restored.seated and restored.snap_degrees==45,"Obnova VR komfortu")
	check(shell.ui.game.save()==OK,"Uložení společné pozice")
	check(Saves.export_progress("user://academy_test_xr_transfer.json")==OK,"Export přenositelného postupu")
	shell.ui.game.progress.xp+=25
	shell.ui.game.save()
	check(Saves.import_progress("user://academy_test_xr_transfer.json")==OK,"Import přenositelného postupu")
	check(Saves.load_game().progress.xp==0,"Import obnovil XP")
	var invalid=FileAccess.open("user://academy_test_xr_invalid.json",FileAccess.WRITE)
	invalid.store_string("{broken"); invalid.close()
	var before=FileAccess.get_file_as_string(Saves.save_path())
	check(Saves.import_progress("user://academy_test_xr_invalid.json")==ERR_INVALID_DATA,"Vadný import odmítnut")
	check(FileAccess.get_file_as_string(Saves.save_path())==before,"Vadný import nezmění save")
	print("XR_MODES: %d checks, %d failures; synthetic tests, no hardware tracking claim" % [checks,failures])
	shell.queue_free()
	await frames()
	quit(1 if failures else 0)
