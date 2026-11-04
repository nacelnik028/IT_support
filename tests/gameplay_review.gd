extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Display=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
var shell
var rig
var trackers=[]
var checks=0
var failures=0
var suffix=""

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_gameplay_review_"+tag+".json"
	Display.path_override="user://academy_test_gameplay_review_"+tag+".cfg"
	Comfort.path_override="user://academy_test_gameplay_review_"+tag+"_vr.cfg"
	Saves.save_game({},true); Comfort.new().save_settings()
	var settings=Display.new(); settings.vsync=false; settings.introduction_seen=true; settings.quality="Úsporná"; settings.save_settings()
	call_deferred("run")

func frames(n=8):
	for i in n: await process_frame

func check(ok,text):
	checks+=1
	if not ok: failures+=1; push_error(text)

func capture(name, viewport=null):
	if DisplayServer.get_name()=="headless" or not "--screenshots" in OS.get_cmdline_user_args(): return
	await frames(); await RenderingServer.frame_post_draw
	var folder="res://docs/ui-review/2026-11-03-gameplay"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var target=viewport if viewport!=null else root
	check(target.get_texture().get_image().save_png(folder+"/"+RenderingServer.get_current_rendering_method()+"-"+name+"-"+suffix+".png")==OK,"Snímek "+name)

func click_button(button, hand=null):
	if not is_instance_valid(button): return
	var ancestor=button.get_parent()
	while ancestor!=null:
		if ancestor is ScrollContainer: ancestor.ensure_control_visible(button); ancestor.scroll_vertical+=4
		ancestor=ancestor.get_parent()
	await frames()
	var viewport=button.get_viewport()
	check(viewport.get_visible_rect().encloses(button.get_global_rect()),"Viditelné tlačítko "+button.text)
	var at=button.get_global_rect().get_center()
	if hand!=null:
		var local=Vector3((at.x/1600.0-0.5)*rig.monitor.dimensions.x,(0.5-at.y/1200.0)*rig.monitor.dimensions.y,0)
		pose(hand,rig.monitor.to_global(local)+rig.monitor.global_basis.z*0.8,rig.monitor.to_global(local))
		await frames()
		rig.pressed(rig.left if hand==trackers[1] else rig.right,"trigger_click")
		rig.pressed(rig.right if hand==trackers[1] else rig.left,"trigger_click")
		rig.released(rig.left if hand==trackers[1] else rig.right,"trigger_click")
	else:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		var move=InputEventMouseMotion.new(); move.position=at; viewport.push_input(move,true)
		for down in [true,false]:
			var e=InputEventMouseButton.new(); e.position=at; e.button_index=MOUSE_BUTTON_LEFT; e.pressed=down; viewport.push_input(e,true)
	await frames()

func button(prefix):
	for b in shell.find_children("*","Button",true,false):
		if b.is_visible_in_tree() and b.text.begins_with(prefix): return b
	push_error("Chybí tlačítko "+prefix); failures+=1
	return null

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var g=shell.ui.game; var ui=shell.ui
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for scale_value in [1.0,1.3]:
			suffix=str(resolution.x)+"-"+str(roundi(scale_value*100))
			ui.apply_display_settings(resolution,false); ui.save_preference("text_scale",scale_value)
			ui.page="menu"; ui.draw_ui(); shell.set_mode("menu"); await frames()
			check(ui.find_child("AuthorCredit",true,false).text=="Vytvořil Vít Kellner","Podpis zachován")
			await capture("menu")
			shell.enter_world("Hlavní serverovna"); shell.show_introduction(); await capture("intro-offer")
			await click_button(button("Zahájit praktický úvod")); check(shell.practical_intro.active,"PC klik zahájil úvod")
			shell.update_time=1; shell._process(0.1); await capture("intro-world")
			shell.practical_intro.finish(false)
			shell.enter_world("Hlavní serverovna"); shell.open_app("Souvislé směny")
			await click_button(button("Zahájit Síť a dostupnost" if g.shifts.data.session.is_empty() else "Pokračovat ve směně"))
			check(g.session_kind=="shift","PC klik zahájil vlastní směnu")
			shell.show_tasks(); await capture("shift")
			g.apply("probe",{"vm":"100"}); shell.open_app("Síť"); await capture("network")
			shell.enter_world("English in London"); g.english.progress.intro_seen=true
			g.english.cancel(); g.english.start("LON02","learn",0); g.english.open_questions(g.english.revision)
			shell.world.player.position=Vector3(12,0.02,8.8); shell.open_english()
			await capture("london-audio")
			var before=g.english.revision
			await click_button(button("Poslechnout / zopakovat"))
			check(shell.speech.playing and g.english.revision==before,"PC poslech hraje a nevybere odpověď")
			shell.return_to_world(); check(not shell.speech.playing,"Odchod zastaví řeč")
	# Real SubViewport contents and both complete controller press/release paths.
	ui.apply_display_settings(Vector2i(1600,900),false); ui.save_preference("text_scale",1.0)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; shell.xr_rig=rig; shell.world.player.add_child(rig)
	shell.vr_active=true
	var head=XRPositionalTracker.new(); head.name="head"; head.type=XRServer.TRACKER_HEAD
	head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	XRServer.add_tracker(head); trackers.append(head)
	for name in ["left_hand","right_hand"]:
		var tracker=XRControllerTracker.new(); tracker.name=name; tracker.type=XRServer.TRACKER_CONTROLLER
		tracker.set_input("primary",Vector2.ZERO)
		tracker.set_pose("aim",Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		tracker.set_pose("grip",Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		XRServer.add_tracker(tracker); trackers.append(tracker)
	rig.activate(false); await frames()
	for scale_value in [1.0,1.3]:
		ui.save_preference("text_scale",scale_value); suffix="vr-"+str(roundi(scale_value*100))
		for screen in ["intro","shift","network","audio"]:
			if screen=="intro": shell.show_introduction()
			elif screen=="shift": shell.enter_world("Hlavní serverovna"); shell.open_app("Souvislé směny")
			elif screen=="network": shell.open_app("Síť")
			else:
				shell.enter_world("English in London"); shell.world.player.position=Vector3(12,0.02,8.8)
				g.english.cancel(); g.english.start("LON02","practice",0); g.english.open_questions(g.english.revision); shell.open_english()
			await capture(screen,rig.monitor.viewport)
			var field=LineEdit.new(); field.position=Vector2(170,900); field.size=Vector2(600,45); rig.monitor.keyboard.get_parent().add_child(field); rig.monitor.keyboard.get_parent().move_child(field,0)
			await frames(); field.grab_focus(); rig.monitor.keyboard.track_focus(); await frames()
			check(rig.monitor.keyboard.visible,"Klávesnice ve skutečném SubViewportu")
			await capture(screen+"-keyboard",rig.monitor.viewport)
			rig.monitor.keyboard.dismiss(); field.queue_free(); await frames()
			if screen=="audio":
				var rev=g.english.revision
				await click_button(button("Poslechnout / zopakovat"),trackers[1])
				check(shell.speech.playing and g.english.revision==rev,"Levý paprsek přehrává bez volby/dvojí akce")
				await click_button(button("Pomaleji"),trackers[2])
				check(shell.speech.playing and shell.speech.pitch_scale==1.0,"Pravý paprsek ovládá pomalou variantu")
	await synthetic_intro()
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.request_play_mode("desktop"); shell.queue_free(); await frames(); OS.delay_msec(120)
	print("GAMEPLAY REVIEW: %d checks, %d failures; synthetic XR, no headset" % [checks,failures]); quit(1 if failures else 0)

func pose(tracker, origin, target):
	var transform=Transform3D(Basis().looking_at(target-origin),origin)
	var local=rig.global_transform.affine_inverse()*transform
	for name in ["aim","grip"]: tracker.set_pose(name,local,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)

func synthetic_intro():
	var intro=shell.practical_intro
	intro.start(); await create_timer(0.8).timeout; await frames()
	trackers[0].set_pose("default",Transform3D(Basis(Vector3.UP,0.7),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); await frames()
	check(intro.step==1,"XR orientace podle head pose")
	check(rig.teleport_to(Vector3(7.5,0,3.5)),"XR přesun na skutečnou podlahu"); await frames()
	check(intro.step==2,"XR cíl přesunu")
	var control=shell.world.devices["DOOR-CONTROL-OPS"]
	pose(trackers[2],Vector3(7.5,1.35,1.65),control.global_position); await frames()
	rig.pressed(rig.right,"trigger_click"); rig.released(rig.right,"trigger_click"); await frames()
	check(intro.step==3 and shell.world.door_open,"XR ray/trigger ovladače dveří")
	await create_timer(0.8).timeout
	check(rig.teleport_to(Vector3(10.3,0,3.5)),"XR průchod otevřenými dveřmi"); await frames()
	check(intro.step==4,"XR fyzické překročení vstupu")
	pose(trackers[1],Vector3(11.2,1.5,2.2),shell.world.devices["TRAIN-PC-PVE"].global_position); await frames()
	rig.pressed(rig.left,"trigger_click"); rig.released(rig.left,"trigger_click"); await frames()
	check(intro.step==5,"XR otevře správný monitor")
	await click_button(button("Ověřit cvičný přehled"),trackers[1]); check(intro.step==6,"XR skutečný UI prvek")
	var spare
	for item in rig.spare_objects:
		if item.get_meta("laboratory") and item.get_meta("spare")=="SPARE-2T": spare=item
	pose(trackers[2],spare.global_position+Vector3(0,0,0.35),spare.global_position); await frames()
	rig.pressed(rig.right,"grip_click"); await frames()
	check(intro.step==7 and shell.ui.game.sim.state.world.held=="SPARE-2T","XR grip konkrétního cvičného dílu")
	pose(trackers[2],Vector3(10,1.3,-4.7),Vector3(10,1.3,-5.5)); await frames()
	rig.released(rig.right,"grip_click"); await frames()
	check(intro.step==8,"XR bezpečné vrácení do správné skříně")
	rig.pressed(rig.left,"by_button"); rig.released(rig.left,"by_button"); await frames()
	await click_button(button("Pokračovat"),trackers[2])
	check(not intro.active and not shell.ui.game.introduction_active,"XR zakončení/úklid praktického úvodu")
