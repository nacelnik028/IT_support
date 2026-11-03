extends RefCounted

static func evidence(meta: Dictionary) -> String:
	if meta.is_empty(): return "Žádný zaznamenaný pokus."
	return "%s / %s · režim %s · pomoc: %s · %d / 100 · %s" % [meta.source,meta.id,{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška","campaign":"Kampaň"}.get(meta.mode,meta.mode),meta.help+(" / nesplněný pokus" if not meta.passed else ""),int(meta.score),Time.get_datetime_string_from_unix_time(int(meta.time))+" UTC" if int(meta.time)>0 else "datum nezaznamenáno"]

static func draw(ui, parent: Node):
	if parent.get_parent() is ScrollContainer: parent.get_parent().follow_focus=true
	var head=ui.card(parent,"Moje znalosti akademie","Stávající kariéra a ověřené výsledky napříč místnostmi. Otevření nic neodměňuje.")
	head.add_child(ui.label("Stav popisuje zaznamenané pokusy, nikoli úplné zvládnutí celé oblasti. Nezkoušeno není neúspěch. Body IT, programování a jazykových úloh se nesčítají do společné známky ani CEFR certifikátu.",16))
	var skills=ui.game.Profile.skills(ui.game)
	for row in skills:
		var card=ui.card(parent,row.skill+" / "+row.status,"Zaznamenané zdroje: "+str(int(row.count)))
		card.add_child(ui.label("Historický nejlepší výsledek: "+("—" if int(row.best)<0 else str(int(row.best))+" / 100")+"\n"+evidence(row.best_source),14,ui.MUTED))
		card.add_child(ui.label("Poslední pokus / "+evidence(row.latest),15))
		if not row.target.is_empty():
			card.add_child(ui.label(row.target.reason,14,ui.MUTED))
			var action=ui.button("Doporučeno: "+row.target.id+" / "+row.target.title+" / "+{"learn":"Učím se","practice":"Procvičování"}.get(row.target.mode,row.target.mode),func():
				var result=preload("res://scripts/training/RecommendationRouter.gd").open(ui,row.target)
				if not result.ok: ui.show_message("Doporučení nelze otevřít",result.get("text","Oblast nyní není dostupná.")))
			action.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; card.add_child(action)
	if not ui.game.english.progress.archive.is_empty():
		var archive=ui.card(parent,"Archiv angličtiny A1–A2","Tyto původní výsledky nepotvrzují nové B1–B2, kvíz ani poslech.")
		for id in ui.game.english.progress.archive.get("results",{}): archive.add_child(ui.label(id+" / "+str(int(ui.game.english.progress.archive.results[id].best))+" / 100",14))
