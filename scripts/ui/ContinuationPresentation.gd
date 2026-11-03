extends RefCounted

static func draw(ui):
	var view=ui.scroll(ui.center)
	view.add_child(ui.label("POKRAČOVÁNÍ / uložená práce",24,ui.CYAN))
	view.add_child(ui.label(ui.game.persistence_caption(),14,ui.MUTED))
	view.add_child(ui.label("Kampaň a směna mají vlastní svět. Výuku a kód obnovíš výslovně až v odpovídající učebně. Obnova konceptu nic neprovede ani neudělí XP.",16))
	view.add_child(ui.button("Pokračovat v kampani",func():
		if ui.world_enabled: ui.world_requested.emit("Hlavní serverovna")
		ui.game.resume_campaign(); ui.navigate("Tickety")))
	if not ui.game.shifts.data.session.is_empty():
		view.add_child(ui.button("Pokračovat ve směně / "+ui.game.shifts.data.session.id,func():
			if ui.world_enabled: ui.world_requested.emit("Hlavní serverovna")
			if ui.game.shifts.resume(): ui.page="Souvislé směny"; ui.draw_ui()))
	for key in ui.game.work.data.lessons:
		var record=ui.game.work.data.lessons[key]
		var saved=record.snapshot
		var definition=ui.game.Saves.rules().lesson_by_id(int(saved.id))
		var card=ui.card(view,definition.title+" / "+saved.tutorial.mode,"Krok %d · nápovědy %d · chyby %d. Původní režim zůstane zachovaný." % [int(saved.tutorial.step)+1,int(saved.hints),int(saved.state.errors)])
		if ui.game.game_mode.is_training():
			card.add_child(ui.button("Obnovit výuku",func():
				if ui.game.resume_lesson(int(saved.id),saved.tutorial.mode):
					ui.host=definition.server; ui.page=saved.tutorial.get("page",definition.category); ui.draw_ui(); ui.lesson_launched.emit()
				else: ui.show_message("Obnovení odmítnuto","Snímek je zastaralý nebo nejsi v IT učebně. Můžeš zahájit nový pokus.")))
		else: card.add_child(ui.button("Přejít do IT učebny / poté otevři Pokračování",func(): ui.navigate("Trénink")))
		card.add_child(ui.button("Smazat tento výukový snímek",func(): ui.game.work.data.lessons.erase(key); ui.game.save(); ui.draw_ui()))
	view.add_child(ui.label("Programovací koncepty: %d / 128. V programovací učebně otevři Rozepsaná práce. IT formuláře se obnovují pouze pro stejný pokus, operaci a zařízení; rizikové potvrzení se neukládá." % ui.game.programming.progress.drafts.size(),16))
	view.add_child(ui.button("Smazat koncepty IT formulářů / model zůstane beze změny",func(): ui.game.work.data.forms.clear(); ui.form_drafts.clear(); ui.game.save(); ui.draw_ui()))
	if ui.world_enabled: view.add_child(ui.button("Přejít do programovací učebny",func(): ui.world_requested.emit("Programming Academy")))
