extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var shell
var checks=0
var failures=0

func _init():
	Saves.path_override="user://academy_test_world_ui.json"
	Settings.path_override="user://academy_test_world_ui.cfg"
	Saves.save_game({},true); Settings.new().save_settings()
	call_deferred("run")

func check(ok,message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func frames():
	for i in 5: await process_frame

func escape():
	var event=InputEventKey.new(); event.keycode=KEY_ESCAPE; event.pressed=true
	var destination=root
	for window in shell.ui.get_children():
		if window is Window and window.visible: destination=window
	if destination==root: destination.push_input(event,true)
	else: destination.window_input.emit(event)
	event.pressed=false
	if destination==root: destination.push_input(event,true)
	await frames()

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell)
	await frames()
	var ui=shell.ui
	ui.game.start_mission(0,true)
	ui.first_shift_requested=true
	shell.enter_world()
	check(shell.mode=="introduction" and not shell.world.player.enabled,"První směna nabídne přeskočitelné seznámení")
	await capture("introduction")
	shell.finish_introduction()
	check(shell.mode=="world" and ui.display_settings.introduction_seen,"Přeskočení dovolí hru a uloží se")
	shell.pause_menu()
	shell.settings_from_pause=true; shell.open_app("Nastavení")
	check(not shell.world.player.enabled and shell.mode=="app","Nastavení z pauzy blokuje chůzi")
	await escape()
	check(shell.mode=="pause","Escape z nastavení vrací pauzu")
	shell.open_app("Proxmox")
	ui.open_action("management")
	var input=ui.form_controls.management.hostname
	input.grab_focus()
	var before=shell.world.player.position
	var key=InputEventKey.new(); key.physical_keycode=KEY_W; key.keycode=KEY_W; key.unicode=119; key.pressed=true
	root.push_input(key,true); await frames()
	check(shell.world.player.position==before and not shell.world.player.enabled,"Psaní do formuláře neovládá hráče")
	key.pressed=false; root.push_input(key,true)
	ui.show_message("Modální dialog","Escape má zavřít pouze tento dialog.")
	await escape()
	check(shell.mode=="app","Escape dialogu ponechá konzoli otevřenou")
	await escape()
	check(shell.mode=="world","Další Escape vrátí 3D")
	# F11 uses a modal confirmation; failed settings writes roll back.
	ui.open_settings()
	var previous=Settings.path_override
	var blocked=ProjectSettings.globalize_path("user://academy_test_settings_blocked")
	DirAccess.make_dir_absolute(blocked)
	Settings.path_override=blocked
	var old_volume=ui.display_settings.volume
	check(not ui.save_preference("volume",0.12) and ui.display_settings.volume==old_volume,"Chyba zápisu nezmění potvrzenou hlasitost")
	for node in ui.get_children():
		if node is AcceptDialog: node.hide(); node.queue_free()
	ui.preview_display(Vector2i(1280,720),true); ui.resolve_display(true)
	check(not ui.display_settings.fullscreen,"Chyba zápisu obrazu vrátí potvrzený režim")
	Settings.path_override=previous
	DirAccess.remove_absolute(blocked)
	for node in ui.get_children():
		if node is AcceptDialog: node.hide(); node.queue_free()
	ui.close_settings()
	# Actual preset effects, including the compatibility renderer.
	var metrics=[]
	ui.apply_display_settings(Vector2i(1920,1080),false)
	shell.return_to_world()
	shell.world.player.position=Vector3(6.6,0.02,4.2)
	shell.world.player.camera.look_at(Vector3(-0.7,1.45,-3))
	for preset in ["Úsporná","Vyvážená","Vysoká"]:
		ui.save_preference("quality",preset)
		var expected=Viewport.MSAA_DISABLED if preset=="Úsporná" else (Viewport.MSAA_2X if preset=="Vyvážená" else Viewport.MSAA_4X)
		check(root.msaa_3d==expected,"Předvolba skutečně mění MSAA: "+preset)
		for node in shell.world.find_children("*","WorldEnvironment",true,false):
			check(node.environment.ssr_enabled==(RenderingServer.get_current_rendering_method()=="forward_plus" and preset=="Vysoká"),"Předvolba mění skutečné odlesky")
		if "--benchmark" in OS.get_cmdline_user_args():
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED); Engine.max_fps=0
			for i in 30: await process_frame
			var begin=Time.get_ticks_usec()
			for i in 90: await process_frame
			var elapsed=(Time.get_ticks_usec()-begin)/90000.0
			metrics.append({"quality":preset,"mean_ms":elapsed,"fps":1000.0/elapsed})
		await capture("quality-"+str(metrics.size()) if not metrics.is_empty() else "quality-"+preset)
	if not metrics.is_empty():
		var file=FileAccess.open("res://test-output/ux-quality-benchmark.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(metrics,"  ")); file.close()
		print("QUALITY BENCHMARK: "+JSON.stringify(metrics))
	ui.save_preference("fps_limit",60)
	check(Engine.max_fps==60,"FPS limit je aktivní")
	ui.save_preference("fps_limit",0)
	# All three lesson modes describe the active session; notice is hidden in apps.
	shell.enter_world("Trénink")
	for mode in ["learn","practice","exam"]:
		ui.begin_lesson(1002,mode,false)
		shell.update_time=1.0; shell._process(0.01)
		check(not "vyber si lekci" in shell.status_label.text and "Vytvoření Linux VM" in shell.status_label.text,"HUD ukazuje aktivní lekci / "+mode)
		check(not shell.room_notice.visible,"Aktivní lekce neukazuje staré oznámení výběru")
		await capture("hud-"+mode)
		if mode=="learn":
			check(shell.instruction_plate.size.y<282,"Krátké instrukce zmenší panel")
			shell.open_app("Proxmox"); ui.open_action("pve_resources"); await frames()
			await capture("world-console")
		shell.open_app("Trénink"); shell._process(0.01)
		check(not shell.room_notice.visible,"Oznámení nepřekrývá nabídku lekcí")
	ui.search_queries.lessons="Vytvoření Linux"; ui.draw_ui()
	check(find_label(ui,"Vytvoření Linux VM") and not find_label(ui,"Příprava Proxmox hostitele"),"Výuka filtruje názvy")
	shell.queue_free(); await frames(); OS.delay_msec(80)
	print("WORLD UI: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)

func find_label(node: Node,text: String) -> bool:
	if node is Label and node.text==text: return true
	for child in node.get_children():
		if find_label(child,text): return true
	return false

func capture(title: String):
	if DisplayServer.get_name()=="headless" or not "--screenshots" in OS.get_cmdline_user_args(): return
	await frames(); await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/ux-"+title+".png")
