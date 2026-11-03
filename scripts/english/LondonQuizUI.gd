extends RefCounted

static func draw(ui):
	var quiz=ui.manager.quiz
	if ui.page=="quiz_home":
		ui.label_text("Otázky na Londýn / B1–B2",28)
		ui.label_text("Památky, Temže, doprava a kultura. Vysvětlení s ověřenými zdroji fungují offline. Hodnotíme čtení a znalosti. První odpověď určuje skóre; v Učím se lze chybu opravit.",20)
		var row=HBoxContainer.new(); ui.content.add_child(row)
		for mode in ["learn","practice","exam"]:
			var button=ui.shell.ui.button(("✓ " if ui.selected_mode==mode else "")+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}[mode],func(): ui.selected_mode=mode; ui.draw())
			row.add_child(button); ui.buttons.append(button)
		if ui.recommendation.get("area")=="quiz":
			ui.action("Nová doporučená otázka / "+ui.recommendation.id,func():
				if quiz.start_question(ui.recommendation.id,ui.selected_mode): ui.page="quiz"; ui.draw())
		for count in [20,5]:
			ui.action("Spustit %d otázek" % count,func():
				ui.manager.session.clear(); quiz.start(ui.selected_mode,count)
				ui.page="quiz"; ui.show_translation=false; ui.draw(),count==20)
		ui.action("Uložené výsledky kvízu",func(): ui.page="quiz_progress"; ui.draw())
		if not quiz.session.is_empty(): ui.action("Pokračovat v kvízu",func(): ui.page="quiz"; ui.draw())
		return
	if ui.page=="quiz_progress":
		ui.label_text("Procvičeno %d / 20 • nejlepší série %d / 100" % [quiz.progress.results.size(),int(quiz.progress.best)],25)
		for q in quiz.catalog.questions:
			var r=quiz.progress.results.get(q.id,{})
			ui.label_text(q.id+" / "+q.prompt+"\n"+("%d bodů • %d pokusů%s" % [int(r.best),int(r.attempts)," • opraveno" if r.corrected else ""] if not r.is_empty() else "Zatím neprocvičeno"),19)
		ui.action("Znovu vybrat kvíz",func(): ui.page="quiz_home"; ui.draw())
		return
	var s=quiz.session
	if s.is_empty(): ui.page="quiz_home"; draw(ui); return
	ui.selected_mode=s.mode
	if s.completed:
		ui.label_text("Dokončeno • %d / 100" % int(s.score),28)
		ui.label_text("Skóre vychází z prvních odpovědí. Opravy jsou zaznamenané. Výsledek není jazykový certifikát.",19)
		for a in s.answers:
			var q=quiz.definition(a.id)
			var selected=""
			for o in q.options:
				if o.id==a.selected: selected=o.text
			ui.label_text(("✓ " if a.correct else "✗ ")+q.id+" / "+q.prompt+"\nTvoje odpověď: "+selected+(" • opraveno" if a.corrected else "")+"\n"+q.explanation+"\n"+q.explanation_cs+"\nZdroj: "+q.source,19)
		ui.action("Opakovat kvíz",func(): ui.page="quiz_home"; ui.draw(),true)
		return
	var q=quiz.definition()
	ui.label_text("Otázka %d / %d • %s" % [int(s.position)+1,s.queue.size(),q.id],20)
	ui.label_text(q.prompt,26)
	if ui.show_translation and s.mode!="exam": ui.label_text(quiz.help(),20)
	var token=quiz.revision
	if s.current.is_empty() or (s.mode=="learn" and not s.current.correct and not s.current.corrected):
		for o in quiz.choices():
			ui.actions.append(o.id)
			ui.action("%d  %s" % [ui.actions.size(),o.text],func(): ui.quiz_choose(o.id,token))
	if not s.current.is_empty():
		if s.mode!="exam":
			ui.label_text(("Správně. " if s.current.correct else "První odpověď byla chybná. ")+q.explanation+"\n"+q.explanation_cs+"\nZdroj: "+q.source,19)
			if s.current.corrected: ui.label_text("✓ Oprava zaznamenána; první odpověď určuje skóre.",19)
		else: ui.label_text("Odpověď zaznamenána. Vyhodnocení bude na konci.",19)
		ui.action("Odevzdat sérii" if s.position+1==s.queue.size() else "Další otázka",func(): quiz.next(token); ui.show_translation=false; ui.draw(),true)
	if s.mode!="exam": ui.action("Skrýt překlad" if ui.show_translation else "Český překlad na vyžádání",func(): ui.show_translation=not ui.show_translation; ui.draw())
