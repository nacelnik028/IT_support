extends RefCounted

static func add(ui, parent, title: String, callback: Callable, primary: bool = false):
	var button=ui.button(title,callback,primary); button.custom_minimum_size.y=52
	parent.add_child(button); return button

static func draw(shell, page: String = "main"):
	shell.set_mode("pause")
	for child in shell.overlay.get_children(): shell.overlay.remove_child(child); child.queue_free()
	var shade=ColorRect.new(); shade.color=Color(0.015,0.025,0.045,0.88); shell.overlay.add_child(shade); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center=CenterContainer.new(); shell.overlay.add_child(center); center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel=PanelContainer.new(); panel.name="CompactPause"; panel.custom_minimum_size.x=560; panel.add_theme_stylebox_override("panel",shell.ui.box(Color("14232d"),Color("3b5865"),24)); center.add_child(panel)
	var v=VBoxContainer.new(); v.add_theme_constant_override("separation",10); panel.add_child(v)
	var ui=shell.ui
	v.add_child(ui.label({"main":"Pauza","destinations":"Kam jít","help":"Ovládání a nápověda","work":"Tickety a směny"}.get(page,"Pauza"),28,ui.CYAN))
	if page=="destinations":
		for item in [["Rozcestník akademie","Rozcestník akademie"],["Serverovna","Hlavní serverovna"],["IT trénink","Trénink"],["Programování","Programming Academy"],["English in London","English in London"]]:
			add(ui,v,item[0],func(): shell.enter_world(item[1]))
		add(ui,v,"Tickety a směny",shell.pause_work)
		add(ui,v,"Zpět do pauzy",shell.pause_menu)
	elif page=="work":
		add(ui,v,"Tickety a mise",func(): shell.open_app("Tickety"))
		add(ui,v,"Souvislé směny",func(): shell.enter_world("Hlavní serverovna"); shell.open_app("Souvislé směny"))
		add(ui,v,"Zpět",shell.pause_destinations)
	elif page=="help":
		var text=ui.label("WASD: chůze · myš: pohled\nE: interakce · Tab: aktuální úkol\nF: baterka · Esc: návrat / pauza\n\nVR: levý joystick / teleport, pravý otáčení.\nTrigger: interakce · B/Y: zpět · A/X: panel.",17)
		text.custom_minimum_size.x=500; v.add_child(text)
		add(ui,v,"Praktické seznámení s ovládáním",shell.show_introduction,true)
		add(ui,v,"Zpět do nastavení",shell.return_from_utility)
	else:
		add(ui,v,"Pokračovat",shell.return_to_world,true)
		add(ui,v,"Kam jít",shell.pause_destinations)
		add(ui,v,"Moje znalosti",func(): shell.open_app("Moje znalosti"))
		add(ui,v,"Nastavení",func(): shell.settings_from_pause=true; shell.open_app("Nastavení"))
		if ui.game.active or not ui.game.english.session.is_empty() or not ui.game.programming.current.is_empty(): add(ui,v,"Aktuální úkol",shell.open_current_task)
		if shell.vr_active: add(ui,v,"Komfort VR",shell.show_vr_settings)
		if ui.game.unsaved:
			v.add_child(ui.label(ui.game.save_message,16,ui.ORANGE))
			add(ui,v,"Zkusit uložit znovu",func(): ui.game.save(); shell.pause_menu())
		add(ui,v,"Uložit a hlavní menu",func():
			if ui.game.save()==OK: ui.page="menu"; ui.draw_ui(); shell.set_mode("menu")
			else: shell.pause_menu())
	var first=v.find_children("*","Button",true,false)
	if not first.is_empty(): first[0].grab_focus()
