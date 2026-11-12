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
var previous_room = "main"
var leaving_scene = false
var settings_from_pause = false
var pause_page="main"
var utility_to_settings=false
var controls_label: Label
var controls_plate: Panel
var introduction_step = 0
var introduction_return_mode="world"
var ui_layer: CanvasLayer
var xr_rig
var vr_active = false
var code_editor
var speech
var english_dialog
var diagnostics
var practical_intro
var london_navigation

func _notification(what: int):
	if what!=MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT: return
	if is_instance_valid(speech): speech.stop_speech()
	if vr_active: return
	# Keep desktop movement from continuing behind another application. Returning
	# focus never resumes automatically; the player chooses Continue in pause.
	for action in ["walk_left","walk_right","walk_forward","walk_back","walk_fast","interact"]:
		if InputMap.has_action(action): Input.action_release(action)
	if mode=="world" and is_instance_valid(world) and is_instance_valid(ui): pause_menu()

func _ready():
	# Explicit opt-in used by MCP and graphical smoke tests, before Game.new().
	if "--test-world" in OS.get_cmdline_user_args():
		var tag=str(OS.get_process_id())
		preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_"+tag+".json"
		preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_"+tag+".cfg"
		preload("res://scripts/xr/VRSettings.gd").path_override = "user://academy_test_world_"+tag+"_vr.cfg"
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
	ui.shell_ref=weakref(self)
	layer.add_child(ui)
	speech=preload("res://scripts/english/LondonSpeech.gd").new(); speech.shell=self; add_child(speech)
	london_navigation=preload("res://scripts/english/LondonNavigation.gd").new(); london_navigation.shell=self
	world.game = ui.game
	practical_intro=preload("res://scripts/world/PracticalIntroduction.gd").new()
	practical_intro.shell=self; add_child(practical_intro)
	ui.display_settings.apply_world(world)
	ui.preferences_changed.connect(apply_ui_preferences)
	ui.settings_closed.connect(func():
		if settings_from_pause: settings_from_pause=false; pause_menu())
	ui.world_requested.connect(enter_world)
	ui.play_mode_requested.connect(request_play_mode)
	ui.lesson_launched.connect(func(): enter_world())
	world.player.interaction_requested.connect(interact)
	world.player.focus_changed.connect(func(target):
		if is_instance_valid(prompt): prompt.text = interaction_hint(target)
		if is_instance_valid(reticle): reticle.set_focus(is_instance_valid(target))
		if is_instance_valid(context_plate): context_plate.visible = is_instance_valid(target))
	chrome = Control.new()
	layer.add_child(chrome)
	chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.oversampling_with_scale = CanvasItem.OVERSAMPLING_WITH_SCALE_ENABLED
	chrome.size = Vector2(1600,900)
	diagnostics=preload("res://scripts/world/RuntimeDiagnostics.gd").new()
	chrome.add_child(diagnostics)
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
	controls_plate=hud_plate(Vector2(22,850),Vector2(1556,35),Color("253f50"))
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
	room_notice = ui.label("",15)
	chrome.add_child(room_notice)
	room_notice.position = Vector2(22,778)
	room_notice.size = Vector2(480,60)
	room_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	room_notice.add_theme_stylebox_override("normal",ui.box(Color(0.02,0.05,0.08,0.95),ui.CYAN,8))
	room_notice.hide()
	world.training_zone.game = ui.game
	ui.game.room_probe = world.training_zone.contains_player
	ui.game.programming_probe=world.programming_room.contains_player
	ui.game.english_probe=world.english_room.contains_player
	ui.game.hub_probe=world.hub.contains_player
	ui.game.network_lab_probe=world.network_room.contains_player
	ui.game.english.location=world.english_room.near
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
		world.english_room.sync()
		world.network_room.sync()
		var keys=ui.display_settings.bindings
		if vr_active: controls_label.text="B/Y: pauza a ovládání · A/X: aktuální úkol"
		elif ui.display_settings.introduction_seen and not practical_intro.active: controls_label.text="Esc: pauza · %s: úkol · %sovládání" % [OS.get_keycode_string(keys.task_list),"F1: " if not KEY_F1 in keys.values() else "Nastavení → "]
		else: controls_label.text="%s/%s/%s/%s pohyb · myš pohled · %s interakce · %s rychle · %s zadání · %s baterka · Esc pauza" % [OS.get_keycode_string(keys.walk_forward),OS.get_keycode_string(keys.walk_left),OS.get_keycode_string(keys.walk_back),OS.get_keycode_string(keys.walk_right),OS.get_keycode_string(keys.interact),OS.get_keycode_string(keys.walk_fast),OS.get_keycode_string(keys.task_list),OS.get_keycode_string(keys.flashlight)]
		controls_label.size.x=630 if vr_active or (ui.display_settings.introduction_seen and not practical_intro.active) else 1520
		controls_plate.size.x=controls_label.size.x+32
		prompt.text=interaction_hint(world.player.target)
		context_plate.visible=prompt.text!=""
		prompt.size.y=0; prompt.size.y=prompt.get_minimum_size().y
		prompt.position.y=minf(766,819-prompt.size.y)
		context_plate.position.y=prompt.position.y-12; context_plate.size.y=prompt.size.y+24
		status_label.text = "SERVEROVNA 01"
		if ui.game.game_mode.is_hub(): status_label.text="ROZCESTNÍK AKADEMIE / 01–05\nVyber označený průchod do učebny."
		if ui.game.game_mode.is_network_lab():
			var lab = ui.game.network_lab
			status_label.text = "05 / POČÍTAČOVÉ SÍTĚ\nVyber ročník u plánu nebo u terminálu."
			if lab.demo_step>=0:
				status_label.text = "UKÁZKA / "+lab.task.title+"\n"+lab.demo_comment
			elif not lab.task.is_empty():
				status_label.text = ("05 / "+lab.task.title+"\n"+lab.network.last_message).strip_edges()
			if world.network_room.workshop.in_workshop:
				var workshop = ui.game.network_workshop
				status_label.text = "05 / SÍŤOVÁ TRÉNINKOVÁ DÍLNA\n"+(workshop.task.title if not workshop.task.is_empty() else "Vyber ticket u servisního stolu.")
				if workshop.network.cable!="": status_label.text += "\nKonektor "+workshop.network.cable+" / "+str(workshop.network.patch_map.get(workshop.network.cable,""))+" → vyber SW port"
				elif workshop.network.last_message!="": status_label.text += "\n"+workshop.network.last_message
		if ui.game.game_mode.is_english():
			status_label.text="ENGLISH IN LONDON\n%d / 6 situací • [Tab] přehled" % ui.game.english.progress.results.size()
			if not ui.game.english.session.is_empty(): status_label.text+="\n"+ui.game.english.definition().title
		elif ui.game.game_mode.is_programming(): status_label.text="PROGRAMOVACÍ UČEBNA\nPython / tvorba webu · lekce u počítače"
		if ui.game.game_mode.is_training():
			status_label.text = "IT TRÉNINKOVÁ AKADEMIE · výběr lekcí"
			if ui.game.active and ui.game.session_kind=="lesson": status_label.text="VÝUKA / "+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}.get(ui.game.tutorial.session.mode,"Lekce")
			elif ui.game.active and ui.game.session_kind=="random": status_label.text="NÁHODNÉ PROCVIČOVÁNÍ"
		if ui.game.active:
			status_label.text += "\n"+ui.game.current.title
			if ui.game.session_kind in ["campaign","shift"]:
				var goals=ui.Eval.evaluate(ui.game.sim.state,ui.game.current.objectives)
				var complete=goals.filter(func(goal): return goal.passed).size()
				status_label.text += "\n%d / %d cílů  ·  %s zadání" % [complete,goals.size(),OS.get_keycode_string(keys.task_list)]
				var next=goals.filter(func(goal): return not goal.passed)
				status_label.text += "\nDalší cíl: "+str(next[0].label) if not next.is_empty() else "\n✓ Vše ověřeno · předej ticket"
		if practical_intro.active: status_label.text="PRAKTICKÝ ÚVOD / DOČASNÝ STAV\nKampaň i směna jsou bezpečně odložené. Bez XP."
		if pending_cable!="": status_label.text += "\nNeseš konektor "+pending_cable+" → SW-CORE / vyber port."
		if ui.game.sim.state.world.held!="": status_label.text += "\nNeseš: "+ui.game.sim.state.world.stock[ui.game.sim.state.world.held].serial
		if world.door_feedback!="" and not ui.game.game_mode.is_english() and not ui.game.game_mode.is_programming(): status_label.text+="\n"+world.door_feedback+" / ustup od dveří"
		if ui.game.game_mode.is_programming() and "OBSAZENÝ" in world.programming_room.door_notice.text: status_label.text+="\nPRŮCHOD OBSAZENÝ / ustup od dveří"
		if ui.game.unsaved: status_label.text += "\nZMĚNY NEJSOU ULOŽENÉ — Esc → Zkusit uložit znovu"
		update_guidance()
		instruction_plate.visible = instruction.text!=""
		instruction.size.y=0
		instruction.size.y=instruction.get_minimum_size().y
		instruction_plate.size.y=instruction.size.y+20
		status_label.size.y=0
		status_label.size.y=status_label.get_minimum_size().y
		hud.get_node("StatusPlate").size.y=status_label.size.y+52
		direction.position.y=minf(650.0,context_plate.position.y-direction.size.y-8) if context_plate.visible else 650.0 if london_navigation!=null and london_navigation.target!="" else 730.0
	if mode == "world" and save_time>8.0:
		save_time = 0.0
		store_pose()

func interaction_hint(object) -> String:
	if not is_instance_valid(object): return ""
	var use="Trigger" if vr_active else OS.get_keycode_string(ui.display_settings.bindings.interact)
	if practical_intro.active and object.device_id!=practical_intro.target_id(): return "Teď najdi "+practical_intro.target_id() if practical_intro.target_id()!="" else "Pokračuj podle kroku úvodu."
	if ui.game.game_mode.is_hub(): return "Nejdřív projdi označeným vstupem do učebny."
	if object.kind=="network_lab":
		if not ui.game.game_mode.is_network_lab(): return "Nejdřív projdi vstupem do síťové laboratoře."
		var lab = ui.game.network_lab
		var title: String = object.caption
		var can_edit: bool = not lab.task.is_empty() and lab.demo_step<0 and not lab.locked()
		if can_edit and object.console in lab.network.CLIENTS:
			title += " · vybrat nebo odložit konektor"
		elif can_edit and lab.network.cable!="" and str(object.console).is_valid_int():
			title += " · zapojit vybraný konektor"
		return "%s · %s" % [use,title]
	if ui.game.game_mode.is_network_lab(): return "Toto zařízení patří do jiné učebny."
	if object.kind=="english" and not ui.game.game_mode.is_english(): return "Nejdřív vstup do Londýna."
	if object.kind=="programming" and not ui.game.game_mode.is_programming(): return "Nejdřív vstup do programovací učebny."
	if not object.kind in ["door","program_door","programming","english"]:
		var training_object=object.laboratory or object.kind=="instructor" or object.device_id=="EXAM-PC"
		if ui.game.game_mode.is_english() or ui.game.game_mode.is_programming() or ui.game.game_mode.is_training()!=training_object: return "Toto zařízení patří do jiné učebny."
	var action={"computer":"Otevřít konzoli","server":"Prohlédnout zařízení","disk":"Prohlédnout disk / zásah","spares":"Vybrat nebo vrátit díl","monitor":"Otevřít přehled","door":"Ovládat dveře","program_door":"Ovládat dveře","programming":"Otevřít programování","english":"Zahájit interakci","instructor":"Vybrat lekci","cable":"Uchopit konektor / připojení","supply":"Zkontrolovat napájení","switch":"Otevřít síť","port":"Připojit nesený konektor" if pending_cable!="" else "Nejdřív uchop konektor u serveru"}.get(object.kind,"Otevřít")
	if object.kind in ["door","program_door"]:
		var blocked=world.door_feedback if object.kind=="door" else world.programming_room.door_notice.text
		if "OBSAZENÝ" in blocked: return "PRŮCHOD OBSAZENÝ / ustup od dveří"
	var caption=object.caption.replace(" [E]","").replace(" dveře — "," · ")
	return "%s · %s\n%s" % [use,action,caption]

func controls_help_text() -> String:
	if vr_active: return "Levý joystick / teleport: pohyb\nPravý joystick: otáčení / posuv v panelu\nOba paprsky + trigger: interakce\nGrip: uchopení dílu · B/Y: pauza / zpět\nA/X: úkol / přemístění panelu"
	var keys=ui.display_settings.bindings
	return "%s/%s/%s/%s: chůze · myš: pohled\n%s: interakce · %s: aktuální úkol\n%s: baterka · %s: rychlá chůze\nEsc: pauza / zpět" % [OS.get_keycode_string(keys.walk_forward),OS.get_keycode_string(keys.walk_left),OS.get_keycode_string(keys.walk_back),OS.get_keycode_string(keys.walk_right),OS.get_keycode_string(keys.interact),OS.get_keycode_string(keys.task_list),OS.get_keycode_string(keys.flashlight),OS.get_keycode_string(keys.walk_fast)]

func set_mode(value: String):
	if value!="english" and is_instance_valid(speech): speech.stop_speech()
	if value == "menu" and ui.game.game_mode.is_away():
		world.player.position = Vector3(7,0.02,3.5)
		ui.game.reconcile_room()
		var restored_pose = ui.game.sim.state.world.player
		world.player.position = safe_saved_position(Vector3(restored_pose.x,0.02,restored_pose.z))
		world.player.rotation.y = restored_pose.yaw
		world.player.camera.rotation.x = restored_pose.pitch
		ui.page = "menu"
		ui.draw_ui()
	if mode=="world" and value!="world": store_pose()
	mode = value
	update_time = 1.0
	backing.visible = value in ["menu","app"]
	ui.visible = value in ["menu","app"]
	hud.visible = value == "world"
	app_bar.visible = value == "app"
	overlay.visible = value in ["detail","pause","tasks","introduction","coding","network_lab"]
	overlay.offset_bottom = 300 if vr_active and value=="network_lab" else 0
	if value=="english": overlay.visible=true
	if is_instance_valid(english_dialog): english_dialog.visible=value=="english"
	if is_instance_valid(code_editor): code_editor.visible=value=="coding"
	world.player.set_enabled(value == "world")
	if vr_active: xr_rig.mode_changed()

func safe_saved_position(point: Vector3) -> Vector3:
	# Old programming-room positions now lie beyond the sealed north wall.
	# Move only the pose; mission state, equipment, XP and results stay untouched.
	if world.english_room.contains_point(point) or (point.x>3.1 and point.x<6.9 and point.z>6.5 and point.z<7.5): return Vector3(5,0.02,5.5)
	if point.z < -7.2 and not world.programming_room.contains_point(point):
		return Vector3(-7,0.02,0)
	return point

func enter_world(destination: String = "Serverovna"):
	var restore_main_pose: bool = destination=="Hlavní serverovna" and ui.game.game_mode.is_away()
	# A fresh menu entry starts in the neutral hall. Continue inside the live
	# world keeps its pose; explicit course shortcuts still target their rooms.
	if destination=="Rozcestník akademie":
		pending_cable=""
		world.player.position=world.hub.SPAWN
		world.player.velocity=Vector3.ZERO
		world.player.rotation.y=0; world.player.camera.rotation.x=0
		ui.game.reconcile_room()
		pose_revision=ui.game.session_revision
		set_mode("world")
		ui.first_shift_requested=false
		return
	if destination=="Počítačové sítě":
		world.player.position=world.network_room.SPAWN
		world.player.velocity=Vector3.ZERO
		world.player.rotation.y=0; world.player.camera.rotation.x=0
		ui.game.reconcile_room()
		pose_revision=ui.game.session_revision
		set_mode("world")
		ui.first_shift_requested=false
		return
	if destination == "Hlavní serverovna":
		world.player.position = Vector3(7,0.02,3.5)
		world.player.velocity = Vector3.ZERO
		ui.game.reconcile_room()
	if not ui.game.active and not ui.game.game_mode.is_away(): ui.game.start_mission(0)
	if pose_revision != ui.game.session_revision or restore_main_pose:
		var pose = ui.game.sim.state.world.player
		world.player.position = safe_saved_position(Vector3(pose.x,0.02,pose.z))
		world.player.rotation.y = pose.yaw
		world.player.camera.rotation.x = pose.pitch
		pose_revision = ui.game.session_revision
	if destination == "Trénink":
		pending_cable = ""
		world.player.position = Vector3(15,0.02,5.5)
		world.player.rotation.y = 0
		world.player.camera.rotation.x = 0
	if destination=="Programming Academy":
		world.player.position=world.programming_room.entrance_position()
		world.player.velocity=Vector3.ZERO
		world.player.rotation.y=world.programming_room.rotation.y; world.player.camera.rotation.x=0
	if destination=="English in London":
		world.player.position=world.english_room.entrance_position()
		world.player.velocity=Vector3.ZERO
		world.player.rotation.y=PI; world.player.camera.rotation.x=0
	ui.game.reconcile_room()
	pose_revision = ui.game.session_revision
	if ui.game.session_kind!="lesson":
		for object in world.devices.values(): object.set_guided(false)
	world.sync_state()
	set_mode("world")
	if ui.first_shift_requested:
		ui.first_shift_requested=false
		if not ui.display_settings.introduction_seen: introduction_step=0; show_introduction()

func show_introduction():
	introduction_return_mode=mode
	set_mode("introduction")
	var v=panel("Seznámení s ovládáním","Praktický úvod na 3–5 minut: rozhlédnutí v hale, pohyb, dveře, monitor, cvičný díl a pauza. Tvůj postup i rozpracovaná relace se po skončení obnoví.")
	v.add_child(ui.button("Zahájit praktický úvod",practical_intro.start,true))
	v.add_child(ui.button("Přeskočit seznámení",finish_introduction))

func finish_introduction():
	if practical_intro.active: practical_intro.finish(false); return
	ui.save_preference("introduction_seen",true)
	if introduction_return_mode=="menu": ui.page="menu"; ui.draw_ui(); set_mode("menu")
	else: return_to_world()

func return_to_world():
	ui.capture_form_drafts()
	set_mode("world")
	world.sync_state()
	if not practical_intro.active and pose_revision != ui.game.session_revision: enter_world()

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
	var scroll_content = ui.scroll(margin)
	scroll_content.get_parent().follow_focus=true
	var padding=MarginContainer.new(); padding.add_theme_constant_override("margin_bottom",16); scroll_content.add_child(padding)
	var v=ui.vbox(padding,16)
	v.add_child(ui.label(title,32,ui.CYAN))
	if subtitle != "": v.add_child(ui.label(subtitle,17))
	return v

func interact(object):
	if practical_intro.interact(object): return
	ui.game.reconcile_room()
	if ui.game.game_mode.is_hub(): return
	if object.kind=="network_lab":
		if ui.game.game_mode.is_network_lab(): interact_network_lab(object.console)
		return
	if ui.game.game_mode.is_network_lab(): return
	if object.kind=="english":
		if ui.game.game_mode.is_english():
			london_navigation.interacted(object.console)
			if object.console=="tower" and ui.game.english.arrive_tower(): open_english("tower")
			elif object.console!="tower": open_english(object.console)
		return
	if object.kind=="program_door": world.programming_room.toggle_door(); return
	if object.kind=="programming":
		if ui.game.game_mode.is_programming(): open_programming(object.console)
		return
	if ui.game.game_mode.is_programming() or ui.game.game_mode.is_english(): return
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

func interact_network_lab(id: String):
	if id.begins_with("work:"):
		interact_network_workshop(id.trim_prefix("work:"))
		return
	var lab = ui.game.network_lab
	var model = lab.network
	if id in ["year1","year2"]:
		lab.year = int(id.right(1))
		lab.station = -1
		open_network_lab("home")
		return
	if id=="plan":
		lab.station = -1
		open_network_lab("home")
		return
	if not lab.task.is_empty() and lab.demo_step<0 and not lab.locked():
		if id in model.CLIENTS:
			model.select_cable(id)
			world.network_room.sync()
			return
		if id.is_valid_int() and model.cable!="":
			model.connect_cable(int(id))
			world.network_room.sync()
			return
		if id in ["sim_a","sim_b"]:
			model.move_sim(0 if id=="sim_a" else 1)
			world.network_room.sync()
			return
	if lab.task.is_empty():
		lab.station = 5 if id in ["gsm","sim_a","sim_b"] else 4 if id in ["splitter","dsl","ap"] else 0 if id!="terminal" else -1
		open_network_lab("home")
	elif id.is_valid_int():
		lab.selected_port = int(id)
		open_network_lab("measure")
	elif id in ["switch","patch","router","splitter","dsl","ap","gsm","sim_a","sim_b"]:
		open_network_lab("measure")
	else:
		open_network_lab()

func open_network_lab(page: String = ""):
	if not ui.game.game_mode.is_network_lab(): return
	if world.network_room.workshop.in_workshop:
		open_network_workshop()
		return
	if page!="": ui.game.network_lab.view = page
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	var panel_node = preload("res://scripts/network_lab/LabPanel.gd").new()
	panel_node.shell = self
	set_mode("network_lab")
	overlay.add_child(panel_node)
	if vr_active: xr_rig.monitor.place_in_front(xr_rig.head)

func interact_network_workshop(id: String):
	var lab = ui.game.network_workshop
	if id.begins_with("door_"):
		world.network_room.workshop.toggle()
		return
	if id.begins_with("socket_") or id.begins_with("patch_"): id = id.get_slice("_",1)
	if id in lab.network.CLIENTS and (not lab.task.is_empty() or lab.mode=="free"):
		lab.select_cable(id)
		return
	if id.is_valid_int():
		lab.selected_port = int(id)
		if lab.network.cable!="":
			lab.connect_port(int(id))
			return
	if id.begins_with("screen_"): lab.selected = id.trim_prefix("screen_")
	if id in ["near","far"] and not lab.task.is_empty(): lab.measure(id)
	open_network_workshop("home" if id=="desk" else "repair" if id.is_valid_int() or id=="ap" else "measure")

func open_network_workshop(page: String = ""):
	if not ui.game.game_mode.is_network_lab(): return
	if page!="": ui.game.network_workshop.view = page
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	var panel_node = preload("res://scripts/network_lab/WorkshopPanel.gd").new()
	panel_node.shell = self
	set_mode("network_lab")
	overlay.add_child(panel_node)
	if vr_active: xr_rig.monitor.place_in_front(xr_rig.head)

func open_english(station: String = "tickets", intro: bool = false):
	if not ui.game.game_mode.is_english(): return
	for child in overlay.get_children(): overlay.remove_child(child); child.queue_free()
	english_dialog=preload("res://scripts/english/DialogueController.gd").new()
	english_dialog.shell=self; english_dialog.manager=ui.game.english; english_dialog.station=station
	english_dialog.page=("listening_home" if ui.game.english.listening.session.is_empty() else "listening") if station=="listening" else "quiz_home" if station=="quiz" else "intro" if intro else "home" if ui.game.english.session.is_empty() else "dialog"
	if station=="info" and not intro: english_dialog.page="home"
	set_mode("english")
	overlay.add_child(english_dialog)
	if vr_active:
		# Initial placement is anchored near the counter, at the current seated/standing height.
		xr_rig.monitor.place_in_front(xr_rig.head)

func open_programming(category: String = "dashboard"):
	if not ui.game.game_mode.is_programming(): return
	if is_instance_valid(code_editor) and code_editor.is_inside_tree() and not code_editor.is_queued_for_deletion():
		code_editor.focus_station(category)
		set_mode("coding")
		return
	for child in overlay.get_children(): overlay.remove_child(child); child.queue_free()
	code_editor=preload("res://scripts/programming/CodeEditorController.gd").new()
	code_editor.manager=ui.game.programming; code_editor.shell=self
	overlay.add_child(code_editor)
	code_editor.focus_station(category)
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
	if practical_intro.active: practical_intro.pause(); return
	pause_page="main"; utility_to_settings=false
	preload("res://scripts/ui/PausePresentation.gd").draw(self)

func pause_destinations():
	pause_page="destinations"
	preload("res://scripts/ui/PausePresentation.gd").draw(self,pause_page)

func pause_work():
	pause_page="work"
	preload("res://scripts/ui/PausePresentation.gd").draw(self,pause_page)

func show_controls_help(from_settings: bool = true):
	pause_page="help"; utility_to_settings=from_settings
	preload("res://scripts/ui/PausePresentation.gd").draw(self,pause_page)

func return_from_utility():
	if utility_to_settings:
		utility_to_settings=false; pause_page="main"; open_app("Nastavení")
	else: pause_menu()

func open_current_task():
	if ui.game.game_mode.is_english() and not ui.game.english.session.is_empty(): open_english()
	elif ui.game.game_mode.is_programming() and not ui.game.programming.current.is_empty(): open_programming(ui.game.programming.current.category)
	else: show_tasks()

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
	enter_world("Rozcestník akademie")
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
	pause_page="vr"
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
	for item in [["panel_scale","Velikost panelu (násobek)",0.8,1.4,0.05],["panel_distance","Vzdálenost panelu (m)",0.9,2.0,0.05]]:
		var slider=HSlider.new()
		slider.min_value=item[2]; slider.max_value=item[3]; slider.step=item[4]; slider.value=settings.get(item[0])
		slider.custom_minimum_size.y=44
		var value_label=ui.label(item[1]+": %.2f" % slider.value,18)
		v.add_child(value_label); v.add_child(slider)
		slider.value_changed.connect(func(value):
			settings.set(item[0],value); value_label.text=item[1]+": %.2f" % value
			xr_rig.monitor.configure(settings); xr_rig.monitor.place_in_front(xr_rig.head))
	v.add_child(ui.button("Výchozí velikost a vzdálenost panelu",func():
		settings.panel_scale=1.0; settings.panel_distance=1.25; xr_rig.monitor.configure(settings); show_vr_settings()))
	v.add_child(ui.button("Uložit komfort a pokračovat",func():
		if settings.save_settings()==OK: return_to_world()
		else: v.add_child(ui.label("Nastavení se nepodařilo uložit.",18))))

func show_progress_transfer(from_settings: bool = false):
	pause_page="transfer"; utility_to_settings=from_settings
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
	v.add_child(ui.button("Zpět do nastavení" if utility_to_settings else "Zpět do pauzy",return_from_utility))

func export_smoke():
	if "--test-world" not in OS.get_cmdline_user_args(): get_tree().quit(2); return
	await get_tree().process_frame
	print("EXPORT_SMOKE menu=",mode," missions=",ui.game.missions.size()," lessons=",ui.game.tutorial.lessons.size())
	print("EXPORT_SMOKE game_version=",ProjectSettings.get_setting("application/config/version","neurčena"))
	print("EXPORT_SMOKE usability_menu=",ui.ui_targets.has("menu:intro") and ui.ui_targets.has("menu:resume") and ui.ui_targets["menu:resume"].disabled)
	enter_world("Rozcestník akademie")
	await get_tree().process_frame
	print("EXPORT_SMOKE hub=",ui.game.game_mode.is_hub()," neutral=",not ui.game.active)
	print("EXPORT_SMOKE world=",mode," objects=",world.devices.size())
	enter_world("Trénink")
	await get_tree().process_frame
	print("EXPORT_SMOKE training=",ui.game.game_mode.is_training())
	enter_world("Programming Academy")
	print("EXPORT_SMOKE programming_west=",world.programming_room.door.global_position.x < -8.5)
	print("EXPORT_SMOKE programming=",ui.game.game_mode.is_programming()," tasks=",ui.game.programming.catalog.missions.size()," lessons=",ui.game.programming.catalog.lessons.size())
	ui.game.programming.start("PY01","practice")
	ui.game.programming.edit("main.py","print('Ahoj, světe!')")
	print("EXPORT_SMOKE python=",ui.game.programming.test_program().ok)
	ui.game.programming.start("WEB28","practice")
	for filename in ui.game.programming.current.example: ui.game.programming.edit(filename,ui.game.programming.current.example[filename])
	open_programming("web")
	code_editor.load_current()
	code_editor.run_code()
	var preserved_files=ui.game.programming.files.duplicate(true)
	code_editor.toggle_sidebar()
	print("EXPORT_SMOKE sidebar_preserved=",code_editor.sidebar_collapsed and not code_editor.sidebar.visible and ui.game.programming.files==preserved_files)
	print("EXPORT_SMOKE web=",ui.game.programming.test_program().ok," preview=",code_editor.preview.document.nodes.size()>0)
	print("EXPORT_SMOKE limits=",FileAccess.file_exists("res://data/programming/LIMITS.txt"))
	enter_world("Hlavní serverovna")
	print("EXPORT_SMOKE programming_cancelled=",ui.game.programming.current.is_empty())
	enter_world("English in London")
	var english=ui.game.english
	english.progress.intro_seen=true
	for id in english.IDS:
		english.cancel(); english.start(id,"practice",0)
		world.player.position=Vector3(12,0.02,8.8)
		if id=="LON06":
			world.player.position=Vector3(6,0.02,11.4)
			english.act("directions",english.revision)
			smoke_question(english,"repeat")
			english.act("route",english.revision)
			world.player.position=Vector3(4,0.02,24)
			english.arrive_tower()
		else:
			var topics={"LON01":["options","included"],"LON02":["family","included"],"LON03":["options","included"],"LON04":["availability","recommend"],"LON05":["change"]}[id]
			for topic in topics: smoke_question(english,topic)
			if id=="LON05": english.act("change",english.revision)
			if id=="LON03": english.act("price",english.revision)
			english.act("order",english.revision)
			english.act("product_standard",english.revision)
			if id=="LON04": english.act("time_14:00",english.revision); english.act("next",english.revision)
			else: english.act("time_"+english.session.goal.time,english.revision)
			if id in ["LON03","LON05"]: smoke_question(english,"total")
			english.act("confirm",english.revision)
			world.player.position=Vector3(10,0.02,8.7)
			english.pay(english.revision); english.act("thanks",english.revision)
			world.player.position=Vector3(17,0.02,16.6)
			english.present_ticket()
	print("EXPORT_SMOKE english=",ui.game.game_mode.is_english()," scenarios=",english.catalog.scenarios.size()," completed=",english.progress.results.size())
	var quiz=english.quiz
	quiz.start("exam",20,71)
	for i in 20: quiz.answer(quiz.definition().answer,quiz.revision); quiz.next(quiz.revision)
	print("EXPORT_SMOKE quiz=",quiz.session.completed," questions=",quiz.catalog.questions.size()," score=",quiz.session.score)
	enter_world("Hlavní serverovna")
	print("EXPORT_SMOKE english_cancelled=",english.session.is_empty())
	print("EXPORT_SMOKE return_main=",not ui.game.game_mode.is_training())
	preload("res://scripts/shifts/GameplaySmoke.gd").run(self)
	await preload("res://scripts/network_lab/WorkshopSmoke.gd").run(self)
	get_tree().quit()

func smoke_question(english, topic: String):
	english.open_questions(english.revision,english.Questions.TOPICS.find(topic)/3)
	english.act("q_"+topic,english.revision); english.act("understood",english.revision)

func show_tasks():
	ui.game.reconcile_room()
	if ui.game.game_mode.is_hub():
		set_mode("tasks")
		var v=panel("Rozcestník akademie","01 / Serverovna — kampaň a incidenty\n02 / IT trénink — cvičná infrastruktura\n03 / Programování — Python a web\n04 / English in London — B1–B2 a londýnský kvíz\n05 / Počítačové sítě — síťová laboratoř")
		v.add_child(ui.button("Zpět do haly",return_to_world)); return
	if ui.game.game_mode.is_network_lab(): open_network_lab(); return
	if ui.game.game_mode.is_english(): open_english(); return
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
	var ticket_revision=ui.game.session_revision
	v.add_child(ui.button("Předat vyřešený ticket",func():
		var result = ui.game.complete(ticket_revision)
		v.add_child(ui.label(("Hodnocení: %d / 100\n" % result.score if result.ok else "")+result.text+("\n\n"+ui.game.assessment() if result.ok else ""),18))
		if result.ok: v.add_child(ui.button("Další ticket / přehled směny" if ui.game.session_kind=="shift" else "Další úkol / přehled misí",func():
			if ui.game.session_kind=="shift" and not ui.game.finished: show_tasks()
			else: open_app("Souvislé směny" if ui.game.session_kind=="shift" else "Tickety")))))
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
	if event.keycode==KEY_F1 and mode=="world" and not KEY_F1 in ui.display_settings.bindings.values():
		show_controls_help(false); get_viewport().set_input_as_handled(); return
	if event.keycode == KEY_ESCAPE:
		if mode == "world": pause_menu()
		elif mode == "introduction": finish_introduction()
		elif mode == "pause" and practical_intro.active and practical_intro.step==10: practical_intro.finish(true)
		elif mode=="pause" and pause_page=="work": pause_destinations()
		elif mode=="pause" and pause_page!="main": return_from_utility()
		elif mode == "app" and ui.page=="Nastavení": ui.close_settings()
		elif mode == "app" and ui.page=="Pokračování": ui.page="menu"; ui.draw_ui(); set_mode("menu")
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
	if practical_intro.active: practical_intro.guidance(); return
	if london_navigation!=null:
		london_navigation.update()
		if london_navigation.target!="": return
	var game = ui.game
	if not game.game_mode.is_training() or not game.active or game.session_kind!="lesson": return
	var t = game.tutorial
	if not t.guided():
		instruction.text = ("ZKOUŠKA / bez nápovědy" if t.session.mode=="exam" else "PROCVIČOVÁNÍ / vlastní postup")+"\n"+("A/X: celé zadání" if vr_active else "%s: celé zadání" % OS.get_keycode_string(ui.display_settings.bindings.task_list))
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
		if not is_instance_valid(world.player.target): instruction.text += "\n"+("Namiř paprsek a stiskni trigger." if vr_active else "Zaměř zařízení a stiskni %s." % OS.get_keycode_string(ui.display_settings.bindings.interact))
	target.set_guided(true)
	var offset = target.global_position-world.player.global_position
	var local = world.player.global_basis.inverse()*offset
	var angle = atan2(local.x,-local.z)
	var arrow = "↑ Před tebou" if absf(angle)<0.35 else ("→ Vpravo" if angle>0 else "← Vlevo")
	if absf(angle)>2.4: arrow = "↓ Za tebou"
	direction.text = "%s  /  %.1f m\n%s" % [arrow,offset.length(),target.caption]

func on_room_changed(training_room: bool):
	if leaving_scene or not ui.is_inside_tree(): return
	if ui.game.game_mode.current==0 and not ui.game.active and not world.hub.contains_player() and not world.training_zone.contains_player() and not world.programming_room.contains_player() and not world.english_room.contains_player() and not world.network_room.contains_player(): ui.game.resume_campaign()
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
	var current_room="network_lab" if ui.game.game_mode.is_network_lab() else "hub" if ui.game.game_mode.is_hub() else "english" if ui.game.game_mode.is_english() else "programming" if ui.game.game_mode.is_programming() else "training" if training_room else "main"
	var exit_text={"english":"Odchod z angličtiny.","programming":"Odchod z programovací učebny.","training":"Odchod z IT tréninkové akademie."}.get(previous_room,"")+" Kampaň obnovena."
	room_notice.text={"network_lab":"05 / Počítačové sítě · ročník vyber u plánu nebo u terminálu.","hub":"Rozcestník / kampaň bezpečně odložena. Vyber si označený průchod.","english":"English in London / přepážka Tickets, Alex a most k věži.","programming":"Programovací učebna / vyber lekci u počítače.","training":"IT tréninková akademie / vyber serverovou lekci."}.get(current_room,exit_text)
	if current_room=="english" and not ui.game.english.progress.intro_seen:
		call_deferred("english_welcome")
	previous_room=current_room
	notice_time = 4.0
	room_notice.show()

func english_welcome():
	if ui.game.game_mode.is_english() and mode=="world": open_english("tickets",true)

func _exit_tree():
	leaving_scene = true
	if london_navigation!=null: london_navigation.clear(); london_navigation.shell=null; london_navigation=null
	if is_instance_valid(practical_intro) and practical_intro.active: practical_intro.finish(false)
	if is_instance_valid(ui):
		ui.game.room_probe = Callable()
		ui.game.programming_probe=Callable()
		ui.game.english_probe=Callable()
		ui.game.hub_probe=Callable()
		ui.game.network_lab_probe=Callable()
		ui.game.english.location=Callable()
		ui.game.leave_training()
