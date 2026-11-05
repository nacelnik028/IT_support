extends RefCounted

static func section(ui, parent, title: String) -> VBoxContainer:
	var panel=PanelContainer.new(); parent.add_child(panel)
	panel.add_theme_stylebox_override("panel",preload("res://scripts/ui/AcademyTheme.gd").surface())
	var box=VBoxContainer.new(); box.add_theme_constant_override("separation",10); panel.add_child(box)
	box.add_child(ui.shell.ui.label(title,18,Color("77deca")))
	return box

static func draw(ui):
	var m=ui.manager; var s=m.session
	if s.is_empty(): ui.page="home"; ui.draw_home(); return
	ui.selected_mode=s.mode
	if s.completed or ui.show_assessment or s.get("exam_ended",false):
		result(ui); return
	var row=HBoxContainer.new(); row.size_flags_vertical=Control.SIZE_EXPAND_FILL; row.add_theme_constant_override("separation",18); ui.content.add_child(row)
	var side_scroll=ScrollContainer.new(); side_scroll.custom_minimum_size.x=350; side_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; side_scroll.follow_focus=true; row.add_child(side_scroll)
	var side=VBoxContainer.new(); side.custom_minimum_size.x=330; side.size_flags_horizontal=Control.SIZE_EXPAND_FILL; side_scroll.add_child(side)
	var task=section(ui,side,"Tvůj úkol")
	var g=s.goal
	if s.id=="LON06": task.add_child(ui.shell.ui.label("Upřesni trasu u Alexe. Přejdi most a potvrď příchod u věže.",18))
	else:
		task.add_child(ui.shell.ui.label("%d adult + %d child · %s\n%s · rozmezí %s–%s\nRozpočet %s" % [int(g.adult),int(g.child),g.product,g.time,g.earliest,g.latest,m.money(int(g.budget))],18))
	var full=ui.shell.ui.label(m.task(),17); full.visible=ui.task_details
	var expand=ui.shell.ui.button("Celé zadání / podmínky",func(): ui.task_details=not ui.task_details; full.visible=ui.task_details)
	task.add_child(expand); ui.buttons.append(expand); task.add_child(full)
	if s.id!="LON06":
		var basket=section(ui,side,"Objednávka" if s.ticket.is_empty() else "Objednávka / peněženka")
		basket.add_child(ui.shell.ui.label("%d adult + %d child · %s\n%s · %s\n%s" % [int(s.cart.adult),int(s.cart.child),s.cart.product,s.cart.time if s.cart.time!="" else "Čas nevybrán",m.money(m.total()),"ZAPLACENO" if s.paid else "POTVRZENO" if s.confirmed else "NEPOTVRZENO"],17))
		if not s.ticket.is_empty(): basket.add_child(ui.shell.ui.label("Lístek %s\n%s · %s" % [s.ticket.id,m.money(int(s.ticket.pence)),"POUŽITÝ" if s.ticket.used else "PLATNÝ"],16))
	var goalbox=section(ui,side,"Podmínky dokončení" if s.mode=="exam" else "Postup a cíle")
	for goal in m.goal_status():
		goalbox.add_child(ui.shell.ui.label(("• " if s.mode=="exam" else "✓ " if goal.met else "○ ")+goal.label,16))
	var main_scroll=ScrollContainer.new(); main_scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL; main_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; main_scroll.follow_focus=true; row.add_child(main_scroll)
	var main=VBoxContainer.new(); main.size_flags_horizontal=Control.SIZE_EXPAND_FILL; main.add_theme_constant_override("separation",12); main_scroll.add_child(main)
	var npc=section(ui,main,"Alex / INFORMATION" if s.id=="LON06" else "Sam / TICKETS")
	npc.add_child(ui.shell.ui.label(s.npc,23))
	var old=ui.content; ui.content=npc
	ui.audio_controls(s.npc,"Alex" if s.id=="LON06" else "Sam")
	if ui.shell.ui.display_settings.london_autoplay and not ui.shell.speech.find_line(s.npc,"Alex" if s.id=="LON06" else "Sam").is_empty(): ui.shell.speech.speak(s.npc,"Alex" if s.id=="LON06" else "Sam")
	if ui.show_translation and s.mode!="exam": task.add_child(ui.shell.ui.label("Překlad NPC: "+s.translation,18,Color("f3d598")))
	var feedback=m.visible_feedback()
	if feedback!="": main.add_child(ui.shell.ui.label(feedback,18,Color("f3d598")))
	var replies=section(ui,main,"Tvoje odpověď")
	replies.name="PlayerReplies"; ui.content=replies
	var token=m.revision
	var near=ui.shell.world.english_room.near("info" if s.id=="LON06" else "tickets")
	if s.node=="pay":
		if ui.station=="terminal" and ui.shell.world.english_room.near("terminal"):
			ui.action("Přiložit CVIČNOU KARTU — zaplatit "+m.money(m.total()),func(): m.pay(token); ui.draw(),true)
		else: navigate(ui,"terminal","Ukázat cestu k terminálu")
	elif s.node=="gate":
		if ui.station=="gate" and ui.shell.world.english_room.near("gate"):
			ui.action("Předložit vstupenku z peněženky",func():
				if not m.present_ticket(): m.review_attempt(); ui.show_assessment=true
				ui.draw(),true)
		else: navigate(ui,"gate","Ukázat cestu ke kontrole")
	elif s.node=="walk": navigate(ui,"tower","Ukázat cestu k věži přes most")
	var options=m.choices()
	if not near and not s.node in ["pay","gate","walk"]:
		options=[]; navigate(ui,"info" if s.id=="LON06" else "tickets","Ukázat cestu k Alexovi" if s.id=="LON06" else "Ukázat cestu k Samovi")
	for option in options:
		ui.actions.append(option.id)
		var b=ui.action("%d  %s" % [ui.actions.size(),option.text],func(): ui.choose(option.id,token))
		b.theme_type_variation="ReplyButton"
	var help=section(ui,main,"Pomoc a další kroky"); ui.content=help
	if not s.paid and not s.node in ["walk","gate"] and near:
		ui.action("Zpět k objednávce" if s.node in ["questions","answer"] else "Zeptat se na nabídku…" if s.id!="LON06" else "Požádat o zopakování…",func():
			if s.node in ["questions","answer"]: s.node=s.return_node; m.revision+=1
			else: m.open_questions(token,2 if s.id=="LON06" else 0)
			ui.draw())
	if s.mode!="exam":
		var aids=HBoxContainer.new(); help.add_child(aids)
		for item in [["Překlad",ui.toggle_translation],["Nápověda",ui.request_hint]]:
			var b=ui.shell.ui.button(item[0],item[1]); aids.add_child(b); ui.buttons.append(b)
		if ui.help_text!="": task.add_child(ui.shell.ui.label("Nápověda: "+ui.help_text,17,Color("f3d598")))
	var recordings=options.filter(func(option): return not ui.shell.speech.find_line(option.text,"customer").is_empty())
	if not recordings.is_empty():
		help.add_child(ui.shell.ui.label("Poslech hráčovy repliky (výběr zde neodesílá odpověď)",16))
		var select=OptionButton.new(); select.custom_minimum_size.x=180; help.add_child(select); ui.buttons.append(select)
		for i in recordings.size(): select.add_item("Replika "+str(ui.actions.find(recordings[i].id)+1))
		var audio=HFlowContainer.new(); help.add_child(audio)
		for item in [["Přehrát repliku",false],["Repliku pomaleji",true]]:
			var b=ui.shell.ui.button(item[0],func(): ui.shell.speech.speak(recordings[select.selected].text,"customer",item[1])); audio.add_child(b); ui.buttons.append(b)
		var stop=ui.shell.ui.button("Zastavit repliku",ui.shell.speech.stop_speech); audio.add_child(stop); ui.buttons.append(stop)
	ui.content=old

static func navigate(ui, destination: String, caption: String):
	ui.action(caption,func(): ui.shell.london_navigation.start(destination),true)

static func result(ui):
	var m=ui.manager; var s=m.session
	if not s.completed and not s.get("exam_ended",false): ui.action("Pokračovat ve stejné situaci",func(): ui.show_assessment=false; ui.draw(),true)
	ui.action("Opakovat situaci",func():
		var id=s.id; var mode=s.mode; var variant=s.variant
		m.cancel(); m.start(id,mode,variant); ui.show_assessment=false; ui.help_text=""; ui.show_translation=false; ui.draw())
	ui.action("Vybrat další situaci",func(): ui.page="home"; ui.show_assessment=false; ui.draw())
	for goal in m.goal_status(): ui.label_text(("✓ " if goal.met else "○ Nesplněno: ")+goal.label,18)
	var mistakes=[]
	for error in s.errors:
		var text=("Jazykově vhodné, věcná chyba: " if error.language_ok else "Jazyková chyba: ")+error.text
		if not text in mistakes: mistakes.append(text)
	ui.label_text("Chyby: žádné." if mistakes.is_empty() else "Podstatné chyby:\n"+"\n".join(mistakes),18)
	ui.label_text(m.definition().explanation,18)
	ui.label_text("Užitečné formulace:\n"+"\n".join(s.phrases.slice(0,4)),18)
