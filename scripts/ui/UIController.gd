extends Control

signal world_requested(destination: String)
signal lesson_launched
signal preferences_changed
signal settings_closed
var world_enabled = false

const Game = preload("res://scripts/core/GameManager.gd")
const Racks = preload("res://scripts/ui/RackView.gd")
const Eval = preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
const Display=preload("res://scripts/core/DisplaySettings.gd")
const Icons=preload("res://scripts/ui/VectorIcons.gd")
var display_settings=Display.new()
var manage_display=true
var settings_controls: Dictionary={}
var quitting=false
var game = Game.new()
var page = "menu"
var tab = ""
var host = "PVE-01"
var root_box: Control
var center: VBoxContainer
var notice = ""
var bad_notice = false
var terminal_history = "DATACENTER ACADEMY • bezpečný simulovaný terminál\nZadej help pro seznam podporovaných příkazů.\n"
var command_history: Array = []
var history_position = 0
var sound_on = true
var terminal_host = "PVE-01"
var full_notice = ""
var form_controls: Dictionary = {}
var form_buttons: Dictionary = {}
var academy_category = "Proxmox"
var academy_article = 0
var selected_vm = ""
var player: AudioStreamPlayer
var click_sound: AudioStreamWAV
var transition: Tween
var tutorial_overlay: Control
var ui_targets: Dictionary={}
var training_category="Všechny lekce"
var training_view="lessons"
var mission_filter="Vše"
var content_box: VBoxContainer
var persistence_box: VBoxContainer
var form_drafts: Dictionary={}
var form_scopes: Dictionary={}
var form_defaults: Dictionary={}
var draft_revision=-1
var save_caption: Label
const Forms = preload("res://scripts/ui/FormValues.gd")
const Console = preload("res://scripts/ui/ConsoleNavigation.gd")
const Context = preload("res://scripts/simulation/OperationContext.gd")
var working_context = preload("res://scripts/ui/WorkingContext.gd").new()
var active_action = ""
var wizard_step = 0
var wizard_unlocked = 0
var wizard_vm = "101"
var context_open = false
var settings_tab = "Obraz"
var settings_return = "menu"
var display_previous = {}
var display_dialog: ConfirmationDialog
var display_deadline = 0
var binding_dialog: AcceptDialog
var binding_action = ""
const Search = preload("res://scripts/ui/CatalogSearch.gd")
const TutorialUI = preload("res://scripts/ui/TutorialPresentation.gd")
var search_queries = {}
var search_status = {}
var first_shift_requested = false
var notice_kind = "success"
var last_action = ""
var tutorial_reveal_frames = 0

const CYAN = Color("3ddbc6")
const MUTED = Color("8c9eb5")
const WHITE = Color("e5edf7")
const ORANGE = Color("ffb65c")

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Rasterize glyphs and DPITexture icons at their displayed pixel size.
	# Scaling the Control alone otherwise magnifies the original small atlas.
	oversampling_with_scale=CanvasItem.OVERSAMPLING_WITH_SCALE_ENABLED
	# Existing simulation tests retain their own window and never read player settings.
	manage_display=Game.Saves.path_override=="" or Display.path_override!=""
	if manage_display:
		display_settings.load_settings()
		display_settings.apply(get_window())
		sync_display_layout()
	get_tree().auto_accept_quit=false
	get_window().close_requested.connect(quit_game)
	display_settings.apply_preferences()
	sound_on=not display_settings.muted
	theme = make_theme()
	create_sound()
	game.persistence_changed.connect(refresh_persistence_status)
	draw_ui()
	if "--capture" in OS.get_cmdline_user_args(): capture_later()

func make_theme() -> Theme:
	var t = Theme.new()
	t.default_font_size = roundi(15*display_settings.text_scale)
	t.set_color("font_color","Label",WHITE)
	t.set_color("font_color","Button",WHITE)
	t.set_color("font_hover_color","Button",CYAN)
	for type in ["Button","OptionButton"]:
		t.set_stylebox("normal",type,box(Color("17273c"),Color("293c54"),7))
		t.set_stylebox("hover",type,box(Color("203a50"),CYAN,7))
		t.set_stylebox("pressed",type,box(Color("19483f"),CYAN,7))
		t.set_stylebox("focus",type,box(Color(0,0,0,0),CYAN,7))
		t.set_stylebox("disabled",type,box(Color("101b2c"),Color("1c293d"),7))
	t.set_stylebox("normal","LineEdit",box(Color("091522"),Color("2a4057"),6))
	t.set_stylebox("focus","LineEdit",box(Color("11263a"),CYAN,6))
	t.set_color("font_color","LineEdit",WHITE)
	t.set_color("font_color","OptionButton",WHITE)
	t.set_stylebox("panel","PopupMenu",box(Color("152539"),Color("35516b"),6))
	t.set_stylebox("panel","AcceptDialog",box(Color("132338"),CYAN,10))
	t.set_stylebox("background","ProgressBar",box(Color("213147"),Color(0,0,0,0),4))
	t.set_stylebox("fill","ProgressBar",box(CYAN,Color(0,0,0,0),4))
	Icons.apply(t)
	return t

func box(bg: Color, border = Color("23364d"), radius = 10) -> StyleBoxFlat:
	var b = StyleBoxFlat.new()
	b.bg_color = bg
	b.border_color = border
	b.set_border_width_all(1)
	b.set_corner_radius_all(radius)
	b.content_margin_left = 14
	b.content_margin_right = 14
	b.content_margin_top = 10
	b.content_margin_bottom = 10
	return b

func label(text: String, size_px = 15, color = WHITE) -> Label:
	var l = Label.new()
	l.text = text
	l.set_meta("base_font_size",size_px)
	l.add_theme_font_size_override("font_size",roundi(size_px*display_settings.text_scale))
	l.add_theme_color_override("font_color",color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

func button(text: String, action: Callable, primary = false) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size.y = 40
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(func(): play_click(); action.call())
	if primary:
		b.add_theme_stylebox_override("normal",box(Color("194d4a"),Color("2ea594"),7))
		b.add_theme_color_override("font_color",Color("8af6df"))
	return b

func vbox(parent: Node, separation = 12) -> VBoxContainer:
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation",separation)
	parent.add_child(v)
	return v

func hbox(parent: Node, separation = 12) -> HBoxContainer:
	var h = HBoxContainer.new()
	h.add_theme_constant_override("separation",separation)
	parent.add_child(h)
	return h

func card(parent: Node, title = "", subtitle = "") -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel",box(Color("101e30")))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var v = vbox(panel)
	if title != "": v.add_child(label(title,18))
	if subtitle != "": v.add_child(label(subtitle,13,MUTED))
	return v

func scroll(parent: Node) -> VBoxContainer:
	var s = ScrollContainer.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(s)
	var v = vbox(s,16)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return v

func clear_ui():
	ui_targets.clear()
	if is_instance_valid(tutorial_overlay): tutorial_overlay.queue_free()
	if transition and transition.is_valid(): transition.kill()
	form_controls.clear()
	form_buttons.clear()
	form_scopes.clear()
	form_defaults.clear()
	settings_controls.clear()
	if is_instance_valid(root_box):
		remove_child(root_box)
		root_box.queue_free()
	root_box = MarginContainer.new()
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: root_box.add_theme_constant_override("margin_"+side,70 if side=="bottom" and world_enabled else 20)
	add_child(root_box)
	var layout=vbox(root_box,10)
	persistence_box=vbox(layout,0)
	content_box=vbox(layout,0)
	content_box.size_flags_vertical=Control.SIZE_EXPAND_FILL
	refresh_persistence_status()

func refresh_persistence_status():
	if is_instance_valid(save_caption): save_caption.text="Neuložené změny — použij opakování zápisu nahoře." if game.unsaved else "Postup uložen."
	if not is_instance_valid(persistence_box): return
	for child in persistence_box.get_children():
		persistence_box.remove_child(child)
		child.queue_free()
	if game.load_warning=="" and not game.unsaved: return
	var panel=card(persistence_box,"Změny čekají na uložení" if game.unsaved else "Uložený postup nebyl načten",game.save_message if game.unsaved else game.load_warning)
	panel.get_parent().add_theme_stylebox_override("panel",box(Color("29231e"),ORANGE,10))
	var row=hbox(panel)
	row.add_child(button("Zkusit uložit znovu",func(): game.save()))
	if game.last_save_error==ERR_FILE_CORRUPT or game.load_warning!="":
		row.add_child(button("Zálohovat vadný soubor a uložit",func(): game.save(true)))

func save_and_menu():
	if game.save()!=OK: return
	page="menu"
	draw_ui()

func draw_ui():
	working_context.capture(self)
	if draft_revision==game.session_revision: capture_form_drafts()
	else:
		form_drafts.clear()
		working_context.views.clear()
		wizard_step=0
		wizard_unlocked=0
		wizard_vm="101"
		active_action=""
		selected_vm=""
		context_open=false
		draft_revision=game.session_revision
		TutorialUI.route(self)
	normalize_selection()
	clear_ui()
	if page == "menu": draw_menu(); working_context.restore(self); return
	if page == "Nastavení": draw_settings(); working_context.restore(self); return
	var whole = vbox(content_box,16)
	whole.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var top = hbox(whole)
	var brand = vbox(top,2)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_child(label("◈  DATACENTER ACADEMY",21,CYAN))
	brand.add_child(label("NORTHSTAR IT  /  OPERATIONS CENTER",10,MUTED))
	top.add_child(label("ÚROVEŇ %d   •   %d XP" % [1+int(float(game.progress.xp)/600.0),int(game.progress.xp)],15))
	top.add_child(button("Uložit a menu",save_and_menu))
	var body = hbox(whole,18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var nav = HFlowContainer.new()
	whole.add_child(nav)
	whole.move_child(nav,1)
	for target in ["Serverovna","Tickety","Trénink","Proxmox","Hyper-V","Storage","Síť","Terminál","Akademie","Statistiky"]:
		var b = button(target,func(): navigate(target),page==target)
		b.custom_minimum_size.y=32
		nav.add_child(b)
		register_target("nav:"+target,b)
	nav.add_child(button("Nastavení",func(): open_settings()))
	var context_button=button("← Konfigurace" if context_open else ("Instruktor / zadání" if game.session_kind=="lesson" else "Zadání ticketu"),func(): context_open=not context_open; draw_ui())
	top.add_child(context_button)
	register_target("context:toggle",context_button)
	brand.get_child(1).text="CVIČNÁ INFRASTRUKTURA · kampaň pozastavena" if game.game_mode.is_training() else "HLAVNÍ SERVEROVNA · pracovní směna"
	if page in ["Proxmox","Hyper-V","Storage"]:
		var scene_path={"Proxmox":"res://scenes/consoles/proxmox/Proxmox.tscn","Hyper-V":"res://scenes/consoles/hyperv/HyperV.tscn","Storage":"res://scenes/consoles/raid/Storage.tscn"}[page]
		center=load(scene_path).instantiate()
		body.add_child(center)
		center.add_theme_constant_override("separation",14)
	else: center = vbox(body,14)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(label(page,30))
	if notice != "" and page not in ["Proxmox","Hyper-V","Storage"]:
		center.add_child(label(("Chyba: " if bad_notice else "Hotovo: ")+notice.left(180),13,ORANGE if bad_notice else CYAN))
	if context_open and game.active:
		if game.session_kind=="lesson": draw_lesson_panel(center)
		else: draw_ticket(center)
		working_context.restore(self)
		call_deferred("focus_tutorial")
		return
	if page in ["Proxmox","Hyper-V","Storage"]: TutorialUI.draw(self,center)
	match page:
		"Trénink": draw_training_center()
		"Serverovna": draw_datacenter()
		"Tickety": draw_tickets()
		"Proxmox", "Hyper-V", "Storage": draw_console()
		"Síť": draw_network()
		"Terminál": draw_terminal()
		"Akademie": draw_academy()
		"Statistiky": draw_stats()
	whole.add_child(label("DATACENTER ACADEMY     /     Pozorovat → diagnostikovat → bezpečně změnit → ověřit → zdokumentovat",10,MUTED))
	root_box.modulate.a=0.85
	transition=create_tween()
	transition.tween_property(root_box,"modulate:a",1.0,0.14)
	working_context.restore(self)
	call_deferred("focus_tutorial")

func draw_menu():
	# A load warning must not push the exit/settings buttons below the viewport.
	var all = scroll(content_box) if game.load_warning!="" or game.unsaved else vbox(content_box,24)
	all.add_theme_constant_override("separation",24)
	all.size_flags_vertical=Control.SIZE_EXPAND_FILL
	all.add_child(label("◈   DATACENTER ACADEMY",22,CYAN))
	var body = hbox(all,44)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var left = vbox(body,22)
	left.custom_minimum_size.x = 490
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var space = Control.new()
	space.custom_minimum_size.y=70
	left.add_child(space)
	left.add_child(label("IT SUPPORT SIMULATOR",13,CYAN))
	left.add_child(label("Tvá první směna\nzačíná tady.",49))
	left.add_child(label("Šest serverů. Skutečná rozhodnutí.\nNauč se udržet infrastrukturu v provozu.",19,MUTED))
	left.add_child(button("Pokračovat v rozehrané směně" if game.active else "Zahájit první směnu   →",func():
		if not game.active: first_shift_requested=true; game.start_mission(0)
		navigate("Serverovna"),true))
	left.add_child(button("Kampaň a přehled ticketů",func():
		if game.session_kind!="campaign": game.resume_campaign()
		elif not game.active: game.start_mission(0)
		game.set_campaign_mode(false)
		navigate("Tickety")))
	left.add_child(button("◇  Tréninkové centrum",func(): navigate("Trénink")))
	left.add_child(button("Volný trénink  •  všechny laboratoře",func():
		if not game.active: game.start_mission(0,true)
		game.set_campaign_mode(true)
		navigate("Tickety")))
	var system_buttons=hbox(left,12)
	var settings_button=button("Nastavení",open_settings)
	settings_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	system_buttons.add_child(settings_button)
	var exit_button=button("Ukončit hru",quit_game)
	exit_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	system_buttons.add_child(exit_button)
	left.add_child(label("PROXMOX VE     /     HYPER-V     /     RAID & STORAGE",12,CYAN))
	var right = vbox(body,18)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var fill = Control.new()
	fill.custom_minimum_size.y=60
	right.add_child(fill)
	right.add_child(label("NORTHSTAR / SERVER ROOM 01",12,MUTED))
	var racks = Racks.new()
	right.add_child(racks)
	racks.custom_minimum_size = Vector2(520,460)
	racks.state = game.sim.state
	racks.server_selected.connect(func(_name):
		if not game.active: game.start_mission(0)
		navigate("Serverovna"))
	var info = card(right,"Praktická laboratoř", "Konfiguruj virtuální stroje, opravuj sítě a obnovuj data. Hra funguje offline a ukládá každý zásah.")
	if world_enabled:
		info.add_child(button("15 praktických úkolů ve 3D",func():
			if not game.active: game.start_mission(0,true)
			game.set_campaign_mode(true)
			mission_filter="3D praxe"
			navigate("Tickety")))
	info.add_child(label("%d TICKETŮ     •     %d LEKCÍ     •     TVÉ TEMPO" % [game.missions.size(),game.tutorial.lessons.size()],12,CYAN))
	all.add_child(label("Výuková simulace správy serverů  /  Čeština  /  Godot 4",12,MUTED))

func sync_display_layout():
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position=Vector2.ZERO
	size=Vector2(Display.DESIGN_SIZE)
	scale=Vector2(display_settings.resolution)/Vector2(Display.DESIGN_SIZE)

func open_settings():
	if page!="Nastavení": settings_return=page
	page="Nastavení"
	notice=""
	draw_ui()

func close_settings():
	if not display_previous.is_empty(): resolve_display(false)
	page=settings_return
	draw_ui()
	settings_closed.emit()

func draw_settings():
	preload("res://scripts/ui/SettingsPanel.gd").draw(self)

func save_preference(key: String, value) -> bool:
	var previous=display_settings.get(key)
	display_settings.set(key,value)
	if display_settings.save_settings()!=OK:
		display_settings.set(key,previous)
		notice="Nastavení se nepodařilo uložit. Zkontroluj přístup k uživatelské složce."
		bad_notice=true
		show_message("Nastavení nebylo uloženo",notice)
		return false
	display_settings.apply_preferences()
	sound_on=not display_settings.muted
	theme=make_theme()
	preferences_changed.emit()
	return true

func preview_display(resolution: Vector2i, fullscreen: bool):
	if not display_previous.is_empty(): resolve_display(false)
	display_previous={"resolution":display_settings.resolution,"fullscreen":display_settings.fullscreen}
	apply_display_settings(resolution,fullscreen,false)
	display_deadline=Time.get_ticks_msec()+15000
	display_dialog=ConfirmationDialog.new()
	display_dialog.title="Potvrdit zobrazení"
	display_dialog.ok_button_text="Ponechat zobrazení"
	display_dialog.cancel_button_text="Vrátit původní obraz"
	add_child(display_dialog)
	display_dialog.confirmed.connect(func(): resolve_display(true))
	display_dialog.canceled.connect(func(): resolve_display(false))
	bind_dialog_escape(display_dialog)
	display_dialog.popup_centered(Vector2i(520,180))

func resolve_display(keep: bool):
	if display_previous.is_empty(): return
	var previous=display_previous.duplicate()
	display_previous.clear()
	if keep and display_settings.save_settings()!=OK:
		keep=false
		notice="Zobrazení se nepodařilo uložit; obnoven původní obraz."
		bad_notice=true
	if not keep:
		display_settings.resolution=previous.resolution
		display_settings.fullscreen=previous.fullscreen
		display_settings.apply(get_window())
		sync_display_layout()
	if is_instance_valid(display_dialog): display_dialog.hide(); display_dialog.queue_free()
	draw_ui()

func _process(_delta):
	working_context.process(self)
	if tutorial_reveal_frames>0:
		tutorial_reveal_frames-=1
		ensure_tutorial_visible()
	if not display_previous.is_empty():
		var remaining=maxi(0,ceili((display_deadline-Time.get_ticks_msec())/1000.0))
		display_dialog.dialog_text="Je obraz čitelný? Potvrď změnu do %d s.\nBez potvrzení se vrátí poslední potvrzené nastavení." % remaining
		if remaining==0: resolve_display(false)

func capture_binding(action: String):
	binding_action=action
	binding_dialog=AcceptDialog.new()
	binding_dialog.title="Změna klávesy"
	binding_dialog.dialog_text="Stiskni novou klávesu pro: "+Display.KEY_LABELS[action]+". Escape změnu zruší."
	binding_dialog.close_requested.connect(func(): binding_action=""; binding_dialog.queue_free())
	binding_dialog.confirmed.connect(func(): binding_action=""; binding_dialog.queue_free())
	binding_dialog.window_input.connect(_input)
	add_child(binding_dialog)
	binding_dialog.popup_centered(Vector2i(520,180))

func _input(event):
	if binding_action=="" or not event is InputEventKey or not event.pressed or event.echo: return
	get_viewport().set_input_as_handled()
	var key=event.physical_keycode if event.physical_keycode!=0 else event.keycode
	if key==KEY_ESCAPE:
		binding_action=""; binding_dialog.queue_free(); return
	if key in [KEY_F11,KEY_SHIFT,KEY_CTRL,KEY_ALT,KEY_META] and key!=KEY_SHIFT:
		binding_dialog.dialog_text="Tato klávesa je vyhrazená. Zvol jinou klávesu."; return
	for action in display_settings.bindings:
		if action!=binding_action and display_settings.bindings[action]==key:
			binding_dialog.dialog_text="Klávesu používá "+Display.KEY_LABELS[action]+". Zvol jinou klávesu."; return
	var keys=display_settings.bindings.duplicate(); keys[binding_action]=key
	if save_preference("bindings",keys):
		binding_action=""; binding_dialog.queue_free(); draw_ui()

func apply_display_settings(resolution: Vector2i,fullscreen: bool, persist: bool = true):
	if not resolution in Display.RESOLUTIONS: return
	var previous_resolution=display_settings.resolution
	var previous_fullscreen=display_settings.fullscreen
	display_settings.resolution=resolution
	display_settings.fullscreen=fullscreen
	var error=display_settings.save_settings() if persist else OK
	if error!=OK:
		display_settings.resolution=previous_resolution
		display_settings.fullscreen=previous_fullscreen
		notice="Nastavení se nepodařilo uložit. Zkontroluj přístup k uživatelské složce."
		bad_notice=true
	else:
		display_settings.apply(get_window())
		sync_display_layout()
		notice="Uloženo: %d × %d • %s" % [resolution.x,resolution.y,"celá obrazovka" if fullscreen else "okno"]
		bad_notice=false
	draw_ui()

func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F11:
		preview_display(display_settings.resolution,not display_settings.fullscreen)
		get_viewport().set_input_as_handled()

func bind_dialog_escape(dialog: AcceptDialog):
	dialog.window_input.connect(func(event):
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
			dialog.set_input_as_handled()
			dialog.hide()
			dialog.canceled.emit())

func quit_game():
	if quitting: return
	if game.save()!=OK:
		show_message("Hru se nepodařilo uložit","Před ukončením zkontroluj přístup k uživatelské složce a zkus uložení znovu.")
		return
	quitting=true
	player.stop()
	player.stream=null
	click_sound=null
	# Let the audio thread release the final button sound before shutting down.
	await get_tree().create_timer(0.06).timeout
	get_tree().quit()

func navigate(target: String):
	if world_enabled and target in ["Serverovna","Trénink"]:
		world_requested.emit(target)
		return
	if not world_enabled and target == "Trénink": game.enter_training()
	page=target
	tab=""
	notice=""
	if game.session_kind=="lesson":
		game.tutorial.session.page=page
		game.tutorial.session.tab=tab
		game.save()
	if not game.active and not page in ["Trénink","menu"]: game.start_mission(0)
	context_open=false
	TutorialUI.route(self)
	draw_ui()

func draw_datacenter():
	var contents = scroll(center)
	contents.add_child(label("PŘEHLED INFRASTRUKTURY   /   kliknutím otevři správu zařízení",12,MUTED))
	var metrics = hbox(contents)
	for pair in [["06","SPRAVOVANÝCH ZAŘÍZENÍ"],[str(game.progress.scores.size()).pad_zeros(2),"UZAVŘENÝCH TICKETŮ"],["LAB","BEZPEČNÉ PROSTŘEDÍ"]]:
		var metric = card(metrics)
		metric.add_child(label(pair[0],30,CYAN))
		metric.add_child(label(pair[1],10,MUTED))
	var racks = preload("res://scenes/datacenter/Datacenter.tscn").instantiate()
	racks.custom_minimum_size.y=420
	racks.state=game.sim.state
	for server_id in racks.names_list: register_target("rack:"+server_id,racks)
	contents.add_child(racks)
	racks.server_selected.connect(func(server_name):
		host=server_name
		game.notify_event({"type":"server_selected","host":server_name})
		navigate("Proxmox" if server_name.begins_with("PVE") else ("Hyper-V" if server_name.begins_with("HV") else "Storage")))
	var c = card(contents,"Aktuální směna",game.current.get("symptoms","Vyber ticket."))
	c.add_child(button("Otevřít pracovní konzoli   →",func(): navigate(game.current.get("category","Proxmox")),true))

func draw_ticket(parent: Node):
	var holder = VBoxContainer.new()
	holder.custom_minimum_size.x=292
	holder.size_flags_vertical=Control.SIZE_EXPAND_FILL
	holder.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	parent.add_child(holder)
	var v = scroll(holder)
	var c = card(v,"INC-%03d" % int(game.current.id),game.current.priority+"  •  "+game.current.server)
	c.add_child(label(game.current.title,23))
	c.add_child(label("TRÉNINK" if game.training else ("VYŘEŠENO" if game.finished else "PROBÍHÁ ŘEŠENÍ"),11,CYAN))
	c.add_child(label(game.current.description,14))
	c.add_child(label("PODMÍNKY PŘEDÁNÍ",11,MUTED))
	var passed=0
	for goal in game.goals():
		c.add_child(label(("✓  " if goal.passed else "○  ")+goal.label,13,CYAN if goal.passed else MUTED))
		if goal.passed: passed+=1
	var bar = ProgressBar.new()
	bar.max_value = maxi(game.goals().size(),1)
	bar.value=passed
	bar.show_percentage=false
	bar.custom_minimum_size.y=5
	c.add_child(bar)
	c.add_child(button("Ověřit a uzavřít ticket",close_ticket,true))
	if game.session_kind!="random" or game.education.random.get("hints_allowed",true): c.add_child(button("Nápověda  %d / 3" % game.hints_used,hint))
	c.add_child(button("Restartovat laboratoř",restart_confirm))
	if game.finished: c.add_child(button("Krátké opakování znalostí",show_review))
	if game.training:
		var undo_button=button("Vrátit poslední zásah",func():
			if game.undo(): notice="Poslední zásah vrácen."
			draw_ui())
		undo_button.disabled=game.undo_states.is_empty()
		c.add_child(undo_button)
	if game.finished and game.session_kind=="random": c.add_child(button("Další úloha / souhrn série",next_random_task,true))
	elif game.finished and int(game.current.id)<game.missions.size(): c.add_child(button("Další ticket   →",func(): start_ticket(int(game.current.id)),true))
	save_caption=label("Neuložené změny — použij opakování zápisu nahoře." if game.unsaved else "Postup uložen.",11,MUTED)
	c.add_child(save_caption)

func draw_tickets():
	var v = scroll(center)
	if game.game_mode.is_training():
		v.add_child(label("Pracovní mise jsou během návštěvy tréninkového centra pozastavené.",20,CYAN))
		v.add_child(button("Vrátit se k uložené kampani",return_to_campaign))
		return
	Search.draw(self,v,"missions",true)
	var mode = hbox(v)
	mode.add_child(button("Kampaň",func(): game.set_campaign_mode(false); draw_ui(),not game.training))
	mode.add_child(button("Volný trénink",func(): game.set_campaign_mode(true); draw_ui(),game.training))
	v.add_child(label("Kapitoly se v kampani otevírají postupně. Trénink zpřístupní všechny situace bez změny XP.",14,MUTED))
	var category_picker=OptionButton.new()
	var categories=["Vše","Proxmox","Hyper-V","Storage","3D praxe"]
	for category in categories: category_picker.add_item(category)
	category_picker.select(maxi(0,categories.find(mission_filter)))
	category_picker.item_selected.connect(func(i): mission_filter=category_picker.get_item_text(i); draw_ui())
	v.add_child(category_picker)
	for i in game.missions.size():
		var m = game.missions[i]
		if not Search.matches(self,"missions",m.title+" "+m.description+" "+m.category,game.progress.scores.has(str(m.id))): continue
		if mission_filter=="3D praxe":
			if not m.get("world_task",false): continue
		elif mission_filter!="Vše" and m.category!=mission_filter: continue
		if int(m.id)==25: v.add_child(label("NOVÉ INCIDENTY  /  rozšířená praxe",15,CYAN))
		var c = card(v,"%02d  /  %s" % [int(m.id),m.title],m.category+"  •  "+m.difficulty+"  •  "+m.server)
		var row=hbox(c)
		row.add_child(label(m.symptoms,13,MUTED))
		var unlocked=game.training or game.unlocked(i)
		var b = button(("Otevřít laboratoř" if not game.progress.scores.has(str(m.id)) else "Zopakovat  •  %d bodů" % int(game.progress.scores[str(m.id)])) if unlocked else "Uzamčeno",func(): start_ticket(i),unlocked)
		b.disabled=not unlocked
		row.add_child(b)

func start_ticket(index: int):
	if not game.start_mission(index,game.training): return
	host=game.current.server
	if world_enabled:
		world_requested.emit("Serverovna")
		return
	navigate(game.current.category)

func normalize_selection():
	if page not in ["Proxmox","Hyper-V"]: return
	if game.sim.state.hosts.get(host,{}).get("kind","") != page: host="PVE-01" if page=="Proxmox" else "HV-01"
	if selected_vm != "":
		var vm=game.sim.get_vm(selected_vm)
		# The host comes from the selected object's real identity.
		if vm.is_empty() or Context.platform(game.sim.state,vm)!=page: selected_vm=""
		else: host=vm.host

func draw_console():
	Console.draw(self)

func open_action(id: String):
	for a in game.actions:
		if a.id != id or a.get("console","Proxmox") != page: continue
		if not ui_targets.has("section:"+a.panel): draw_ui()
		if tab != a.panel: ui_targets["section:"+a.panel].pressed.emit()
		if a.panel == "Průvodce VM":
			wizard_step=Console.STEPS.find(id)
			wizard_unlocked=maxi(wizard_unlocked,wizard_step)
			draw_ui()
		elif ui_targets.has("operation:"+id): ui_targets["operation:"+id].pressed.emit()
		return

func option_value(picker: OptionButton, index: int = -1) -> String:
	return Forms.option_value(picker,index)

func draw_tree(parent: Node):
	var c=card(parent,"Zařízení")
	var tree=Tree.new()
	tree.custom_minimum_size=Vector2(238,190)
	tree.add_theme_font_size_override("font_size",13)
	tree.hide_root=true
	var tree_root=tree.create_item()
	for node_name in (["PVE-01","PVE-02"] if page=="Proxmox" else ["HV-01","HV-02"]):
		var node=tree.create_item(tree_root)
		node.set_text(0,node_name+"  /  "+("Online" if game.sim.state.hosts[node_name].online else "Offline"))
		node.set_metadata(0,{"host":node_name,"vm":""})
		for vm_id in game.sim.state.vms:
			var vm=game.sim.state.vms[vm_id]
			if vm.get("exists",false) and vm.host==node_name:
				var item=tree.create_item(node)
				item.set_text(0,vm_id+"  "+vm.name+"  ["+("běží" if vm.status=="Running" else "vypnuto")+"]")
				item.set_metadata(0,{"host":node_name,"vm":vm_id})
				if selected_vm==vm_id: item.select(0)
		if selected_vm=="" and host==node_name: node.select(0)
		if page=="Proxmox" and node_name=="PVE-01":
			for ct_id in game.sim.state.ct:
				var item=tree.create_item(node)
				item.set_text(0,ct_id+"  "+game.sim.state.ct[ct_id].name+"  [LXC]")
				item.set_metadata(0,{"host":node_name,"vm":""})
	c.add_child(tree)
	if page=="Proxmox":
		var wizard=button("Create VM — průvodce",func():
			tab="Průvodce VM"
			if game.notify_event({"type":"action_opened","action":"create_vm"}): TutorialUI.route(self)
			draw_ui())
		c.add_child(wizard)
		register_target("wizard:create_vm",wizard)
	register_target("tree:PVE-01",tree)
	register_target("tree:PVE-02",tree)
	register_target("tree:HV-01",tree)
	register_target("tree:HV-02",tree)
	tree.item_selected.connect(func():
		select_console_item(tree.get_selected()))
	# Re-selecting the highlighted row emits no item_selected signal. It is
	# still an explicit user choice and must confirm the host tutorial step.
	tree.gui_input.connect(func(event):
		if not game.tutorial.guided() or game.tutorial.current_step().get("event",{}).get("type","")!="node_selected": return
		if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			var item=tree.get_item_at_position(event.position)
			if item!=null and item==tree.get_selected(): select_console_item(item)
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER,KEY_SPACE]: select_console_item(tree.get_selected()))

func select_console_item(item: TreeItem):
	if item==null: return
	var meta=item.get_metadata(0)
	if not meta is Dictionary: return
	capture_form_drafts()
	host=meta.host
	selected_vm=meta.vm
	if game.notify_event({"type":"node_selected","host":host,"vm":selected_vm}): TutorialUI.route(self)
	call_deferred("draw_ui")

func draw_state(parent: Node):
	var s=game.sim.state
	var c=card(parent,"Živý stav infrastruktury")
	if page=="Proxmox":
		var h=s.hosts[host]
		c.add_child(label("%s  •  %s  •  VT: %s  •  %s\nManagement: %s  |  %s GiB RAM\nvmbr0 → eno1  •  VLAN-aware: %s" % [host,"Zapnuto" if h.online else "Vypnuto","ano" if h.vt else "ne",h.mode,h.ip,h.ram,"ano" if s.network.switches.vmbr0.vlan_aware else "ne"],13,MUTED))
	for id in s.vms:
		var vm=s.vms[id]
		if not vm.get("exists",false): continue
		if selected_vm!="" and id!=selected_vm: continue
		if page in ["Proxmox","Hyper-V"] and vm.host!=host: continue
		if (page=="Proxmox" and vm.host.begins_with("PVE")) or (page=="Hyper-V" and vm.host.begins_with("HV")):
			c.add_child(label("%s  %s  •  %s\n%d vCPU / %s GiB RAM / disk %s GB → FS %s GB\n%s / VLAN %d / %s" % [id,vm.name,"běží" if vm.status=="Running" else "vypnuto",int(vm.cpu),str(vm.ram),str(vm.disk),str(vm.filesystem),vm.bridge,int(vm.vlan),vm.ip],13,CYAN))
	if page=="Hyper-V":
		var h=s.hosts[host]
		c.add_child(label("%s VMMS: %s  •  role: %s  •  po restartu: %s\nHost: %s GiB RAM; rezerva %s GiB; jiné služby %s GiB" % [host,"běží" if h.vmms else "zastaveno","nainstalována" if h.role else "chybí","ano" if h.rebooted else "ne",h.ram,h.reserve,h.other_ram],13,MUTED))
	if page=="Proxmox" and tab in ["ZFS / disky","Cluster","Storage","Podle ticketu"]:
		c.add_child(label("ZFS tank: %s  •  A / %s: %s  •  B / %s: %s\nPool: %s / %s GB; metadata %s%%\nCluster: %d/3 hlasů, fencing %s" % [s.zfs.health,s.zfs.disks.A.serial,s.zfs.disks.A.health,s.zfs.disks.B.serial,s.zfs.disks.B.health,s.storage.used,s.storage.capacity,s.storage.metadata,1+int(s.cluster.peer_online)+int(s.cluster.qdevice),s.cluster.fenced],12,MUTED))
	if page=="Storage":
		c.add_child(label("%s  •  %s  •  %.0f GB\nPool: %.0f / %.0f GB fyzicky; přislíbeno %.0f GB" % [s.raid.level,s.raid.health,float(s.raid.capacity),float(s.storage.used),float(s.storage.capacity),float(s.storage.provisioned)],14,CYAN))
		var grid=GridContainer.new()
		grid.columns=4
		c.add_child(grid)
		for id in s.disks:
			var d=s.disks[id]
			var role="Vadný disk" if d.health=="Failed" else ("Hot spare" if d.get("spare",false) else ("Člen pole "+d.pool if d.pool!="" else "Volný disk"))
			var b=button("SLOT %s · %s\n%s · %s GB" % [id,role,d.serial,d.capacity],func(): show_message("Fyzický disk "+id,"Slot %s / %s\nKapacita: %s GB\nRole: %s\nStav: %s" % [id,d.serial,d.capacity,role,Forms.health_text(d.health)]))
			b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			grid.add_child(b)
		if not s.created_raid.is_empty(): c.add_child(label("Nové pole: %s / %s GB / členové %s / inicializováno %s" % [s.created_raid.level,s.created_raid.capacity,str(s.created_raid.members),s.created_raid.initialized],13,CYAN))
		c.add_child(label("Disk Management: %s  %sGB / %s / %s / %s:\nKapacitní vrstvy: pool%s → logical%s → hostFS%s" % [s.disk.serial,s.disk.capacity,s.disk.style,s.disk.fs,s.disk.letter,s.storage.capacity,s.storage.logical,s.storage.host_fs],13,MUTED))

func draw_form(parent: Node, action: Dictionary):
	var c=card(parent,action.label,action.get("description","Změna se projeví ve sdíleném modelu infrastruktury."))
	if action.id in ["prepare","management","install","web","repositories","update","bridge","security"]: c.add_child(label("Cíl hostitelské operace: PVE-01",11,CYAN))
	if action.id in ["hv_prepare","hv_role","hv_restart","switch"]: c.add_child(label("Cíl hostitelské operace: HV-01",11,CYAN))
	var inputs={}
	for field in action.fields:
		c.add_child(label(field.label,12,MUTED))
		var value=Forms.initial_value(self,action,field)
		var input: Control
		match field.get("type","text"):
			"bool":
				input=CheckButton.new()
				input.text=field.label
				input.button_pressed=bool(value)
			"choice":
				input=OptionButton.new()
				var field_options=Forms.choices(self,action,field)
				for option in field_options:
					input.add_item(Forms.display(self,field,option))
					input.set_item_metadata(input.item_count-1,str(option))
				var idx=field_options.find(value)
				input.select(-1 if field_options.is_empty() else maxi(0,idx))
				input.disabled=field_options.is_empty()
			"number":
				input=SpinBox.new()
				input.min_value=field.get("min",0)
				input.max_value=field.get("max",100000)
				input.step=field.get("step",1)
				input.value=float(value) if str(value).is_valid_float() else 0.0
			"disks":
				input=VBoxContainer.new()
				input.set_meta("selection",[])
				var disk_grid=GridContainer.new()
				disk_grid.columns=2
				input.add_child(disk_grid)
				for disk_id in game.sim.state.disks:
					var disk=game.sim.state.disks[disk_id]
					var check=CheckBox.new()
					check.text="Slot %s  %s  %s GB\n%s" % [disk_id,disk.serial,disk.capacity,"VADNÝ" if disk.health=="Failed" else ("HOT SPARE" if disk.get("spare",false) else ("VOLNÝ" if disk.pool=="" else "ČLEN POLE: "+disk.pool))]
					check.size_flags_horizontal=Control.SIZE_EXPAND_FILL
					check.set_meta("disk_id",disk_id)
					disk_grid.add_child(check)
					var target=input
					check.toggled.connect(func(on):
						var ids=target.get_meta("selection")
						if on: ids.append(disk_id)
						else: ids.erase(disk_id)
						ids.sort()
						target.set_meta("selection",ids)
						update_raid_preview(inputs))
			_:
				input=LineEdit.new()
				input.text=str(value)
		input.custom_minimum_size.y=36
		input.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		c.add_child(input)
		inputs[field.key]=input
		register_target("field:"+str(action.id)+":"+str(field.key),input)
	if action.id=="raid_create":
		var preview=label("Vyber členy pro výpočet kapacity.",14,CYAN)
		c.add_child(preview)
		inputs["_preview"]=preview
		inputs.level.item_selected.connect(func(_i): update_raid_preview(inputs))
	form_controls[action.id]=inputs
	var target_vm=option_value(inputs.vm) if inputs.has("vm") and inputs.vm is OptionButton else selected_vm
	var scope=page+"|"+host+"|"+target_vm+"|"+str(action.id)
	form_scopes[action.id]=scope
	form_defaults[action.id]=read_form(inputs)
	if form_drafts.has(scope): restore_form(inputs,form_drafts[scope])
	if inputs.has("vm") and inputs.vm is OptionButton:
		var vm_picker=inputs.vm
		vm_picker.item_selected.connect(func(i):
			capture_form_drafts()
			selected_vm=option_value(vm_picker,i)
			if action.panel=="Průvodce VM": wizard_vm=selected_vm
			draw_ui())
	var feedback=label("",13,ORANGE)
	feedback.visible=false
	c.add_child(feedback)
	var action_button=button(action.label,func():
		var problem=Forms.validate(self,action,inputs)
		if problem!="":
			feedback.text=problem; feedback.show(); return
		var params={}
		for key in inputs:
			if key.begins_with("_"): continue
			var input=inputs[key]
			if input is CheckButton: params[key]=input.button_pressed
			elif input is OptionButton: params[key]=option_value(input)
			elif input is SpinBox:
				commit_number(input)
				params[key]=input.value
			elif input.has_meta("selection"): params[key]=input.get_meta("selection").duplicate()
			else: params[key]=input.text.strip_edges()
		if action.get("danger",false):
			confirm_action(action,params)
		else: perform(action.id,params),true)
	var fixed=Context.fixed_host(action.id)
	if inputs.has("vm") and inputs.vm is OptionButton and inputs.vm.item_count==0:
		action_button.disabled=true
		c.add_child(label("Na hostiteli %s není kompatibilní VM. Vyber zařízení ve stromu nebo nejprve vytvoř novou VM." % host,13,ORANGE))
	if fixed!="" and host!=fixed:
		action_button.disabled=true
		c.add_child(button("Operace je dostupná na "+fixed+" — vybrat hostitele",func(): capture_form_drafts(); selected_vm=""; host=fixed; draw_ui()))
	c.add_child(action_button)
	if notice!="":
		var message=label(({"error":"Chyba: ","warning":"Upozornění: "}.get(notice_kind,"Hotovo: "))+notice,13,ORANGE if bad_notice or notice_kind=="warning" else CYAN)
		message.max_lines_visible=3
		message.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
		c.add_child(message)
		c.add_child(button("Otevřít provozní deník",func(): show_message("Deník operací","\n".join(game.sim.state.journal))))
		if bad_notice: c.add_child(button("Vysvětlení a související výuka",show_operation_help))
	form_buttons[action.id]=action_button
	register_target("action:"+str(action.id),action_button)

func read_form(inputs: Dictionary) -> Dictionary:
	var values={}
	for key in inputs:
		if key.begins_with("_"): continue
		var input=inputs[key]
		if input is CheckButton: values[key]=input.button_pressed
		elif input is OptionButton: values[key]=option_value(input)
		elif input is SpinBox: values[key]={"value":input.value,"text":input.get_line_edit().text}
		elif input.has_meta("selection"): values[key]=input.get_meta("selection").duplicate()
		else: values[key]=input.text
	return values

func capture_form_drafts():
	for action in form_controls:
		var values=read_form(form_controls[action])
		var edits={}
		for key in values:
			if key=="vm": continue # The target belongs to the scope, never to edits.
			if values[key]!=form_defaults[action].get(key): edits[key]=values[key]
		form_drafts[form_scopes[action]]=edits

func restore_form(inputs: Dictionary, values: Dictionary):
	for key in values:
		if not inputs.has(key): continue
		var input=inputs[key]
		var value=values[key]
		if input is CheckButton: input.button_pressed=value
		elif input is OptionButton:
			for i in input.item_count:
				if option_value(input,i)==value: input.select(i); break
		elif input is SpinBox:
			input.value=value.value
			input.set_meta("restored_value",input.value)
			input.get_line_edit().text=value.text
		elif input.has_meta("selection"):
			for check in input.get_child(0).get_children(): check.button_pressed=check.get_meta("disk_id") in value
		else: input.text=value
	update_raid_preview(inputs)

func commit_number(input: SpinBox):
	# Restored text can still be uncommitted. An explicit value change since
	# restoration takes precedence (e.g. arrow keys or an automated UI driver).
	if input.get_line_edit().has_focus() or (input.has_meta("restored_value") and input.value==input.get_meta("restored_value")):
		input.apply()

func update_raid_preview(inputs: Dictionary):
	if not inputs.has("_preview"): return
	var sizes=[]
	for id in inputs.members.get_meta("selection"): sizes.append(game.sim.state.disks[id].capacity)
	var level=inputs.level.get_item_text(inputs.level.selected)
	var raid=preload("res://scripts/simulation/RAIDSimulator.gd")
	var capacity=raid.capacity(level,sizes)
	inputs._preview.text="%s: %.0f GB = %.2f TiB před režií. Hot spare není součást kapacity." % [level,capacity,raid.tb_to_tib(capacity/1000.0)]

func confirm_action(action: Dictionary, params: Dictionary):
	var d=ConfirmationDialog.new()
	d.title="Potvrzení zásahu do simulace"
	var target=game.sim.get_vm(str(params.get("vm",params.get("id",""))))
	var identity="%s / %s na %s" % [target.get("id",""),target.get("name",""),target.get("host",host)] if not target.is_empty() else host
	var changes=[]
	for field in action.fields:
		if not params.has(field.key): continue
		var value=params[field.key]
		changes.append(field.label+": "+(("ano" if value else "ne") if value is bool else str(value)))
	d.dialog_text="%s\nZařízení: %s\n\n%s\n\n%s" % [action.label,identity,"\n".join(changes),action.get("warning","Před provedením ověř identitu a uvedené změny.")]
	if game.session_kind=="lesson": d.dialog_text+="\n\nLekce je oddělená od kampaně. Operaci můžeš zrušit nebo lekci bezpečně restartovat; uložený postup kampaně zůstane zachován."
	d.ok_button_text="Provést simulovanou operaci"
	d.cancel_button_text="Vrátit se ke kontrole"
	add_child(d)
	d.confirmed.connect(func(): perform(action.id,params); d.queue_free())
	d.canceled.connect(d.queue_free)
	bind_dialog_escape(d)
	d.popup_centered(Vector2i(600,450))

func perform(action: String, params: Dictionary):
	last_action=action
	var tutorial_step=game.tutorial.session.get("step",-1)
	var result=game.apply(action,params)
	if result.ok and tab=="Průvodce VM" and action in Console.STEPS:
		if action=="vm_identity": wizard_vm=str(params.id); selected_vm=wizard_vm
		var guided_target=game.tutorial.target(game.sim.state).split(":") if game.tutorial.guided() else []
		if guided_target.size()>1 and guided_target[1] in Console.STEPS:
			wizard_step=Console.STEPS.find(guided_target[1])
		elif wizard_step<5:
			wizard_step+=1
		wizard_unlocked=maxi(wizard_unlocked,wizard_step)
	if result.ok and form_scopes.has(action):
		form_drafts.erase(form_scopes[action])
		form_controls.erase(action)
	full_notice=result.text
	notice=result.text.left(600)
	bad_notice=not result.ok
	notice_kind="error" if bad_notice else result.get("severity","success")
	if result.ok and game.tutorial.guided() and tutorial_step!=game.tutorial.session.get("step",-1): TutorialUI.route(self)
	draw_ui()

func show_operation_help():
	var lesson={}
	for candidate in game.tutorial.lessons:
		if last_action in candidate.available_actions: lesson=candidate; break
	var d=AcceptDialog.new()
	d.title="Vysvětlení operace"
	d.dialog_text=full_notice+"\n\n"+game.current.get("explanations","")
	if not lesson.is_empty():
		d.dialog_text+="\n\nDoporučená lekce: "+lesson.title
		d.add_button("Najít lekci",false,"lesson")
		d.custom_action.connect(func(_action): search_queries.lessons=lesson.title; training_view="lessons"; navigate("Trénink"); d.queue_free())
	add_child(d)
	d.confirmed.connect(d.queue_free)
	d.canceled.connect(d.queue_free)
	bind_dialog_escape(d)
	d.popup_centered(Vector2i(620,340))

func close_ticket():
	var result=game.complete()
	if not result.ok: show_message("Ticket zatím nelze předat",result.text); return
	show_message(("Lekce vyhodnocena" if game.session_kind=="lesson" else "Ticket vyřešen")+" • %d / 100 bodů" % result.score,result.text+"\n\n"+game.assessment()+"\n\nProvedené kroky:\n"+"\n".join(game.sim.state.journal))
	draw_ui()

func hint():
	if game.session_kind=="lesson":
		show_message("Nápověda",game.lesson_hint())
		return
	if game.session_kind=="random" and not game.education.random.get("hints_allowed",true): return
	var level=mini(game.hints_used,2)
	game.hints_used=mini(game.hints_used+1,3)
	game.save()
	show_message("Nápověda %d / 3" % (level+1),game.current.hints[level]+"\n\nKaždý stupeň sníží hodnocení o 4 body.")

func register_target(key: String,control: Control):
	ui_targets[key]=control

func begin_lesson(id: int,mode: String,resume: bool=true):
	if game.start_lesson(id,mode,resume):
		host=game.current.server
		page=game.tutorial.session.get("page","Serverovna") if mode=="learn" else game.current.category
		tab=game.tutorial.session.get("tab","")
		selected_vm=""
		context_open=false
		notice=""
		draw_ui()
		if world_enabled: lesson_launched.emit()
	else:
		show_message("Lekci nelze spustit","Nejprve vstup do tréninkového centra.")

func cancel_training_ui():
	if is_instance_valid(tutorial_overlay):
		tutorial_overlay.hide()
		tutorial_overlay.queue_free()
		tutorial_overlay = null
	for child in get_children():
		if child is Window:
			child.hide()
			child.queue_free()
	form_drafts.clear()
	selected_vm = ""
	notice = ""
	full_notice = ""
	terminal_history = "DATACENTER ACADEMY • bezpečný simulovaný terminál\n"

func return_to_campaign():
	if world_enabled: world_requested.emit("Hlavní serverovna")
	game.resume_campaign()
	navigate("Serverovna")

func draw_training_center():
	var container=preload("res://scenes/training/TrainingCenter.tscn").instantiate()
	container.size_flags_vertical=Control.SIZE_EXPAND_FILL
	center.add_child(container)
	var v=scroll(container)
	var hero=card(v,"Tréninkové centrum","Senior administrátor / praktická laboratoř")
	hero.add_child(label("Vyber lekci a způsob učení. Cvičné servery používají vlastní izolovanou infrastrukturu. Odchod z místnosti zruší rozpracované cvičení.",15,MUTED))
	hero.add_child(label("Učím se: instruktor vede jednotlivé kroky. Procvičování: samostatná práce s dobrovolnou nápovědou. Zkouška: bez nápovědy a zvýraznění řešení.",13,MUTED))
	var tabs=hbox(hero,8)
	for item in [["lessons","Lekce"],["random","Náhodné procvičování"],["profile","Moje IT znalosti"],["glossary","IT slovník"]]:
		tabs.add_child(button(item[1],func(): training_view=item[0]; draw_ui(),training_view==item[0]))
	hero.add_child(button("Vrátit se k uložené kampani",return_to_campaign))
	if not game.game_mode.is_training():
		hero.add_child(label("Lekce jsou dostupné pouze uvnitř tréninkového centra.",16,ORANGE))
		if world_enabled: hero.add_child(button("Vstoupit do tréninkového centra",func(): world_requested.emit("Trénink")))
		return
	if game.active and game.session_kind=="lesson" and not game.finished:
		hero.add_child(button("Pokračovat: "+game.current.title,func():
			page=game.tutorial.session.get("page",game.current.category)
			if page in ["menu","Trénink"]: page=game.tutorial.current_step().get("page",game.current.category) if game.tutorial.guided() else game.current.category
			tab=game.tutorial.session.get("tab","")
			draw_ui(),true))
	if training_view=="random": draw_random_setup(v); return
	if training_view=="profile": draw_knowledge_profile(v); return
	if training_view=="glossary": draw_glossary(v); return
	Search.draw(self,v,"lessons",true)
	var categories=OptionButton.new()
	var category_names=["Všechny lekce","Proxmox VE","Microsoft Hyper-V","RAID a disková pole","Sítě a virtualizace","Zálohování a obnova","Diagnostika a řešení problémů"]
	for category in category_names: categories.add_item(category)
	categories.select(maxi(0,category_names.find(training_category)))
	categories.item_selected.connect(func(i): training_category=category_names[i]; draw_ui())
	v.add_child(categories)
	for lesson in game.tutorial.lessons:
		var completed=game.education.lessons.get(str(lesson.id),{}).get("status","")=="Dokončeno"
		if not Search.matches(self,"lessons",lesson.title+" "+lesson.description+" "+lesson.category,completed): continue
		if training_category!="Všechny lekce" and lesson.training_category!=training_category: continue
		var status=game.education.lessons.get(str(lesson.id),{}).get("status","Nedokončeno")
		var c=card(v,lesson.title,lesson.get("training_category",lesson.category)+"  •  "+status)
		c.add_child(label(lesson.description,14,MUTED))
		var row=hbox(c)
		for item in [["learn","Učím se"],["practice","Procvičování"],["exam","Zkouška"]]:
			row.add_child(button(item[1],func(): begin_lesson(int(lesson.id),item[0]),item[0]=="learn"))
		if game.education.lessons.has(str(lesson.id)): c.add_child(label("Nejlepší výsledek: %d / 100. Každý režim lze zopakovat." % int(game.education.lessons[str(lesson.id)].get("best",0)),12,CYAN))

func draw_random_setup(parent: Node):
	var c=card(parent,"Náhodné procvičování","Scénáře se před zařazením celé přehrají v odděleném simulátoru a ověří se jejich řešitelnost.")
	var area=OptionButton.new()
	for value in ["Vše","Proxmox","Hyper-V","RAID","Sítě","Zálohy","Diagnostika"]: area.add_item(value)
	c.add_child(label("Oblast",12,MUTED)); c.add_child(area)
	var difficulty=OptionButton.new()
	for value in ["Vše","Začátečník","Pokročilý","Administrátor","Expert"]: difficulty.add_item(value)
	c.add_child(label("Obtížnost",12,MUTED)); c.add_child(difficulty)
	var count=SpinBox.new()
	count.min_value=1; count.max_value=20; count.value=5
	c.add_child(label("Počet úloh",12,MUTED)); c.add_child(count)
	var hints=CheckButton.new()
	hints.text="Povolit nápovědu"; hints.button_pressed=true
	c.add_child(hints)
	var inputs={"area":area,"difficulty":difficulty,"count":count,"hints":hints}
	form_controls._random_setup=inputs
	form_scopes._random_setup="random_setup"
	form_defaults._random_setup=read_form(inputs)
	if form_drafts.has("random_setup"): restore_form(inputs,form_drafts.random_setup)
	c.add_child(button("Sestavit a spustit trénink",func():
		commit_number(count)
		if game.start_random(area.get_item_text(area.selected),difficulty.get_item_text(difficulty.selected),int(count.value),hints.button_pressed):
			host=game.current.server
			navigate(game.current.category)
		else: show_message("Nelze sestavit sérii","Pro tuto kombinaci nejsou dostupné řešitelné scénáře. Zvol širší oblast nebo jinou obtížnost."),true))
	if game.session_kind=="random": c.add_child(button("Pokračovat v rozehrané sérii",func(): navigate(game.current.category)))
	var batch=game.education.random
	if not batch.get("session",{}).is_empty() and game.session_kind!="random": c.add_child(button("Obnovit uloženou sérii",func():
		if game.resume_random(): host=game.current.server; navigate(game.current.category)))
	if not batch.is_empty():
		c.add_child(label("Poslední série: %d / %d vyhodnocených úloh" % [batch.results.size(),batch.queue.size()],15,CYAN))
		for result in batch.results: c.add_child(label("%s: %d / 100" % [result.title,int(result.score)],13,MUTED))

func next_random_task():
	if game.next_random(): host=game.current.server; navigate(game.current.category)
	else:
		training_view="random"
		navigate("Trénink")

func draw_knowledge_profile(parent: Node):
	var profile=game.Profile.summarize(game)
	var c=card(parent,"Moje IT znalosti")
	c.add_child(label("%d / %d dokončených lekcí  •  %d úloh bez nápovědy\n%d uložených pokusů  •  %d / %d misí v kampani" % [profile.completed,game.tutorial.lessons.size(),profile.without_help,profile.attempts,game.progress.scores.size(),game.missions.size()],19,CYAN))
	var total_score=0
	var solved=0
	for attempt in game.education.attempts:
		if attempt.kind in ["campaign","random"]: total_score+=int(attempt.score); solved+=1
	if solved>0: c.add_child(label("Úspěšnost praktických úloh: průměr%d / 100 z%d vyhodnocení" % [int(float(total_score)/solved),solved],14,MUTED))
	for domain in game.Profile.DOMAINS:
		var item=profile.domains[domain]
		var status="Neprocvičeno" if item.count==0 else ("Silná oblast" if item.average>=85 else ("Doporučeno opakování" if item.average<70 else "Rozvíjí se"))
		c.add_child(label("%s  •  %s  •  %s" % [domain,status,"—" if item.count==0 else "%d / 100 (%d pokusů)" % [item.average,item.count]],14))
		var bar=ProgressBar.new(); bar.value=item.average; bar.show_percentage=false; bar.custom_minimum_size.y=6
		c.add_child(bar)
	var rec=card(parent,"Doporučené lekce","Podle skutečných výsledků, chyb a dosud neprocvičených oblastí.")
	for lesson in game.Profile.recommendations(game): rec.add_child(button(lesson.title,func(): begin_lesson(int(lesson.id),"learn")))
	var exams=card(parent,"Poslední zkoušky")
	if profile.exams.is_empty(): exams.add_child(label("Zatím nemáš dokončenou zkoušku.",14,MUTED))
	for exam in profile.exams:
		exams.add_child(label("%s: %d / 100  •  chyb%d  •  rizik%d" % [exam.title,int(exam.score),int(exam.errors),int(exam.risks)],14,CYAN))

func draw_glossary(parent: Node):
	Search.draw(self,parent,"glossary")
	var terms=JSON.parse_string(FileAccess.get_file_as_string("res://data/training/glossary.json"))
	for term in terms:
		if not Search.matches(self,"glossary",term.term+" "+term.text): continue
		var c=card(parent,term.term,term.text)
		c.add_child(button("Procvičit související lekci",func(): begin_lesson(int(term.lesson),"learn")))

func draw_lesson_panel(parent: Node):
	var holder=VBoxContainer.new()
	holder.custom_minimum_size.x=292
	holder.size_flags_vertical=Control.SIZE_EXPAND_FILL
	holder.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	parent.add_child(holder)
	var v=scroll(holder)
	var t=game.tutorial
	var c=card(v,"Právě se učíš",game.current.title)
	var mode={"learn":"UČÍM SE","practice":"PROCVIČOVÁNÍ","exam":"ZKOUŠKA"}.get(t.session.get("mode","learn"),"VÝUKA")
	c.add_child(label(mode,11,CYAN))
	if t.guided() and not t.current_step().is_empty():
		var step=t.current_step()
		c.add_child(label("Krok %d z %d — %s" % [int(t.session.step)+1,t.lesson.steps.size(),step.title],19,CYAN))
		c.add_child(label(step.text,15))
		c.add_child(label("Proč?",13,CYAN))
		c.add_child(label(step.why,13,MUTED))
		c.add_child(button("Více informací",func(): show_message(step.title,step.more)))
		var recover=button("Zobrazit potřebný panel",recover_tutorial_target)
		c.add_child(recover)
		register_target("tutorial:recover",recover)
	else:
		c.add_child(label(game.current.description,14))
		for goal in game.goals(): c.add_child(label(("✓ " if goal.passed else "○ ")+goal.label,12,CYAN if goal.passed else MUTED))
	if t.last_feedback!="": c.add_child(label(t.last_feedback,13,ORANGE))
	if int(t.session.get("step",0))>=t.lesson.steps.size() and t.session.mode=="learn": c.add_child(label("Všechny kroky ověřeny. Lekci můžeš předat.",14,CYAN))
	c.add_child(button("Vyhodnotit lekci",close_ticket,true))
	if t.session.mode!="exam": c.add_child(button("Nápověda",hint))
	c.add_child(button("Restartovat lekci",func(): begin_lesson(int(game.current.id),t.session.mode,false)))
	c.add_child(button("Zpět k nabídce lekcí (průběh zůstane)",func():
		if game.save()==OK: navigate("Trénink")))
	c.add_child(label("Kampaň je pozastavená. Odchod z tréninkové místnosti zruší rozpracovanou lekci; dokončené výsledky zůstanou uložené.",11,MUTED))

func focus_tutorial():
	var expected_root=root_box
	await get_tree().process_frame
	if not is_instance_valid(expected_root) or root_box!=expected_root: return
	if not game.tutorial.guided() or game.session_kind!="lesson" or page in ["menu","Trénink"]: return
	var key=TutorialUI.target_key(self)
	if not ui_targets.has(key): return
	var control=ui_targets[key]
	if not is_instance_valid(control): return
	if is_instance_valid(tutorial_overlay): tutorial_overlay.queue_free()
	tutorial_overlay=preload("res://scripts/training/TutorialOverlay.gd").new()
	add_child(tutorial_overlay)
	tutorial_overlay.target=control
	# Nested containers settle over several frames; reveal once that layout
	# and the saved scroll position have both been applied, then leave scrolling free.
	tutorial_reveal_frames=4
	var overlay=tutorial_overlay
	if key.begins_with("rack:"):
		await get_tree().process_frame
		if is_instance_valid(control) and is_instance_valid(overlay) and not overlay.is_queued_for_deletion() and not control.boxes.is_empty():
			var index=control.names_list.find(key.trim_prefix("rack:"))
			if index>=0 and index<control.boxes.size(): overlay.local_rect=control.boxes[index]
	elif key.begins_with("tree:"):
		var item=control.get_root().get_first_child()
		while item:
			if item.get_text(0).begins_with(key.trim_prefix("tree:")): tutorial_overlay.local_rect=control.get_item_area_rect(item,0); break
			item=item.get_next()
	ensure_tutorial_visible()

func ensure_tutorial_visible():
	if not is_inside_tree() or game.session_kind!="lesson" or not game.tutorial.guided() or not is_instance_valid(tutorial_overlay): return
	var control=tutorial_overlay.target
	if not is_instance_valid(control): return
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor is ScrollContainer:
			# Use local UI units at every resolution, after restoring working scroll.
			var rect=ancestor.get_global_transform().affine_inverse()*control.get_global_rect()
			if rect.position.y<0 or rect.end.y>ancestor.size.y:
				var content=ancestor.get_child(0) as Control
				var content_rect=content.get_global_transform().affine_inverse()*control.get_global_rect()
				ancestor.scroll_vertical=roundi(content_rect.get_center().y-ancestor.size.y*0.5)
		ancestor=ancestor.get_parent()

func recover_tutorial_target():
	if not game.tutorial.guided() or game.session_kind!="lesson": return
	var step=game.tutorial.current_step()
	if step.is_empty(): return
	capture_form_drafts()
	context_open=false
	if world_enabled and step.get("page",game.current.category)=="Serverovna":
		world_requested.emit("Serverovna")
		return
	TutorialUI.route(self,true)
	game.save()
	draw_ui()

func show_review():
	if not game.current.has("review"): return
	var review=game.current.review
	var dialog=preload("res://scenes/results/Review.tscn").instantiate()
	dialog.title="Rozhodnutí v kontextu zásahu"
	dialog.min_size=Vector2i(620,320)
	var content=vbox(dialog,18)
	content.add_child(label(review.question,21))
	for index in review.options.size():
		var b=button(review.options[index],func():
			var correct=index==int(review.correct)
			if not game.sim.state.get("review_answered",false):
				game.sim.state.review_answered=true
				if not correct:
					var topic=game.current.topic
					game.progress.mistakes[topic]=int(game.progress.mistakes.get(topic,0))+1
				game.save()
			dialog.hide()
			dialog.queue_free()
			show_message("Správně" if correct else "Zopakuj si souvislost",review.explanation))
		b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		content.add_child(b)
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	bind_dialog_escape(dialog)
	dialog.popup_centered(Vector2i(660,360))

func restart_confirm():
	var d=ConfirmationDialog.new()
	d.title="Restart laboratorní situace"
	d.dialog_text="Konfigurace aktuální úlohy se vrátí do výchozího stavu. Získané XP zůstanou zachované."
	if game.session_kind=="random": d.dialog_text+="\nPozice série, dosavadní výsledky i odložená kampaň zůstanou zachované."
	add_child(d)
	d.confirmed.connect(func(): game.restart_current(); notice=""; draw_ui(); d.queue_free())
	d.canceled.connect(d.queue_free)
	bind_dialog_escape(d)
	d.popup_centered()

func show_message(title: String, text: String):
	var d=AcceptDialog.new()
	d.title=title
	d.min_size=Vector2i(560,280)
	var sc=ScrollContainer.new()
	sc.custom_minimum_size=Vector2(550,280)
	sc.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	d.add_child(sc)
	var l=label(text,15)
	l.custom_minimum_size.x=520
	sc.add_child(l)
	add_child(d)
	d.confirmed.connect(d.queue_free)
	d.canceled.connect(d.queue_free)
	bind_dialog_escape(d)
	d.popup_centered(Vector2i(620,430))

func draw_network():
	var v=scroll(center)
	v.add_child(label("SÍŤOVÁ MAPA  /  různé vrstvy mají různé příčiny výpadku",12,MUTED))
	for id in game.sim.state.vms:
		var vm=game.sim.get_vm(id)
		if vm.is_empty(): continue
		var c=card(v,id+" / "+vm.host+" → "+vm.name+"  →  "+vm.bridge+"  →  VLAN "+str(vm.vlan),"Hostitel / uplink → bridge → VLAN → VM → gateway %s → DNS %s → HTTPS:443" % [vm.gateway,vm.dns])
		var net=preload("res://scripts/simulation/NetworkSimulator.gd").probe(game.sim.state,id)
		var row=hbox(c)
		for k in ["link","ip","dns","app"]:
			var step=card(row)
			step.add_child(label(("●  " if net[k] else "○  ")+k.to_upper(),15,CYAN if net[k] else ORANGE))
		c.add_child(label(net.reason,14,MUTED))
		c.add_child(button("Upravit síť "+vm.name,func(): capture_form_drafts(); selected_vm=id; host=vm.host; page=Context.platform(game.sim.state,vm); tab="Síť" if page=="Proxmox" else "Virtuální síť"; active_action="network"; notice=""; draw_ui()))
	var switches_card=card(v,"Virtuální switche")
	for sw in game.sim.state.network.switches:
		var data=game.sim.state.network.switches[sw]
		switches_card.add_child(label("%s / %s / uplink %s / VLAN-aware %s" % [sw,data.type,data.uplink,data.vlan_aware],14,MUTED))

func draw_terminal():
	var v=scroll(center)
	var context=OptionButton.new()
	for node in ["PVE-01","PVE-02","HV-01","HV-02"]: context.add_item(node)
	context.select(["PVE-01","PVE-02","HV-01","HV-02"].find(terminal_host))
	context.item_selected.connect(func(index): terminal_host=context.get_item_text(index); draw_ui())
	v.add_child(context)
	var c=card(v,"Simulovaný terminál", "Příkazy se nikdy nespouštějí v operačním systému.")
	var output=RichTextLabel.new()
	output.text=terminal_history
	output.fit_content=true
	output.selection_enabled=true
	output.add_theme_color_override("default_color",CYAN)
	output.add_theme_font_override("normal_font",SystemFont.new())
	output.get_theme_font("normal_font").font_names=PackedStringArray(["Consolas","monospace"])
	c.add_child(output)
	var input=LineEdit.new()
	input.placeholder_text="help"
	input.custom_minimum_size.y=42
	c.add_child(input)
	form_controls._terminal={"command":input}
	form_scopes._terminal="terminal|"+terminal_host
	form_defaults._terminal={"command":""}
	if form_drafts.has(form_scopes._terminal): restore_form(form_controls._terminal,form_drafts[form_scopes._terminal])
	input.text_submitted.connect(func(command):
		command_history.append(command)
		history_position=command_history.size()
		terminal_history+=("\n%s > %s\n" % [terminal_host,command])+preload("res://scripts/simulation/TerminalParser.gd").execute(game.sim,command,terminal_host)+"\n"
		terminal_history=terminal_history.right(14000)
		game.save()
		form_drafts.erase(form_scopes._terminal)
		form_controls.erase("_terminal")
		draw_ui())
	input.gui_input.connect(func(event):
		if event is InputEventKey and event.pressed and event.keycode in [KEY_UP,KEY_DOWN] and not command_history.is_empty():
			history_position=clampi(history_position+(-1 if event.keycode==KEY_UP else 1),0,command_history.size()-1)
			input.text=command_history[history_position]
			input.caret_column=input.text.length())
	c.add_child(button("Vyčistit výpis",func(): terminal_history=""; draw_ui()))
	input.grab_focus()
	v.get_parent().set_deferred("scroll_vertical",999999)

func draw_academy():
	var v=scroll(center)
	Search.draw(self,v,"articles")
	var articles=JSON.parse_string(FileAccess.get_file_as_string("res://data/knowledge/articles.json"))
	var categories=OptionButton.new()
	for category in ["Proxmox","Hyper-V","Storage"]: categories.add_item(category)
	categories.select(["Proxmox","Hyper-V","Storage"].find(academy_category))
	categories.item_selected.connect(func(i): academy_category=categories.get_item_text(i); academy_article=0; draw_ui())
	v.add_child(categories)
	var selected=[]
	for article in articles:
		if article.category==academy_category and Search.matches(self,"articles",article.title+" "+article.text): selected.append(article)
	if selected.is_empty():
		v.add_child(label("Žádný článek neodpovídá hledání. Zkus kratší výraz nebo jinou oblast.",15,MUTED))
		return
	var picker=OptionButton.new()
	picker.clip_text=true
	for article in selected: picker.add_item(article.title)
	picker.select(mini(academy_article,selected.size()-1))
	picker.item_selected.connect(func(i): academy_article=i; draw_ui())
	v.add_child(picker)
	var article=selected[mini(academy_article,selected.size()-1)]
	var c=card(v,article.title,"Zdroj: studijní příručka Student IT support / Notion, načteno 24.10.2026.")
	c.add_child(label(article.text,15))
	c.add_child(label(article.source,11,MUTED))
	var logs=card(v,"Provozní deník")
	logs.add_child(label("\n".join(game.sim.state.journal).right(10000),13,MUTED))

func draw_stats():
	var v=scroll(center)
	var c=card(v,"Tvůj administrátorský profil")
	c.add_child(label("%d XP  •  %d uzavřených ticketů\nAchievementy: %s" % [int(game.progress.xp),game.progress.scores.size(),", ".join(game.progress.achievements)],19,CYAN))
	for topic in game.progress.mistakes: c.add_child(label("%s: %d chyb — doporučeno opakování" % [topic,int(game.progress.mistakes[topic])],14,ORANGE))
	for category in ["Proxmox","Hyper-V","Storage"]:
		var count=0
		var total=0
		for m in game.missions:
			if m.category==category and game.progress.scores.has(str(m.id)):
				count+=1
				total+=int(game.progress.scores[str(m.id)])
		var available=0
		for m in game.missions:
			if m.category==category: available+=1
		c.add_child(label("%s: %d / %d ticketů; průměr %d / 100" % [category,count,available,int(float(total)/maxi(count,1))],16))
	var weak=card(v,"Doporučený trénink", "Výběr podle skutečných chyb; opakování nezmění postup v kampani.")
	var shown=0
	for m in game.missions:
		if game.progress.mistakes.has(m.topic) and shown<4:
			weak.add_child(button(m.title,func(): game.training=true; start_ticket(int(m.id)-1)))
			shown+=1
	if shown==0: weak.add_child(label("Zatím bez opakovaných chyb. Začni novým ticketem nebo volným tréninkem.",14,MUTED))

func create_sound():
	player=AudioStreamPlayer.new()
	add_child(player)
	click_sound=AudioStreamWAV.new()
	click_sound.format=AudioStreamWAV.FORMAT_16_BITS
	click_sound.mix_rate=22050
	var bytes=PackedByteArray()
	bytes.resize(1500)
	for i in 750:
		var sample=int(sin(i*0.23)*2000*(1.0-float(i)/750.0))
		bytes.encode_s16(i*2,sample)
	click_sound.data=bytes
	player.stream=click_sound
	player.volume_db=-18

func play_click():
	if sound_on: player.play()

func _exit_tree():
	# Scene replacement must release the sound as explicitly as Quit does.
	if is_instance_valid(player):
		player.stop()
		player.stream = null
	click_sound = null

func capture_later():
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("res://test-output/menu.png")
