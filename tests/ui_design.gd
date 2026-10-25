extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var ui
var checks=0
var failures=0
var suffix=""

func _init():
	var renderer="_gpu" if DisplayServer.get_name()!="headless" else ""
	Saves.path_override="user://academy_test_ui_design"+renderer+".json"
	Settings.path_override="user://academy_test_ui_design"+renderer+".cfg"
	Saves.save_game({},true)
	Settings.new().save_settings()
	call_deferred("run")

func check(ok, message):
	checks+=1
	if not ok: failures+=1; push_error(message+" "+suffix)

func frames():
	for i in 5: await process_frame
	if DisplayServer.get_name()!="headless": await RenderingServer.frame_post_draw

func visible(control):
	if not is_instance_valid(control) or not control.is_visible_in_tree(): return false
	var rect=control.get_global_rect()
	if not rect.has_area() or not root.get_visible_rect().encloses(rect): return false
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor.clip_contents and not ancestor.get_global_rect().encloses(rect): return false
		ancestor=ancestor.get_parent()
	return true

func reveal(control):
	if not is_instance_valid(control): return
	for ancestor in ui.get_scroll_ancestors(control):
		var rect=ancestor.get_child(0).get_global_transform().affine_inverse()*control.get_global_rect()
		ancestor.scroll_vertical=maxi(0,roundi(rect.end.y-ancestor.size.y+12))
	await frames()

func click(control):
	await reveal(control)
	check(visible(control),"Akce je viditelná a dostupná myší")
	if not visible(control): return
	var at=control.get_global_rect().get_center()
	var motion=InputEventMouseMotion.new(); motion.position=at; root.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; event.position=at
		root.push_input(event,true)
		await process_frame
	await frames()

func find_button(node, caption):
	if node is Button and node.text==caption: return node
	for child in node.get_children():
		var found=find_button(child,caption)
		if found: return found
	return null

func capture(title):
	if DisplayServer.get_name()=="headless" or not "--screenshots" in OS.get_cmdline_user_args(): return
	await frames()
	root.get_texture().get_image().save_png("res://test-output/design-final-"+title+"-"+suffix+".png")

func run():
	ui=load("res://scenes/main_menu/Main.tscn").instantiate(); root.add_child(ui)
	await frames()
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for text_scale in [1.0,1.3]:
			suffix=str(resolution.x)+"-"+str(roundi(text_scale*100))
			ui.game.leave_training()
			ui.apply_display_settings(resolution,false)
			ui.save_preference("text_scale",text_scale)
			ui.page="menu"; ui.draw_ui(); await frames()
			check(visible(ui.ui_targets["menu:primary"]),"Hlavní akce menu je ihned vidět")
			check(ui.ui_targets["menu:primary"].theme_type_variation=="PrimaryButton","Menu má odlišenou hlavní akci")
			await capture("menu")
			await click(find_button(ui,"Nastavení"))
			await click(ui.ui_targets["settings:Obraz"])
			check(ui.page=="Nastavení" and visible(ui.settings_controls.apply),"Nastavení má dostupné potvrzení obrazu")
			await capture("settings")
			await click(ui.ui_targets["settings:Ovládání"])
			check(visible(ui.ui_targets["binding:flashlight"]),"Klávesy se vejdou i se zvětšeným textem")
			await capture("controls")
			await click(find_button(ui,"← Zpět"))
			ui.game.start_mission(3,false)
			ui.navigate("Proxmox"); ui.open_action("management"); await frames()
			check(visible(ui.form_buttons.management),"Potvrzení síťového formuláře je vidět")
			check(visible(ui.ui_targets["console:context"]),"Platforma a hostitel jsou stále vidět")
			check(ui.ui_targets["nav:Proxmox"].button_pressed,"Výběr navigace je skutečný stav tlačítka")
			await capture("proxmox")
			var score_errors=ui.game.sim.state.errors
			ui.form_controls.management.ip.text="chybná IP"
			await click(ui.form_buttons.management)
			var error=ui.ui_targets["error:management:ip"]
			check(visible(error) and "IPv4" in error.text,"Chyba je u konkrétního pole")
			check(ui.form_controls.management.ip.has_focus(),"Validace předá fokus chybnému poli")
			check(ui.game.sim.state.errors==score_errors,"Formátová chyba nemění skóre")
			await capture("validation")
			# A real key edit removes the inline error without rebuilding the form.
			var field=ui.form_controls.management.ip
			field.select_all()
			var key=InputEventKey.new(); key.pressed=true; key.keycode=KEY_1; key.unicode=49
			root.push_input(key,true); await frames()
			check(not error.visible and field.has_focus(),"Psaní odstraní chybu a zachová fokus")
			await click(ui.ui_targets["nav:Hyper-V"])
			ui.open_action("memory"); await frames()
			check(ui.host=="HV-01" and visible(ui.ui_targets["console:context"]),"Hyper-V má vlastní správný kontext")
			check("200" in ui.ui_targets["console:vm"].text and "FS01" in ui.ui_targets["console:vm"].text,"Záhlaví ukazuje skutečnou VM z formuláře i bez kliknutí ve stromu")
			await capture("hyperv")
			await click(ui.ui_targets["nav:Storage"])
			check(ui.page=="Storage","Navigace otevřela Storage")
			ui.open_action("raid_create"); await frames()
			if not ui.form_buttons.has("raid_create"):
				check(false,"Konfigurátor RAID je otevřený: "+ui.page+" / "+ui.tab+" / "+ui.active_action)
				quit(1); return
			await reveal(ui.form_buttons.raid_create)
			check(visible(ui.form_buttons.raid_create),"Dlouhý diskový formulář má dosažitelné potvrzení")
			await capture("storage")
			await click(ui.ui_targets["nav:Tickety"])
			await capture("missions")
			ui.navigate("Trénink"); await frames()
			check(visible(ui.ui_targets["search:lessons"]),"Filtry lekcí zůstávají viditelné")
			await capture("lessons")
			var search=ui.ui_targets["search:lessons"]
			search.grab_focus(); search.text="žádná-taková-lekce"; search.caret_column=5; search.text_changed.emit(search.text)
			await frames()
			check(ui.ui_targets["search:lessons"].has_focus() and ui.ui_targets["search:lessons"].caret_column==5,"Hledání zachová fokus a kurzor po překreslení")
			ui.search_queries.lessons=""; ui.draw_ui(); await frames()
			await click(find_button(ui,"Učím se"))
			check(ui.game.session_kind=="lesson" and ui.game.tutorial.guided(),"Lekce se spustí skutečným kliknutím")
			await capture("instructor")
			ui.game.leave_training()
	ui.queue_free(); await frames(); await create_timer(0.15).timeout
	print("UI DESIGN MATRIX: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
