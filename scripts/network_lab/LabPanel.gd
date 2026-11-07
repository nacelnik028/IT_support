extends Control

var shell
var lab
var ui
var layout: VBoxContainer
var content: VBoxContainer
var actions: Array[Button]
var scroll: ScrollContainer
var data_font := SystemFont.new()

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	data_font.font_names = PackedStringArray(["Consolas","DejaVu Sans Mono","Noto Sans Mono"])
	lab = shell.ui.game.network_lab
	ui = shell.ui
	draw(false)

func action(parent: Node, title: String, callback: Callable, primary := false) -> Button:
	var button: Button = ui.button(title,callback,primary)
	button.custom_minimum_size.y = 48
	parent.add_child(button)
	actions.append(button)
	return button

func heading(title: String):
	content.add_child(ui.label(title,20,ui.CYAN))

func paragraph(body: String):
	content.add_child(ui.label(body,18))

func data(body: String):
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel",ui.box(Color("203442"),Color("3a606e"),9))
	content.add_child(card)
	var label: Label = ui.label(body,16,Color("d3f5ec"))
	label.add_theme_font_override("font",data_font)
	card.add_child(label)

func navigate(page: String):
	lab.view = page
	draw(false)

func draw(keep_position := true):
	var offset := scroll.scroll_vertical if is_instance_valid(scroll) and keep_position else 0
	var old_focus := get_viewport().gui_get_focus_owner() as Button
	var focus_index := actions.find(old_focus) if keep_position else -1
	for child in get_children():
		remove_child(child)
		child.queue_free()
	actions.clear()
	var shade := ColorRect.new()
	shade.color = Color("101f2a")
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,76)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,26)
	layout = ui.vbox(margin,8)
	layout.add_child(ui.label("05 / POČÍTAČOVÉ SÍTĚ    ·    %d. ročník    /    %s" % [lab.year,lab.MODES[lab.mode]],17,ui.CYAN))
	var title: String = lab.task.title if not lab.task.is_empty() and lab.view!="home" else "Síťová laboratoř"
	layout.add_child(ui.label(title,29))
	if not lab.task.is_empty() and lab.view=="task":
		layout.add_child(ui.label("Cíl · "+lab.task.goal,17,ui.MUTED))
	var tabs := HFlowContainer.new()
	tabs.add_theme_constant_override("h_separation",10)
	layout.add_child(tabs)
	for tab in [["home","Stanoviště"],["task","Úloha"],["review","Rozbor pokusu"],["measure","Měření a nastavení"],["capture","Analyzátor"],["study","Studijní materiál"],["results","Výsledky"]]:
		if tab[0]=="task" and lab.task.is_empty(): continue
		if tab[0]=="review" and (lab.task.is_empty() or lab.result.is_empty()): continue
		action(tabs,tab[1],navigate.bind(tab[0]),lab.view==tab[0])
	scroll = ScrollContainer.new()
	scroll.follow_focus = true
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_right",12)
	padding.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(padding)
	content = ui.vbox(padding,10)
	if lab.demo_step>=0:
		heading("Komentovaná ukázka")
		paragraph(lab.demo_comment)
		var row := HFlowContainer.new()
		content.add_child(row)
		var next := action(row,"Další krok",func():
			lab.next_demo()
			lab.selected_capture = -1
			draw())
		next.disabled = lab.demo_step>=lab.demo_limit()
		action(row,"Pozorovat v 3D",shell.return_to_world)
		action(row,"Ukončit ukázku",func():
			lab.demo_step = -1
			lab.selected_capture = -1
			navigate("task"))
	match lab.view:
		"home": draw_home()
		"task":
			if lab.demo_step<0: draw_task()
		"review": draw_review()
		"measure": draw_measurements()
		"capture": draw_capture()
		"study": draw_study()
		"results": draw_results()
	var footer := HFlowContainer.new()
	layout.add_child(footer)
	if lab.view=="task" and lab.demo_step<0: draw_submit(footer)
	action(footer,"Zpět do 3D  [B/Y]" if shell.vr_active else "Zpět do 3D  [Esc]",shell.return_to_world)
	if ui.game.unsaved:
		action(footer,"Neuloženo · zkusit znovu",func():
			ui.game.save()
			draw())
	var ordered: Array[Button] = []
	for button in actions:
		if not button.disabled: ordered.append(button)
	for index in ordered.size():
		var button := ordered[index]
		button.focus_neighbor_top = button.get_path_to(ordered[posmod(index-1,ordered.size())])
		button.focus_neighbor_bottom = button.get_path_to(ordered[(index+1)%ordered.size()])
	var pick := focus_index
	if pick<0 or pick>=actions.size(): pick = 0
	if actions[pick].disabled: pick = actions.find(ordered[0])
	restore_focus.call_deferred(actions[pick],offset)
	shell.world.network_room.sync()

func restore_focus(button: Button, offset: int):
	if not is_inside_tree(): return
	await get_tree().process_frame
	if not is_instance_valid(button) or not button.is_inside_tree(): return
	button.grab_focus()
	if scroll.is_ancestor_of(button): scroll.ensure_control_visible(button)
	else: scroll.scroll_vertical = offset

func draw_home():
	paragraph("U vstupu vyber ročník. Vlevo zapoj kabely, u čelního terminálu měř provoz a vpravo najdeš DSL, WLAN a GSM.")
	var row := HFlowContainer.new()
	content.add_child(row)
	for grade in [1,2]:
		action(row,"%d. ročník" % grade,func():
			lab.year = grade
			lab.station = -1
			draw(),lab.year==grade)
	for mode in lab.MODES:
		action(row,lab.MODES[mode],func():
			if lab.mode!=mode:
				var year: int = lab.year
				var station: int = lab.station
				lab.cancel()
				lab.year = year
				lab.station = station
				lab.mode = mode
			draw(),lab.mode==mode)
	if not lab.task.is_empty():
		action(content,"Pokračovat · "+lab.task.title,navigate.bind("task"),true)
	var stations := HFlowContainer.new()
	content.add_child(stations)
	action(stations,"Všechna stanoviště",choose_station.bind(-1),lab.station<0)
	for index in lab.catalog.stations.size():
		action(stations,"%02d" % (index+1),choose_station.bind(index),index==lab.station).tooltip_text = lab.catalog.stations[index]
	for index in lab.catalog.stations.size():
		if lab.station>=0 and lab.station!=index: continue
		var tasks: Array = lab.catalog.tasks.filter(func(item): return int(item.year)==lab.year and int(item.station)==index)
		if tasks.is_empty(): continue
		heading("%02d / %s" % [index+1,lab.catalog.stations[index]])
		for task in tasks:
			action(content,task.title,func():
				if lab.task.is_empty() or lab.task.id!=task.id: lab.start(task)
				navigate("task"))
	if lab.station>=0 and not lab.catalog.tasks.any(func(item): return int(item.year)==lab.year and int(item.station)==lab.station):
		paragraph("Úlohy tohoto stanoviště jsou v druhém ročníku. Použij volbu nahoře.")

func choose_station(index: int):
	lab.station = index
	draw()

func draw_task():
	var task: Dictionary = lab.task
	if lab.stale(): paragraph("Ověření je zastaralé. Změnil se stav nebo odpověď.")
	heading("Situace")
	paragraph(task.situation)
	heading("Co vidíš")
	data(task.evidence)
	heading("Tvoje odpověď")
	paragraph(task.prompt)
	if task.kind=="practical":
		data(lab.practical_measurement(task.id))
		if task.id=="cable" or task.id=="journey":
			action(content,"Jít k 3D konektorům",shell.return_to_world)
		elif task.id=="sim":
			action(content,"Jít k telefonům A a B",shell.return_to_world)
		else:
			action(content,"Otevřít nastavení portů",navigate.bind("measure"))
	match task.kind:
		"order": draw_order(task)
		"match": draw_match(task)
		"choice","diagnosis","practical":
			if task.has("answer"): draw_choices(content,task.options,0)
			if task.kind=="diagnosis":
				paragraph("Které pozorování tvůj závěr podporuje?")
				var proofs := HFlowContainer.new()
				content.add_child(proofs)
				draw_choices(proofs,task.proof,1)
	var row := HFlowContainer.new()
	content.add_child(row)
	if lab.mode!="exam":
		var hint := action(row,"Nápověda",func():
			lab.hint()
			draw())
		hint.disabled = lab.hints>0 or lab.credited
		if lab.hints>0: paragraph("Nápověda · "+task.hint)
	if lab.mode=="learn":
		action(row,"Komentovaná ukázka",func():
			lab.start_demo()
			draw(false))


func draw_submit(footer: Node):
	var verify := action(footer,"Odevzdat zkoušku" if lab.mode=="exam" else "Ověřit řešení",func():
		lab.verify()
		navigate("review"),true)
	verify.disabled = lab.locked() or lab.answer.has(-1)
	action(footer,"Resetovat pokus",func():
		lab.restart()
		draw(false))

func draw_review():
	if lab.stale():
		heading("Ověření je zastaralé")
		paragraph("Od posledního ověření se změnil stav nebo odpověď. Vrať se k úloze a ověř aktuální pokus.")
	else:
		heading(("✓ Splněno" if lab.result.passed else "○ Nesplněno")+"    %d / 100" % lab.result.score)
		paragraph(lab.result.reason)
		if lab.result.measurement!="": data(lab.result.measurement)
	draw_sources(lab.task.sources)

func draw_order(task: Dictionary):
	var rows := HFlowContainer.new()
	content.add_child(rows)
	for index in lab.answer.size():
		var title: String = "%d · %s" % [index+1,task.options[lab.answer[index]]]
		action(rows,title,func():
			lab.selected_row = index
			draw(),lab.selected_row==index).disabled = lab.locked()
	var controls := HFlowContainer.new()
	content.add_child(controls)
	for step in [[-1,"↑ Posunout nahoru"],[1,"↓ Posunout dolů"]]:
		var index: int = lab.selected_row+step[0]
		action(controls,step[1],func():
			lab.move_answer(step[0])
			draw()).disabled = lab.locked() or index<0 or index>=lab.answer.size()

func draw_match(task: Dictionary):
	var rows := HFlowContainer.new()
	content.add_child(rows)
	for index in task.rows.size():
		var choice: int = lab.answer[index]
		action(rows,"%s · %s" % [task.rows[index],task.options[choice] if choice>=0 else "—"],func():
			lab.selected_row = index
			draw(),lab.selected_row==index).disabled = lab.locked()
	paragraph("Význam pro „%s“" % task.rows[lab.selected_row])
	draw_choices(content,task.options,lab.selected_row)

func draw_choices(parent: Node, options: Array, group: int):
	for index in options.size():
		var chosen: bool = lab.answer[group]==index
		action(parent,("✓  " if chosen else "")+options[index],func():
			lab.set_answer(group,index)
			draw(),chosen).disabled = lab.locked()

func draw_measurements():
	var model = lab.current_network()
	heading("Topologie a konfigurace PC 04")
	data(model.overview()+"\n\n"+model.configuration())
	if model.last_message!="": data(model.last_message)
	if lab.demo_step>=0 or lab.locked(): return
	if lab.task.is_empty():
		paragraph("Pro změny zapojení a konfigurace nejdřív zahaj úlohu.")
		return
	var tests := HFlowContainer.new()
	content.add_child(tests)
	for test in [["Obnovit DHCP",model.renew],["ARP · tiskárna",func(): model.arp("printer",model.IPS.printer,true)],
		["ARP · vzdálený web",func(): model.arp("router",model.WEB,true)],["Změřit DNS",model.dns_test],
		["Změřit TCP na 443",model.tcp_test],["Otevřít HTTPS",model.web_test]]:
		action(tests,test[0],measure.bind(test[1]))
	heading("Přiřazení portu")
	var ports := HFlowContainer.new()
	content.add_child(ports)
	for port in range(3,9):
		action(ports,"%02d · VLAN %d" % [port,model.vlans[port]],func():
			lab.selected_port = port
			draw(),lab.selected_port==port)
	if lab.selected_port in range(3,9):
		for vlan in [10,20]:
			action(ports,"Nastavit VLAN %d" % vlan,measure.bind(model.set_vlan.bind(lab.selected_port,vlan)))
	heading("Záznam A / "+model.PORTAL)
	var records := HFlowContainer.new()
	content.add_child(records)
	for address in ["",model.WEB,model.IPS.printer]:
		action(records,"Bez záznamu" if address=="" else address,measure.bind(model.set_dns.bind(address)),model.dns_record==address)
	heading("Kabely")
	var connectors := HFlowContainer.new()
	content.add_child(connectors)
	for device in model.CLIENTS:
		action(connectors,"Odpojit · "+model.NAMES[device],measure.bind(model.unplug.bind(device))).disabled = model.ports[device]==0
	heading("Přístupová síť")
	var access := HFlowContainer.new()
	content.add_child(access)
	for measurement in ["DSL","WLAN","IP notebooku","Web přes kabel","RTT"]:
		action(access,measurement,measure.bind(model.access_test.bind(measurement)))
	heading("Telefony / fyzická SIM")
	data(model.comparison())

func measure(operation: Callable):
	operation.call()
	lab.selected_capture = -1
	draw()

func draw_capture():
	var model = lab.current_network()
	heading("Zachycený provoz")
	if lab.selected_capture>=0 and lab.selected_capture<model.capture.size():
		var frame: Dictionary = model.capture[lab.selected_capture]
		heading(frame.title)
		data("Ethernet II    "+frame.frame+"\nIPv4    "+frame.ip+"\nTransport    "+frame.transport+"\nZpráva    "+frame.application)
		paragraph("Na fyzickém spoji se rámec přenáší signálem. V přehledu TCP/IP tvoří Ethernet a médium přístup k síti.")
		action(content,"Zpět k zachyceným rámcům",func():
			lab.selected_capture = -1
			draw(false))
		return
	data(model.tables())
	if model.capture.is_empty(): paragraph("Zatím bez záznamu. Proveď měření, nebo spusť komentovanou ukázku.")
	for index in range(model.capture.size()-1,-1,-1):
		action(content,"%02d    %s" % [index+1,model.capture[index].title],func():
			lab.selected_capture = index
			draw(false))

func draw_sources(keys: Array):
	heading("Studijní materiál")
	for key in keys:
		var source: Dictionary = lab.catalog.chapters[key]
		action(content,"Otevřít Notion · "+source.title,func(): OS.shell_open(source.url))

func draw_study():
	if not lab.task.is_empty(): draw_sources(lab.task.sources)
	for card in lab.catalog.cards:
		if int(card.year)!=lab.year or (lab.station>=0 and int(card.station)!=lab.station): continue
		var source: Dictionary = lab.catalog.chapters[card.source]
		heading(source.title)
		paragraph(card.text)
		action(content,"Otevřít kapitolu v Notionu",func(): OS.shell_open(source.url))
	var root: Dictionary = lab.catalog.chapters["start" if lab.year==1 else "lab"]
	action(content,"Studijní rozcestník · "+root.title,func(): OS.shell_open(root.url))

func draw_results():
	heading("Výsledky síťové laboratoře")
	if lab.attempts.is_empty():
		paragraph("Zatím tu není žádné vyhodnocené cvičení.")
	for index in range(lab.attempts.size()-1,-1,-1):
		var record: Dictionary = lab.attempts[index]
		var title: String = record.id
		for task in lab.catalog.tasks:
			if task.id==record.id:
				title = task.title
				break
		paragraph("%s  /  %s  ·  %s  ·  %d / 100" % [title,lab.MODES[record.mode],"Splněno" if record.passed else "Nesplněno",record.score])
