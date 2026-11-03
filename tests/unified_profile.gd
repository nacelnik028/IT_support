extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Router=preload("res://scripts/training/RecommendationRouter.gd")
var checks=0
var failures=0
var shell

func _init():
	root.gui_embed_subwindows=true
	var tag=str(OS.get_process_id())
	Saves.path_override="user://unified_profile_"+tag+".json"
	Settings.path_override="user://unified_profile_"+tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override="user://unified_profile_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	var settings=Settings.new(); settings.resolution=Vector2i(1600,900); settings.introduction_seen=true; settings.save_settings()
	call_deferred("run")

func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; push_error(text)

func frames(n: int = 5):
	for i in n: await process_frame

func same(a,b) -> bool: return JSON.parse_string(JSON.stringify(a))==JSON.parse_string(JSON.stringify(b))

func skill(game, name: String) -> Dictionary:
	return game.Profile.skills(game).filter(func(row): return row.skill==name)[0]

func click(control: Control):
	check(control!=null,"Požadované tlačítko existuje")
	if control==null: return
	for scroll in shell.ui.get_scroll_ancestors(control): scroll.ensure_control_visible(control)
	await frames()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var viewport=control.get_viewport(); var at=control.get_global_rect().get_center()
	if viewport is Window and viewport!=root and viewport.is_embedded(): at+=Vector2(viewport.position); viewport=root
	var motion=InputEventMouseMotion.new(); motion.position=at; viewport.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; viewport.push_input(event,true); await process_frame
	await frames()

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var game=shell.ui.game
	var rows=game.Profile.skills(game)
	check(rows.size()==13 and rows.all(func(row): return row.status=="Nezkoušeno" and int(row.best)==-1),"Nový hráč: nezkoušeno není neúspěch")
	check(rows.all(func(row): return Router.valid(game,row.target)),"Všech 13 doporučení má skutečné ID a režim")
	check(JSON.stringify(rows)==JSON.stringify(game.Profile.skills(game)),"Doporučení jsou lokální a deterministická")
	var xp=game.progress.xp
	await click(shell.ui.ui_targets["menu:knowledge"])
	check(shell.ui.page=="Moje znalosti" and game.progress.xp==xp,"Skutečný vstup z menu neudělí XP")
	check(shell.ui.root_box.find_children("*","Label",true,false).any(func(label): return label.text.contains("Anglický poslech / Nezkoušeno")),"Stávající profil obsahuje nový poslech")
	shell.enter_world("Hlavní serverovna"); game.start_mission(3,true)
	game.apply("physical_inspect",{"device":"PVE-01"}); game.apply("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true}); game.apply("verify",{})
	check(game.complete().ok and skill(game,"Sítě").status=="Doloženo bez pomoci","Profil odvodil skutečnou síťovou dovednost z IT výsledku")
	shell.enter_world("Programming Academy")
	game.programming.start("PY01","practice"); game.programming.edit("main.py","print('chybně')"); game.programming.test_program()
	check(skill(game,"Python").status=="Procvičeno","Neúspěšný test není zvládnutí")
	game.programming.edit("main.py",game.programming.current.example["main.py"]); check(game.programming.test_program().ok,"Skutečné ověření Python řešení")
	game.programming.edit("main.py","print(unknown_name)"); game.programming.test_program()
	var python=skill(game,"Python")
	check(python.status=="Doloženo bez pomoci" and int(python.best)==100 and python.latest.failed and int(python.latest.score)<100,"Historický nejlepší je oddělený od poslední chyby")
	check(python.latest.source.begins_with("Programování") and python.latest.mode=="practice" and python.latest.time>0,"Zdroj, režim, pomoc a skutečné datum pokusu")
	for id in ["WEB01","WEB12","WEB28"]:
		game.programming.start(id,"practice")
		for file in game.programming.current.example: game.programming.edit(file,game.programming.current.example[file])
		check(game.programming.test_program().ok,"Skutečně ověřená webová dovednost "+id)
	for name in ["HTML","CSS","JavaScript"]: check(skill(game,name).status=="Doloženo bez pomoci","Samostatná dovednost "+name)
	shell.enter_world("English in London"); game.english.progress.intro_seen=true
	game.english.quiz.start_question("LONQ01","learn"); game.english.quiz.help()
	var question=game.english.quiz.definition(); game.english.quiz.answer(question.answer,game.english.quiz.revision); game.english.quiz.next(game.english.quiz.revision)
	check(skill(game,"London Quiz").status=="Dokončeno s pomocí","Překlad kvízu je skutečně zaznamenaná pomoc")
	game.english.listening.start("LONL01","practice",3); game.english.listening.answer("ticket_options",game.english.listening.revision)
	check(skill(game,"Anglický poslech").status=="Dokončeno s pomocí","Správný význam bez dokončeného audia není doložený poslech bez pomoci")
	var original_xp=game.progress.xp
	for i in 3: game.Profile.skills(game)
	check(game.progress.xp==original_xp,"Čtení profilu ani změna doporučení neodměňuje")
	# Initial fixture for old A1–A2 evidence, not a completion action in the new content.
	var old=Saves.load_game(); old.english={"results":{"LON01":{"best":100,"completed":1,"hints":0}},"attempts":[],"phrases":[],"intro_seen":true}
	var path="user://unified_profile_legacy_"+str(OS.get_process_id())+".json"; var current_path=Saves.path_override
	var file=FileAccess.open(path,FileAccess.WRITE); file.store_string(JSON.stringify(old)); file.close(); Saves.path_override=path
	var legacy=Game.new()
	check(not legacy.english.progress.archive.is_empty() and skill(legacy,"Anglické situace").status=="Nezkoušeno" and skill(legacy,"Anglický poslech").status=="Nezkoušeno","Archiv A1–A2 není důkaz B1–B2 ani poslechu")
	Saves.path_override=current_path; legacy=null
	shell.enter_world("Hlavní serverovna"); game.start_mission(3,true)
	var campaign=game.snapshot().duplicate(true)
	game.shifts.start("SHIFT-RECOVERY"); game.apply("physical_spare",{"spare":"SPARE-2T"})
	var shift_state=game.sim.state.duplicate(true)
	var before=game.snapshot().duplicate(true); var before_mode=game.game_mode.current
	check(not Router.open(shell.ui,{"area":"code","id":"UNKNOWN","mode":"learn"}).ok and same(game.snapshot(),before) and game.game_mode.current==before_mode,"Neplatné doporučení nezmění relaci ani oblast")
	var target={"area":"code","id":"PY02","mode":"practice"}
	check(Router.open(shell.ui,target).ok and game.game_mode.is_programming() and game.programming.current.id=="PY02","Doporučení otevřelo skutečný editor a správné ID")
	check(game.programming.last_run.is_empty() and game.programming.last_result.is_empty(),"Doporučení nespouští kód ani test")
	var editor=shell.code_editor; editor.editor.select_all(); editor.editor.insert_text_at_caret("# vlastní koncept\nprint("); await frames(); editor.capture_editor_state(); game.save()
	var code=game.programming.files.duplicate(true)
	check(Router.open(shell.ui,{"area":"it","id":"1002","mode":"exam"}).ok and game.game_mode.is_training() and int(game.current.id)==1002,"Přímý vstup do doporučené existující IT lekce")
	game.lesson_hint(); check(game.hints_used==0,"Doporučená zkouška si zachová zákaz pomoci")
	check(Router.open(shell.ui,target).ok,"Návrat k doporučení s konceptem")
	var restore: Button
	for button in shell.code_editor.find_children("*","Button",true,false):
		if button.text=="Obnovit rozepsanou práci": restore=button; break
	await click(restore)
	check(game.programming.current.id=="PY02" and game.programming.files==code and game.programming.last_result.is_empty(),"Výslovná volba obnoví relevantní zdroj bez restartu/ověření")
	var saved_lesson=game.work.data.lessons["1002:exam"].snapshot.duplicate(true)
	var choice=Router.open(shell.ui,{"area":"it","id":"1002","mode":"learn"})
	check(choice.ok and choice.get("choice",false) and shell.ui.page=="Pokračování" and not game.active,"Profil nezmění nedokončenou zkoušku na learn; nabízí původní snímek")
	check(game.resume_lesson(1002,"exam") and same(game.snapshot(),saved_lesson),"Původní zkouška obnoví správný krok/model/pomoc")
	check(Router.open(shell.ui,{"area":"quiz","id":"LONQ08","mode":"practice"}).ok and game.english.quiz.definition().id=="LONQ08","Doporučení otevře přesnou skutečnou otázku")
	check(game.english.quiz.session.current.is_empty(),"Otevření kvízu neodešle odpověď")
	var pending_quiz=game.english.quiz.session.duplicate(true)
	check(Router.open(shell.ui,{"area":"listening","id":"LONL07","mode":"practice"}).ok,"Doporučení otevře poslech v Londýně")
	if game.english.listening.session.is_empty():
		var new_task: Button
		for button in shell.english_dialog.buttons:
			if button.text=="Nová doporučená úloha / LONL07": new_task=button
		await click(new_task)
	check(game.english.listening.session.id=="LONL07" and game.english.listening.session.answer=="" and same(game.english.quiz.session,pending_quiz),"Poslechové doporučení má správné ID a zachová neodevzdaný kvíz")
	game.english.listening.cancel(); game.english.quiz.cancel()
	check(Router.open(shell.ui,{"area":"english","id":"LON06","mode":"practice"}).ok and game.english.session.id=="LON06" and shell.world.english_room.near("info"),"Doporučení situace otevře správného skutečného NPC")
	shell.enter_world("Hlavní serverovna")
	check(game.session_kind=="shift" and same(game.sim.state,shift_state) and same(game.suspended_campaign,campaign),"Všechny přechody doporučení zachovaly směnu, inventář i kampaň")
	var route_xp=game.progress.xp
	shell.open_app("Moje znalosti"); await frames()
	check(game.progress.xp==route_xp and game.Profile.skills(game).all(func(row): return Router.valid(game,row.target)),"Smíšený profil je čitelný bez XP a všechna doporučení zůstávají platná")
	game=null; editor=null; shell.queue_free(); shell=null; await frames(12)
	print("UNIFIED PROFILE: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
