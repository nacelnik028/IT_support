extends RefCounted

static func draw(ui):
	var v=ui.scroll(ui.center)
	v.get_parent().follow_focus=true
	v.add_child(ui.label("SOUVISLÉ SMĚNY / společná infrastruktura a priority",24,ui.CYAN))
	v.add_child(ui.label("Nová směna odloží kampaň. Nové spuštění nahradí rozpracovanou směnu; historie zůstane. XP jen za zlepšení nejlepšího výsledku, kampaň se neodemyká.",16))
	var shifts=ui.game.shifts
	if not shifts.data.session.is_empty():
		var session=shifts.data.session
		var d=shifts.definition(session.id)
		var c=ui.card(v,d.title,"Dokončeno" if session.finished else "Rozpracováno: ticket %d / %d" % [int(session.index)+1,d.tickets.size()])
		c.add_child(ui.button("Pokračovat ve směně",func():
			if shifts.resume(): ui.navigate("Serverovna")))
		c.add_child(ui.button("Restart směny…",func():
			var dialog=ConfirmationDialog.new(); dialog.dialog_text="Ztratit rozpracovanou práci této směny? Historie a kampaň zůstanou."
			ui.add_child(dialog); dialog.confirmed.connect(func(): shifts.start(session.id); ui.navigate("Serverovna"); dialog.queue_free()); dialog.canceled.connect(dialog.queue_free); dialog.popup_centered()))
		for index in d.tickets.size():
			var ticket=d.tickets[index]
			var closed=shifts.completed_ticket(index)
			c.add_child(ui.label(("✓ Předáno / " if closed else "→ Vybráno / " if index==int(session.index) else "○ Otevřeno / ")+ticket.get("priority","")+" "+ticket.title,18))
			if d.get("advanced",false):
				c.add_child(ui.label(ticket.impact,15))
				var blockers=[]
				for id in ticket.depends:
					for other in d.tickets:
						if other.id==id and not ui.game.Evaluator.evaluate(session.state,other.objectives).all(func(goal): return goal.passed): blockers.append(other.title)
				c.add_child(ui.label("Závislost: "+(", ".join(blockers) if not blockers.is_empty() else "podmínky připravené / ověř vlastní cíle"),13,ui.MUTED))
				if not closed and not session.finished:
					var revision=ui.game.session_revision
					c.add_child(ui.button("Vybrat incident / "+ticket.id,func():
						if shifts.resume() and shifts.select_ticket(index,revision): ui.context_open=true; ui.draw_ui()))
		if d.get("advanced",false):
			var runtime=session.state.shift_runtime
			c.add_child(ui.label("Simulovaný čas %d min · výpadek alespoň jedné služby %d min. Čas běží pouze výslovným tlačítkem; pořadí oprav je volné." % [int(runtime.clock),int(runtime.outage_minutes)],15))
			if not session.finished: c.add_child(ui.button("Posunout simulovaný čas o 1 minutu",func(): ui.game.apply("shift_wait",{"minutes":1}); ui.draw_ui()))
			for event in runtime.events: c.add_child(ui.label("Plánovaný incident: "+event.id+" / revize "+str(int(event.revision)),14,ui.ORANGE))
	for d in shifts.catalog:
		var c=ui.card(v,d.title,"%d ticketů%s · nejlepší %d / 100" % [d.tickets.size()," / současné incidenty" if d.get("advanced",false) else " / navazující",int(shifts.data.best.get(d.id,0))])
		c.add_child(ui.button("Zahájit "+d.title,func():
			if shifts.data.session.is_empty() or shifts.data.session.finished:
				shifts.start(d.id); ui.navigate("Serverovna")
			else:
				var dialog=ConfirmationDialog.new(); dialog.dialog_text="Nahradit rozpracovanou směnu novou? Kampaň a historie zůstanou."
				ui.add_child(dialog); dialog.confirmed.connect(func(): shifts.start(d.id); ui.navigate("Serverovna"); dialog.queue_free()); dialog.canceled.connect(dialog.queue_free); dialog.popup_centered()))
	v.add_child(ui.button("Kampaň — obnovit původní ticket",func(): ui.game.resume_campaign(); ui.navigate("Serverovna")))
	for record in shifts.data.history.slice(-6):
		v.add_child(ui.button("Rozpis hodnocení / %s: %d / 100" % [record.id,int(record.score)],func():
			var lines=["Směna / %s: %d / 100" % [record.id,int(record.score)]]
			for result in record.results:
				lines.append("Ticket %d" % (int(result.ticket)+1))
				lines.append(shifts.Scoring.describe(result.breakdown,int(record.get("xp",0)) if result==record.results.back() else 0) if result.has("breakdown") else "Historické skóre: %d / 100. Rozpis penalizací nebyl zaznamenán." % int(result.score))
			ui.show_message("Uložené hodnocení směny","\n\n".join(lines))))
