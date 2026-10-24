extends Control

const Game = preload("res://scripts/core/GameManager.gd")
const Racks = preload("res://scripts/ui/RackView.gd")
const Eval = preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
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
var player: AudioStreamPlayer
var click_sound: AudioStreamWAV

const CYAN = Color("3ddbc6")
const MUTED = Color("8c9eb5")
const WHITE = Color("e5edf7")
const ORANGE = Color("ffb65c")

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = make_theme()
	create_sound()
	draw_ui()
	if "--capture" in OS.get_cmdline_user_args(): capture_later()

func make_theme() -> Theme:
	var t = Theme.new()
	t.default_font_size = 15
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
	l.add_theme_font_size_override("font_size",size_px)
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
	if is_instance_valid(root_box):
		remove_child(root_box)
		root_box.queue_free()
	root_box = MarginContainer.new()
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: root_box.add_theme_constant_override("margin_"+side,20)
	add_child(root_box)

func draw_ui():
	clear_ui()
	if page == "menu": draw_menu(); return
	var whole = vbox(root_box,16)
	var top = hbox(whole)
	var brand = vbox(top,2)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_child(label("◈  DATACENTER ACADEMY",21,CYAN))
	brand.add_child(label("NORTHSTAR IT  /  OPERATIONS CENTER",10,MUTED))
	top.add_child(label("ÚROVEŇ %d   •   %d XP" % [1+int(game.progress.xp)/600,int(game.progress.xp)],15))
	top.add_child(button("Uložit a menu",func(): game.save(); page="menu"; draw_ui()))
	var body = hbox(whole,18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sidebar = vbox(body,8)
	sidebar.custom_minimum_size.x = 172
	sidebar.add_child(label("PRACOVIŠTĚ",10,MUTED))
	for item in [["Serverovna","▦"],["Tickety","≡"],["Proxmox","◈"],["Hyper-V","▣"],["Storage","▤"],["Síť","⌁"],["Terminál",">_"],["Akademie","◇"],["Statistiky","↗"]]:
		var target = item[0]
		var b = button(item[1]+"   "+target,func(): navigate(target),page==target)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		sidebar.add_child(b)
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar.add_child(spacer)
	sidebar.add_child(label("●  OFFLINE LAB\nVšechny zásahy jsou simulované.",11,CYAN))
	sidebar.add_child(button("Zvuk: " + ("zapnut" if sound_on else "vypnut"),func(): sound_on=not sound_on; draw_ui()))
	center = vbox(body,14)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(label(page,30))
	if notice != "":
		var n = card(center)
		n.add_child(label(notice,13,Color("ff8d99") if bad_notice else CYAN))
		if notice.length()>300: n.get_parent().custom_minimum_size.y=80
	match page:
		"Serverovna": draw_datacenter()
		"Tickety": draw_tickets()
		"Proxmox", "Hyper-V", "Storage": draw_console()
		"Síť": draw_network()
		"Terminál": draw_terminal()
		"Akademie": draw_academy()
		"Statistiky": draw_stats()
	if game.active and page != "Tickety": draw_ticket(body)
	whole.add_child(label("DATACENTER ACADEMY     /     Pozorovat → diagnostikovat → bezpečně změnit → ověřit → zdokumentovat",10,MUTED))

func draw_menu():
	var all = vbox(root_box,24)
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
		if not game.active: game.start_mission(0)
		navigate("Serverovna"),true))
	left.add_child(button("Kampaň a přehled ticketů",func():
		if not game.active: game.start_mission(0)
		navigate("Tickety")))
	left.add_child(button("Volný trénink  •  všechny laboratoře",func():
		if not game.active: game.start_mission(0,true)
		game.training=true
		navigate("Tickety")))
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
	info.add_child(label("24 TICKETŮ     •     3 KAPITOLY     •     TVÉ TEMPO",12,CYAN))
	all.add_child(label("Výuková simulace správy serverů  /  Čeština  /  Godot 4",12,MUTED))

func navigate(target: String):
	page=target
	tab=""
	notice=""
	draw_ui()

func draw_datacenter():
	var contents = scroll(center)
	contents.add_child(label("PŘEHLED INFRASTRUKTURY   /   kliknutím otevři správu zařízení",12,MUTED))
	var metrics = hbox(contents)
	for pair in [["06","SPRAVOVANÝCH ZAŘÍZENÍ"],[str(game.progress.scores.size()).pad_zeros(2),"UZAVŘENÝCH TICKETŮ"],["LAB","BEZPEČNÉ PROSTŘEDÍ"]]:
		var c = card(metrics)
		c.add_child(label(pair[0],30,CYAN))
		c.add_child(label(pair[1],10,MUTED))
	var racks = Racks.new()
	racks.custom_minimum_size.y=420
	racks.state=game.sim.state
	contents.add_child(racks)
	racks.server_selected.connect(func(name):
		host=name
		navigate("Proxmox" if name.begins_with("PVE") else ("Hyper-V" if name.begins_with("HV") else "Storage")))
	var c = card(contents,"Aktuální směna",game.current.get("symptoms","Vyber ticket."))
	c.add_child(button("Otevřít pracovní konzoli   →",func(): navigate(game.current.get("category","Proxmox")),true))

func draw_ticket(parent: Node):
	var holder = VBoxContainer.new()
	holder.custom_minimum_size.x=292
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
	c.add_child(button("Nápověda  %d / 3" % game.hints_used,hint))
	c.add_child(button("Restartovat laboratoř",restart_confirm))
	c.add_child(label("Postup se ukládá po každém zásahu.",11,MUTED))

func draw_tickets():
	var v = scroll(center)
	var mode = hbox(v)
	mode.add_child(button("Kampaň",func(): game.training=false; game.save(); draw_ui(),not game.training))
	mode.add_child(button("Volný trénink",func(): game.training=true; game.save(); draw_ui(),game.training))
	v.add_child(label("Kapitoly se v kampani otevírají postupně. Trénink zpřístupní všechny situace bez změny XP.",14,MUTED))
	for i in game.missions.size():
		var m = game.missions[i]
		var c = card(v,"%02d  /  %s" % [int(m.id),m.title],m.category+"  •  "+m.difficulty+"  •  "+m.server)
		var row=hbox(c)
		row.add_child(label(m.symptoms,13,MUTED))
		var unlocked=game.training or game.unlocked(i)
		var b = button(("Otevřít laboratoř" if not game.progress.scores.has(str(m.id)) else "Zopakovat  •  %d bodů" % int(game.progress.scores[str(m.id)])) if unlocked else "Uzamčeno",func(): start_ticket(i),unlocked)
		b.disabled=not unlocked
		row.add_child(b)

func start_ticket(index: int):
	game.start_mission(index,game.training)
	host=game.current.server
	navigate(game.current.category)

func draw_console():
	center.add_child(label(("Datacenter  ›  " + host + "  ›  VM / CT") if page=="Proxmox" else ("Hyper-V Manager  ›  " + host if page=="Hyper-V" else "Storage Controller  ›  NAS-01"),12,CYAN))
	var options=[]
	for a in game.actions:
		if a.get("console","Proxmox")==page and not a.panel in options: options.append(a.panel)
	if options.is_empty():
		center.add_child(label("Zvol příslušný modul kampaně.",15,MUTED))
		return
	if not tab in options: tab=options[0]
	var picker=OptionButton.new()
	picker.custom_minimum_size.y=40
	for opt in options: picker.add_item(opt)
	picker.select(options.find(tab))
	picker.item_selected.connect(func(i): tab=options[i]; notice=""; draw_ui())
	center.add_child(picker)
	var v=scroll(center)
	draw_state(v)
	for action in game.actions:
		if action.get("console","Proxmox")==page and action.panel==tab: draw_form(v,action)

func draw_state(parent: Node):
	var s=game.sim.state
	var c=card(parent,"Živý stav infrastruktury")
	if page=="Proxmox":
		var h=s.hosts["PVE-01"]
		c.add_child(label("PVE-01  •  %s  •  VT: %s  •  %s\nManagement: %s  |  64 GB RAM\nvmbr0 → eno1  •  VLAN-aware: %s" % ["ONLINE" if h.online else "OFFLINE",str(h.vt),h.mode,h.ip,str(s.network.switches.vmbr0.vlan_aware)],13,MUTED))
	for id in s.vms:
		var vm=s.vms[id]
		if (page=="Proxmox" and vm.host.begins_with("PVE")) or (page=="Hyper-V" and vm.host.begins_with("HV")):
			c.add_child(label("%s  %s  •  %s\n%d vCPU / %s GB RAM / disk %s GB → FS %s GB\n%s / VLAN %d / %s" % [id,vm.name,vm.status,int(vm.cpu),str(vm.ram),str(vm.disk),str(vm.filesystem),vm.bridge,int(vm.vlan),vm.ip],13,CYAN))
	if page=="Storage":
		c.add_child(label("%s  •  %s  •  %.0f GB\nPool: %.0f / %.0f GB fyzicky; přislíbeno %.0f GB" % [s.raid.level,s.raid.health,float(s.raid.capacity),float(s.storage.used),float(s.storage.capacity),float(s.storage.provisioned)],14,CYAN))
		var grid=GridContainer.new()
		grid.columns=4
		c.add_child(grid)
		for id in s.disks:
			var d=s.disks[id]
			var b=button("SLOT %s\n%s\n%s" % [id,d.serial,d.health],func(): show_message("Fyzický disk "+id,JSON.stringify(d,"  ")))
			b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			grid.add_child(b)

func draw_form(parent: Node, action: Dictionary):
	var c=card(parent,action.label,action.get("description","Změna se projeví ve sdíleném modelu infrastruktury."))
	var inputs={}
	for field in action.fields:
		c.add_child(label(field.label,12,MUTED))
		var value=Eval.read_path(game.sim.state,field.get("path",""),field.get("default","")) if field.has("path") else field.get("default","")
		var input: Control
		match field.get("type","text"):
			"bool":
				input=CheckButton.new()
				input.text="Zapnuto / potvrzeno"
				input.button_pressed=bool(value)
			"choice":
				input=OptionButton.new()
				for option in field.options: input.add_item(str(option))
				var idx=field.options.find(value)
				input.select(maxi(0,idx))
			"number":
				input=SpinBox.new()
				input.min_value=field.get("min",0)
				input.max_value=field.get("max",100000)
				input.step=field.get("step",1)
				input.value=float(value) if str(value).is_valid_float() else 0
			_:
				input=LineEdit.new()
				input.text=str(value)
		input.custom_minimum_size.y=36
		input.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		c.add_child(input)
		inputs[field.key]=input
	c.add_child(button(action.label,func():
		var params={}
		for key in inputs:
			var input=inputs[key]
			if input is CheckButton: params[key]=input.button_pressed
			elif input is OptionButton: params[key]=input.get_item_text(input.selected)
			elif input is SpinBox: params[key]=input.value
			else: params[key]=input.text.strip_edges()
		if action.get("danger",false):
			confirm_action(action,params)
		else: perform(action.id,params),true))

func confirm_action(action: Dictionary, params: Dictionary):
	var d=ConfirmationDialog.new()
	d.title="Potvrzení zásahu do simulace"
	d.dialog_text="%s\n\n%s\n\nCílové parametry:\n%s\n\nOvěř identitu zařízení a dostupnost zálohy. Operace může zničit data v simulaci." % [action.label,action.get("warning","Destruktivní operace."),JSON.stringify(params,"  ")]
	d.ok_button_text="Provést simulovanou operaci"
	d.cancel_button_text="Vrátit se ke kontrole"
	add_child(d)
	d.confirmed.connect(func(): perform(action.id,params); d.queue_free())
	d.canceled.connect(d.queue_free)
	d.popup_centered(Vector2i(600,450))

func perform(action: String, params: Dictionary):
	var result=game.apply(action,params)
	notice=result.text.left(600)
	bad_notice=not result.ok
	draw_ui()

func close_ticket():
	var result=game.complete()
	if not result.ok: show_message("Ticket zatím nelze předat",result.text); return
	show_message("Ticket vyřešen • %d / 100 bodů" % result.score,result.text+"\n\nProvedené kroky:\n"+"\n".join(game.sim.state.journal))
	draw_ui()

func hint():
	var level=mini(game.hints_used,2)
	game.hints_used=mini(game.hints_used+1,3)
	game.save()
	show_message("Nápověda %d / 3" % (level+1),game.current.hints[level]+"\n\nKaždý stupeň sníží hodnocení o 4 body.")

func restart_confirm():
	var d=ConfirmationDialog.new()
	d.title="Restart laboratorní situace"
	d.dialog_text="Konfigurace této mise se vrátí do výchozího stavu. Získané XP zůstanou uložené."
	add_child(d)
	d.confirmed.connect(func(): game.start_mission(int(game.current.id)-1,game.training); notice=""; draw_ui(); d.queue_free())
	d.canceled.connect(d.queue_free)
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
	d.popup_centered(Vector2i(620,430))

func draw_network():
	var v=scroll(center)
	var c=card(v,"Síťová cesta APP01", "VM → virtuální switch → fyzický uplink → VLAN 20 → gateway → DNS → HTTPS")
	var net=preload("res://scripts/simulation/NetworkSimulator.gd").probe(game.sim.state,"100")
	for k in ["link","ip","dns","app"]: c.add_child(label(("●  " if net[k] else "○  ")+k.to_upper(),17,CYAN if net[k] else ORANGE))
	c.add_child(label(net.reason,14,MUTED))
	c.add_child(button("Otevřít síťovou konfiguraci",func(): navigate("Proxmox")))

func draw_terminal():
	var v=scroll(center)
	var c=card(v,"Simulovaný terminál", "Příkazy se nikdy nespouštějí v operačním systému.")
	c.add_child(label(terminal_history,14,CYAN))
	var input=LineEdit.new()
	input.placeholder_text="help"
	input.custom_minimum_size.y=42
	c.add_child(input)
	input.text_submitted.connect(func(command): terminal_history+="\n> "+command+"\nTerminál bude rozšířen v další etapě.\n"; draw_ui())
	input.grab_focus()

func draw_academy():
	var v=scroll(center)
	var c=card(v,"Příručka administrátora", "Primární studijní materiály jsou uloženy v data/knowledge a budou dostupné i ve hře.")
	c.add_child(label("RAID není záloha. Snapshot není nezávislá kopie. Replikace nenahrazuje historii záloh.\n\nPři zásahu ověř identitu zařízení a možnost návratu. Obnovu testuj v izolované síti a kontroluj skutečná data aplikace.",16,MUTED))

func draw_stats():
	var v=scroll(center)
	var c=card(v,"Tvůj administrátorský profil")
	c.add_child(label("%d XP  •  %d uzavřených ticketů\nAchievementy: %s" % [int(game.progress.xp),game.progress.scores.size(),", ".join(game.progress.achievements)],19,CYAN))
	for topic in game.progress.mistakes: c.add_child(label("%s: %d chyb — doporučeno opakování" % [topic,int(game.progress.mistakes[topic])],14,ORANGE))

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

func capture_later():
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("res://test-output/menu.png")
