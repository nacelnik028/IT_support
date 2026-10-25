extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var ui
var failures=0
var checks=0

func _init():
	Saves.path_override="user://academy_test_console_ux.json"
	Settings.path_override="user://academy_test_console_ux.cfg"
	Saves.save_game({},true)
	Settings.new().save_settings()
	call_deferred("run")

func check(ok,message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func settle():
	for i in 4: await process_frame

func visible(control: Control) -> bool:
	if not control.is_visible_in_tree(): return false
	var rect=control.get_global_rect()
	if not rect.has_area() or not root.get_visible_rect().encloses(rect): return false
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor.clip_contents and not ancestor.get_global_rect().encloses(rect): return false
		ancestor=ancestor.get_parent()
	return true

func reveal(control: Control):
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor is ScrollContainer:
			var content=ancestor.get_child(0)
			var rect=content.get_global_transform().affine_inverse()*control.get_global_rect()
			ancestor.scroll_vertical=roundi(rect.end.y-ancestor.size.y+12)
		ancestor=ancestor.get_parent()
	await settle()

func click(control: Control):
	await reveal(control)
	check(visible(control),"Kliknutelný viditelný prvek: "+str(control.name))
	var at=control.get_global_rect().get_center()
	for down in [true,false]:
		var event=InputEventMouseButton.new()
		event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; event.position=at
		Input.parse_input_event(event)
		await process_frame
	await settle()

func choose(picker: OptionButton,value: String):
	for i in picker.item_count:
		if ui.option_value(picker,i)==value:
			picker.select(i); picker.item_selected.emit(i); return
	check(false,"Nabídka obsahuje "+value)

func run():
	ui=load("res://scenes/main_menu/Main.tscn").instantiate(); root.add_child(ui)
	await settle()
	ui.game.start_mission(11,true)
	ui.navigate("Proxmox")
	ui.selected_vm="100"; ui.draw_ui()
	ui.navigate("Hyper-V")
	check(ui.selected_vm=="" and ui.host=="HV-01","Přechod na platformu ruší nekompatibilní výběr")
	ui.open_action("memory"); await settle()
	check(ui.form_controls.size()==1,"Jediný aktivní formulář")
	for i in ui.form_controls.memory.vm.item_count: check(ui.option_value(ui.form_controls.memory.vm,i)!="100","Hyper-V nenabízí PVE VM")
	ui.game.sim.state.vms["200"].merge({"minimum":3,"ram":7,"maximum":11},true)
	ui.draw_ui()
	check(ui.form_controls.memory.minimum.value==3 and ui.form_controls.memory.ram.value==7 and ui.form_controls.memory.maximum.value==11,"Dynamic Memory čte skutečnou konfiguraci")
	ui.navigate("Proxmox"); ui.open_action("pve_resources")
	ui.game.sim.state.vms["100"].cpu=5; ui.game.sim.state.vms["100"].ram=9; ui.draw_ui()
	check(ui.form_controls.pve_resources.cpu.value==5 and ui.form_controls.pve_resources.ram.value==9,"CPU a RAM PVE jsou aktuální")
	ui.selected_vm=""; ui.host="PVE-02"; ui.draw_ui()
	check(ui.form_controls.pve_resources.vm.item_count==0,"Prázdný uzel nenabízí VM jiného hostitele")
	ui.open_action("prepare")
	check(ui.form_buttons.prepare.disabled,"Příprava PVE-01 se nespustí nad vybraným PVE-02")
	ui.host="PVE-01"; ui.draw_ui(); ui.open_action("pve_resources")
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		ui.apply_display_settings(resolution,false); await settle()
		check(visible(ui.form_buttons.pve_resources),"Formulář CPU/RAM dostupný v "+str(resolution))
		check(visible(ui.ui_targets["tree:PVE-01"]),"Strom je pevně viditelný")
		await capture("console-"+str(resolution.x))
		ui.settings_tab="Obraz"; ui.open_settings(); await settle()
		check(visible(ui.settings_controls.apply),"Potvrzení obrazu dostupné v "+str(resolution))
		await capture("settings-"+str(resolution.x))
		await click(ui.ui_targets["settings:Ovládání"])
		await capture("controls-"+str(resolution.x))
		ui.close_settings(); await settle()
	# Rejected model action retains scroll, number edit, focus, and caret.
	ui.apply_display_settings(Vector2i(1280,720),false)
	ui.open_action("create_vm"); await settle()
	var name=ui.form_controls.create_vm.name
	name.text="ROZEPSANÝ-SERVER"; name.grab_focus(); name.caret_column=6
	var sc=ui.get_scroll_ancestors(ui.form_controls.create_vm.name)[0]
	sc.scroll_vertical=180
	var position_before=sc.scroll_vertical
	ui.perform("memory",{"vm":"100","dynamic":true,"minimum":2,"ram":6,"maximum":8})
	await settle()
	check(ui.bad_notice,"Chybná operace zobrazí chybu")
	check(ui.form_controls.create_vm.name.text=="ROZEPSANÝ-SERVER","Odmítnutí zachová text")
	check(ui.form_controls.create_vm.name.has_focus() and ui.form_controls.create_vm.name.caret_column==6,"Fokus a kurzor zůstávají")
	var new_sc=ui.get_scroll_ancestors(ui.form_controls.create_vm.name)[0]
	check(new_sc.scroll_vertical==position_before,"Posuv zůstává po odmítnutí")
	ui.perform("inspect",{"scope":"Events"}); await settle()
	check(not ui.bad_notice and ui.form_controls.create_vm.name.has_focus(),"Úspěch zachová fokus")
	new_sc=ui.get_scroll_ancestors(ui.form_controls.create_vm.name)[0]
	check(new_sc.scroll_vertical==position_before,"Úspěch zachová posuv")
	ui.open_settings(); ui.preview_display(Vector2i(1920,1080),false)
	ui.display_deadline=Time.get_ticks_msec()-1
	await settle()
	check(ui.display_settings.resolution==Vector2i(1280,720),"Odpočet vrátí nepotvrzené rozlišení")
	ui.close_settings(); await settle()
	check(ui.form_controls.create_vm.name.text=="ROZEPSANÝ-SERVER","Nastavení zachová koncept")
	# All six wizard steps are reached using real pointer events.
	ui.game.start_mission(2,true); ui.navigate("Proxmox"); await settle()
	await click(ui.ui_targets["wizard:create_vm"])
	check(ui.tab=="Průvodce VM" and ui.wizard_step==0,"Klik otevřel první krok")
	var steps=[{"id":"101","name":"WEB01"},{"iso":"debian.iso"},{"cpu":2,"ram_mib":4096},{"size":32,"storage":"local-lvm"},{"bridge":"vmbr0","vlan":20,"ip":"192.168.20.101"},{}]
	for index in steps.size():
		var action=ui.Console.STEPS[index]
		check(ui.form_controls.size()==1 and ui.form_controls.has(action),"Pouze aktuální krok "+action)
		for key in steps[index]:
			var input=ui.form_controls[action][key]
			var value=steps[index][key]
			if input is LineEdit: input.text=str(value)
			elif input is SpinBox: input.value=value
			elif input is OptionButton: choose(input,str(value))
		await capture("wizard-"+str(index+1))
		await click(ui.form_buttons[action])
		check(not ui.bad_notice,"Skutečná operace průvodce: "+action)
	check(ui.game.sim.get_vm("101").get("os_installed",false),"Průvodce nainstaloval skutečnou VM101")
	await click(ui.ui_targets["action:power"])
	await click(ui.ui_targets["action:verify"])
	check(ui.game.sim.state.verified.vms["101"],"VM101 skutečně běží a je ověřena")
	await click(ui.ui_targets["nav:Síť"])
	var edit=find_button(ui,"Upravit síť WEB01")
	check(edit!=null,"Nová VM101 má síťový záznam")
	if edit: await click(edit)
	check(ui.page=="Proxmox" and ui.selected_vm=="101" and ui.active_action=="network","Síťový odkaz vybral skutečnou VM")
	# Local format validation never records a simulated operational mistake.
	var errors=ui.game.sim.state.errors
	ui.form_controls.network.ip.text="není IP"
	await click(ui.form_buttons.network)
	check(ui.game.sim.state.errors==errors,"Formátová chyba nezmění hodnocení")
	ui.open_settings(); ui.settings_tab="Ovládání"; ui.draw_ui()
	ui.capture_binding("interact")
	var event=InputEventKey.new(); event.pressed=true; event.physical_keycode=KEY_W
	ui._input(event)
	check(ui.binding_action=="interact" and ui.display_settings.bindings.interact==KEY_E,"Kolize kláves zůstává neuložená")
	event.physical_keycode=KEY_G; ui._input(event)
	check(ui.display_settings.bindings.interact==KEY_G,"Nová klávesa je aktivní")
	ui.save_preference("muted",true); ui.save_preference("volume",0.42); ui.save_preference("text_scale",1.3)
	var loaded=Settings.new(); loaded.load_settings()
	check(loaded.muted and is_equal_approx(loaded.volume,0.42) and loaded.text_scale==1.3 and loaded.bindings.interact==KEY_G,"Zvuk, text a klávesy přežijí nové načtení")
	ui.settings_tab="Rozhraní"; ui.draw_ui(); await settle(); await capture("text-130")
	ui.save_preference("bindings",Settings.DEFAULT_KEYS.duplicate()); ui.save_preference("text_scale",1.0)
	await create_timer(0.1).timeout
	ui.queue_free(); await settle()
	print("CONSOLE UX: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)

func find_button(node: Node, caption: String):
	if node is Button and node.text==caption: return node
	for child in node.get_children():
		var found=find_button(child,caption)
		if found: return found
	return null

func capture(title: String):
	if DisplayServer.get_name()=="headless" or not "--screenshots" in OS.get_cmdline_user_args(): return
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/ux-"+title+".png")
