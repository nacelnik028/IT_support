extends RefCounted

static func audio(ui):
	var listening=ui.manager.listening
	var id=listening.session.id
	var row=HFlowContainer.new(); ui.content.add_child(row)
	for entry in [["Poslechnout / zopakovat",false],["Pomaleji / zaznamená pomoc",true]]:
		var button=ui.shell.ui.button(entry[0],func(): ui.shell.speech.listen(id,entry[1]))
		button.custom_minimum_size.y=48; row.add_child(button); ui.buttons.append(button)
	var stop=ui.shell.ui.button("Zastavit",ui.shell.speech.stop); row.add_child(stop); ui.buttons.append(stop)

static func draw(ui):
	var listening=ui.manager.listening
	if ui.page=="listening_home":
		ui.label_text("Poslechové procvičování / 12 samostatných úloh",27)
		ui.label_text("Přehraj celou repliku, vyber význam a porovnej vysvětlení. Přepis je skrytý; v Učím se a Procvičování ho lze vyžádat. Zkouška přepis nepovolí. Pomalá nahrávka, přepis i ztlumený zvuk se zaznamenají jako pomoc. Opakování normálního audia je povolené. Výsledky nejsou CEFR certifikát a nepřidávají XP.",19)
		var row=HBoxContainer.new(); ui.content.add_child(row)
		for mode in ["learn","practice","exam"]:
			var button=ui.shell.ui.button(("✓ " if ui.selected_mode==mode else "")+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}[mode],func(): ui.selected_mode=mode; ui.draw())
			row.add_child(button); ui.buttons.append(button)
		if not listening.progress.pending.is_empty():
			ui.action("Obnovit nedokončený poslech / "+listening.progress.pending.id+" / "+listening.progress.pending.mode,func():
				if listening.resume(): ui.page="listening"; ui.draw())
		if ui.recommendation.get("area")=="listening":
			ui.action("Nová doporučená úloha / "+ui.recommendation.id,func():
				if listening.start(ui.recommendation.id,ui.selected_mode): ui.page="listening"; ui.draw())
		ui.label_text("Nová úloha nahradí nedokončený poslech. Původní nákup a neodevzdaný kvíz zůstanou zachované.",17)
		for task in listening.catalog.tasks:
			var record=listening.progress.results.get(task.id,{})
			ui.action(task.id+" / Nová úloha porozumění"+(" · nejlepší "+str(int(record.best))+" / 100" if not record.is_empty() else " · Nezkoušeno"),func():
				if listening.start(task.id,ui.selected_mode): ui.page="listening"; ui.draw())
		ui.action("Uložené poslechové výsledky",func(): ui.page="listening_progress"; ui.draw())
		return
	if ui.page=="listening_progress":
		ui.label_text("Vlastní výsledky poslechu / oddělené od dialogu a kvízu",25)
		for task in listening.catalog.tasks:
			var result=listening.progress.results.get(task.id,{})
			ui.label_text(task.id+" / "+("Nezkoušeno" if result.is_empty() else "Doloženo bez pomoci" if result.unassisted else "Dokončeno s pomocí" if result.helped else "Procvičeno")+(" · nejlepší %d / 100 · pokusů %d" % [int(result.best),int(result.attempts)] if not result.is_empty() else ""),20)
		for attempt in listening.progress.attempts.slice(-8): ui.label_text("Poslední / %s · %s · %d bodů · %s · %s" % [attempt.id,attempt.mode,int(attempt.score),"s pomocí" if attempt.assisted else "bez přepisu/pomalé varianty/ztlumení",Time.get_datetime_string_from_unix_time(int(attempt.time))],17)
		ui.action("Vybrat poslech",func(): ui.page="listening_home"; ui.draw()); return
	if listening.session.is_empty(): ui.page="listening_home"; draw(ui); return
	var session=listening.session
	var task=listening.definition()
	ui.selected_mode=session.mode
	ui.label_text("Poslech / "+task.id,26)
	ui.label_text(task.prompt,25)
	ui.label_text("Pravidla: "+("zkouška bez přepisu; pomalá varianta je pomoc" if session.mode=="exam" else "přepis jen na vyžádání, použitá pomoc se zaznamená")+". Poslech nemění nákup ani kvíz.",17)
	audio(ui)
	var line={}
	for candidate in ui.shell.speech.mapping.lines:
		if candidate.id==task.clip: line=candidate; break
	if session.completed:
		var record=listening.progress.attempts.back()
		var selected=""
		for option in task.options:
			if option.id==session.answer: selected=option.text
		ui.label_text(("Správně. " if session.answer==task.answer else "Tuto repliku ještě procvič. ")+"Tvoje odpověď: "+selected,23)
		ui.label_text(task.explanation+"\nPřesná replika: "+line.text,20)
		ui.label_text("Výsledek: %d / 100 · %s · přehrání %d. Pomoc: přepis %s, pomalá %s, ztlumení %s, bez dokončeného audia %s. XP 0." % [int(record.score),"s pomocí" if record.assisted else "bez zaznamenané pomoci",int(record.plays),("ano" if record.aids.transcript else "ne"),("ano" if record.aids.slow else "ne"),("ano" if record.aids.muted else "ne"),("ano" if record.aids.no_audio else "ne")],18)
		ui.action("Vybrat další poslech",func(): ui.page="listening_home"; ui.draw(),true)
		return
	if session.transcript: ui.label_text("Přepis / použitá pomoc: "+line.text,21)
	elif session.transcript_allowed: ui.action("Zobrazit přepis / zaznamená pomoc",func(): listening.transcript(listening.revision); ui.draw())
	if not ui.shell.speech.audible(): ui.label_text("Zvuk je ztlumený nebo má nulovou hlasitost. Dokončení je přístupné; nebude označené jako doložený poslech bez pomoci.",18)
	var token=listening.revision
	for option in listening.choices():
		ui.actions.append(option.id)
		ui.action("%d  %s" % [ui.actions.size(),option.text],func(): ui.listening_choose(option.id,token))
	if ui.shell.ui.display_settings.london_autoplay and not session.auto_played:
		session.auto_played=true; listening.checkpoint()
		ui.call_deferred("listening_autoplay",task.id,token)
