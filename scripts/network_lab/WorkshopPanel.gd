extends "res://scripts/network_lab/LabPanel.gd"

var menu_mode := "practice"

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	data_font.font_names = PackedStringArray(["Consolas","DejaVu Sans Mono"])
	lab = shell.ui.game.network_workshop
	ui = shell.ui
	menu_mode = lab.mode
	draw(false)

func draw(keep_position := true):
	var offset := scroll.scroll_vertical if is_instance_valid(scroll) and keep_position else 0
	var focus := get_viewport().gui_get_focus_owner() as Button
	var focus_text := focus.text if is_instance_valid(focus) and keep_position else ""
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
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,38)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,16)
	layout = ui.vbox(margin,7)
	layout.add_child(ui.label("05 / SÍŤOVÁ TRÉNINKOVÁ DÍLNA · "+lab.MODES[lab.mode],17,Color("f3c476")))
	layout.add_child(ui.label(lab.task.title if not lab.task.is_empty() else "Servisní stůl",25))
	layout.add_child(ui.label("Zařízení: "+lab.network.NAMES.get(lab.selected,lab.selected)+" · "+("ODEVZDÁNO" if lab.submitted else "Změř → oprav → znovu změř"),17))
	var tabs := HFlowContainer.new()
	layout.add_child(tabs)
	for tab in [["home","Tickety"],["ticket","Aktuální ticket"],["measure","Diagnostika"],["capture","Analyzátor"],["review","Rozbor"],["history","Historie"]]:
		action(tabs,tab[1],navigate.bind(tab[0]),lab.view==tab[0])
	scroll = ScrollContainer.new()
	scroll.follow_focus = true
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var padding := MarginContainer.new()
	padding.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	padding.add_theme_constant_override("margin_right",12)
	scroll.add_child(padding)
	content = ui.vbox(padding,8)
	if lab.demo:
		heading("UKÁZKA / samostatná kopie sítě")
		paragraph(["Změř výchozí linku.","Zachyť DHCP a porovnej pronájem.","Ukázka provede zásah v izolované síti.","Obnov pronájem po opravě.","Změř HTTPS podle jména.","Ukázka dokončena; vlastní pokus zůstal zachovaný."][lab.demo_step])
		data(lab.example.last_message)
		action(content,"Další krok ukázky",func(): lab.demo_next(); draw()).disabled = lab.demo_step>=5
		action(content,"Zavřít ukázku a obnovit pokus",func(): lab.demo = false; draw())
	else:
		match lab.view:
			"home": workshop_home()
			"ticket": workshop_ticket()
			"measure": workshop_measure()
			"capture": workshop_capture()
			"review":
				if lab.stale(): heading("ZASTARALÉ OVĚŘENÍ / zopakuj měření a ověření")
				if not lab.result.is_empty():
					heading("✓ Splněno" if lab.result.passed else "○ Nesplněno")
					for line in lab.result.missing: paragraph(line)
				paragraph(lab.review_text())
			"history":
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
					action(content,"%s / %s / %s / %d bodů" % [record.id,lab.MODES[record.mode],"Splněno" if record.passed else "Nesplněno",record.score],func(): lab.selected_history = lab.attempts.find(record); draw(false))
	var footer := HFlowContainer.new()
	layout.add_child(footer)
	if not lab.task.is_empty() and not lab.demo and not lab.submitted:
		if lab.mode!="exam": action(footer,"Ověřit řešení",func(): lab.verify(); draw(false),true)
		if lab.mode!="free": action(footer,"Odevzdat ticket",func(): lab.submit(); draw(false),lab.mode=="exam")
	action(footer,"Zpět do 3D  [B/Y]" if shell.vr_active else "Zpět do 3D  [Esc]",shell.return_to_world)
	if ui.game.unsaved: action(footer,"Neuloženo · zkusit znovu",func(): ui.game.save(); draw())
	var pick: Button = actions[0]
	for current in actions:
		if current.text==focus_text and not current.disabled: pick = current
	restore_focus.call_deferred(pick,offset)
	shell.world.network_room.workshop.sync(lab.model())

func row() -> HFlowContainer:
	var value := HFlowContainer.new()
	content.add_child(value)
	return value

func workshop_home():
	paragraph("Mezi učebnou a dílnou zůstávají oba pokusy zachované během jedné návštěvy. Odchod z celého pavilonu do haly, menu či jiné učebny dočasné pokusy ukončí. Uložené výsledky zůstanou.")
	var modes := row()
	for key in lab.MODES:
		action(modes,lab.MODES[key],func(): menu_mode = key; draw(),menu_mode==key)
	if menu_mode=="free":
		action(content,"Otevřít funkční výchozí síť",func(): lab.mode = "free"; lab.start(""); draw(false))
	for task in lab.catalog.tasks:
		paragraph("%s / %d. ročník / %s / %s" % [task.id,task.year,task.difficulty,task.service])
		action(content,task.id+" / "+task.title,func(): lab.mode = menu_mode; lab.start(task.id); draw(false))

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
		action(content,"Komentovaná ukázka",func(): lab.start_demo(); draw())
	if lab.mode not in ["exam","free"] and not lab.submitted:
		action(content,"Nápověda na vyžádání",func(): lab.hint(); draw())
		if lab.hints: paragraph(lab.task.hint)
	if lab.task.id=="H" and not lab.submitted:
		heading("Uzavření ticketu / vyber zjištěné příčiny")
		for pair in [["vlan","Nesprávná VLAN"],["dns","Starý DNS záznam"],["cable","Vadný kabel"]]:
			action(content,("✓ " if lab.causes.get(pair[0],false) else "○ ")+pair[1],func(): lab.causes[pair[0]] = not lab.causes.get(pair[0],false); draw())
		heading("Důkazy o opravě / výběr musí odpovídat skutečnému měření")
		for pair in [["dhcp","Úplný DHCP pronájem"],["services","HTTPS, tiskárna a PC 02"],["led_only","Stačí svítící LED"]]:
			action(content,("✓ " if lab.evidence_summary.get(pair[0],false) else "○ ")+pair[1],func(): lab.evidence_summary[pair[0]] = not lab.evidence_summary.get(pair[0],false); draw())
	action(content,"Změřit",navigate.bind("measure"),true)

func operate(callback: Callable):
	callback.call()
	lab.selected_frame = -1
	draw()

func workshop_measure():
	var model = lab.model()
	var devices := row()
	for key in model.CLIENTS:
		action(devices,model.NAMES[key],func(): lab.selected = key; draw(),lab.selected==key)
	data(model.overview()+"\n"+model.configuration())
	data("Z04 → PP04 → SW %02d / Z02 → PP02 → SW %02d / Z07 → PP07 → SW %02d\nDNS záznam %s / cache %s\nDHCP .20–.49: %s / brána MAC %s\nHTTPS %s / pravidlo 443 %s / správa %s / AP %s" % [model.ports.pc04,model.ports.pc02,model.ports.printer,model.dns_record,model.dns_cache,"volné adresy" if model.dhcp_pool else "vyčerpáno",model.gateway_mac,"běží" if model.tcp_enabled else "zastaveno","povoleno" if model.rules.https else "blokováno","povolena" if model.rules.management else "blokována","uprostřed" if model.ap_position=="center" else "vpředu"])
	if model.last_message!="": paragraph(model.last_message)
	if lab.submitted:
		paragraph("Pokus je uzavřený. Nový pokus spusť výslovným výběrem ticketu.")
		return
	var probes := row()
	paragraph("Linka a brána měří vybrané zařízení. DHCP, ARP, DNS, TCP a HTTPS používají klienta PC 04; kontrolní měření používá PC 02. W1/W2 měří cvičný Wi-Fi klient.")
	for pair in [["link","Změřit linku"],["dhcp","Obnovit a změřit DHCP"],["gateway","Změřit bránu"],["arp","Porovnat ARP"],["printer","Změřit tiskárnu"],["control","Změřit PC 02"],["dns","Změřit DNS"],["tcp","Změřit TCP 443"],["https","Otevřít HTTPS"],["near","Změřit W1"],["far","Změřit W2"]]:
		action(probes,pair[1],operate.bind(lab.measure.bind(pair[0])))
	for key in model.measurements:
		var m: Dictionary = model.measurements[key]
		paragraph(m.detail+(" / ZASTARALÉ · změř znovu "+str(key) if m.revision!=model.revision else " / ✓" if m.passed else " / ○"))
	if lab.task.is_empty() and lab.mode!="free": return
	heading("Přesný výběr kabelu a portu / stejná akce jako ve 3D")
	paragraph("Konektor: "+(model.NAMES.get(model.cable,model.cable)+" → "+str(model.patch_map.get(model.cable,""))+" → vyber SW port" if model.cable!="" else "odložený"))
	var connectors := row()
	for key in model.CLIENTS: action(connectors,"Konektor / "+model.NAMES[key],operate.bind(lab.select_cable.bind(key)))
	action(connectors,"Odložit konektor",func(): model.cable = ""; draw())
	var ports := row()
	for port in range(3,9):
		action(ports,"SW %02d / VLAN %d" % [port,model.vlans[port]],func():
			lab.selected_port = port
			if model.cable!="": lab.connect_port(port)
			draw(),lab.selected_port==port)
	var vlans := row()
	for value in [10,20]: action(vlans,"Port %02d → VLAN %d" % [lab.selected_port,value],operate.bind(lab.vlan.bind(lab.selected_port,value)))
	heading("Konfigurace / laboratorní předvolby")
	var configs := row()
	for change in [["pool",true,"DHCP / uvolnit rozsah"],["pool",false,"DHCP / vyčerpat rozsah"],["static",null,"PC 04 / pevná adresa"],["arp",null,"Smazat souseda 192.168.10.1"],["flush",null,"Obnovit DNS cache"],["dns",model.WEB,"DNS A / 203.0.113.20"],["dns","203.0.113.19","DNS A / 203.0.113.19"],["tcp",true,"HTTPS / spustit službu"],["tcp",false,"HTTPS / zastavit službu"],["https_rule",true,"Pravidlo / povolit jen 443"],["https_rule",false,"Pravidlo / blokovat 443"],["management",true,"Správa / povolit"],["management",false,"Správa / blokovat"],["ap","center","AP / středový úchyt"],["ap","front","AP / přední úchyt"]]:
		action(configs,change[2],operate.bind(lab.edit.bind(change[0],change[1])))
	if not lab.undo_stack.is_empty():
		paragraph("Krok zpět vrátí: "+str(lab.undo_stack[-1].title))
		action(content,"Vrátit poslední zásah",operate.bind(lab.undo))
	action(content,"Obnovit výchozí stav pokusu",func(): lab.start(str(lab.task.get("id",""))); draw(false))

func workshop_capture():
	var model = lab.model()
	heading("Offline analyzátor / Ethernet, IPv4, ARP, DHCP, DNS, TCP a HTTPS")
	paragraph("Jde o uzavřený model; zjednodušené TLS ukazuje popis zprávy po rozbalení. Výběr zvýrazní cestu v racku a zůstane dostupný po návratu z ticketu.")
	var filters := row()
	for key in ["Vše","DHCP","ARP","DNS","TCP","HTTPS"]:
		action(filters,key,func(): lab.filter = key; draw(),lab.filter==key)
	if lab.selected_frame>=0 and lab.selected_frame<model.capture.size():
		var frame: Dictionary = model.capture[lab.selected_frame]
		data(frame.title+"\n"+frame.frame+"\n"+frame.ip+"\n"+frame.transport+"\n"+frame.application)
		action(content,"Ukázat cestu ve 3D",shell.return_to_world)
	for index in range(model.capture.size()-1,-1,-1):
		var frame: Dictionary = model.capture[index]
		if lab.filter!="Vše" and not frame.title.contains(lab.filter): continue
		action(content,"Rámec %02d / %s" % [index+1,frame.title],func(): lab.selected_frame = index; model.last_path = frame.path.duplicate(); draw())
