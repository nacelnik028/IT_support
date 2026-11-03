extends RefCounted

static func draw(ui):
	var v=ui.scroll(ui.center)
	v.add_child(ui.label("SOUVISLÉ SMĚNY / jedna infrastruktura, tři tickety",24,ui.CYAN))
	v.add_child(ui.label("Nová směna odloží kampaň. Nové spuštění nahradí rozpracovanou směnu; historie zůstane. XP jen za zlepšení nejlepšího výsledku, kampaň se neodemyká.",16))
	var shifts=ui.game.shifts
	if not shifts.data.session.is_empty():
		var session=shifts.data.session
		var d=shifts.definition(session.id)
		var c=ui.card(v,d.title,"Dokončeno" if session.finished else "Rozpracováno: ticket %d / 3" % (int(session.index)+1))
		c.add_child(ui.button("Pokračovat ve směně",func():
			if shifts.resume(): ui.navigate("Serverovna")))
		c.add_child(ui.button("Restart směny…",func():
			var dialog=ConfirmationDialog.new(); dialog.dialog_text="Ztratit rozpracovanou práci této směny? Historie a kampaň zůstanou."
			ui.add_child(dialog); dialog.confirmed.connect(func(): shifts.start(session.id); ui.navigate("Serverovna"); dialog.queue_free()); dialog.canceled.connect(dialog.queue_free); dialog.popup_centered()))
		for index in d.tickets.size():
			c.add_child(ui.label(("✓ " if index<session.results.size() else "→ " if index==int(session.index) else "○ ")+d.tickets[index].title,18))
	for d in shifts.catalog:
		var c=ui.card(v,d.title,"3 navazující tickety · nejlepší %d / 100" % int(shifts.data.best.get(d.id,0)))
		c.add_child(ui.button("Zahájit "+d.title,func():
			if shifts.data.session.is_empty() or shifts.data.session.finished:
				shifts.start(d.id); ui.navigate("Serverovna")
			else:
				var dialog=ConfirmationDialog.new(); dialog.dialog_text="Nahradit rozpracovanou směnu novou? Kampaň a historie zůstanou."
				ui.add_child(dialog); dialog.confirmed.connect(func(): shifts.start(d.id); ui.navigate("Serverovna"); dialog.queue_free()); dialog.canceled.connect(dialog.queue_free); dialog.popup_centered()))
	v.add_child(ui.button("Kampaň — obnovit původní ticket",func(): ui.game.resume_campaign(); ui.navigate("Serverovna")))
	for record in shifts.data.history.slice(-6): v.add_child(ui.label("Výsledek / %s: %d / 100" % [record.id,int(record.score)],17))
