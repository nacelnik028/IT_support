extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Game=preload("res://scripts/core/GameManager.gd")
const EXPECTED=["ticket_options","ticket_choice","family_ages","clarify","compare_total","price_conditions","sold_later","next_slot","change_before_pay","preferred_time","offer_directions","walk_landmarks"]
var shell
var checks=0
var failures=0
var focus_outs=0

func _init():
	root.focus_exited.connect(func(): focus_outs+=1; print("TEST WINDOW FOCUS OUT / ",focus_outs))
	var tag=str(OS.get_process_id())
	Saves.path_override="user://london_listening_"+tag+".json"
	Settings.path_override="user://london_listening_"+tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override="user://london_listening_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	var settings=Settings.new(); settings.resolution=Vector2i(1600,900); settings.introduction_seen=true; settings.muted=false; settings.volume=0.5; settings.save_settings()
	call_deferred("run")

func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; push_error(text)

func frames(n: int = 5):
	for i in n: await process_frame

func same(a,b) -> bool: return JSON.parse_string(JSON.stringify(a))==JSON.parse_string(JSON.stringify(b))

func button(caption: String):
	for item in shell.english_dialog.buttons:
		if is_instance_valid(item) and item.text==caption: return item
	return null

func click(control: Control):
	check(control!=null,"Skutečné požadované tlačítko existuje")
	if control==null: return
	for scroll in shell.ui.get_scroll_ancestors(control): scroll.ensure_control_visible(control); scroll.scroll_vertical+=4
	await frames()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var viewport=control.get_viewport(); var at=control.get_global_rect().get_center()
	var visible=viewport.get_visible_rect().encloses(control.get_global_rect().grow(-0.5))
	for scroll in shell.ui.get_scroll_ancestors(control): visible=visible and scroll.get_global_rect().encloses(control.get_global_rect().grow(-0.5))
	check(visible,"Cíl kliknutí je plně odkrytý po posuvu: "+control.text)
	var motion=InputEventMouseMotion.new(); motion.position=at; motion.global_position=at; viewport.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=at; event.global_position=at; event.button_index=MOUSE_BUTTON_LEFT; event.button_mask=MOUSE_BUTTON_MASK_LEFT if down else 0; event.pressed=down; viewport.push_input(event,true)
	await frames()

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var game=shell.ui.game
	shell.enter_world("Hlavní serverovna"); game.start_mission(3,true)
	var campaign=game.snapshot().duplicate(true)
	shell.enter_world("English in London"); game.english.progress.intro_seen=true
	var english=game.english; var listening=english.listening
	english.start("LON05","practice",0); english.quiz.start("practice",5,31)
	var dialogue=english.session.duplicate(true); var quiz=english.quiz.session.duplicate(true)
	var xp=game.progress.xp
	check(listening.catalog.tasks.size()==12,"Dvanáct samostatných poslechových úloh")
	for index in 12:
		var task=listening.catalog.tasks[index]
		check(task.id=="LONL%02d" % (index+1) and task.answer==EXPECTED[index],"Ručně určený význam "+task.id)
		var line=shell.speech.mapping.lines.filter(func(item): return item.id==task.clip)[0]
		var lengths={}
		for variant in ["normal","slow"]:
			var stream=load(line[variant])
			check(stream is AudioStreamMP3 and stream.get_length()>0.5,"Existující skutečný klip "+task.id+variant)
			var hash_value=HashingContext.new(); hash_value.start(HashingContext.HASH_SHA256); hash_value.update(stream.data)
			check(hash_value.finish().hex_encode()==line[variant+"_sha256"],"Hash skutečných audio bajtů "+task.id+variant)
			var playback=stream.instantiate_playback(); playback.start(); var nonzero=false
			for sample in playback.mix_audio(1.0,4096):
				if sample.length_squared()>0.000001: nonzero=true
			check(nonzero,"Nenulové dekódované vzorky "+task.id+variant); playback.stop()
			lengths[variant]=stream.get_length()
		check(lengths.slow>lengths.normal*1.1,"Samostatná pomalá varianta bez změny pitch")
		for mode in ["learn","practice","exam"]:
			check(listening.start(task.id,mode,300+index),"Start oddělené úlohy/režimu "+task.id+mode)
			shell.open_english("listening"); await frames()
			var ui=shell.english_dialog
			check(not ui.content.find_children("*","Label",true,false).any(func(label): return label.text.contains(line.text)),"Přesný přepis je před odpovědí skrytý")
			check(ui.buttons.all(func(item): return not item.tooltip_text.contains(".mp3") and not item.tooltip_text.contains(EXPECTED[index])),"Tooltip/file metadata neprozrazuje odpověď")
			if mode=="learn":
				# Foreground changes caused by the desktop/test host must exercise
				# the real focus guard, not be mistaken for an audio end failure.
				# Explicitly click Replay after refocusing; production never resumes.
				for replay in 3:
					if DisplayServer.get_name()!="headless": root.grab_focus()
					await frames()
					var focus_before=focus_outs
					await click(button("Poslechnout / zopakovat"))
					check(shell.speech.playing and shell.speech.line_id==task.clip and shell.speech.pitch_scale==1.0,"Skutečný player přehrává správný klip")
					await create_timer(lengths.normal).timeout
					for poll in 100:
						if not shell.speech.playing: break
						await create_timer(0.03).timeout
					await frames()
					if listening.session.heard: break
					if focus_outs==focus_before: break
					check(not shell.speech.playing and not listening.session.heard,"Skutečný desktop focus-out přerušil klip bez falešného potvrzení")
					print("TEST explicit replay after focus interruption / ",task.id)
				if not listening.session.heard: print("AUDIO END DIAGNOSTIC ",task.id," mode=",shell.mode," playing=",shell.speech.playing," revision=",listening.revision," spoken=",shell.speech.spoken_revision," session=",listening.session)
				check(listening.session.heard and not listening.session.completed and listening.session.answer=="","Konec skutečného audia sám nevybere odpověď / "+task.id)
			else:
				check(shell.speech.listen(task.id),"Režim používá stejný skutečný klip")
				shell.speech.stop_speech()
			var selected=""
			for option in task.options:
				if option.id==EXPECTED[index]: selected=str(listening.session.order.find(option.id)+1)+"  "+option.text
			var token=listening.revision
			await click(button(selected))
			check(listening.session.completed and listening.progress.attempts.back().correct,"Skutečná odpověď a konkrétní vysvětlení "+task.id+mode)
			check(not listening.answer(EXPECTED[index],token),"Starý nebo druhý trigger nezapíše další výsledek")
			check(listening.progress.attempts.back().assisted==(mode!="learn"),"Nedokončené audio není vydáváno za samostatný poslech / "+task.id+mode)
			check(same(english.session,dialogue) and same(english.quiz.session,quiz) and game.progress.xp==xp,"Poslech nemění košík/platbu/kvíz ani XP")
	check(listening.progress.results.size()==12 and listening.progress.attempts.size()==36,"Vlastní oddělené výsledky všech úloh/režimů")
	listening.start("LONL01","practice",900); var order=listening.session.order.duplicate(); shell.open_english("listening"); await frames()
	await click(button("Zobrazit přepis / zaznamená pomoc"))
	check(listening.session.transcript and same(english.session,dialogue),"Přepis je výslovná pomoc bez změny dialogu")
	shell.speech.listen("LONL01",true)
	check(listening.session.slow and listening.session.answer=="" and shell.speech.pitch_scale==1.0,"Pomalá varianta nezvolí odpověď a je pomoc")
	shell.pause_menu(); check(not shell.speech.playing,"Pauza zastaví poslech")
	shell.set_mode("english"); check(not shell.speech.playing,"Návrat sám řeč nespustí")
	shell.speech.listen("LONL01"); shell.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not shell.speech.playing,"Focus-out zastaví poslech")
	shell.set_mode("english"); shell.speech.listen("LONL01"); listening.start("LONL02","practice",2); await frames()
	check(not shell.speech.playing and listening.session.answer=="","Rychlá změna úlohy zastaví starý klip")
	# A queued completion for an explicitly stopped/replaced play is not proof.
	listening.start("LONL01","practice",3); shell.speech.listen("LONL01")
	var old_token=shell.speech.spoken_revision; var old_generation=shell.speech.play_generation
	shell.speech.stop_speech(); shell.speech.complete_listening_clip(old_token,old_generation)
	check(not listening.session.heard,"Zastavené přehrání odmítne opožděný callback")
	shell.speech.listen("LONL01"); shell.speech.complete_listening_clip(old_token,old_generation)
	check(not listening.session.heard,"Starý callback neoznačí nové přehrání za dokončené")
	shell.speech.stop_speech()
	listening.start("LONL01","exam",900)
	check(not listening.transcript(listening.revision),"Zkouška blokuje přepis")
	var exam_order=listening.session.order.duplicate()
	shell.enter_world("Rozcestník akademie"); check(listening.session.is_empty() and not shell.speech.playing,"Odchod čistí živý poslech a řeč")
	var restored=Game.new()
	check(not restored.english.listening.resume(),"Mimo Londýn se poslech neobnoví")
	restored.enter_english()
	check(restored.english.listening.resume() and restored.english.listening.session.mode=="exam" and restored.english.listening.session.order==exam_order and not restored.english.listening.session.transcript_allowed,"Obnova zachová přesný režim, pořadí a pravidla zkoušky bez automatického audia")
	restored=null
	shell.enter_world("English in London"); listening.start("LONL01","practice",1); shell.set_mode("english")
	shell.ui.save_preference("muted",true); shell.speech.listen("LONL01"); listening.answer(EXPECTED[0],listening.revision)
	check(listening.progress.attempts.back().assisted and listening.progress.attempts.back().aids.muted,"Ztlumené dokončení je přístupné a označené s pomocí")
	shell.ui.save_preference("muted",false)
	var data=Saves.load_game()
	for mutation in ["id","selected","aids","pending"]:
		var bad=data.duplicate(true)
		match mutation:
			"id": bad.english.listening.attempts[0].id="LON01"
			"selected": bad.english.listening.attempts[0].selected="UNKNOWN"
			"aids": bad.english.listening.attempts[0].assisted=not bad.english.listening.attempts[0].assisted
			"pending": bad.english.listening.pending={"id":"LONL01","mode":"exam","transcript_allowed":true}
		check(not Saves.rules().valid(bad),"Neplatný poslechový save odmítnut / "+mutation)
	check(Saves.rules().valid(Saves.load_game()),"Poslechové výsledky jsou validní")
	shell.enter_world("Hlavní serverovna")
	check(same(game.snapshot(),campaign) and game.progress.xp==xp,"Poslech a restart nepoškodily původní kampaň ani XP")
	game=null; english=null; listening=null; shell.queue_free(); shell=null; await frames(12)
	print("LONDON LISTENING: %d checks, %d failures; audio decoded/player tested, no human listening claim" % [checks,failures]); quit(1 if failures else 0)
