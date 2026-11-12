extends "res://scripts/network_lab/LabPanel.gd"

const PROBES = [
	["Připojení",[["link","Změřit linku"],["gateway","Změřit bránu"]]],
	["Adresace",[["dhcp","Obnovit a změřit DHCP"],["arp","Porovnat ARP"]]],
	["Služby",[["dns","Změřit DNS"],["tcp","Změřit TCP 443"],["https","Otevřít HTTPS"]]],
	["Kontrolní měření",[["printer","Změřit tiskárnu"],["control","Změřit PC 02"]]],
	["Wi-Fi",[["near","Změřit W1"],["far","Změřit W2"]]]]
const GROUPS = {"cable":"Kabeláž a porty","vlan":"VLAN","dhcp":"DHCP a adresace","arp":"ARP","dns":"DNS","https":"HTTPS a pravidla","wifi":"Wi-Fi a poloha AP"}
var menu_mode := "practice"
var repair_group := "cable"
var expanded := {}
var positions := {}
var current_page := ""
var reset_pending := false
var rebuilding := false
var owner_serial := -1

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	data_font.font_names = PackedStringArray(["Consolas","DejaVu Sans Mono"])
	lab = shell.ui.game.network_workshop
	ui = shell.ui
	menu_mode = lab.mode
	owner_serial = lab.attempt_serial
	repair_group = lab.panel_state.get("group","cable")
	expanded = lab.panel_state.get("expanded",{}).duplicate()
	positions = lab.panel_state.get("positions",{}).duplicate(true)
	resized.connect(responsive_redraw)
	draw(false)

func responsive_redraw():
	if is_inside_tree() and not rebuilding: draw.call_deferred()

func control(parent: Node, title: String, callback: Callable, active := false, identity := "") -> Button:
	var b := action(parent,title,callback)
	b.custom_minimum_size.y = 46
	b.set_meta("workshop_id",identity if identity!="" else title.trim_prefix("✓ ").trim_prefix("○ "))
	if active:
		b.add_theme_stylebox_override("normal",ui.box(Color("2c4657"),Color("6d9eb9"),6))
	return b

func primary(b: Button):
	b.add_theme_stylebox_override("normal",ui.box(Color("745830"),Color("f3c476"),6))
	b.add_theme_stylebox_override("hover",ui.box(Color("886a3b"),Color("ffe0a7"),6))

func remember_position():
	if owner_serial!=lab.attempt_serial: return
	if current_page=="" or not is_instance_valid(scroll): return
	var focused := get_viewport().gui_get_focus_owner()
	var identity := str(focused.get_meta("workshop_id","")) if is_instance_valid(focused) else ""
	positions[current_page] = {"scroll":scroll.scroll_vertical,"focus":identity}
	lab.panel_state = {"group":repair_group,"expanded":expanded.duplicate(),"positions":positions.duplicate(true)}

func _exit_tree():
	remember_position()

func navigate(page: String):
	remember_position()
	lab.view = page
	reset_pending = false
	draw(false)

func restore_workshop_focus(identity: String, offset: int):
	await get_tree().process_frame
	if not is_inside_tree(): return
	var pick: Button
	for b in actions:
		if b.get_meta("workshop_id","")==identity and not b.disabled: pick = b
	if pick==null:
		for b in actions:
			if not b.disabled:
				pick = b
				break
	if pick!=null: pick.grab_focus()
	# Restoring a focus owner must not jump to its top edge after every probe.
	scroll.scroll_vertical = offset

func draw(keep_position := true):
	if not is_inside_tree(): return
	if owner_serial!=lab.attempt_serial:
		positions.clear()
		expanded.clear()
		owner_serial = lab.attempt_serial
	rebuilding = true
	if keep_position: remember_position()
	current_page = lab.view
	var saved: Dictionary = positions.get(current_page,{"scroll":0,"focus":"nav:"+current_page})
	for child in get_children():
		remove_child(child)
		child.queue_free()
	actions.clear()
	var shade := ColorRect.new()
	shade.color = Color("17232d")
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,24)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,14)
	layout = ui.vbox(margin,8)
	var header = ui.hbox(layout,16)
	var titles = ui.vbox(header,2)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_child(ui.label("05 / SÍŤOVÁ TRÉNINKOVÁ DÍLNA",15,Color("f3c476")))
	titles.add_child(ui.label((lab.task.id+" / "+lab.task.title) if not lab.task.is_empty() else "Servisní stůl",22))
	var navigation = ui.vbox(header,4)
	var browsing = ui.hbox(navigation,8)
	control(browsing,"Výběr ticketů",navigate.bind("home"),lab.view=="home","nav:home")
	control(browsing,"Historie",navigate.bind("history"),lab.view=="history","nav:history")
	navigation.add_child(ui.label(lab.MODES[lab.mode]+" · "+attempt_status(),15,ui.MUTED))
	var tabs = ui.hbox(layout,6)
	tabs.name = "WorkTabs"
	for tab in [["ticket","Ticket"],["measure","Diagnostika"],["repair","Opravy"],["capture","Analyzátor"],["review","Rozbor"]]:
		var b := control(tabs,tab[1],navigate.bind(tab[0]),false,"nav:"+tab[0])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if lab.view==tab[0]:
			var style = ui.box(Color("203b46"),Color("43dad0"),5)
			style.border_width_bottom = 3
			b.add_theme_stylebox_override("normal",style)
	scroll = ScrollContainer.new()
	scroll.name = "WorkScroll"
	scroll.follow_focus = true
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var padding := MarginContainer.new()
	padding.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	padding.add_theme_constant_override("margin_right",14)
	padding.add_theme_constant_override("margin_bottom",12)
	scroll.add_child(padding)
	content = ui.vbox(padding,10)
	if lab.demo:
		heading("UKÁZKA / samostatná kopie sítě")
		paragraph(["Změř výchozí linku.","Zachyť DHCP a porovnej pronájem.","Ukázka provede zásah v izolované síti.","Obnov pronájem po opravě.","Změř HTTPS podle jména.","Ukázka dokončena; vlastní pokus zůstal zachovaný."][lab.demo_step])
		data(lab.example.last_message)
		control(content,"Další krok ukázky",func(): lab.demo_next(); draw(),false,"demo:next").disabled = lab.demo_step>=5
		control(content,"Zavřít ukázku a obnovit pokus",func(): lab.demo = false; draw())
	else:
		match lab.view:
			"home": workshop_home()
			"ticket": workshop_ticket()
			"measure": workshop_measure()
			"repair": workshop_repairs()
			"capture": workshop_capture()
			"review": workshop_review()
			"history": workshop_history()
	var footer_card := PanelContainer.new()
	footer_card.name = "WorkFooter"
	footer_card.add_theme_stylebox_override("panel",ui.box(Color("20313e"),Color("53616a"),6))
	layout.add_child(footer_card)
	var footer = ui.vbox(footer_card,6)
	if ui.game.unsaved:
		var warning = ui.hbox(footer,12)
		warning.add_child(ui.label("! Změny čekají na uložení. "+error_string(ui.game.last_save_error),16,Color("ffbe91")))
		control(warning,"Zkusit uložit znovu",func(): ui.game.save(); draw(),false,"save:retry")
	var commands = ui.hbox(footer,10)
	if not lab.task.is_empty() and not lab.demo and not lab.submitted:
		if lab.mode!="exam": control(commands,"Ověřit řešení",func(): lab.verify(); draw(),false,"attempt:verify")
		if lab.mode!="free": primary(control(commands,"Odevzdat ticket",func(): lab.submit(); draw(),false,"attempt:submit"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	commands.add_child(spacer)
	control(commands,"Zpět do 3D  [B/Y]" if shell.vr_active else "Zpět do 3D  [Esc]",shell.return_to_world,false,"world:return")
	var ordered: Array[Button] = []
	for b in actions:
		if not b.disabled: ordered.append(b)
	for index in ordered.size():
		var b := ordered[index]
		b.focus_next = b.get_path_to(ordered[(index+1)%ordered.size()])
		b.focus_previous = b.get_path_to(ordered[posmod(index-1,ordered.size())])
		b.focus_neighbor_top = b.focus_previous
		b.focus_neighbor_bottom = b.focus_next
	restore_workshop_focus.call_deferred(str(saved.focus),int(saved.scroll))
	shell.world.network_room.workshop.sync(lab.model())
	rebuilding = false

func attempt_status() -> String:
	if lab.demo: return "Izolovaná ukázka"
	if lab.submitted: return "Odevzdáno · uzavřený pokus"
	if lab.task.is_empty(): return "Volná síť" if lab.mode=="free" else "Vyber ticket"
	if lab.mode=="exam": return "Rozpracováno"
	if lab.stale(): return "! Ověření zastaralé"
	if not lab.result.is_empty(): return "✓ Ověřeno" if lab.result.passed else "○ Ověřeno · nesplněno"
	return "Rozpracováno · bez ověření"

func row() -> HFlowContainer:
	var value := HFlowContainer.new()
	value.add_theme_constant_override("h_separation",8)
	value.add_theme_constant_override("v_separation",8)
	content.add_child(value)
	return value

func fold(parent: Node, id: String, title: String, body: String):
	control(parent,("− " if expanded.get(id,false) else "+ ")+title,func(): expanded[id] = not expanded.get(id,false); draw(),false,"detail:"+id)
	if expanded.get(id,false): parent.add_child(ui.label(body,16,Color("c5d6dc")))

func operate(callback: Callable):
	var frames_before: Array = lab.model().capture
	var selected_frame: Dictionary = frames_before[lab.selected_frame].duplicate(true) if lab.selected_frame>=0 and lab.selected_frame<frames_before.size() else {}
	callback.call()
	if not selected_frame.is_empty(): lab.selected_frame = lab.model().capture.find(selected_frame)
	draw()

func measurement_status(key: String) -> String:
	var model = lab.model()
	if not model.measurements.has(key): return "— Nezměřeno"
	var m: Dictionary = model.measurements[key]
	if m.revision!=model.revision: return "! Zastaralé · zopakuj měření"
	return "✓ Úspěšné · aktuální" if m.passed else "× Neúspěšné · aktuální důkaz"

func probe_route(key: String, source := "") -> String:
	var model = lab.model()
	if key in ["near","far"]: return "Wi-Fi klient / "+("W1" if key=="near" else "W2")+" → AP → HTTPS"
	var device: String = source if source!="" else lab.selected if key in ["link","gateway"] else "pc02" if key=="control" else "pc04"
	var target: String = {"link":"zásuvka / patch / switch","gateway":"brána 192.168.10.1","dhcp":"DHCP / obnoví pronájem","arp":"cache ↔ MAC brány","printer":"tiskárna 192.168.10.50","control":"brána 192.168.10.1","dns":"portál / DNS","tcp":"203.0.113.20:443","https":"portál / HTTPS"}.get(key,key)
	return model.NAMES.get(device,device)+" → "+target

func measurement_overview():
	if lab.task.is_empty() or lab.mode=="exam" and not lab.submitted: return
	heading("Provedená měření / stav důkazů")
	for group in PROBES:
		for probe in group[1]:
			if not lab.network.measurements.has(probe[0]): continue
			var m: Dictionary = lab.network.measurements[probe[0]]
			paragraph(probe[1]+" / "+probe_route(probe[0],m.source)+" / "+measurement_status(probe[0]))

func device_summary(model) -> String:
	var id: String = lab.selected
	var address: Dictionary = model.lease if id=="pc04" else {"ip":model.IPS[id],"mask":"255.255.255.0","gateway":model.IPS.router,"dns":model.IPS.resolver}
	return "%s / %s\nSW %02d · VLAN %d\nIP %s\nMaska %s\nBrána %s\nDNS %s" % [model.NAMES[id],"LINK" if model.link(id) else "BEZ LINKY",model.ports[id],model.segment(id),address.get("ip","nepřidělena"),address.get("mask","—"),address.get("gateway","—"),address.get("dns","—")]

func workshop_measure():
	var model = lab.model()
	var wide: bool = not shell.vr_active and size.x/ui.display_settings.text_scale>=1400
	var columns: Container
	if wide: columns = HBoxContainer.new()
	else: columns = VBoxContainer.new()
	columns.add_theme_constant_override("separation",18)
	content.add_child(columns)
	var devices = ui.vbox(columns,8)
	if wide: devices.custom_minimum_size.x = 280
	devices.add_child(ui.label("Zařízení / linka a brána",18,ui.CYAN))
	var choices: Container
	if wide: choices = VBoxContainer.new()
	else: choices = HFlowContainer.new()
	devices.add_child(choices)
	for key in model.CLIENTS:
		control(choices,model.NAMES[key],func(): lab.selected = key; draw(),lab.selected==key,"device:"+key)
	devices.add_child(ui.label(device_summary(model) if wide else device_summary(model).replace("\n","  ·  "),16))
	fold(devices,"network","Podrobné zapojení a konfigurace",model.overview()+"\n"+model.configuration()+"\nZ04 → PP04 → SW %02d / Z02 → PP02 → SW %02d / Z07 → PP07 → SW %02d" % [model.ports.pc04,model.ports.pc02,model.ports.printer])
	var tools = ui.vbox(columns,10)
	tools.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools.add_child(ui.label("Měření / zdroj je uveden u každého nástroje",18,ui.CYAN))
	tools.add_child(ui.label("Neúspěšné měření může být platným důkazem závady. Změna zařízení ovlivní pouze linku a bránu.",16,ui.MUTED))
	for group in PROBES:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel",ui.box(Color("1c2e3a"),Color("354c59"),6))
		tools.add_child(card)
		var body = ui.vbox(card,8)
		body.add_child(ui.label(group[0],18,Color("d9e5e9")))
		for probe in group[1]:
			var key: String = probe[0]
			var line = ui.hbox(body,14)
			var b := control(line,probe[1],operate.bind(lab.measure.bind(key)),false,"probe:"+key)
			b.custom_minimum_size.x = 290
			b.disabled = lab.submitted
			var text = ui.vbox(line,2)
			text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			text.add_child(ui.label(probe_route(key),16,ui.MUTED))
			text.add_child(ui.label(measurement_status(key),17))
			if model.measurements.has(key):
				var m: Dictionary = model.measurements[key]
				text.add_child(ui.label(m.detail.left(180)+("…" if m.detail.length()>180 else ""),16))
				# A selected-device change must not relabel an older observation.
				text.add_child(ui.label("Naměřeno: "+probe_route(key,m.source),15,ui.MUTED))
				fold(body,"probe:"+key,"Technické detaily / "+probe[1],m.detail)
	if lab.submitted: paragraph("Pokus je uzavřený. Nový pokus spusť výslovným výběrem ticketu.")

func choose_group(key: String):
	remember_position()
	repair_group = key
	positions["repair"] = {"scroll":0,"focus":"group:"+key}
	reset_pending = false
	draw(false)

func workshop_repairs():
	var model = lab.model()
	if lab.submitted or lab.task.is_empty() and lab.mode!="free":
		paragraph("Pokus je uzavřený. Nový pokus spusť výslovným výběrem ticketu." if lab.submitted else "Nejdřív vyber ticket nebo volný trénink.")
		return
	var groups := row()
	for key in GROUPS: control(groups,GROUPS[key],choose_group.bind(key),repair_group==key,"group:"+key)
	heading(GROUPS[repair_group]+" / současný stav a zásahy")
	if model.last_message!="": paragraph(model.last_message)
	match repair_group:
		"cable","vlan":
			paragraph("Držený konektor: "+(model.NAMES.get(model.cable,model.cable)+" → "+str(model.patch_map.get(model.cable,"")) if model.cable!="" else "odložený")+". Zvolený port: SW %02d / VLAN %d." % [lab.selected_port,model.vlans[lab.selected_port]])
			if repair_group=="cable":
				var connectors := row()
				for key in model.CLIENTS: control(connectors,"Konektor / "+model.NAMES[key],operate.bind(lab.select_cable.bind(key)),model.cable==key,"cable:"+key)
				control(connectors,"Odložit konektor",func(): model.cable = ""; draw())
			var ports := row()
			for port in range(3,9):
				var holder: String = model.occupant(port)
				var b := control(ports,"SW %02d / VLAN %d" % [port,model.vlans[port]],func():
					lab.selected_port = port
					if repair_group=="cable" and model.cable!="": lab.connect_port(port)
					draw(),lab.selected_port==port,"port:"+str(port))
				b.tooltip_text = "Volný port" if holder=="" else "Obsazeno: "+model.NAMES.get(holder,holder)
			paragraph("Obsazenost: "+" · ".join(range(3,9).map(func(port): return "%02d: %s / VLAN %d" % [port,model.NAMES.get(model.occupant(port),"volný"),model.vlans[port]])))
			paragraph("Trasy: Z04 → PP04 → SW %02d / Z02 → PP02 → SW %02d / Z07 → PP07 → SW %02d. Obsazený port jiné zařízení neodpojí." % [model.ports.pc04,model.ports.pc02,model.ports.printer])
			if repair_group=="vlan":
				var vlans := row()
				for value in [10,20]: control(vlans,"Port %02d → VLAN %d" % [lab.selected_port,value],operate.bind(lab.vlan.bind(lab.selected_port,value)),false,"vlan:"+str(value))
		"dhcp":
			paragraph("Rozsah .20–.49: "+("volné adresy" if model.dhcp_pool else "vyčerpán")+". PC 04: "+str(model.lease)+" / zdroj "+model.lease_source)
			edit_controls([["pool",true,"DHCP / uvolnit rozsah"],["pool",false,"DHCP / vyčerpat rozsah"],["static",null,"PC 04 / pevná adresa"]])
		"arp":
			paragraph("PC 04 / ARP cache: "+str(model.cache)+". Štítek brány: "+model.gateway_mac)
			edit_controls([["arp",null,"Smazat souseda 192.168.10.1"]])
		"dns":
			paragraph("Autoritativní A: "+model.dns_record+" / cache PC 04: "+(model.dns_cache if model.dns_cache!="" else "prázdná"))
			edit_controls([["flush",null,"Obnovit DNS cache"],["dns",model.WEB,"DNS A / 203.0.113.20"],["dns","203.0.113.19","DNS A / 203.0.113.19"]])
		"https":
			paragraph("HTTPS: "+("běží" if model.tcp_enabled else "zastaveno")+" / pravidlo 443: "+("povoleno" if model.rules.https else "blokováno")+" / správa: "+("povolena" if model.rules.management else "blokována"))
			edit_controls([["tcp",true,"HTTPS / spustit službu"],["tcp",false,"HTTPS / zastavit službu"],["https_rule",true,"Pravidlo / povolit jen 443"],["https_rule",false,"Pravidlo / blokovat 443"],["management",true,"Správa / povolit"],["management",false,"Správa / blokovat"]])
		"wifi":
			paragraph("Poloha AP: "+("středový úchyt" if model.ap_position=="center" else "přední úchyt")+". Ověř pokrytí modelovým klientem na W1 a W2 v Diagnostice.")
			edit_controls([["ap","center","AP / středový úchyt"],["ap","front","AP / přední úchyt"]])
	heading("Historie zásahů tohoto pokusu")
	var undo_button := control(content,"Vrátit poslední zásah",operate.bind(lab.undo),false,"attempt:undo")
	undo_button.disabled = lab.undo_stack.is_empty()
	paragraph("Krok zpět vrátí: "+str(lab.undo_stack[-1].title) if not lab.undo_stack.is_empty() else "Žádný zásah k vrácení.")
	fold(content,"reset","Obnovení celého pokusu","Obnovení zruší měření, zásahy a rozehrané odpovědi aktuálního pokusu. Historie odevzdaných ticketů zůstane.")
	control(content,"Obnovit výchozí stav pokusu",func(): reset_pending = true; draw(),false,"attempt:reset")
	if reset_pending:
		paragraph("Obnovit výchozí stav? Rozpracované změny tohoto pokusu zmizí.")
		var confirm := row()
		control(confirm,"Potvrdit obnovení pokusu",func(): lab.start(str(lab.task.get("id",""))); expanded.clear(); positions.clear(); reset_pending = false; draw(false),false,"attempt:confirm-reset")
		control(confirm,"Zachovat rozpracovaný pokus",func(): reset_pending = false; draw())

func edit_controls(changes: Array):
	var buttons := row()
	for change in changes: control(buttons,change[2],operate.bind(lab.edit.bind(change[0],change[1])),false,"edit:"+change[0]+":"+str(change[1]))

func workshop_review():
	if lab.mode=="exam" and not lab.submitted:
		paragraph("Rozbor bude dostupný po odevzdání.")
		return
	if lab.stale(): heading("! ZASTARALÉ OVĚŘENÍ / zopakuj měření a ověření")
	elif not lab.result.is_empty(): heading("✓ Splněno" if lab.result.passed else "○ Nesplněno")
	if not lab.result.is_empty():
		for line in lab.result.missing: paragraph(line)
	paragraph(lab.review_text())

func workshop_home():
	paragraph("Mezi učebnou a dílnou zůstávají oba pokusy zachované během jedné návštěvy. Odchod z celého pavilonu do haly, menu či jiné učebny dočasné pokusy ukončí. Uložené výsledky zůstanou.")
	var modes := row()
	for key in lab.MODES:
		control(modes,lab.MODES[key],func(): menu_mode = key; draw(),menu_mode==key)
	if menu_mode=="free":
		control(content,"Otevřít funkční výchozí síť",func(): lab.mode = "free"; lab.start(""); draw(false))
	for task in lab.catalog.tasks:
		paragraph("%s / %d. ročník / %s / %s" % [task.id,task.year,task.difficulty,task.service])
		control(content,task.id+" / "+task.title,func(): lab.mode = menu_mode; lab.start(task.id); draw(false))

func workshop_ticket():
	if lab.task.is_empty():
		paragraph("U servisního stolu výslovně vyber ticket nebo funkční síť pro volný trénink.")
		return
	heading("Ticket %s / %d. ročník / %s" % [lab.task.id,lab.task.year,lab.task.difficulty])
	paragraph(lab.task.ticket)
	paragraph("Požadovaná služba: "+lab.task.service+". Důkazy: "+", ".join(lab.task.goals)+". PC 02 a VLAN 20 musí zůstat funkční a oddělené.")
	if lab.mode=="learn":
		paragraph("1. Změř výchozí stav: "+", ".join(lab.task.before)+". 2. Dohledávej cestu od zásuvky přes patch ke switchi. 3. Po zásahu změř všechny požadované služby. Kroky potvrzuje skutečné měření.")
		var observed := 0
		var fresh := 0
		for key in lab.task.before:
			if lab.network.measurements.has(key): observed += 1
		for key in lab.task.goals:
			if lab.network.fresh(key): fresh += 1
		paragraph("Průběh: výchozí měření %d/%d · zásahy %d · nové důkazy %d/%d" % [observed,lab.task.before.size(),lab.undo_stack.size(),fresh,lab.task.goals.size()])
		control(content,"Komentovaná ukázka",func(): lab.start_demo(); draw())
	if lab.mode not in ["exam","free"] and not lab.submitted:
		control(content,"Nápověda na vyžádání",func(): lab.hint(); draw())
		if lab.hints: paragraph(lab.task.hint)
	if lab.task.id=="H" and not lab.submitted:
		heading("Uzavření ticketu / vyber zjištěné příčiny")
		for pair in [["vlan","Nesprávná VLAN"],["dns","Starý DNS záznam"],["cable","Vadný kabel"]]:
			control(content,("✓ " if lab.causes.get(pair[0],false) else "○ ")+pair[1],func(): lab.causes[pair[0]] = not lab.causes.get(pair[0],false); draw(),false,"cause:"+pair[0])
		heading("Důkazy o opravě / výběr musí odpovídat skutečnému měření")
		for pair in [["dhcp","Úplný DHCP pronájem"],["services","HTTPS, tiskárna a PC 02"],["led_only","Stačí svítící LED"]]:
			control(content,("✓ " if lab.evidence_summary.get(pair[0],false) else "○ ")+pair[1],func(): lab.evidence_summary[pair[0]] = not lab.evidence_summary.get(pair[0],false); draw(),false,"evidence:"+pair[0])
	measurement_overview()
	control(content,"Změřit",navigate.bind("measure"))


func workshop_history():
	heading("Odevzdané tickety / samostatná historie")
	if lab.attempts.is_empty(): paragraph("Zatím bez odevzdaného výsledku. Volný trénink sem nic nezapisuje.")
	if lab.selected_history>=0 and lab.selected_history<lab.attempts.size():
		var selected_record: Dictionary = lab.attempts[lab.selected_history]
		var task: Dictionary = lab.definition(selected_record.id)
		paragraph("SYMPTOM / "+task.ticket+"\nPŘÍČINA / "+task.cause)
		paragraph("ZÁSAH / "+"; ".join(selected_record.changes))
		for proof in selected_record.proof: paragraph(proof.detail+" / "+("OK" if proof.passed else "NESPLNĚNO"))
		paragraph("Nápověda %d / chybná ověření %d" % [selected_record.hints,selected_record.errors])
	var records: Array = lab.attempts.duplicate()
	records.reverse()
	for record in records:
		control(content,"%s / %s / %s / %d bodů" % [record.id,lab.MODES[record.mode],"Splněno" if record.passed else "Nesplněno",record.score],func(): lab.selected_history = lab.attempts.find(record); draw(false))

func workshop_capture():
	var model = lab.model()
	heading("Offline analyzátor / Ethernet, IPv4, ARP, DHCP, DNS, TCP a HTTPS")
	paragraph("Jde o uzavřený model; zjednodušené TLS ukazuje popis zprávy po rozbalení. Výběr zvýrazní cestu v racku a zůstane dostupný po návratu z ticketu.")
	var filters := row()
	for key in ["Vše","DHCP","ARP","DNS","TCP","HTTPS"]:
		control(filters,key,func(): lab.filter = key; draw(),lab.filter==key)
	if lab.selected_frame>=0 and lab.selected_frame<model.capture.size():
		var frame: Dictionary = model.capture[lab.selected_frame]
		data(frame.title+"\n"+frame.frame+"\n"+frame.ip+"\n"+frame.transport+"\n"+frame.application)
		control(content,"Ukázat cestu ve 3D",func(): model.last_path = frame.path.duplicate(); shell.return_to_world(),false,"capture:show-path")
	for index in range(model.capture.size()-1,-1,-1):
		var frame: Dictionary = model.capture[index]
		if lab.filter!="Vše" and not frame.title.contains(lab.filter): continue
		control(content,"Rámec %02d / %s" % [index+1,frame.title],func(): lab.selected_frame = index; model.last_path = frame.path.duplicate(); draw())
