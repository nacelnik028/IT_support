extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var ui
var checks=0
var failures=0

func _init():
	Saves.path_override="user://academy_test_ui_safety.json"
	Settings.path_override="user://academy_test_ui_safety.cfg"
	Saves.save_game({},true)
	Settings.new().save_settings()
	call_deferred("run")

func check(ok, message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func find_button(node: Node, caption: String):
	if node is Button and node.text==caption: return node
	for child in node.get_children():
		var found=find_button(child,caption)
		if found: return found
	return null

func sound():
	ui.open_settings()
	ui.ui_targets["settings:Zvuk"].pressed.emit()
	ui.settings_controls.muted.button_pressed=not ui.settings_controls.muted.button_pressed
	ui.close_settings()

func choose(picker: OptionButton, value: String):
	for i in picker.item_count:
		if ui.option_value(picker,i)==value:
			picker.select(i)
			picker.item_selected.emit(i)
			return
	check(false,"Volba je dostupná: "+value)

func run():
	ui=load("res://scenes/main_menu/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	ui.game.start_mission(3,true)
	ui.game.sim.state.vms["100"].vlan=39
	ui.game.enter_training()
	ui.game.start_random("Sítě","Začátečník",2,true,91)
	for operation in ui.game.current.reference: ui.game.apply(operation[0],operation[1])
	ui.game.complete(); ui.game.next_random()
	ui.navigate(ui.game.current.category)
	var campaign=ui.game.suspended_campaign.duplicate(true)
	var results=ui.game.education.random.results.duplicate(true)
	ui.ui_targets["context:toggle"].pressed.emit()
	find_button(ui,"Restartovat laboratoř").pressed.emit()
	ui.context_open=false
	for child in ui.get_children():
		if child is ConfirmationDialog: child.confirmed.emit(); break
	await process_frame
	check(ui.game.session_kind=="random" and ui.game.current.id==20001,"UI restart používá typ relace")
	check(ui.game.education.random.results==results and ui.game.suspended_campaign==campaign,"UI restart chrání sérii i kampaň")
	ui.game.resume_campaign()
	ui.game.sim.state.vms["100"].vlan=41
	ui.game.save()
	ui.training_view="random"
	ui.navigate("Trénink")
	check(find_button(ui,"Obnovit uloženou sérii")==null,"Po odchodu se stará série nenabízí k pokračování")
	ui.game.start_random("Sítě","Začátečník",2,true,91)
	ui.begin_lesson(1002,"practice",false)
	ui.navigate("Trénink")
	find_button(ui,"Obnovit uloženou sérii").pressed.emit()
	await process_frame
	ui.game.resume_campaign()
	check(ui.game.sim.state.vms["100"].vlan==41,"Skutečné tlačítko obnovy série odložilo nejnovější kampaň")
	ui.game.enter_training()
	ui.begin_lesson(1002,"learn",false)
	ui.game.notify_event({"type":"server_selected","host":"PVE-01"})
	ui.game.notify_event({"type":"node_selected","host":"PVE-01"})
	ui.game.notify_event({"type":"action_opened","action":"create_vm"})
	ui.game.apply("vm_identity",{"id":"101","name":"WEB01"})
	ui.game.apply("vm_media",{"vm":"101","iso":"debian.iso"})
	ui.recover_tutorial_target()
	await process_frame
	ui.form_controls.vm_resources.ram_mib.value=6144
	ui.form_controls.vm_resources.cpu.get_line_edit().text="7"
	ui.open_action("vm_identity")
	ui.form_controls.vm_identity.name.text="ROZEPSÁNO"
	ui.open_action("vm_network")
	choose(ui.form_controls.vm_network.bridge,"LAB")
	ui.open_action("vm_resources")
	sound()
	check(ui.form_controls.vm_resources.ram_mib.value==6144,"Zvuk zachoval RAM6144")
	check(ui.form_controls.vm_resources.cpu.get_line_edit().text=="7","Zvuk zachoval nepotvrzený text SpinBox")
	ui.open_action("vm_identity")
	check(ui.form_controls.vm_identity.name.text=="ROZEPSÁNO","Zvuk zachoval text")
	ui.open_action("vm_network")
	check(ui.option_value(ui.form_controls.vm_network.bridge)=="LAB","Zvuk zachoval nabídku")
	ui.open_action("vm_resources")
	ui.apply_display_settings(Vector2i(1280,720),false)
	await process_frame
	await process_frame
	check(ui.form_controls.vm_resources.ram_mib.value==6144,"Rozlišení zachovalo rozepsanou RAM")
	check(ui.game.sim.state.vms["101"].ram==1,"Koncept neaplikoval konfiguraci do simulace")
	check(is_instance_valid(ui.tutorial_overlay) and ui.tutorial_overlay.target==ui.form_controls.vm_resources.ram_mib,"Zvýraznění míří na zachované skutečné pole")
	await capture("safety-draft-720p")
	var f11=InputEventKey.new(); f11.keycode=KEY_F11; f11.pressed=true
	ui._unhandled_key_input(f11)
	ui.resolve_display(true)
	await process_frame
	check(ui.form_controls.vm_resources.ram_mib.value==6144,"F11 zachovalo koncept")
	ui.apply_display_settings(Vector2i(3840,2160),false)
	await process_frame
	await capture("safety-draft-4k")
	check(ui.oversampling_with_scale==CanvasItem.OVERSAMPLING_WITH_SCALE_ENABLED,"Ostrost fontu zachována")
	ui.apply_display_settings(Vector2i(1600,900),false)
	choose(ui.form_controls.vm_resources.vm,"100")
	check(ui.form_controls.vm_resources.ram_mib.value!=6144,"Jiná VM nepřebírá koncept RAM")
	ui.form_controls.vm_resources.ram_mib.value=8192
	choose(ui.form_controls.vm_resources.vm,"101")
	check(ui.form_controls.vm_resources.ram_mib.value==6144,"VM101 má vlastní koncept")
	choose(ui.form_controls.vm_resources.vm,"100")
	check(ui.form_controls.vm_resources.ram_mib.value==8192,"VM100 má vlastní koncept")
	choose(ui.form_controls.vm_resources.vm,"101")
	ui.form_buttons.vm_resources.pressed.emit()
	check(ui.game.sim.state.vms["101"].cpu==7 and ui.game.sim.state.vms["101"].ram==6,"Zachovaný nepotvrzený text se při odeslání skutečně použije")
	ui.begin_lesson(1002,"practice",false)
	ui.page="Proxmox"; ui.tab="Průvodce VM"; ui.draw_ui()
	ui.open_action("vm_resources")
	check(ui.form_controls.vm_resources.ram_mib.value==1024,"Jiný režim nemá koncept z vedené lekce")
	ui.game.start_mission(2,true)
	ui.navigate("Proxmox"); ui.tab="VM / CT"; ui.draw_ui()
	ui.open_action("create_vm")
	ui.form_controls.create_vm.name.text="NOVÁ-KONFIGURACE"
	ui.form_controls.create_vm.agent.button_pressed=true
	ui.form_controls.create_vm.ram.value=8
	sound()
	check(ui.form_controls.create_vm.agent.button_pressed,"Zvuk zachoval checkbox")
	check(ui.form_controls.create_vm.name.text=="NOVÁ-KONFIGURACE","Text mise se zachová")
	ui.game.restart_current(); ui.draw_ui(); ui.open_action("create_vm")
	check(ui.form_controls.create_vm.name.text=="NOVY-SERVER","Restart mise zahodil staré koncepty")
	ui.game.start_mission(16,true)
	ui.navigate("Storage"); ui.tab="RAID konfigurátor"; ui.draw_ui()
	var grid=ui.form_controls.raid_create.members.get_child(0)
	grid.get_child(0).button_pressed=true; grid.get_child(1).button_pressed=true
	sound()
	check(ui.form_controls.raid_create.members.get_meta("selection")==["0","1"],"Zvuk zachoval výběr fyzických disků")
	check(ui.form_controls.raid_create.members.get_child(0).get_child(0).button_pressed,"Výběr disku zůstal viditelný")
	ui.navigate("Terminál")
	ui.form_controls._terminal.command.text="qm config 100"
	sound()
	check(ui.form_controls._terminal.command.text=="qm config 100","Zvuk zachoval rozepsaný příkaz")
	ui.game.start_mission(3,true)
	ui.navigate("Proxmox")
	# Force real save failure without touching the last valid file.
	var raw=FileAccess.get_file_as_string(Saves.save_path())
	var temp=ProjectSettings.globalize_path(Saves.save_path()+".tmp")
	DirAccess.make_dir_absolute(temp)
	ui.perform("inspect",{"scope":"Events"})
	check(not ui.bad_notice and ui.game.unsaved,"UI rozlišuje úspěšný zásah od zápisu")
	check(find_button(ui,"Zkusit uložit znovu")!=null,"UI nabízí opakování zápisu")
	check(FileAccess.get_file_as_string(Saves.save_path())==raw,"UI chyba zápisu zachovala poslední soubor")
	find_button(ui,"Uložit a menu").pressed.emit()
	check(ui.page!="menu","Uložit a menu při chybě neslibuje uložení")
	ui.quit_game()
	check(not ui.quitting,"Chyba uložení zabrání ukončení")
	for child in ui.get_children():
		if child is AcceptDialog: child.confirmed.emit()
	await capture("safety-save-failed")
	DirAccess.remove_absolute(temp)
	find_button(ui,"Zkusit uložit znovu").pressed.emit()
	check(not ui.game.unsaved and find_button(ui,"Zkusit uložit znovu")==null,"Opakování zápisu aktualizuje stav UI")
	await dispose_ui()
	# Startup warning is visible even in the main menu; replacing needs the
	# explicit button that first preserves the original bytes in a backup.
	var file=FileAccess.open(Saves.save_path(),FileAccess.WRITE)
	file.store_string('{"schema":2,"progress":{"scores":null}}'); file.close()
	ui=load("res://scenes/main_menu/Main.tscn").instantiate()
	root.add_child(ui); await process_frame
	check(ui.game.load_warning!="" and find_button(ui,"Zálohovat vadný soubor a uložit")!=null,"Menu ukazuje vadný save a bezpečnou obnovu")
	await capture("safety-invalid-save")
	find_button(ui,"Zálohovat vadný soubor a uložit").pressed.emit()
	check(ui.game.load_warning=="" and not ui.game.unsaved,"Výslovná obnova funguje přes skutečné tlačítko")
	await dispose_ui()
	print("UI SAFETY: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)

func dispose_ui():
	ui.player.stop()
	ui.player.stream=null
	ui.click_sound=null
	await create_timer(0.08).timeout
	ui.queue_free()
	await process_frame
	# Audio mixing runs on its own wall clock, even when headless frames advance fast.
	OS.delay_msec(120)

func capture(caption: String):
	if DisplayServer.get_name()=="headless" or not "--screenshots" in OS.get_cmdline_user_args(): return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/"+caption+".png")
