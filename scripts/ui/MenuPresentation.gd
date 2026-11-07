extends RefCounted

static func draw(ui):
	ui.root_box.add_theme_constant_override("margin_bottom",24)
	ui.root_box.add_theme_constant_override("margin_right",24)
	var all=ui.vbox(ui.content_box,16); all.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var header=ui.hbox(all,14)
	var emblem=TextureRect.new(); emblem.texture=load("res://assets/icons/academy.svg"); emblem.custom_minimum_size=Vector2(40,40); emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; emblem.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; header.add_child(emblem)
	var identity=ui.vbox(header,2); identity.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	identity.add_child(ui.label("TRAINING ACADEMY",30))
	identity.add_child(ui.label("NORTHSTAR IT  /  UČ SE VLASTNÍM TEMPEM",12,ui.CYAN))
	var body=ui.hbox(all,20); body.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var continuation=preload("res://scripts/ui/ContinuationPresentation.gd")
	var work=continuation.available(ui.game)
	var left=ui.card(body,"Tvoje další práce","Vrať se k rozpracované činnosti, nebo začni v některé učebně.")
	var resume=ui.button("Pokračovat v rozehrané práci"+("  (%d)" % work.size() if work.size()>1 else ""),func(): ui.navigate("Pokračování"),true)
	resume.disabled=work.is_empty(); left.add_child(resume); ui.register_target("menu:resume",resume)
	left.add_child(ui.label("Žádná rozpracovaná činnost. Vyber učebnu nebo praktický úvod." if work.is_empty() else (work[0].title+"\n"+work[0].status if work.size()==1 else "%d činností · nejdřív si vybereš, ke které se vrátit." % work.size()),16,ui.MUTED))
	if ui.world_enabled:
		var fresh=not ui.display_settings.introduction_seen and not continuation.has_history(ui.game)
		var intro=ui.card(left,"Poprvé v akademii?" if fresh else "Ovládání a praktický úvod","Dojdi k pracovišti → zaměř zařízení → otevři → proveď zásah → ověř.")
		var start=ui.button("Začít praktickým úvodem",func(): ui.shell_ref.get_ref().practical_intro.start(),fresh)
		intro.add_child(start); ui.register_target("menu:intro",start)
		if fresh:
			var skip=ui.button("Přeskočit úvod",func(): ui.save_preference("introduction_seen",true); ui.draw_ui())
			intro.add_child(skip); ui.register_target("menu:skip_intro",skip)
		intro.add_child(ui.label("Dobrovolné · 3–5 minut · kdykoliv bezpečně ukončíš",13,ui.MUTED))
	var right=ui.card(body,"Vybrat učebnu","Pět oblastí. Konkrétní úlohu a režim vybereš uvnitř.")
	var primary=ui.button("Vybrat učebnu / rozcestník",func():
		if ui.world_enabled:
			if not OS.has_feature("android"): ui.play_mode_requested.emit("desktop")
			ui.world_requested.emit("Rozcestník akademie")
		else: ui.navigate("Tickety"),true)
	right.add_child(primary); ui.register_target("menu:primary",primary)
	for item in [["01 / Serverovna a pracovní úlohy","Hlavní serverovna","tickets","8acfe9"],["02 / IT trénink","Trénink","training","efca8b"],["03 / Programování","Programming Academy","programming","76dfc7"],["04 / Angličtina v Londýně","English in London","english","e9a18b"],["05 / Počítačové sítě","Počítačové sítě","network_lab","43dad0"]]:
		var entry=ui.button(item[0],func():
			if ui.world_enabled: ui.world_requested.emit(item[1])
			else: ui.navigate("Trénink" if item[2]=="training" else "Tickety"))
		entry.add_theme_color_override("font_color",Color(item[3])); right.add_child(entry); ui.register_target("menu:"+item[2],entry)
	var footer=ui.hbox(all,10)
	var spacer=Control.new(); spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL; footer.add_child(spacer)
	if ui.world_enabled and not OS.has_feature("android"):
		var vr=ui.button("Spustit ve VR",func(): ui.play_mode_requested.emit("vr")); footer.add_child(vr); ui.register_target("menu:vr",vr)
	for item in [["Moje znalosti",func(): ui.navigate("Moje znalosti"),"knowledge"],["Studijní materiály",func(): ui.navigate("Akademie"),"study"],["Nastavení",ui.open_settings,"settings"],["Ukončit hru",ui.quit_game,"quit"]]:
		var b=ui.button(item[0],item[1]); footer.add_child(b); ui.register_target("menu:"+item[2],b)
	var credit=ui.label("Vytvořil Vít Kellner",14,ui.MUTED); credit.name="AuthorCredit"; credit.autowrap_mode=TextServer.AUTOWRAP_OFF; credit.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT; credit.mouse_filter=Control.MOUSE_FILTER_IGNORE; credit.focus_mode=Control.FOCUS_NONE; all.add_child(credit)