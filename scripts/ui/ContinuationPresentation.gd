extends RefCounted

const MODES={"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}

# Pure inspection: opening a menu never checkpoints, resumes or starts work.
static func available(game) -> Array:
	var entries=[]
	var campaign=game.snapshot() if game.active and game.session_kind=="campaign" else game.suspended_campaign
	if not campaign.is_empty() and not campaign.finished:
		entries.append({"kind":"campaign","title":"Kampaň / "+game.missions[int(campaign.id)-1].title,"status":"Ticket %02d · %d záznamů zásahů" % [int(campaign.id),campaign.state.journal.size()]})
	var shift=game.shifts.data.session
	if not shift.is_empty() and not shift.finished:
		var definition=game.shifts.definition(shift.id)
		entries.append({"kind":"shift","title":"Směna / "+definition.title,"status":"Ticket %d z %d · %s" % [int(shift.index)+1,definition.tickets.size(),definition.tickets[int(shift.index)].title]})
	for key in game.work.data.lessons:
		var saved=game.work.data.lessons[key].snapshot
		if saved.finished: continue
		var definition=game.Saves.rules().lesson_by_id(int(saved.id))
		entries.append({"kind":"lesson","key":key,"id":int(saved.id),"mode":saved.tutorial.mode,"title":"IT výuka / "+definition.title,"status":"%s · krok %d · chyby %d" % [MODES[saved.tutorial.mode],int(saved.tutorial.step)+1,int(saved.state.errors)]})
	for key in game.programming.progress.drafts:
		var draft=game.programming.progress.drafts[key]
		var definition=game.programming.drafts.task(draft)
		entries.append({"kind":"code","key":key,"title":"Programování / "+draft.id+" · "+definition.title,"status":MODES[draft.mode]+" · "+draft.active+(" · série %d/%d" % [int(draft.position)+1,int(draft.series.count)] if not draft.series.is_empty() else "")})
	return entries

static func has_history(game) -> bool:
	return game.last_saved_at>0 or not available(game).is_empty() or game.progress.xp>0 or not game.progress.scores.is_empty() or not game.education.lessons.is_empty() or not game.english.progress.results.is_empty()

static func resume(ui, entry: Dictionary):
	# Only the explicitly chosen row may restore a session. Room transitions use
	# the existing suspension mechanism; code restore never runs or evaluates it.
	match entry.kind:
		"campaign", "shift":
			if ui.world_enabled: ui.world_requested.emit("Hlavní serverovna")
			if entry.kind=="campaign": ui.game.resume_campaign()
			elif not ui.game.shifts.resume(): return
			if ui.world_enabled: ui.shell_ref.get_ref().enter_world(); ui.shell_ref.get_ref().show_tasks()
			else: ui.page="Tickety"; ui.draw_ui()
		"lesson":
			if ui.world_enabled: ui.world_requested.emit("Trénink")
			else: ui.game.enter_training()
			if ui.game.resume_lesson(entry.id,entry.mode):
				ui.host=ui.game.current.server; ui.page=ui.game.tutorial.session.get("page",ui.game.current.category); ui.draw_ui(); ui.lesson_launched.emit()
			else: ui.show_message("Obnovení odmítnuto","Výukový snímek již není dostupný. Uložená práce zůstala zachovaná.")
		"code":
			if not ui.world_enabled: return
			ui.world_requested.emit("Programming Academy")
			if ui.game.programming.restore_draft(entry.key): ui.shell_ref.get_ref().open_programming(ui.game.programming.current.category)
			else: ui.show_message("Obnovení odmítnuto","Koncept již není dostupný. Uložená práce zůstala zachovaná.")

static func draw(ui):
	var view=ui.scroll(ui.center); view.get_parent().follow_focus=true
	view.add_child(ui.label("Vyber rozpracovanou činnost",24,ui.CYAN))
	view.add_child(ui.label("Obnoví se pouze zvolená práce. Kód se sám nespustí ani neověří.",16))
	var entries=available(ui.game)
	if entries.is_empty(): view.add_child(ui.label("Nemáš žádnou rozpracovanou činnost. Začni výběrem učebny v hlavní nabídce.",18))
	for entry in entries:
		var card=ui.card(view,entry.title,entry.status)
		var action=ui.button("Pokračovat v kampani" if entry.kind=="campaign" else "Pokračovat ve směně / "+ui.game.shifts.data.session.id if entry.kind=="shift" else "Obnovit výuku" if entry.kind=="lesson" else "Otevřít programovací koncept",func(): resume(ui,entry),true)
		card.add_child(action); ui.register_target("resume:"+entry.kind+":"+entry.get("key",""),action)
		if entry.kind=="lesson":
			card.add_child(ui.button("Začít lekci znovu / původní režim "+MODES[entry.mode],func(): ui.begin_lesson(entry.id,entry.mode,false)))
			card.add_child(ui.button("Smazat tento výukový snímek",func(): ui.game.work.data.lessons.erase(entry.key); ui.game.save(); ui.draw_ui()))
	view.add_child(ui.button("Zpět do hlavní nabídky",func(): ui.page="menu"; ui.draw_ui()))
	view.add_child(ui.label("Správa uložené práce",18,ui.MUTED))
	view.add_child(ui.button("Smazat koncepty IT formulářů / model zůstane beze změny",func(): ui.game.work.data.forms.clear(); ui.form_drafts.clear(); ui.game.save(); ui.draw_ui()))
	view.add_child(ui.label("Uložené rozbory / nejvýše 20 posledních předání",18,ui.CYAN))
	for review in ui.game.work.data.reviews:
		view.add_child(ui.button(review.title+" / "+str(int(review.score))+" bodů",func(): preload("res://scripts/ui/DebriefPresentation.gd").show(ui,review)))
