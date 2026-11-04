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
var desktop_focus_outs=0

func _init():
	root.focus_exited.connect(func(): desktop_focus_outs+=1; print("TEST WINDOW FOCUS OUT / ",desktop_focus_outs))
	root.gui_embed_subwindows=true
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_continuation_review_"+tag+".json"
	Display.path_override="user://academy_test_continuation_review_"+tag+".cfg"
	Comfort.path_override="user://academy_test_continuation_review_"+tag+"_vr.cfg"
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
	var folder="res://docs/ui-review/2026-11-03-continuation"
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
	if viewport is Window and viewport!=root and viewport.is_embedded(): at+=Vector2(viewport.position); viewport=root if hand==null else rig.monitor.viewport
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

func show_screen(screen):
	var g=shell.ui.game
	for w in shell.ui.find_children("*","Window",true,false): w.hide(); w.queue_free()
	if screen=="code":
		shell.enter_world("Programming Academy"); g.programming.start("PY01","practice"); shell.open_programming(); await frames(); shell.code_editor.load_current()
		shell.code_editor.editor.select_all(); shell.code_editor.editor.insert_text_at_caret("# moje rozepsaná práce\nprint("); shell.code_editor.capture_editor_state(); g.save()
		shell.code_editor.show_drafts()
	elif screen.begins_with("listening"):
		shell.enter_world("English in London"); g.english.progress.intro_seen=true
		g.english.listening.start("LONL01","practice",19); shell.open_english("listening")
		if screen=="listening-result":
			g.english.listening.answer("ticket_options",g.english.listening.revision); shell.english_dialog.draw()
	else:
		shell.enter_world("Hlavní serverovna")
		if screen=="shift": shell.open_app("Souvislé směny")
		elif screen=="profile": shell.open_app("Moje znalosti")
		elif screen=="settings": shell.open_app("Nastavení")
		else:
			shell.open_app("Pokračování")
			if screen=="review": preload("res://scripts/ui/DebriefPresentation.gd").show(shell.ui,g.work.data.reviews[0])
	await frames()
	if screen=="settings":
		var version=shell.ui.find_child("GameVersionLabel",true,false)
		check(version!=null and version.text=="Verze hry: 1.5.0" and version.is_visible_in_tree() and version.get_viewport().get_visible_rect().encloses(version.get_global_rect().grow(-0.5)),"Aktuální verze je čitelná v nastavení PC i VR")

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var g=shell.ui.game; var ui=shell.ui
	# Actual verified repair creates the review fixture; no finished/XP assignment.
	shell.enter_world("Hlavní serverovna"); g.start_mission(3,true)
	g.apply("physical_inspect",{"device":"PVE-01"}); g.apply("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true}); g.apply("verify",{})
	check(g.complete().ok,"Skutečná oprava pro uložený rozbor")
	g.shifts.start("SHIFT-RECOVERY")
	var screens=["continuation","shift","review","code","listening","listening-result","profile","settings"]
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for scale_value in [1.0,1.3]:
			suffix=str(resolution.x)+"-"+str(roundi(scale_value*100))
			ui.apply_display_settings(resolution,false); ui.save_preference("text_scale",scale_value)
			for screen in screens:
				await show_screen(screen)
				await capture(screen)
				var buttons=shell.find_children("*","Button",true,false).filter(func(b): return b.is_visible_in_tree())
				check(buttons.size()>1,"Ovládání dostupné "+screen)
				var last=buttons.back()
				for scroll in ui.get_scroll_ancestors(last): scroll.ensure_control_visible(last); scroll.scroll_vertical+=4
				await frames()
				check(last.get_viewport().get_visible_rect().encloses(last.get_global_rect().grow(-0.5)),"Poslední ovladač dostupný po posuvu "+screen+" / "+suffix)
	# Synthetic tracker poses, actual monitor, actual ray input and embedded windows.
	ui.apply_display_settings(Vector2i(1600,900),false)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; shell.xr_rig=rig; shell.world.player.add_child(rig); shell.vr_active=true
	var head=XRPositionalTracker.new(); head.name="head"; head.type=XRServer.TRACKER_HEAD
	head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(head); trackers.append(head)
	for name in ["left_hand","right_hand"]:
		var tracker=XRControllerTracker.new(); tracker.name=name; tracker.type=XRServer.TRACKER_CONTROLLER; tracker.set_input("primary",Vector2.ZERO)
		for p in ["aim","grip"]: tracker.set_pose(p,Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		XRServer.add_tracker(tracker); trackers.append(tracker)
	rig.activate(false); await frames()
	for scale_value in [1.0,1.3]:
		ui.save_preference("text_scale",scale_value)
		for panel in [Vector2(0.8,0.9),Vector2(1.4,2.0)]:
			rig.settings.panel_scale=panel.x; rig.settings.panel_distance=panel.y; rig.monitor.configure(rig.settings)
			suffix="vr-"+str(roundi(scale_value*100))+"-panel"+str(panel.x)
			for screen in screens:
				await show_screen(screen); rig.monitor.place_in_front(rig.head)
				check(rig.monitor.viewport.size==Vector2i(1600,1200),"Původní viewport beze změny")
				var center=rig.monitor.global_position
				check(rig.monitor.pixel_at(center+rig.monitor.global_basis.z,-rig.monitor.global_basis.z).distance_to(Vector2(800,600))<0.1,"Fyzický panel/ray/pixel souhlasí")
				await capture(screen,rig.monitor.viewport)
				var windows=ui.find_children("*","Window",true,false).filter(func(w): return w.visible)
				for w in windows: w.hide()
				var field=LineEdit.new(); field.position=Vector2(170,820); field.size=Vector2(600,45); rig.monitor.keyboard.get_parent().add_child(field)
				field.grab_focus(); rig.monitor.keyboard.track_focus(); await frames()
				for w in windows: w.show()
				await frames()
				check(rig.monitor.keyboard.visible,"Klávesnice otevřená "+screen)
				await capture(screen+"-keyboard",rig.monitor.viewport)
				for w in windows: w.hide()
				rig.monitor.keyboard.dismiss(); field.queue_free(); await frames()
				if screen=="listening":
					if DisplayServer.get_name()!="headless": root.grab_focus()
					await frames()
					var focus_before=desktop_focus_outs
					await click_button(button("Poslechnout / zopakovat"),trackers[1])
					if not shell.speech.playing and desktop_focus_outs>focus_before:
						check(not g.english.listening.session.completed,"Desktop focus-out nezvolí poslechovou odpověď")
						root.grab_focus(); await frames(); await click_button(button("Poslechnout / zopakovat"),trackers[1])
					if not shell.speech.playing: print("XR AUDIO DIAGNOSTIC ",suffix," plays=",g.english.listening.session.plays," mode=",shell.mode," focused=",rig.focused," generation=",shell.speech.play_generation," window_focus=",root.has_focus()," pixel=",rig.monitor.last_pixel)
					check(shell.speech.playing,"Levý ray úplný trigger přehrává")
					await click_button(button("Pomaleji"),trackers[2]); check(shell.speech.playing and shell.speech.pitch_scale==1.0,"Pravý ray pomalá varianta")
					rig.lose_focus(); check(not shell.speech.playing,"Focus zastaví nový poslech"); rig.focused=true
	await pointer_safety()
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.request_play_mode("desktop"); shell.queue_free(); await frames()
	print("CONTINUATION REVIEW: %d checks, %d failures; PC matrix and synthetic XR, no headset" % [checks,failures]); quit(1 if failures else 0)

func pointer_safety():
	await show_screen("listening")
	var ui=shell.ui; var g=ui.game
	var test=Button.new(); test.text="XR ovládání"; test.position=Vector2(500,300); test.size=Vector2(300,60); rig.monitor.keyboard.get_parent().add_child(test)
	var counter=[0]; test.pressed.connect(func(): counter[0]+=1)
	var at=test.get_global_rect().get_center()
	var world=rig.monitor.to_global(Vector3((at.x/1600-0.5)*rig.monitor.dimensions.x,(0.5-at.y/1200)*rig.monitor.dimensions.y,0))
	for tracker in [trackers[1],trackers[2]]: pose(tracker,world+rig.monitor.global_basis.z*0.8,world)
	await frames()
	rig.pressed(rig.left,"trigger_click"); rig.pressed(rig.right,"trigger_click"); rig.released(rig.right,"trigger_click"); rig.released(rig.left,"trigger_click"); await frames()
	check(counter[0]==1,"Současné triggery provedou jedinou akci")
	rig.pressed(rig.right,"trigger_click"); rig.monitor.point(Vector2(-1,-1)); rig.released(rig.right,"trigger_click"); await frames()
	check(counter[0]==1 and not rig.monitor.pointer_down,"Uvolnění mimo tlačítko nic nepotvrdí")
	await click_button(test,trackers[2]); await click_button(test,trackers[1]); check(counter[0]==3,"Opakované úplné triggery fungují oběma rukama")
	var stable_count=counter[0]
	rig.pressed(rig.left,"trigger_click"); rig.lose_focus(); await frames()
	check(counter[0]==stable_count and not rig.monitor.pointer_down,"Focus-out zruší držený trigger bez potvrzení tlačítka")
	rig.focused=true
	rig.pressed(rig.left,"trigger_click"); trackers[0].invalidate_pose("default")
	for i in 4: await physics_frame
	await frames()
	check(counter[0]==stable_count and not rig.monitor.pointer_down,"Ztráta trackingu zruší trigger bez potvrzení")
	trackers[0].set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); await frames()
	rig.pressed(rig.right,"trigger_click"); rig.monitor.configure(rig.settings); await frames()
	check(counter[0]==stable_count and not rig.monitor.pointer_down,"Změna panelu zruší původní stisk bez potvrzení")
	rig.pressed(rig.left,"trigger_click"); XRServer.remove_tracker(trackers[0])
	for i in 4: await physics_frame
	await frames()
	check(counter[0]==stable_count and not rig.monitor.pointer_down,"Odebraný head tracker zruší trigger bez potvrzení")
	XRServer.add_tracker(trackers[0]); await frames()
	rig.pressed(rig.left,"trigger_click"); rig.pressed(rig.right,"ax_button"); rig.released(rig.right,"ax_button"); await frames()
	check(counter[0]==stable_count and not rig.monitor.pointer_down,"A/X přemístí panel a zruší držený trigger")
	var slider=HSlider.new(); slider.position=Vector2(500,400); slider.size=Vector2(400,50); rig.monitor.keyboard.get_parent().add_child(slider); await frames()
	rig.monitor.point(Vector2(510,425)); rig.monitor.click(true); rig.monitor.point(Vector2(850,425)); rig.monitor.click(false); await frames(); check(slider.value>70,"Skutečný drag ve VR viewportu")
	test.queue_free(); slider.queue_free(); await show_screen("profile")
	var scroll=ui.center.find_children("*","ScrollContainer",true,false)[0]
	rig.monitor.point(Vector2(1000,600)); var before=scroll.scroll_vertical
	for i in 8: rig.monitor.scroll(-1)
	await frames(); check(scroll.scroll_vertical>before,"Skutečný scroll dlouhého profilu")
	rig.pressed(rig.left,"ax_button"); rig.released(rig.left,"ax_button"); check(rig.monitor.global_position.distance_to(rig.head.global_position)>0.8,"A/X přemístí panel")
	rig.pressed(rig.right,"by_button"); rig.released(rig.right,"by_button"); check(shell.mode=="world","B/Y vrací do světa")
	await show_screen("listening"); shell.speech.listen("LONL01",false); await frames(); trackers[0].invalidate_pose("default")
	for i in 4: await physics_frame
	await frames(); check(not shell.speech.playing,"Ztráta head tracking zastaví poslech")
	trackers[0].set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); rig.focused=true
	shell.enter_world("Hlavní serverovna"); g.shifts.resume(); var clock=g.sim.state.shift_runtime.clock
	shell.pause_menu(); rig.lose_focus(); await create_timer(0.1).timeout
	check(g.sim.state.shift_runtime.clock==clock,"Pauza/focus neposunou simulační čas")
func pose(tracker, origin, target):
	var transform=Transform3D(Basis().looking_at(target-origin),origin)
	var local=rig.global_transform.affine_inverse()*transform
	for name in ["aim","grip"]: tracker.set_pose(name,local,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)

