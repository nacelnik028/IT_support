extends SceneTree

const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
var ui
var failures=0
var checks=0

func _init():
	Saves.path_override="user://academy_test_display_game.json"
	Settings.path_override="user://academy_test_display.cfg"
	call_deferred("run")

func check(ok,message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func run():
	# Isolated settings and save; never change a player's preferences or progress.
	var settings=Settings.new()
	settings.save_settings()
	ui=load("res://scenes/main_menu/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	check(find_button(ui,"Ukončit hru")!=null,"Hlavní menu má tlačítko pro ukončení")
	check(find_button(ui,"Nastavení")!=null,"Hlavní menu má nastavení")
	find_button(ui,"Nastavení").pressed.emit()
	await process_frame
	await process_frame
	check(ui.page=="Nastavení","Otevření nastavení skutečným tlačítkem")
	check(ui.settings_controls.resolution.item_count==Settings.RESOLUTIONS.size(),"Všechna rozlišení jsou v nabídce")
	check_settings_visible()
	ui.game.start_mission(3,false)
	ui.game.sim.state.vms["100"].vlan=39
	for index in Settings.RESOLUTIONS.size():
		var resolution=Settings.RESOLUTIONS[index]
		check(resolution.x*9==resolution.y*16,"Pouze poměr16:9")
		ui.settings_controls.resolution.select(index)
		ui.settings_controls.fullscreen.button_pressed=false
		ui.settings_controls.apply.pressed.emit()
		await process_frame
		await process_frame
		check(root.content_scale_size==resolution,"Skutečné vykreslovací rozlišení "+str(resolution))
		check(root.get_visible_rect().size==Vector2(resolution),"Viewport používá zvolený počet pixelů")
		check(ui.size==Vector2(Settings.DESIGN_SIZE),"Rozhraní má stabilní čitelný layout")
		check_settings_visible()
		var reloaded=Settings.new(); reloaded.load_settings()
		check(reloaded.resolution==resolution and not reloaded.fullscreen,"Volba se ukládá a znovu načítá")
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_size()==Vector2(resolution),"GPU opravdu renderuje zvolené rozlišení")
		if resolution==Vector2i(1280,720): await capture("settings-720p")
		if resolution==Vector2i(3840,2160): await capture("settings-4k")
	check(ui.game.sim.state.vms["100"].vlan==39,"Změna rozlišení nezměnila simulaci")
	# The persistence banner shares vertical space with the settings page.
	ui.game.load_warning="Testovací upozornění: uložený postup nebyl načten."
	for resolution in [Vector2i(1280,720),Vector2i(3840,2160)]:
		ui.apply_display_settings(resolution,false)
		await process_frame
		await process_frame
		check_settings_visible()
		await capture("settings-warning-"+str(resolution.x))
	ui.game.load_warning=""
	ui.draw_ui()
	await process_frame
	await process_frame
	ui.settings_controls.fullscreen.button_pressed=true
	ui.settings_controls.apply.pressed.emit()
	await process_frame
	check(ui.display_settings.fullscreen,"Celá obrazovka zapnutá v nastavení")
	if DisplayServer.get_name()!="headless": check(root.mode==Window.MODE_EXCLUSIVE_FULLSCREEN,"Skutečný režim celé obrazovky")
	var saved=Settings.new(); saved.load_settings()
	check(saved.fullscreen and saved.resolution==Vector2i(3840,2160),"4K a fullscreen zůstávají uložené")
	var f11=InputEventKey.new(); f11.keycode=KEY_F11; f11.pressed=true
	ui._unhandled_key_input(f11)
	await process_frame
	check(not ui.display_settings.fullscreen,"F11 vypne celou obrazovku")
	if DisplayServer.get_name()!="headless": check(root.mode==Window.MODE_WINDOWED,"Skutečný návrat do okna")
	# Tutorial highlight must follow scaled controls at 4K, not double its coordinates.
	ui.game.enter_training()
	ui.begin_lesson(1002,"learn",false)
	ui.game.notify_event({"type":"server_selected","host":"PVE-01"})
	ui.game.notify_event({"type":"node_selected","host":"PVE-01"})
	ui.game.notify_event({"type":"action_opened","action":"create_vm"})
	ui.game.apply("vm_identity",{"id":"101","name":"WEB01"})
	ui.game.apply("vm_media",{"vm":"101","iso":"debian.iso"})
	ui.recover_tutorial_target()
	await process_frame
	await process_frame
	await process_frame
	check(is_instance_valid(ui.tutorial_overlay),"Výukové zvýraznění funguje ve4K")
	check(ui.tutorial_overlay.target==ui.form_controls.vm_resources.ram_mib,"Zvýrazněno skutečné RAM pole")
	var ancestor=ui.tutorial_overlay.target.get_parent()
	while ancestor is Control:
		if ancestor is ScrollContainer:
			check(ancestor.get_global_rect().encloses(ui.tutorial_overlay.target.get_global_rect()),"Zvýrazněné pole je skutečně viditelné ve4K")
		ancestor=ancestor.get_parent()
	await capture("tutorial-4k")
	# Test the real exit button in a separate process invocation.
	ui.page="menu"; ui.draw_ui()
	await process_frame
	await capture("menu-display-buttons")
	if "--quit-button" in OS.get_cmdline_user_args():
		print("DISPLAY SETTINGS: %d checks, %d failures; triggering exit button" % [checks,failures])
		if failures>0: quit(1); return
		find_button(ui,"Ukončit hru").pressed.emit()
		return
	ui.apply_display_settings(Vector2i(1600,900),false)
	await process_frame
	ui.queue_free(); await process_frame
	print("DISPLAY SETTINGS: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)

func find_button(node: Node,text: String):
	if node is Button and node.text==text: return node
	for child in node.get_children():
		var result=find_button(child,text)
		if result: return result
	return null

func check_settings_visible():
	for key in ["fullscreen","resolution","apply"]:
		check(on_screen(ui.settings_controls[key]),"Nastavení je skutečně viditelné a není oříznuté: "+key)

func on_screen(control: Control) -> bool:
	if not control.is_visible_in_tree(): return false
	var rect=control.get_global_rect()
	if not rect.has_area() or not root.get_visible_rect().encloses(rect): return false
	var ancestor=control.get_parent()
	while ancestor is Control:
		if (ancestor is ScrollContainer or ancestor.clip_contents) and not ancestor.get_global_rect().encloses(rect): return false
		ancestor=ancestor.get_parent()
	return true

func capture(title):
	if not "--screenshots" in OS.get_cmdline_user_args() or DisplayServer.get_name()=="headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/"+title+".png")
