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
var instruction: Label
var direction: Label
var reticle: Control
var context_plate: Panel
var instruction_plate: Panel
var room_notice: Label
var notice_time = 0.0
var leaving_scene = false
var settings_from_pause = false
var controls_label: Label
var introduction_step = 0
var ui_layer: CanvasLayer
var xr_rig
var vr_active = false
var code_editor

func _ready():
	# Explicit opt-in used by MCP and graphical smoke tests, before Game.new().
	if "--test-world" in OS.get_cmdline_user_args():
		preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_mcp.json"
		preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_mcp.cfg"
	world = preload("res://scenes/world/Datacenter3D.tscn").instantiate()
	add_child(world)
	var layer = CanvasLayer.new()
	ui_layer = layer
	add_child(layer)
	backing = ColorRect.new()
	backing.color = ui_background()
	layer.add_child(backing)
	backing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui = preload("res://scenes/main_menu/Main.tscn").instantiate()
	ui.world_enabled = true
	layer.add_child(ui)
	world.game = ui.game
	ui.display_settings.apply_world(world)
	ui.preferences_changed.connect(apply_ui_preferences)
	ui.settings_closed.connect(func():
		if settings_from_pause: settings_from_pause=false; pause_menu())
	ui.world_requested.connect(enter_world)
	ui.play_mode_requested.connect(request_play_mode)
	ui.lesson_launched.connect(func(): enter_world())
	world.player.interaction_requested.connect(interact)
	world.player.focus_changed.connect(func(target):
		if is_instance_valid(prompt): prompt.text = "Stiskni E pro interakci\n"+target.caption if is_instance_valid(target) else ""
		if is_instance_valid(reticle): reticle.set_focus(is_instance_valid(target))
		if is_instance_valid(context_plate): context_plate.visible = is_instance_valid(target))
	chrome = Control.new()
	layer.add_child(chrome)
	chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.oversampling_with_scale = CanvasItem.OVERSAMPLING_WITH_SCALE_ENABLED
	chrome.size = Vector2(1600,900)
	hud = Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.theme = ui.theme
	reticle = preload("res://scripts/world/Reticle.gd").new()
	hud.add_child(reticle)
	var status_plate = hud_plate(Vector2(22,20),Vector2(535,158),Color("335565"))
	status_plate.name = "StatusPlate"
	var brand = ui.label("NORTHSTAR  /  IT OPERATIONS",11,ui.CYAN)
	hud.add_child(brand)
	brand.position = Vector2(40,32)
	brand.size = Vector2(490,18)
	context_plate = hud_plate(Vector2(530,753),Vector2(540,78),Color("4bb9b0"))
	context_plate.visible = false
	instruction_plate = hud_plate(Vector2(1055,20),Vector2(522,282),Color("9a8157"))
	instruction_plate.visible = false
	hud_plate(Vector2(22,850),Vector2(1556,35),Color("253f50"))
	prompt = ui.label("",18)
	hud.add_child(prompt)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	prompt.position = Vector2(550,766)
	prompt.size = Vector2(500,64)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var controls = ui.label("",14)
	controls_label = controls
	hud.add_child(controls)
	controls.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	controls.position = Vector2(38,856)
	controls.size = Vector2(1520,28)
	status_label = ui.label("",16,ui.CYAN)
	hud.add_child(status_label)
	status_label.position = Vector2(40,57)
	status_label.size = Vector2(495,115)
	instruction = ui.label("",18)
	hud.add_child(instruction)
	instruction.position = Vector2(1070,24)
	instruction.size = Vector2(500,250)
	direction = ui.label("",20,ui.ORANGE)
	hud.add_child(direction)
	direction.position = Vector2(520,730)
	direction.size = Vector2(560,80)
	direction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	app_bar = HBoxContainer.new()
	chrome.add_child(app_bar)
	app_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	app_bar.offset_top = -50
	app_bar.offset_right = -25
	app_bar.alignment = BoxContainer.ALIGNMENT_END
	app_bar.theme = ui.theme
	app_bar.add_child(ui.button("← Zpět do 3D prostředí  [Esc]",return_to_world))
	overlay = Control.new()
	chrome.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.theme = ui.theme
	room_notice = ui.label("",19)
	chrome.add_child(room_notice)
	room_notice.position = Vector2(300,595)
	room_notice.size = Vector2(1000,125)
	room_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_notice.add_theme_stylebox_override("normal",ui.box(Color(0.02,0.05,0.08,0.95),ui.CYAN,8))
	room_notice.hide()
	world.training_zone.game = ui.game
	ui.game.room_probe = world.training_zone.contains_player
	ui.game.programming_probe=world.programming_room.contains_player
	ui.game.room_changed.connect(on_room_changed)
	set_mode("menu")
	ui.game.reconcile_room()
	if OS.has_feature("android") or "--vr" in OS.get_cmdline_user_args(): call_deferred("start_vr")
	if "--export-smoke" in OS.get_cmdline_user_args(): call_deferred("export_smoke")

func hud_plate(at: Vector2, dimensions: Vector2, border: Color) -> Panel:
	var plate = Panel.new()
	plate.position = at
	plate.size = dimensions
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style=ui.box(Color(0.063,0.082,0.098,0.96),border,8)
	style.border_width_left=3
	plate.add_theme_stylebox_override("panel",style)
	hud.add_child(plate)
	return plate

func ui_background() -> Color:
	return preload("res://scripts/ui/AcademyTheme.gd").BACKGROUND

func apply_ui_preferences():
	ui.display_settings.apply_world(world)
	if vr_active: apply_vr_quality()
	hud.theme=ui.theme
	overlay.theme=ui.theme
	app_bar.theme=ui.theme
	for node in chrome.find_children("*","Label",true,false):
		if node.has_meta("base_font_size"): node.add_theme_font_size_override("font_size",roundi(node.get_meta("base_font_size")*ui.display_settings.text_scale))

func _process(delta):
	ui.game.reconcile_room()
	notice_time = maxf(0.0,notice_time-delta)
	room_notice.visible = notice_time>0.0 and mode=="world" and not (ui.game.active and ui.game.session_kind in ["lesson","random"])
	chrome.scale = Vector2.ONE if vr_active else get_viewport().get_visible_rect().size/Vector2(1600,900)
	if vr_active: ui.scale=Vector2.ONE
	if mode == "app" and ui.page == "menu": set_mode("menu")
	update_time += delta
	save_time += delta
	if update_time > 0.25:
		update_time = 0.0
		world.sync_state()
		world.programming_room.sync()
		var keys=ui.display_settings.bindings
		controls_label.text="%s/%s/%s/%s pohyb  •  myš rozhlížení  •  %s interakce  •  %s rychle  •  %s zadání  •  %s baterka  •  Esc pauza" % [OS.get_keycode_string(keys.walk_forward),OS.get_keycode_string(keys.walk_left),OS.get_keycode_string(keys.walk_back),OS.get_keycode_string(keys.walk_right),OS.get_keycode_string(keys.interact),OS.get_keycode_string(keys.walk_fast),OS.get_keycode_string(keys.task_list),OS.get_keycode_string(keys.flashlight)]
		if is_instance_valid(world.player.target): prompt.text="Stiskni %s pro interakci\n%s" % [OS.get_keycode_string(keys.interact),world.player.target.caption]
		status_label.text = "SERVEROVNA 01"
		if ui.game.game_mode.is_programming(): status_label.text="PROGRAMMING ACADEMY\nVyber lekci u počítače nebo instruktora."
		if ui.game.game_mode.is_training():
			status_label.text = "Tréninkové centrum – vyber si lekci"
			if ui.game.active and ui.game.session_kind=="lesson": status_label.text="VÝUKA / "+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}.get(ui.game.tutorial.session.mode,"Lekce")
			elif ui.game.active and ui.game.session_kind=="random": status_label.text="NÁHODNÉ PROCVIČOVÁNÍ"
		if ui.game.active:
			status_label.text += "\n"+ui.game.current.title
			if ui.game.session_kind=="campaign":
				var goals=ui.Eval.evaluate(ui.game.sim.state,ui.game.current.objectives)
				var complete=goals.filter(func(goal): return goal.passed).size()
				status_label.text += "\n%d / %d cílů  ·  %s zadání" % [complete,goals.size(),OS.get_keycode_string(keys.task_list)]
				var next=goals.filter(func(goal): return not goal.passed)
				status_label.text += "\nDalší cíl: "+str(next[0].label) if not next.is_empty() else "\n✓ Vše ověřeno · předej ticket"
			if pending_cable!="": status_label.text += "\nNeseš konektor "+pending_cable+" — dojdi k SW-CORE a vyber port [E]."
			if ui.game.sim.state.world.held!="": status_label.text += "\nNeseš: "+ui.game.sim.state.world.stock[ui.game.sim.state.world.held].serial
			if ui.game.unsaved: status_label.text += "\nZMĚNY NEJSOU ULOŽENÉ — Esc → Zkusit uložit znovu"
		update_guidance()
		instruction_plate.visible = instruction.text!=""
		instruction.size.y=0
		instruction.size.y=instruction.get_minimum_size().y
		instruction_plate.size.y=instruction.size.y+20
		status_label.size.y=0
		status_label.size.y=status_label.get_minimum_size().y
		hud.get_node("StatusPlate").size.y=status_label.size.y+52
		direction.position.y=650 if context_plate.visible else 730
	if mode == "world" and save_time>8.0:
		save_time = 0.0
		store_pose()

func set_mode(value: String):
	if value == "menu" and ui.game.game_mode.is_education():
		world.player.position = Vector3(7,0.02,3.5)
		ui.game.reconcile_room()
		ui.page = "menu"
		ui.draw_ui()
	if mode=="world" and value!="world": store_pose()
	mode = value
	update_time = 1.0
	backing.visible = value in ["menu","app"]
	ui.visible = value in ["menu","app"]
	hud.visible = value == "world"
	app_bar.visible = value == "app"
	overlay.visible = value in ["detail","pause","tasks","introduction","coding"]
	if is_instance_valid(code_editor): code_editor.visible=value=="coding"
	world.player.set_enabled(value == "world")
	if vr_active: xr_rig.mode_changed()

func enter_world(destination: String = "Serverovna"):
	if destination == "Hlavní serverovna":
		world.player.position = Vector3(7,0.02,3.5)
		world.player.velocity = Vector3.ZERO
		ui.game.reconcile_room()
	if not ui.game.active and not ui.game.game_mode.is_education(): ui.game.start_mission(0)
	if pose_revision != ui.game.session_revision:
		var pose = ui.game.sim.state.world.player
		world.player.position = Vector3(pose.x,0.02,pose.z)
		world.player.rotation.y = pose.yaw
		world.player.camera.rotation.x = pose.pitch
		pose_revision = ui.game.session_revision
	if destination == "Trénink":
		pending_cable = ""
		world.player.position = Vector3(15,0.02,5.5)
		world.player.rotation.y = 0
		world.player.camera.rotation.x = 0
	if destination=="Programming Academy":
		world.player.position=Vector3(-6.5,0.02,-9)
		world.player.velocity=Vector3.ZERO
		world.player.rotation.y=0; world.player.camera.rotation.x=0
	ui.game.reconcile_room()
	pose_revision = ui.game.session_revision
	if ui.game.session_kind!="lesson":
		for object in world.devices.values(): object.set_guided(false)
	world.sync_state()
	set_mode("world")
	if ui.first_shift_requested:
		ui.first_shift_requested=false
		if not vr_active and not ui.display_settings.introduction_seen: introduction_step=0; show_introduction()

func show_introduction():
	set_mode("introduction")
	var steps=[
		["Pohyb a rozhlížení","Pohybuj se klávesami uvedenými dole na HUD. Myší se rozhlížíš, rychlou chůzi zapíná klávesa Shift ve výchozím nastavení."],
		["Zařízení a interakce","Zaměř čelo zařízení nebo ovladač. Když se ukáže název a barevný rám, stiskni klávesu interakce (výchozí E). Dosah je 3,2 metru."],
		["Administrátorský počítač","Na monitorech ADMIN-01 a ADMIN-02 otevřeš konzoli. Ve stromu vyber zařízení, vlevo sekci a nahoře operaci. Escape tě vrátí do místnosti."],
		["Pracovní zadání","Klávesa zadání (výchozí Tab) ukáže ticket a cíle. V konzoli slouží tlačítko Zadání ticketu. Po změně ověř skutečný stav a potom předej ticket."]]
	var step=steps[introduction_step]
	var v=panel("Seznámení %d / 4 — %s" % [introduction_step+1,step[0]],step[1])
	v.add_child(ui.button("Další →" if introduction_step<3 else "Zahájit směnu",func():
		if introduction_step<3: introduction_step+=1; show_introduction()
		else: finish_introduction(),true))
	v.add_child(ui.button("Přeskočit seznámení",finish_introduction))

func finish_introduction():
	ui.save_preference("introduction_seen",true)
	return_to_world()

func return_to_world():
	ui.capture_form_drafts()
	set_mode("world")
	world.sync_state()
	if pose_revision != ui.game.session_revision: enter_world()

func store_pose():
	ui.game.reconcile_room()
	if not ui.game.active or pose_revision != ui.game.session_revision: return
	var p = world.player
	ui.game.sim.state.world.player = {"x":p.position.x,"z":p.position.z,"yaw":p.rotation.y,"pitch":p.camera.rotation.x}
	ui.game.save()

func open_app(page: String, host: String = ""):
	ui.capture_form_drafts()
	if host!="": ui.host = host; ui.selected_vm=""
	ui.context_open=false
	if page=="Nastavení":
		ui.open_settings()
		set_mode("app")
		return
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
	ui.game.reconcile_room()
	if object.kind=="program_door": world.programming_room.toggle_door(); return
	if object.kind=="programming":
		if ui.game.game_mode.is_programming(): open_programming(object.console)
		return
	if ui.game.game_mode.is_programming(): return
	if object.kind != "door":
		var in_training = ui.game.game_mode.is_training()
		var training_object = object.laboratory or object.kind == "instructor" or object.device_id == "EXAM-PC"
		if in_training != training_object: return
	selected = object
	if object.laboratory and (not ui.game.active or not ui.game.session_kind in ["lesson","random"]):
		open_app("Trénink")
		return
	match object.kind:
		"computer":
			if object.laboratory and not ui.game.session_kind in ["lesson","random"]: open_app("Trénink"); return
			open_app(object.console)
			if object.laboratory and ui.game.tutorial.guided(): ui.recover_tutorial_target()
			return
		"server":
			if object.laboratory and not ui.game.session_kind in ["lesson","random"]: open_app("Trénink"); return
			ui.game.apply("physical_inspect",{"device":object.device_id})
			ui.game.notify_event({"type":"server_selected","host":object.device_id})
			show_device(object)
		"disk":
			if object.laboratory and not ui.game.session_kind in ["lesson","random"]: open_app("Trénink"); return
			show_disk(object)
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
		"door": world.toggle_door()
		"instructor": open_app("Trénink")

func open_programming(category: String = "dashboard"):
	if not ui.game.game_mode.is_programming(): return
	if is_instance_valid(code_editor):
		if category=="exam":
			code_editor.mode_picker.select(2)
			if not ui.game.programming.current.is_empty(): code_editor.launch(ui.game.programming.current.get("base_id",ui.game.programming.current.id),false)
		set_mode("coding")
		return
	for child in overlay.get_children(): overlay.remove_child(child); child.queue_free()
	code_editor=preload("res://scripts/programming/CodeEditorController.gd").new()
	code_editor.manager=ui.game.programming; code_editor.shell=self
	overlay.add_child(code_editor)
	if category in ["python","web"]:
		code_editor.selected_category=category
		code_editor.category_picker.select(1 if category=="python" else 5)
		code_editor.populate()
	if category=="exam": code_editor.mode_picker.select(2)
	set_mode("coding")

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
		open_app(object.console,object.device_id)
		if object.laboratory and ui.game.tutorial.guided(): ui.recover_tutorial_target(),true))
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
			var disk_object = world.devices[("TRAIN-" if object.laboratory else "")+pool+":"+slot]
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
	v.add_child(ui.button("Rozsvítit identifikační LED podle serial",func():
		message = ui.game.apply("physical_identify",{"pool":object.pool,"slot":object.slot,"serial":identity.text}).text
		show_disk(object)))
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
	v.add_child(ui.button("Tickety a mise",func(): open_app("Tickety")))
	v.add_child(ui.button("IT Training Academy",func(): enter_world("Trénink")))
	v.add_child(ui.button("Programming Academy",func(): enter_world("Programming Academy")))
	v.add_child(ui.button("Nastavení",func(): settings_from_pause=true; open_app("Nastavení")))
	if vr_active: v.add_child(ui.button("Komfort VR / výška / pohyb",show_vr_settings))
	v.add_child(ui.button("Přenos uloženého postupu",show_progress_transfer))
	v.add_child(ui.button("Seznámení s ovládáním",func(): introduction_step=0; show_introduction()))
	v.add_child(ui.button("Uložit a hlavní menu",func():
		if ui.game.save() == OK:
			ui.page = "menu"
			ui.draw_ui()
			set_mode("menu")
		else: v.add_child(ui.label(ui.game.save_message,16,ui.ORANGE))))

func request_play_mode(value: String):
	if value == "desktop" and vr_active and not OS.has_feature("android"):
		store_pose()
		xr_rig.deactivate()
		vr_active=false
		ui.display_settings.apply_preferences()
		ui.display_settings.apply_world(world)
		return
	if value != "vr": return
	if vr_active: enter_world(); return
	var interface = XRServer.find_interface("OpenXR")
	if interface != null and interface.is_initialized(): start_vr(); return
	if "--vr" in OS.get_cmdline_user_args(): show_vr_error(); return
	# OpenXR graphics integration must be created at engine startup.
	if ui.game.save()!=OK: ui.show_message("Nelze přepnout režim",ui.game.save_message); return
	var arguments=PackedStringArray(["--xr-mode","on","--rendering-method","gl_compatibility"])
	if OS.has_feature("editor"): arguments.append_array(["--path",ProjectSettings.globalize_path("res://")])
	arguments.append("--")
	arguments.append("--vr")
	if "--test-world" in OS.get_cmdline_user_args(): arguments.append("--test-world")
	if OS.create_instance(arguments)<=0: show_vr_error(); return
	get_tree().quit()

func start_vr():
	var interface=XRServer.find_interface("OpenXR")
	if interface == null or not interface.is_initialized(): show_vr_error(); return
	if not is_instance_valid(xr_rig):
		xr_rig=preload("res://scenes/xr/XRPlayer.tscn").instantiate()
		xr_rig.shell=self
		world.player.add_child(xr_rig)
	vr_active=true
	xr_rig.activate()
	apply_vr_quality()
	enter_world()
	print("VR initialized; tracking and device performance require hardware validation.")

func show_vr_error():
	ui.page="menu"
	ui.draw_ui()
	set_mode("menu")
	ui.show_message("VR headset není dostupný","OpenXR se nepodařilo inicializovat. Připoj PICO 4 přes kompatibilní PC VR připojení, zapni OpenXR runtime a spusť hru znovu. Můžeš pokračovat v klasickém 3D. Na PICO používej standalone APK.")

func apply_vr_quality():
	world.get_viewport().msaa_3d=Viewport.MSAA_2X
	for env in world.find_children("*","WorldEnvironment",true,false):
		env.environment.ssao_enabled=false
		env.environment.ssil_enabled=false
		env.environment.ssr_enabled=false
	for light in world.find_children("*","Light3D",true,false): light.shadow_enabled=false
	if OS.has_feature("android"): world.fans.clear()

func show_vr_settings():
	set_mode("pause")
	var v=panel("Komfort VR","Teleport: drž klik levého joysticku, zamiř na volnou podlahu a uvolni. Pravý joystick: snap turn; v monitoru posun obsahu. B/Y nebo menu: pauza. A/X: mise / přemístit monitor.")
	var settings=xr_rig.settings
	var movement=OptionButton.new()
	for caption in ["Teleportace (výchozí)","Plynulá chůze levým joystickem"]: movement.add_item(caption)
	movement.select(1 if settings.locomotion=="smooth" else 0)
	movement.item_selected.connect(func(i): settings.locomotion="smooth" if i==1 else "teleport")
	v.add_child(movement)
	var turn=OptionButton.new()
	for degrees in [15,30,45]: turn.add_item("Snap turn %d°" % degrees)
	turn.select([15,30,45].find(settings.snap_degrees))
	turn.item_selected.connect(func(i): settings.snap_degrees=[15,30,45][i])
	v.add_child(turn)
	var speed=HSlider.new()
	speed.min_value=0.8; speed.max_value=2.5; speed.step=0.1; speed.value=settings.speed
	v.add_child(ui.label("Rychlost chůze (0,8–2,5 m/s)",18))
	v.add_child(speed)
	speed.value_changed.connect(func(value): settings.speed=value)
	var seated=CheckButton.new()
	seated.text="Hraní vsedě — dorovnat výšku očí"
	seated.button_pressed=settings.seated
	seated.toggled.connect(func(value): settings.seated=value; xr_rig.calibrate_height())
	v.add_child(seated)
	v.add_child(ui.button("Znovu nastavit výšku",xr_rig.calibrate_height))
	v.add_child(ui.button("Uložit komfort a pokračovat",func():
		if settings.save_settings()==OK: return_to_world()
		else: v.add_child(ui.label("Nastavení se nepodařilo uložit.",18))))

func show_progress_transfer():
	set_mode("pause")
	var v=panel("Přenos uloženého postupu","Postup i infrastrukturu přenese soubor user://academy-transfer.json. Na PICO jej zkopíruj pomocí ADB; návod je v README. Import vytvoří zálohu a vrátí tě do menu.")
	v.add_child(ui.button("Exportovat postup",func():
		store_pose()
		if ui.game.save()==OK:
			var error=ui.game.Saves.export_progress("user://academy-transfer.json")
			v.add_child(ui.label("Export: "+error_string(error)+"\n"+ProjectSettings.globalize_path("user://academy-transfer.json"),16))))
	v.add_child(ui.button("Importovat postup",func():
		if ui.game.game_mode.is_training(): enter_world("Hlavní serverovna")
		var error=ui.game.Saves.import_progress("user://academy-transfer.json")
		if error==OK: get_tree().reload_current_scene()
		else: v.add_child(ui.label("Import: "+error_string(error),18))))
	v.add_child(ui.button("Zpět",pause_menu))

func export_smoke():
	if "--test-world" not in OS.get_cmdline_user_args(): get_tree().quit(2); return
	await get_tree().process_frame
	print("EXPORT_SMOKE menu=",mode," missions=",ui.game.missions.size()," lessons=",ui.game.tutorial.lessons.size())
	enter_world()
	await get_tree().process_frame
	print("EXPORT_SMOKE world=",mode," objects=",world.devices.size())
	enter_world("Trénink")
	await get_tree().process_frame
	print("EXPORT_SMOKE training=",ui.game.game_mode.is_training())
	enter_world("Programming Academy")
	print("EXPORT_SMOKE programming=",ui.game.game_mode.is_programming()," tasks=",ui.game.programming.catalog.missions.size()," lessons=",ui.game.programming.catalog.lessons.size())
	ui.game.programming.start("PY01","practice")
	ui.game.programming.edit("main.py","print('Ahoj, světe!')")
	print("EXPORT_SMOKE python=",ui.game.programming.test_program().ok)
	ui.game.programming.start("WEB28","practice")
	for filename in ui.game.programming.current.example: ui.game.programming.edit(filename,ui.game.programming.current.example[filename])
	open_programming("web")
	code_editor.load_current()
	code_editor.run_code()
	print("EXPORT_SMOKE web=",ui.game.programming.test_program().ok," preview=",code_editor.preview.document.nodes.size()>0)
	print("EXPORT_SMOKE limits=",FileAccess.file_exists("res://data/programming/LIMITS.txt"))
	enter_world("Hlavní serverovna")
	print("EXPORT_SMOKE programming_cancelled=",ui.game.programming.current.is_empty())
	print("EXPORT_SMOKE return_main=",not ui.game.game_mode.is_training())
	get_tree().quit()

func show_tasks():
	ui.game.reconcile_room()
	if ui.game.game_mode.is_programming(): open_programming(); return
	if not ui.game.active:
		open_app("Trénink")
		return
	set_mode("tasks")
	var v = panel(ui.game.current.title,ui.game.current.description)
	for goal in ui.game.goals(): v.add_child(ui.label(("✓ " if goal.passed else "○ ")+goal.label,18,ui.CYAN if goal.passed else ui.WHITE))
	v.add_child(ui.button("Ověřit infrastrukturu",func():
		ui.game.apply("verify",{})
		show_tasks()))
	v.add_child(ui.button("Předat vyřešený ticket",func():
		var result = ui.game.complete()
		v.add_child(ui.label(("Hodnocení: %d / 100\n" % result.score if result.ok else "")+result.text+("\n\n"+ui.game.assessment() if result.ok else ""),18))
		if result.ok: v.add_child(ui.button("Další úkol / přehled misí",func(): open_app("Tickety")))))
	if ui.game.session_kind=="lesson" and ui.game.tutorial.session.mode!="exam": v.add_child(ui.button("Nápověda",func(): v.add_child(ui.label(ui.game.lesson_hint(),17))))
	if ui.game.session_kind=="lesson": v.add_child(ui.button("Opakovat lekci",func(): ui.begin_lesson(int(ui.game.current.id),ui.game.tutorial.session.mode,false)))
	v.add_child(ui.button("Zpět  [Tab / Esc]",return_to_world))

func _input(event):
	if not event is InputEventKey or event.keycode!=KEY_ESCAPE or not event.pressed or event.echo: return
	for child in ui.get_children():
		if child is Window and child.visible: return
	_unhandled_key_input(event)

func _unhandled_key_input(event):
	if not event.pressed or event.echo: return
	if event.keycode == KEY_ESCAPE:
		if mode == "world": pause_menu()
		elif mode == "introduction": finish_introduction()
		elif mode == "app" and ui.page=="Nastavení": ui.close_settings()
		elif mode == "app" and ui.context_open: ui.context_open=false; ui.draw_ui()
		elif mode != "menu": return_to_world()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("task_list") and mode in ["world","tasks"]:
		if mode == "world": show_tasks()
		else: return_to_world()
		get_viewport().set_input_as_handled()

func update_guidance():
	for object in world.devices.values(): object.set_guided(false)
	instruction.text = ""
	direction.text = ""
	var game = ui.game
	if not game.game_mode.is_training() or not game.active or game.session_kind!="lesson": return
	var t = game.tutorial
	if not t.guided():
		instruction.text = ("ZKOUŠKA" if t.session.mode=="exam" else "PROCVIČOVÁNÍ")+"\n"+game.current.description
		return
	var step = t.current_step()
	var target = world.academy_targets.get(game.current.server,world.academy_targets["PVE-01"])
	if not game.sim.state.world.tutorial_arrived:
		instruction.text = "INSTRUKTOR\nPřejdi k "+target.caption+"."
		if world.player.global_position.distance_to(target.global_position)<2.7:
			game.sim.state.world.tutorial_arrived = true
			game.save()
	else:
		instruction.text = "INSTRUKTOR  /  krok %d z %d\n%s\n%s" % [int(t.session.step)+1,t.lesson.steps.size(),step.get("title","Hotovo"),step.get("text","Všechny kroky jsou ověřené. Tab → předat lekci.")]
		if not t.target(game.sim.state).begins_with("rack:"):
			var key = "TRAIN-PC-HV" if game.current.get("module","")=="Hyper-V" else "TRAIN-PC-PVE"
			if game.current.get("module","")=="Storage": key = "RAID-TRAIN-01"
			target = world.devices[key]
		instruction.text += "\nStiskni E u zařízení a otevři administrační konzoli."
	target.set_guided(true)
	var offset = target.global_position-world.player.global_position
	var local = world.player.global_basis.inverse()*offset
	var angle = atan2(local.x,-local.z)
	var arrow = "↑ Před tebou" if absf(angle)<0.35 else ("→ Vpravo" if angle>0 else "← Vlevo")
	if absf(angle)>2.4: arrow = "↓ Za tebou"
	direction.text = "%s  /  %.1f m\n%s" % [arrow,offset.length(),target.caption]

func on_room_changed(training_room: bool):
	if leaving_scene or not ui.is_inside_tree(): return
	pose_revision = ui.game.session_revision
	if training_room:
		var p = world.player
		ui.game.training_sim.state.world.player = {"x":p.position.x,"z":p.position.z,"yaw":p.rotation.y,"pitch":p.camera.rotation.x}
	pending_cable = ""
	selected = null
	message = ""
	ui.cancel_training_ui()
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	update_guidance()
	instruction_plate.hide()
	world.player.update_focus(null)
	world.sync_state()
	if mode != "menu": set_mode("world")
	ui.page = "Trénink" if training_room else "Serverovna"
	ui.draw_ui()
	room_notice.text = "Vstoupil jsi do tréninkového centra.\nZde můžeš bezpečně procvičovat správu serverů bez ovlivnění hlavní infrastruktury.\nTréninkové centrum – vyber si lekci" if training_room else "Trénink ukončen.\nVrátil ses do hlavní serverovny. Rozpracované cvičení bylo zrušeno."
	if ui.game.game_mode.is_programming(): room_notice.text="Vítej v Programming Academy.\nPython Lab · Web Development Lab · Examination Zone\nU počítače stiskni E a vyber si lekci."
	notice_time = 6.0
	room_notice.show()

func _exit_tree():
	leaving_scene = true
	if is_instance_valid(ui):
		ui.game.room_probe = Callable()
		ui.game.programming_probe=Callable()
		ui.game.leave_training()
