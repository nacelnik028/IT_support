extends Node

var ui
var world
var hud: Control
var overlay: Control
var app_bar: Control
var prompt: Label
var mode = "menu"
var selected
var update_time = 0.0
var chrome: Control
var backing: ColorRect
var status_label: Label
var pending_cable = ""
var save_time = 0.0
var pose_revision = -1
var message = ""

func _ready():
	# Explicit opt-in used by MCP and graphical smoke tests, before Game.new().
	if "--test-world" in OS.get_cmdline_user_args():
		preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_mcp.json"
		preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_mcp.cfg"
	world = preload("res://scenes/world/Datacenter3D.tscn").instantiate()
	add_child(world)
	var layer = CanvasLayer.new()
	add_child(layer)
	backing = ColorRect.new()
	backing.color = Color(0.025,0.04,0.075,0.97)
	layer.add_child(backing)
	backing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui = preload("res://scenes/main_menu/Main.tscn").instantiate()
	ui.world_enabled = true
	layer.add_child(ui)
	world.game = ui.game
	ui.world_requested.connect(enter_world)
	ui.lesson_launched.connect(func(): enter_world("Trénink"))
	world.player.interaction_requested.connect(interact)
	world.player.focus_changed.connect(func(target):
		if is_instance_valid(prompt): prompt.text = "Stiskni E pro interakci\n"+target.caption if is_instance_valid(target) else "")
	chrome = Control.new()
	layer.add_child(chrome)
	chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.size = Vector2(1600,900)
	hud = Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.theme = ui.theme
	var crosshair = ui.label("+",22,ui.CYAN)
	hud.add_child(crosshair)
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position -= Vector2(7,15)
	prompt = ui.label("",18)
	hud.add_child(prompt)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.position = Vector2(-250,-145)
	prompt.size = Vector2(500,90)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var controls = ui.label("WASD pohyb   •   myš rozhlížení   •   E interakce   •   Shift rychlá chůze   •   Tab úkoly   •   F baterka   •   Esc pauza",14)
	hud.add_child(controls)
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	controls.offset_left = 25
	controls.offset_top = -40
	status_label = ui.label("",16,ui.CYAN)
	hud.add_child(status_label)
	status_label.position = Vector2(28,24)
	status_label.size = Vector2(950,120)
	app_bar = HBoxContainer.new()
	chrome.add_child(app_bar)
	app_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	app_bar.offset_top = -50
	app_bar.offset_right = -25
	app_bar.alignment = BoxContainer.ALIGNMENT_END
	app_bar.add_child(ui.button("← Zpět do 3D prostředí  [Esc]",return_to_world,true))
	overlay = Control.new()
	chrome.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.theme = ui.theme
	set_mode("menu")

func _process(delta):
	chrome.scale = get_viewport().get_visible_rect().size/Vector2(1600,900)
	if mode == "app" and ui.page == "menu": set_mode("menu")
	update_time += delta
	save_time += delta
	if update_time > 0.25:
		update_time = 0.0
		world.sync_state()
		if ui.game.active:
			status_label.text = ("IT TRAINING ACADEMY" if world.player.position.x>9 else "NORTHSTAR  /  SERVEROVNA 01")+"\n"+ui.game.current.title
			if pending_cable!="": status_label.text += "\nNeseš konektor "+pending_cable+" — dojdi k SW-CORE a vyber port [E]."
			if ui.game.sim.state.world.held!="": status_label.text += "\nNeseš: "+ui.game.sim.state.world.stock[ui.game.sim.state.world.held].serial
			if ui.game.unsaved: status_label.text += "\nZMĚNY NEJSOU ULOŽENÉ — Esc → Zkusit uložit znovu"
	if mode == "world" and save_time>8.0:
		save_time = 0.0
		store_pose()

func set_mode(value: String):
	if mode=="world" and value!="world": store_pose()
	mode = value
	backing.visible = value in ["menu","app"]
	ui.visible = value in ["menu","app"]
	hud.visible = value == "world"
	app_bar.visible = value == "app"
	overlay.visible = value in ["detail","pause","tasks"]
	world.player.set_enabled(value == "world")

func enter_world(destination: String = "Serverovna"):
	if not ui.game.active: ui.game.start_mission(0)
	if pose_revision != ui.game.session_revision:
		var pose = ui.game.sim.state.world.player
		world.player.position = Vector3(pose.x,0.02,pose.z)
		world.player.rotation.y = pose.yaw
		world.player.camera.rotation.x = pose.pitch
		pose_revision = ui.game.session_revision
	if destination == "Trénink":
		# Academy room is added in the next stage; preserve the route contract.
		pending_cable = ""
	world.sync_state()
	set_mode("world")

func return_to_world():
	ui.capture_form_drafts()
	set_mode("world")
	world.sync_state()
	if pose_revision != ui.game.session_revision: enter_world()

func store_pose():
	if not ui.game.active or pose_revision != ui.game.session_revision: return
	var p = world.player
	ui.game.sim.state.world.player = {"x":p.position.x,"z":p.position.z,"yaw":p.rotation.y,"pitch":p.camera.rotation.x}
	ui.game.save()

func open_app(page: String, host: String = "PVE-01"):
	ui.host = host
	ui.page = page
	ui.tab = ""
	ui.notice = ""
	ui.draw_ui()
	set_mode("app")

func panel(title: String, subtitle: String = "") -> VBoxContainer:
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	var shade = ColorRect.new()
	shade.color = Color(0.015,0.025,0.045,0.88)
	overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin = MarginContainer.new()
	overlay.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,100)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,65)
	var v = ui.scroll(margin)
	v.add_child(ui.label(title,32,ui.CYAN))
	if subtitle != "": v.add_child(ui.label(subtitle,17))
	return v

func interact(object):
	selected = object
	match object.kind:
		"computer": open_app(object.console); return
		"server":
			ui.game.apply("physical_inspect",{"device":object.device_id})
			ui.game.notify_event({"type":"server_selected","host":object.device_id})
			show_device(object)
		"disk": show_disk(object)
		"spares": show_spares()
		"cable", "supply": show_connection(object)
		"switch": open_app("Síť")
		"port":
			if pending_cable == "":
				set_mode("detail")
				var v = panel(object.caption,"Nejprve uchop síťový konektor u konkrétního serveru.")
				v.add_child(ui.button("Zpět",return_to_world))
			else:
				var result = ui.game.apply("physical_cable",{"device":pending_cable,"port":int(object.slot),"connected":true})
				if result.ok: pending_cable = ""
				set_mode("detail")
				var v = panel(object.caption,result.text)
				v.add_child(ui.button("Zpět",return_to_world))
		"monitor": show_monitor()

func show_device(object):
	set_mode("detail")
	var s = ui.game.sim.state
	var v = panel(object.caption,"Fyzické zařízení / živý stav simulace")
	var h = s.hosts[object.device_id]
	var physical = s.world.devices[object.device_id]
	v.add_child(ui.label("Stav: %s   •   RAM: %s GB\nManagement: %s   •   SW-CORE: port%d / předepsaný%d\nNapájení: %s   •   Síťový kabel: %s   •   Hot-swap: %s" % ["Zapnuto" if h.online else "Vypnuto",h.get("ram","—"),h.get("ip","samostatná konzole"),physical.port,physical.expected_port,"připojeno" if physical.power_connected else "odpojeno","připojen" if physical.cable_connected else "odpojen","ano" if physical.hot_swap else "ne"],20))
	var vm_lines = []
	for vm in s.vms.values():
		if vm.get("exists",false) and vm.host==object.device_id: vm_lines.append("%s / %s: %d vCPU, %s GB RAM — %s" % [vm.id,vm.name,vm.cpu,vm.ram,"běží" if vm.status=="Running" else "vypnuto"])
	if not vm_lines.is_empty(): v.add_child(ui.label("\n".join(vm_lines),17))
	v.add_child(ui.button("Otevřít management",func():
		ui.game.notify_event({"type":"node_selected","host":object.device_id,"vm":""})
		open_app(object.console,object.device_id),true))
	var power = ui.hbox(v)
	for operation in ["Start","Shutdown","Restart"]:
		var chosen = operation
		power.add_child(ui.button({"Start":"Zapnout","Shutdown":"Bezpečně vypnout","Restart":"Bezpečně restartovat"}[operation],func():
			message = ui.game.apply("physical_power",{"device":object.device_id,"operation":chosen}).text
			show_device(object)))
	if object.device_id in ["NAS-01","PVE-01"]:
		var pool = "RAID" if object.device_id=="NAS-01" else "ZFS"
		var disks = s.disks if pool=="RAID" else s.zfs.disks
		v.add_child(ui.label("Disky — konkrétní sloty a sériová čísla",20,ui.CYAN))
		var row = ui.hbox(v)
		for slot in disks:
			var disk_object = world.devices[pool+":"+slot]
			row.add_child(ui.button("%s / %s\n%s" % [slot,disks[slot].serial,health_text(disks[slot].health)],func(): show_disk(disk_object)))
	v.add_child(ui.button("Diagnostika a logy",func():
		var result = ui.game.apply("inspect",{"scope":"Events"})
		v.add_child(ui.label(result.text,16))))
	if message!="": v.add_child(ui.label(message,16,ui.ORANGE)); message=""
	v.add_child(ui.button("Zpět do serverovny",return_to_world))

static func health_text(value: String) -> String:
	return {"Healthy":"V pořádku","Failed":"Vadný / selhání","Missing":"Prázdný slot","Degraded":"Snížená redundance","Recovering":"Probíhá obnova","Offline":"Vypnuto"}.get(value,value)

func show_disk(object):
	set_mode("detail")
	var s = ui.game.sim.state
	var d = s.zfs.disks[object.slot] if object.pool=="ZFS" else s.disks[object.slot]
	var pool = s.zfs if object.pool=="ZFS" else s.raid
	var v = panel(object.caption,"Sériové číslo: %s  •  %d GB  •  %s\nPole: %s / %s / obnova %d%%" % [d.serial,d.capacity,health_text(d.health),pool.level,health_text(pool.health),pool.progress])
	var identity = LineEdit.new()
	identity.placeholder_text = "Opiš sériové číslo z inventáře výše"
	v.add_child(identity)
	var backup = CheckButton.new()
	backup.text = "Ověřil jsem nezávislou zálohu a servisní postup"
	v.add_child(backup)
	if d.health!="Missing":
		v.add_child(ui.button("Vytáhnout vybraný disk",func():
			var confirm = ConfirmationDialog.new()
			confirm.title = "Vytažení fyzického disku"
			confirm.dialog_text = "Slot %s / %s. Vytažení zdravého člena může vyřadit pole. Provést zásah?" % [object.slot,identity.text]
			confirm.ok_button_text = "Vytáhnout disk"
			confirm.cancel_button_text = "Zrušit"
			overlay.add_child(confirm)
			confirm.confirmed.connect(func():
				message = ui.game.apply("physical_remove",{"pool":object.pool,"slot":object.slot,"serial":identity.text,"backup_checked":backup.button_pressed,"confirmed":true}).text
				show_disk(object))
			confirm.canceled.connect(confirm.queue_free)
			confirm.popup_centered(Vector2i(650,240))))
	else:
		v.add_child(ui.label("Vezmi disk ze servisní skříně. Kompatibilita: %d GB nebo větší / %s." % [d.capacity,"SATA" if object.pool=="ZFS" else "SAS"],18))
		v.add_child(ui.button("Vložit nesený náhradní disk",func():
			message = ui.game.apply("physical_insert",{"pool":object.pool,"slot":object.slot,"backup_checked":backup.button_pressed}).text
			show_disk(object),true))
	if pool.rebuilding:
		v.add_child(ui.button("Sledovat obnovu — posunout simulovaný čas",func():
			message = ui.game.apply("rebuild",{"pool":object.pool}).text
			show_disk(object),true))
	v.add_child(ui.button("Ověřit konečný stav pole",func():
		message = ui.game.apply("verify",{}).text
		show_disk(object)))
	if message!="": v.add_child(ui.label(message,17,ui.ORANGE)); message=""
	v.add_child(ui.button("Zpět do 3D serverovny",return_to_world))

func show_spares():
	set_mode("detail")
	var w = ui.game.sim.state.world
	var v = panel("Servisní skříň","Vyber náhradní disk podle kapacity a rozhraní. Neseš nejvýše jeden disk.")
	for id in w.stock:
		var chosen = id
		var disk = w.stock[id]
		var b = ui.button("%s / %d GB / %s — %s" % [disk.serial,disk.capacity,disk.interface,"ve skříni" if disk.available else "odebrán"],func():
			message = ui.game.apply("physical_spare",{"spare":chosen}).text
			show_spares())
		b.disabled = not disk.available or w.held!=""
		v.add_child(b)
	if w.held!="": v.add_child(ui.button("Vrátit nesený disk do skříně",func(): ui.game.apply("physical_return_spare",{}); show_spares()))
	if message!="": v.add_child(ui.label(message,17,ui.ORANGE)); message=""
	v.add_child(ui.button("Zpět — odnést disk ke slotu",return_to_world))

func show_connection(object):
	set_mode("detail")
	var d = ui.game.sim.state.world.devices[object.slot]
	var v = panel(object.caption,"Identita: %s  •  předepsaný port SW-CORE: %d" % [object.slot,d.expected_port])
	if object.kind=="supply":
		v.add_child(ui.label("Napájecí přívod: "+("připojen" if d.power_connected else "odpojen"),20))
		v.add_child(ui.button("Připojit napájení" if not d.power_connected else "Odpojit napájení",func():
			message = ui.game.apply("physical_supply",{"device":object.slot,"connected":not d.power_connected}).text
			show_connection(object)))
	else:
		v.add_child(ui.label("Kabel: %s  /  současný port%d" % ["připojen" if d.cable_connected else "odpojen",d.port],20))
		v.add_child(ui.button("Odpojit síťový kabel",func():
			message = ui.game.apply("physical_cable",{"device":object.slot,"connected":false,"port":d.port}).text
			show_connection(object)))
		v.add_child(ui.button("Uchopit konektor a zvolit port na SW-CORE",func():
			pending_cable = object.slot
			return_to_world(),true))
	if message!="": v.add_child(ui.label(message,17,ui.ORANGE)); message=""
	v.add_child(ui.button("Zpět",return_to_world))

func show_monitor():
	ui.game.apply("physical_monitor",{})
	world.sync_state()
	set_mode("detail")
	var v = panel("Monitorovací konzole",world.monitoring.text)
	v.add_child(ui.label("Poslední události\n"+"\n".join(ui.game.sim.state.journal.slice(-8)),16))
	v.add_child(ui.button("Ověřit infrastrukturu a aplikace",func(): ui.game.apply("verify",{}); show_monitor()))
	v.add_child(ui.button("Dokončit přejímku serverovny",func():
		v.add_child(ui.label(ui.game.apply("physical_commission",{}).text,17))))
	v.add_child(ui.button("Zpět",return_to_world))

func pause_menu():
	set_mode("pause")
	var v = panel("Pauza","Pohyb a fyzické interakce jsou pozastavené.")
	v.add_child(ui.button("Pokračovat",return_to_world,true))
	if ui.game.unsaved: v.add_child(ui.button("Zkusit uložit znovu",func(): ui.game.save(); pause_menu(),true))
	v.add_child(ui.label("Citlivost myši",16))
	var slider = HSlider.new()
	slider.min_value = 0.0005
	slider.max_value = 0.005
	slider.step = 0.0001
	slider.value = world.player.sensitivity
	v.add_child(slider)
	slider.value_changed.connect(func(value): world.player.sensitivity = value)
	v.add_child(ui.button("Tickety a mise",func(): open_app("Tickety")))
	v.add_child(ui.button("Nastavení obrazu",func(): open_app("Nastavení")))
	v.add_child(ui.button("Uložit a hlavní menu",func():
		if ui.game.save() == OK:
			ui.page = "menu"
			ui.draw_ui()
			set_mode("menu")
		else: v.add_child(ui.label(ui.game.save_message,16,ui.ORANGE))))

func show_tasks():
	set_mode("tasks")
	var v = panel(ui.game.current.title,ui.game.current.description)
	for goal in ui.game.goals(): v.add_child(ui.label(("✓ " if goal.passed else "○ ")+goal.label,18,ui.CYAN if goal.passed else ui.WHITE))
	v.add_child(ui.button("Ověřit infrastrukturu",func():
		ui.game.apply("verify",{})
		show_tasks()))
	v.add_child(ui.button("Předat vyřešený ticket",func():
		var result = ui.game.complete()
		v.add_child(ui.label(("Hodnocení: %d / 100\n" % result.score if result.ok else "")+result.text,18))))
	v.add_child(ui.button("Zpět  [Tab / Esc]",return_to_world))

func _unhandled_key_input(event):
	if not event.pressed or event.echo: return
	if event.keycode == KEY_ESCAPE:
		if mode == "world": pause_menu()
		elif mode != "menu": return_to_world()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_TAB and mode in ["world","tasks"]:
		if mode == "world": show_tasks()
		else: return_to_world()
		get_viewport().set_input_as_handled()
