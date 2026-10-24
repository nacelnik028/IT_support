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

func _ready():
	# Explicit opt-in used by MCP and graphical smoke tests, before Game.new().
	if "--test-world" in OS.get_cmdline_user_args():
		preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_mcp.json"
		preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_mcp.cfg"
	world = preload("res://scenes/world/Datacenter3D.tscn").instantiate()
	add_child(world)
	var layer = CanvasLayer.new()
	add_child(layer)
	ui = preload("res://scenes/main_menu/Main.tscn").instantiate()
	ui.world_enabled = true
	layer.add_child(ui)
	world.game = ui.game
	ui.world_requested.connect(enter_world)
	ui.lesson_launched.connect(func(): enter_world("Trénink"))
	world.player.interaction_requested.connect(interact)
	world.player.focus_changed.connect(func(target):
		if is_instance_valid(prompt): prompt.text = "Stiskni E pro interakci\n"+target.caption if is_instance_valid(target) else "")
	hud = Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
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
	app_bar = HBoxContainer.new()
	layer.add_child(app_bar)
	app_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	app_bar.offset_top = -50
	app_bar.offset_right = -25
	app_bar.alignment = BoxContainer.ALIGNMENT_END
	app_bar.add_child(ui.button("← Zpět do 3D prostředí  [Esc]",return_to_world,true))
	overlay = Control.new()
	layer.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.theme = ui.theme
	set_mode("menu")

func _process(delta):
	update_time += delta
	if update_time > 0.25:
		update_time = 0.0
		world.sync_state()

func set_mode(value: String):
	mode = value
	ui.visible = value in ["menu","app"]
	hud.visible = value == "world"
	app_bar.visible = value == "app"
	overlay.visible = value in ["detail","pause","tasks"]
	world.player.set_enabled(value == "world")

func enter_world(destination: String = "Serverovna"):
	if not ui.game.active: ui.game.start_mission(0)
	world.sync_state()
	set_mode("world")

func return_to_world():
	ui.capture_form_drafts()
	set_mode("world")
	world.sync_state()

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
	if object.kind == "computer": open_app(object.console); return
	show_device(object)

func show_device(object):
	set_mode("detail")
	var s = ui.game.sim.state
	var v = panel(object.caption,"Fyzické zařízení / živý stav simulace")
	var h = s.hosts[object.device_id]
	v.add_child(ui.label("Stav: %s   •   RAM: %s GB\nManagement: %s" % ["Zapnuto" if h.online else "Vypnuto",h.get("ram",0),h.get("ip","192.168.10.10")],20))
	v.add_child(ui.button("Otevřít management",func():
		ui.game.notify_event({"type":"node_selected","host":object.device_id,"vm":""})
		open_app(object.console,object.device_id),true))
	v.add_child(ui.button("Diagnostika a logy",func():
		var result = ui.game.apply("inspect",{"scope":"Events"})
		v.add_child(ui.label(result.text,16))))
	v.add_child(ui.button("Zpět do serverovny",return_to_world))

func pause_menu():
	set_mode("pause")
	var v = panel("Pauza","Pohyb a fyzické interakce jsou pozastavené.")
	v.add_child(ui.button("Pokračovat",return_to_world,true))
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
