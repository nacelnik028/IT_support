extends RefCounted

static func draw(ui):
	var all = ui.scroll(ui.content_box)
	all.add_theme_constant_override("separation",24)
	var header = ui.hbox(all)
	var emblem = TextureRect.new()
	emblem.texture = load("res://assets/icons/academy.svg")
	emblem.custom_minimum_size = Vector2(32,32)
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(emblem)
	header.add_child(ui.label("NORTHSTAR IT  /  VÝCVIKOVÉ STŘEDISKO",14,ui.MUTED))
	ui.Components.badge(ui,header,"●  OFFLINE AKADEMIE",ui.CYAN)
	var body = ui.hbox(all,28)
	var left = ui.card(body)
	left.get_parent().size_flags_stretch_ratio = 0.92
	left.add_theme_constant_override("separation",16)
	left.add_child(ui.label("IT SUPPORT SIMULATOR",13,ui.CYAN))
	left.add_child(ui.label("DATACENTER\nACADEMY",54))
	left.add_child(ui.label("Tvá první směna začíná tady.",23))
	left.add_child(ui.label("Konfiguruj servery. Vyřeš incident.\nUdrž datacentrum v provozu.",17,ui.MUTED))
	var primary = ui.button("Pokračovat ve VR" if OS.has_feature("android") else "HRÁT V KLASICKÉM 3D",func():
		if ui.world_enabled and not OS.has_feature("android"): ui.play_mode_requested.emit("desktop")
		if not ui.game.active: ui.first_shift_requested=true; ui.game.start_mission(0)
		ui.navigate("Serverovna"),true)
	primary.custom_minimum_size.y = 54
	left.add_child(primary)
	ui.register_target("menu:primary",primary)
	if not OS.has_feature("android") and ui.world_enabled:
		var vr = ui.button("HRÁT VE VR  /  PICO 4 · OpenXR",func(): ui.play_mode_requested.emit("vr"))
		vr.custom_minimum_size.y=48
		left.add_child(vr)
		ui.register_target("menu:vr",vr)
		left.add_child(ui.label("3D: klávesnice a myš. PC VR: připojený headset a OpenXR runtime.\nOba režimy používají stejnou uloženou směnu.",13,ui.MUTED))
	if ui.game.active: left.add_child(ui.label("ROZEHRÁNO  /  "+ui.game.current.title,13,ui.CYAN))
	var choices = ui.vbox(left,8)
	choices.add_child(ui.button("Kampaň a přehled ticketů",func():
		if ui.game.session_kind!="campaign": ui.game.resume_campaign()
		elif not ui.game.active: ui.game.start_mission(0)
		ui.game.set_campaign_mode(false)
		ui.navigate("Tickety")))
	choices.add_child(ui.button("Tréninkové centrum",func(): ui.navigate("Trénink")))
	choices.add_child(ui.button("Volný trénink  •  všechny laboratoře",func():
		if not ui.game.active: ui.game.start_mission(0,true)
		ui.game.set_campaign_mode(true)
		ui.navigate("Tickety")))
	var system = ui.hbox(left,10)
	for item in [["Nastavení",ui.open_settings],["Ukončit hru",ui.quit_game]]:
		var b = ui.button(item[0],item[1])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		system.add_child(b)
	left.add_child(ui.label("PROXMOX VE   /   HYPER-V   /   STORAGE",12,ui.MUTED))
	var right = ui.vbox(body,16)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.08
	right.add_child(ui.label("01  /  TVOJE PRACOVIŠTĚ",13,ui.CYAN))
	right.add_child(ui.label("Šest serverů.\nSkutečná rozhodnutí.",32))
	var racks = ui.Racks.new()
	right.add_child(racks)
	racks.custom_minimum_size = Vector2(520,365)
	racks.state = ui.game.sim.state
	racks.server_selected.connect(func(_name):
		if not ui.game.active: ui.game.start_mission(0)
		ui.navigate("Serverovna"))
	var stats = ui.hbox(right,12)
	for item in [[str(ui.game.missions.size()),"PRAKTICKÝCH MISÍ"],[str(ui.game.tutorial.lessons.size()),"VEDENÝCH LEKCÍ"],["3","ZPŮSOBY UČENÍ"]]:
		var stat = ui.card(stats)
		stat.add_theme_constant_override("separation",2)
		stat.add_child(ui.label(item[0],28,ui.CYAN))
		stat.add_child(ui.label(item[1],11,ui.MUTED))
	if ui.world_enabled:
		right.add_child(ui.button("15 praktických úkolů ve 3D   →",func():
			if not ui.game.active: ui.game.start_mission(0,true)
			ui.game.set_campaign_mode(true)
			ui.mission_filter="3D praxe"
			ui.navigate("Tickety")))
	all.add_child(ui.label("ČESKÁ VÝUKOVÁ SIMULACE     •     VLASTNÍ TEMPO     •     AUTOMATICKÉ UKLÁDÁNÍ",12,ui.MUTED))
