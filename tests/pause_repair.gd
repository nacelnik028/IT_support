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
var save_path=""
var capture_directory="res://docs/ui-review/2026-11-04-interface/"

func _init():
	if "--review-current" in OS.get_cmdline_user_args(): capture_directory="res://docs/ui-review/2026-11-05-alex-portals-editor/"
	DirAccess.make_dir_recursive_absolute(capture_directory)
	var tag="user://academy_test_pause_repair_"+str(OS.get_process_id())
	save_path=tag+".json"; Saves.path_override=save_path; Display.path_override=tag+".cfg"; Comfort.path_override=tag+"_vr.cfg"
	Saves.save_game({},true); call_deferred("run")

func check(ok: bool, title: String):
	checks+=1
	if not ok: failures+=1; push_error(title+" / "+suffix)

func frames(n: int = 8):
	for i in n: await process_frame

func button(title: String):
	for b in shell.find_children("*","Button",true,false):
		if b.is_visible_in_tree() and b.text==title: return b
	check(false,"Chybí skutečné tlačítko "+title); return null

func click(b, hand: int = -1):
	if b==null: return
	var parent=b.get_parent()
	while parent!=null:
		if parent is ScrollContainer: parent.ensure_control_visible(b)
		parent=parent.get_parent()
	await frames()
	var viewport=b.get_viewport(); var at=b.get_global_rect().get_center()
	check(viewport.get_visible_rect().encloses(b.get_global_rect()),"Cíl kliku je celý viditelný: "+b.text)
	if viewport is Window and viewport!=root and viewport.is_embedded():
		at=Vector2(viewport.position)+at*Vector2(viewport.size)/viewport.get_visible_rect().size
		viewport=rig.monitor.viewport if hand>=0 else root
	if hand>=0:
		var monitor=rig.monitor
		var pixel=Vector3((at.x/1600-0.5)*monitor.dimensions.x,(0.5-at.y/1200)*monitor.dimensions.y,0)
		var pose=rig.global_transform.affine_inverse()*Transform3D(monitor.global_basis,monitor.to_global(pixel)+monitor.global_basis.z*0.8)
		trackers[hand+1].set_pose("aim",pose,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		for tick in 2: await physics_frame
		await frames()
		rig.pressed(rig.left if hand==0 else rig.right,"trigger_click"); await frames(2)
		rig.released(rig.left if hand==0 else rig.right,"trigger_click")
	else:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		var move=InputEventMouseMotion.new(); move.position=at; viewport.push_input(move,true)
		for down in [true,false]:
			var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; event.button_mask=MOUSE_BUTTON_MASK_LEFT if down else 0; viewport.push_input(event,true)
	await frames()

func escape():
	var event=InputEventKey.new(); event.keycode=KEY_ESCAPE; event.physical_keycode=KEY_ESCAPE; event.pressed=true
	root.push_input(event,true); event=event.duplicate(); event.pressed=false; root.push_input(event,true); await frames()

func capture(title: String, viewport=null):
	if DisplayServer.get_name()=="headless" or "--screenshots" not in OS.get_cmdline_user_args(): return
	await frames(); await RenderingServer.frame_post_draw
	var target=viewport if viewport!=null else root
	check(target.get_texture().get_image().save_png(capture_directory+title+"-"+suffix+"-"+RenderingServer.get_current_rendering_method()+".png")==OK,"Snímek "+title)

func check_panel():
	var panel=shell.overlay.find_child("CompactPause",true,false)
	check(panel!=null,"Pauza má vlastní kompaktní panel")
	check(shell.overlay.get_viewport().get_visible_rect().encloses(panel.get_global_rect()),"Pauza se celá vejde do viewportu")
	check(panel.get_global_rect().size.x<shell.overlay.get_viewport().get_visible_rect().size.x*0.65,"Pauza nezabírá celou šířku")
	check(shell.overlay.find_children("*","ScrollContainer",true,false).is_empty(),"Základní pauza nemá posouvání")
	check(not shell.world.player.enabled,"Pauza skutečně zastaví chůzi")

func run():
	DirAccess.make_dir_recursive_absolute("res://docs/ui-review/2026-11-04-interface")
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var ui=shell.ui; var g=ui.game
	g.english.progress.intro_seen=true
	shell.enter_world("Hlavní serverovna"); g.start_mission(3); g.sim.state.hosts["PVE-01"].hostname="repair-preserved"
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for text_scale in [1.0,1.3]:
			suffix="%d-%d" % [resolution.x,roundi(text_scale*100)]
			ui.apply_display_settings(resolution,false); ui.save_preference("text_scale",text_scale)
			ui.page="menu"; ui.draw_ui(); shell.set_mode("menu"); await frames()
			var credit=ui.find_child("AuthorCredit",true,false)
			check(credit.text=="Vytvořil Vít Kellner" and credit.get_line_count()==1 and root.get_visible_rect().encloses(credit.get_global_rect()),"Přesný podpis bez ořezu")
			await capture("menu")
			shell.enter_world("Hlavní serverovna"); shell.pause_menu(); await frames(); check_panel(); await capture("pause")
			check(shell.overlay.find_children("*","Button",true,false).size()<=6,"Základní pauza má nanejvýš jeden kontextový příkaz")
			await click(button("Kam jít")); check(shell.pause_page=="destinations","Klik otevře cíle"); await capture("destinations")
			await escape(); check(shell.mode=="pause" and shell.pause_page=="main","Esc z cílů vrátí základní pauzu")
			await click(button("Nastavení")); check(shell.mode=="app" and ui.page=="Nastavení","Nastavení funguje z pauzy")
			await click(ui.ui_targets["settings:Ovládání"]); await click(button("Nápověda a praktický úvod")); check(shell.pause_page=="help","Přesunutá nápověda je dostupná")
			await escape(); check(shell.mode=="app" and ui.page=="Nastavení","Esc z nápovědy vrátí nastavení")
			await click(ui.ui_targets["settings:Postup"]); await click(button("Exportovat / importovat postup")); check(shell.pause_page=="transfer","Přesunutý přenos je dostupný")
			await escape(); check(shell.mode=="app" and ui.page=="Nastavení","Esc z přenosu vrátí nastavení")
			await escape(); check(shell.mode=="pause","Esc z nastavení vrátí pauzu")
			await click(button("Pokračovat")); check(shell.mode=="world" and shell.world.player.enabled,"Pokračovat obnoví chůzi")
	for destination in ["Rozcestník akademie","IT trénink","Programování","English in London","Serverovna"]:
		shell.pause_menu(); await click(button("Kam jít")); await click(button(destination))
		check(shell.mode=="world","Skutečný klik vstoupí do cíle "+destination)
	check(g.current.id==4 and g.sim.state.hosts["PVE-01"].hostname=="repair-preserved","Cesty z nové pauzy zachovaly kampaň")
	shell.pause_menu(); await click(button("Kam jít")); await click(button("Tickety a směny")); await click(button("Souvislé směny"))
	check(ui.page=="Souvislé směny" and shell.mode=="app","Původní směny zůstaly dostupné bez automatického zahájení")
	Saves.path_override="user://missing-pause-repair-"+str(OS.get_process_id())+"/save.json"; g.save(); shell.pause_menu(); await frames()
	check_panel(); await click(button("Uložit a hlavní menu")); check(shell.mode=="pause" and g.unsaved,"Chyba zápisu nepustí do menu")
	Saves.path_override=save_path; g.save()
	ui.apply_display_settings(Vector2i(1600,900),false)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; shell.xr_rig=rig; shell.world.player.add_child(rig)
	var head=XRPositionalTracker.new(); head.name="head"; head.type=XRServer.TRACKER_HEAD; head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(head); trackers.append(head)
	for name_value in ["left_hand","right_hand"]:
		var tracker=XRControllerTracker.new(); tracker.name=name_value; tracker.type=XRServer.TRACKER_CONTROLLER
		tracker.set_input("primary",Vector2.ZERO); tracker.set_input("trigger_click",false)
		tracker.set_pose("aim",Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(tracker); trackers.append(tracker)
	shell.vr_active=true; rig.activate(false); await frames()
	for text_scale in [1.0,1.3]:
		ui.save_preference("text_scale",text_scale); suffix="vr-%d" % roundi(text_scale*100)
		for hand in [0,1]:
			shell.pause_menu(); await frames(); check_panel(); await capture("pause",rig.monitor.viewport)
			await click(button("Kam jít"),hand); check(shell.pause_page=="destinations","Obě ruce otevřou Kam jít")
			await click(button("Zpět do pauzy"),hand); check(shell.pause_page=="main","Obě ruce vrátí pauzu")
			await click(button("Komfort VR"),hand); check(shell.pause_page=="vr","Komfort VR je přímo dostupný")
			shell.pause_menu(); await click(button("Pokračovat"),hand); check(shell.mode=="world","Obě ruce pokračují ze skutečné pauzy")
	rig.deactivate(); shell.vr_active=false
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.queue_free(); await frames()
	print("PAUSE REPAIR: %d checks, %d failures; PC and synthetic XR" % [checks,failures]); quit(1 if failures else 0)
