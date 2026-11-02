extends RefCounted

static func draw(ui):
	var all = ui.vbox(ui.content_box,18)
	all.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var header=ui.hbox(all,14)
	var emblem=TextureRect.new()
	emblem.texture=load("res://assets/icons/academy.svg")
	emblem.custom_minimum_size=Vector2(40,40)
	emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(emblem)
	var identity=ui.vbox(header,2)
	identity.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	identity.add_child(ui.label("TRAINING ACADEMY",30))
	identity.add_child(ui.label("NORTHSTAR IT  /  OFFLINE VÝCVIKOVÉ STŘEDISKO",12,ui.CYAN))
	var body=ui.hbox(all,20)
	body.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var left=ui.card(body,"Serverovna / pracovní směna","Řeš IT incidenty ve 3D. Rozehraná kampaň a její výsledky zůstávají zachované.")
	left.add_theme_constant_override("separation",14)
	var primary=ui.button(("Pokračovat" if ui.game.active else "Zahájit směnu")+"  /  "+("VR" if OS.has_feature("android") else "klasické 3D"),func():
		if ui.world_enabled and not OS.has_feature("android"): ui.play_mode_requested.emit("desktop")
		if not ui.game.active: ui.first_shift_requested=true; ui.game.start_mission(0)
		ui.navigate("Serverovna"),true)
	primary.custom_minimum_size.y=54
	left.add_child(primary); ui.register_target("menu:primary",primary)
	if not OS.has_feature("android") and ui.world_enabled:
		var vr=ui.button("Spustit ve VR  /  PICO 4 · OpenXR",func(): ui.play_mode_requested.emit("vr"))
		vr.tooltip_text="Připojený PC headset a OpenXR runtime. Stejná uložená směna jako ve 3D."
		left.add_child(vr); ui.register_target("menu:vr",vr)
	left.add_child(ui.label("3D: klávesnice a myš. VR: připojený headset s OpenXR.",13,ui.MUTED))
	if ui.game.active:
		var current=ui.label("Rozehráno: "+ui.game.current.title,14,ui.CYAN)
		current.max_lines_visible=2; current.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS; left.add_child(current)
	var tickets=ui.button("Kampaň a přehled ticketů",func():
		if ui.game.session_kind!="campaign": ui.game.resume_campaign()
		elif not ui.game.active: ui.game.start_mission(0)
		ui.game.set_campaign_mode(false); ui.navigate("Tickety"))
	left.add_child(tickets); ui.register_target("menu:tickets",tickets)
	left.add_child(ui.button("Volný trénink / všechny laboratoře",func():
		if not ui.game.active: ui.game.start_mission(0,true)
		ui.game.set_campaign_mode(true); ui.navigate("Tickety")))
	if ui.world_enabled:
		left.add_child(ui.button("15 praktických úkolů ve 3D",func():
			if not ui.game.active: ui.game.start_mission(0,true)
			ui.game.set_campaign_mode(true); ui.mission_filter="3D praxe"; ui.navigate("Tickety")))
	left.add_child(ui.label("65 misí  /  Proxmox VE · Hyper-V · Storage",13,ui.MUTED))
	var right=ui.vbox(body,16); right.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	var training=ui.card(right,"IT tréninková akademie","21 serverových lekcí. Učím se, Procvičování nebo Zkouška; cvičná infrastruktura je oddělená od kampaně.")
	var train=ui.button("Vstoupit do IT tréninkové akademie",func(): ui.navigate("Trénink"))
	training.add_child(train); ui.register_target("menu:training",train)
	var programming=ui.card(right,"Programovací učebna","Python a tvorba webu. 28 lekcí, 60 úloh a opravy kódu. Učebna je vlevo od racků; úlohu si vybereš u počítače.")
	var code=ui.button("Vstoupit do programovací učebny",func(): ui.world_requested.emit("Programming Academy"))
	code.disabled=not ui.world_enabled
	programming.add_child(code); ui.register_target("menu:programming",code)
	var footer=ui.hbox(all,12)
	footer.add_child(ui.label("VLASTNÍ TEMPO  /  ČESKÁ VÝUKOVÁ SIMULACE",12,ui.MUTED))
	for item in [["Nastavení",ui.open_settings,"settings"],["Ukončit hru",ui.quit_game,"quit"]]:
		var b=ui.button(item[0],item[1]); footer.add_child(b); ui.register_target("menu:"+item[2],b)
