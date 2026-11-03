extends RefCounted

static func valid(game, target) -> bool:
	if not target is Dictionary or not target.get("id") is String or not target.get("mode") in ["learn","practice","exam"]: return false
	match target.get("area",""):
		"it": return target.id.is_valid_int() and not game.Saves.rules().lesson_by_id(int(target.id)).is_empty()
		"code": return not preload("res://scripts/training/SkillEvidence.gd").program_task(game,target.id).is_empty()
		"english": return target.id in game.english.IDS
		"quiz": return not game.english.quiz.definition(target.id).is_empty()
		"listening": return not game.english.listening.definition(target.id).is_empty()
	return false

static func open(ui, target: Dictionary) -> Dictionary:
	var game=ui.game
	if not valid(game,target): return {"ok":false,"text":"Doporučení má neplatné ID, oblast nebo režim. Relace se nezměnila."}
	if game.save()!=OK: return {"ok":false,"text":"Před přechodem se nepodařilo uložit rozepsanou práci. Oprav zápis a zopakuj přechod."}
	var shell=ui.shell_ref.get_ref() if ui.shell_ref!=null else null
	if target.area!="it" and shell==null: return {"ok":false,"text":"Tato oblast vyžaduje skutečnou 3D učebnu."}
	if target.area=="it":
		if shell!=null: shell.enter_world("Trénink")
		elif not game.enter_training() and not game.game_mode.is_training(): return {"ok":false,"text":"Vstup do IT učebny nebyl dostupný."}
		if game.active and game.session_kind=="lesson" and int(game.current.id)==int(target.id) and game.tutorial.session.mode==target.mode:
			if shell!=null: shell.return_to_world()
			return {"ok":true,"continued":true}
		for key in game.work.data.lessons:
			if int(game.work.data.lessons[key].snapshot.id)==int(target.id):
				if shell!=null: shell.open_app("Pokračování")
				else: ui.page="Pokračování"; ui.draw_ui()
				return {"ok":true,"choice":true}
		ui.begin_lesson(int(target.id),target.mode,false)
		return {"ok":game.active and int(game.current.id)==int(target.id)}
	if target.area=="code":
		var manager=game.programming
		if game.game_mode.is_programming() and manager.current.get("id")==target.id and manager.mode==target.mode:
			if is_instance_valid(shell.code_editor): shell.set_mode("coding")
			else: shell.open_programming(); shell.code_editor.load_current()
			return {"ok":true,"continued":true}
		shell.enter_world("Programming Academy"); shell.open_programming()
		if not manager.current.is_empty(): shell.code_editor.load_current()
		var keys=manager.progress.drafts.keys()
		keys.sort_custom(func(a,b):
			var first=manager.progress.drafts[a].mode==target.mode
			var second=manager.progress.drafts[b].mode==target.mode
			return first if first!=second else str(a)<str(b))
		for key in keys:
			if manager.progress.drafts[key].id==target.id:
				shell.code_editor.show_drafts(key); return {"ok":true,"choice":true}
		if manager.start(target.id,target.mode,false): shell.code_editor.load_current(); return {"ok":true}
		return {"ok":false,"text":"Programovací úlohu nelze otevřít; zkontroluj stav konceptu."}
	shell.enter_world("English in London")
	var english=game.english
	if target.area=="english":
		var busy=(not english.session.is_empty() and not english.session.get("completed",false)) or (not english.quiz.session.is_empty() and not english.quiz.session.completed)
		if not busy:
			shell.world.player.position=Vector3(6,0.02,11.4) if target.id=="LON06" else Vector3(12,0.02,8.8)
			english.start(target.id,target.mode)
		shell.open_english("info" if target.id=="LON06" else "tickets")
		if busy:
			shell.english_dialog.page="home"; shell.english_dialog.scenario_page=english.IDS.find(target.id)/3
		shell.english_dialog.selected_mode=target.mode; shell.english_dialog.recommendation=target.duplicate(true); shell.english_dialog.draw()
		return {"ok":true,"choice":busy}
	if target.area=="quiz":
		var busy=not english.quiz.session.is_empty() and not english.quiz.session.completed
		if not busy: english.quiz.start_question(target.id,target.mode)
		shell.open_english("quiz"); shell.english_dialog.page="quiz_home" if busy else "quiz"
		shell.english_dialog.selected_mode=target.mode; shell.english_dialog.recommendation=target.duplicate(true); shell.english_dialog.draw()
		return {"ok":true,"choice":busy}
	if target.area=="listening":
		var listening=english.listening
		if not listening.session.is_empty() and not listening.session.completed and listening.session.id==target.id and listening.session.mode==target.mode:
			shell.open_english("listening"); return {"ok":true,"continued":true}
		var busy=not listening.progress.pending.is_empty()
		if not busy: listening.start(target.id,target.mode)
		shell.open_english("listening"); shell.english_dialog.page="listening_home" if busy else "listening"
		shell.english_dialog.selected_mode=target.mode; shell.english_dialog.recommendation=target.duplicate(true); shell.english_dialog.draw()
		return {"ok":true,"choice":busy}
	return {"ok":false,"text":"Neznámá oblast doporučení."}
