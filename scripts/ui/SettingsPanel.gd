extends RefCounted

static func draw(ui):
	var all=ui.vbox(ui.content_box,14)
	all.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var header=ui.hbox(all)
	header.add_child(ui.label("Nastavení",30,ui.CYAN))
	header.add_child(ui.button("← Zpět",ui.close_settings))
	var tabs=ui.hbox(all)
	for title in ["Obraz","Zvuk","Ovládání","Rozhraní"]:
		var b=ui.button(title,func(): ui.settings_tab=title; ui.draw_ui(),ui.settings_tab==title)
		tabs.add_child(b)
		ui.register_target("settings:"+title,b)
	var content=ui.scroll(all)
	var settings=ui.display_settings
	match ui.settings_tab:
		"Obraz":
			var panel=ui.card(content,"Zobrazení","Změnu rozlišení a celé obrazovky potvrď do 15 sekund. Bez potvrzení se vrátí původní obraz.")
			var toggle=CheckButton.new(); toggle.text="Celá obrazovka"; toggle.button_pressed=settings.fullscreen; panel.add_child(toggle)
			ui.settings_controls.fullscreen=toggle
			panel.add_child(ui.label("Rozlišení renderování (počet pixelů, 16:9)",14,ui.MUTED))
			var picker=OptionButton.new()
			for res in ui.Display.RESOLUTIONS: picker.add_item("%d × %d" % [res.x,res.y])
			picker.select(ui.Display.RESOLUTIONS.find(settings.resolution)); panel.add_child(picker)
			ui.settings_controls.resolution=picker
			var apply=ui.button("Použít nastavení",func(): ui.preview_display(ui.Display.RESOLUTIONS[picker.selected],toggle.button_pressed),true)
			panel.add_child(apply); ui.settings_controls.apply=apply
			panel.add_child(ui.label("Velikost textu se nastavuje zvlášť v Rozhraní. F11 přepíná celou obrazovku.",13,ui.MUTED))
			var quality=OptionButton.new()
			for name in ["Úsporná","Vyvážená","Vysoká"]: quality.add_item(name)
			quality.select(["Úsporná","Vyvážená","Vysoká"].find(settings.quality))
			panel.add_child(ui.label("Grafika: stíny, vyhlazování a obrazové efekty",14))
			panel.add_child(quality)
			quality.item_selected.connect(func(i): ui.save_preference("quality",quality.get_item_text(i)))
			var sync=CheckButton.new(); sync.text="VSync"; sync.button_pressed=settings.vsync; panel.add_child(sync)
			sync.toggled.connect(func(on): ui.save_preference("vsync",on))
			var fps=OptionButton.new()
			for limit in [0,30,60,120,144]: fps.add_item("Bez limitu" if limit==0 else str(limit)+" FPS")
			fps.select([0,30,60,120,144].find(settings.fps_limit)); panel.add_child(fps)
			fps.item_selected.connect(func(i): ui.save_preference("fps_limit",[0,30,60,120,144][i]))
		"Zvuk":
			var panel=ui.card(content,"Zvuk","Hlasitost i ztlumení se ukládají pro příští spuštění.")
			var volume=HSlider.new(); volume.min_value=0; volume.max_value=100; volume.step=1; volume.value=settings.volume*100; panel.add_child(volume)
			ui.settings_controls.volume=volume
			volume.drag_ended.connect(func(_changed): ui.save_preference("volume",volume.value/100.0))
			volume.gui_input.connect(func(event):
				if event is InputEventKey and not event.pressed: ui.save_preference("volume",volume.value/100.0))
			var mute=CheckButton.new(); mute.text="Ztlumit zvuk"; mute.button_pressed=settings.muted; panel.add_child(mute)
			mute.toggled.connect(func(on): ui.save_preference("muted",on)); ui.settings_controls.muted=mute
		"Ovládání":
			var panel=ui.card(content,"Myš a klávesy","Escape a F11 jsou vyhrazené. Stejnou klávesu nelze přiřadit dvěma akcím.")
			panel.add_child(ui.label("Citlivost myši",14))
			var sensitivity=HSlider.new(); sensitivity.min_value=0.0005; sensitivity.max_value=0.005; sensitivity.step=0.0001; sensitivity.value=settings.mouse_sensitivity; panel.add_child(sensitivity)
			sensitivity.value_changed.connect(func(value): ui.save_preference("mouse_sensitivity",value))
			ui.settings_controls.sensitivity=sensitivity
			for action in settings.bindings:
				var b=ui.button(settings.KEY_LABELS[action]+": "+OS.get_keycode_string(settings.bindings[action]),func(): ui.capture_binding(action))
				panel.add_child(b); ui.register_target("binding:"+action,b)
			panel.add_child(ui.button("Obnovit výchozí klávesy",func(): ui.save_preference("bindings",ui.Display.DEFAULT_KEYS.duplicate()); ui.draw_ui()))
		"Rozhraní":
			var panel=ui.card(content,"Velikost textu","Písmo se rasterizuje v cílovém rozlišení. Zvětšení textu nemění rozlišení renderování.")
			var picker=OptionButton.new()
			for size in [100,115,130]: picker.add_item(str(size)+" %")
			picker.select([1.0,1.15,1.3].find(settings.text_scale)); panel.add_child(picker)
			picker.item_selected.connect(func(i): ui.save_preference("text_scale",[1.0,1.15,1.3][i]); ui.draw_ui())
			ui.settings_controls.text_scale=picker
	if ui.notice!="": content.add_child(ui.label(ui.notice,14,ui.ORANGE if ui.bad_notice else ui.CYAN))
