extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
const Game=preload("res://scripts/core/GameManager.gd")
var shell
var checks=0
var failures=0

func _init():
	root.gui_embed_subwindows=true
	var tag=str(OS.get_process_id())
	Saves.path_override="user://work_persistence_"+tag+".json"
	Settings.path_override="user://work_persistence_"+tag+".cfg"
	Comfort.path_override="user://work_persistence_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	var settings=Settings.new(); settings.resolution=Vector2i(1600,900); settings.introduction_seen=true; settings.save_settings()
	call_deferred("run")

func check(ok: bool, message: String):
	checks+=1
	if not ok: failures+=1; push_error(message)

func frames(count: int = 5):
	for i in count: await process_frame

func click(control: Control):
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if control==null: check(false,"Požadované tlačítko existuje"); return
	var viewport=control.get_viewport()
	var at=control.get_global_rect().get_center()
	if viewport is Window and viewport!=root and viewport.is_embedded():
		at+=Vector2(viewport.position); viewport=root
	var motion=InputEventMouseMotion.new(); motion.position=at; viewport.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; viewport.push_input(event,true); await process_frame
	await frames()

func named(node: Node, caption: String):
	for button in node.find_children("*","Button",true,false):
		if button.text==caption: return button
	return null

func same(a,b) -> bool:
	return JSON.stringify(JSON.parse_string(JSON.stringify(a)))==JSON.stringify(JSON.parse_string(JSON.stringify(b)))

func create_shell():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()

func run():
	await create_shell()
	var game=shell.ui.game
	shell.enter_world("Hlavní serverovna"); game.start_mission(3,true)
	var original=game.snapshot().duplicate(true)
	shell.enter_world("Programming Academy"); shell.open_programming("python"); await frames()
	var editor=shell.code_editor
	editor.mode_picker.select(1); editor.launch("PY01",false)
	editor.editor.select_all(); editor.editor.insert_text_at_caret("print(\n# skutečný rozepsaný syntax error\n")
	await frames(); editor.editor.set_caret_line(1); editor.editor.set_caret_column(8); editor.editor.select(1,2,1,8); editor.capture_editor_state()
	var python=game.programming.files.duplicate(true)
	check(python["main.py"]=="print(\n# skutečný rozepsaný syntax error\n","Skutečný CodeEdit vstup mění živý koncept")
	check(game.save()==OK,"Python koncept se skutečně zapíše")
	var py_key=game.programming.drafts.key(game.programming.draft_record())
	var py_view=game.programming.views.duplicate(true)
	check(game.programming.progress.drafts.has(py_key),"Stabilní klíč konceptu")
	editor.launch("WEB28",false)
	for file in ["index.html","style.css","script.js"]:
		editor.switch_file(file); editor.editor.select_all(); editor.editor.insert_text_at_caret("/* rozepsáno "+file+" */\n"); await frames()
	editor.editor.set_caret_line(1); editor.capture_editor_state()
	var web=game.programming.files.duplicate(true)
	var web_key=game.programming.drafts.key(game.programming.draft_record())
	check(game.save()==OK,"Všechny webové soubory na disk")
	var xp=game.progress.xp
	editor=null; game=null; shell.queue_free(); shell=null; await frames(12)
	await create_shell(); game=shell.ui.game
	check(game.programming.current.is_empty(),"Restart automaticky nezahájí ani nespustí kód")
	check(game.progress.xp==xp and game.suspended_campaign.get("id",game.current.get("id",0))==original.id,"Nový GameManager zachoval kampaň a XP")
	check(not game.programming.restore_draft(py_key),"Obnova kódu mimo správnou učebnu odmítnuta")
	shell.enter_world("Programming Academy"); shell.open_programming("python"); await frames(); editor=shell.code_editor
	editor.show_drafts(py_key); await frames()
	await click(named(editor,"Obnovit rozepsanou práci"))
	check(game.programming.files==python and editor.editor.text==python["main.py"],"Úplný press/release obnoví přesný chybný Python")
	check(game.programming.last_run.is_empty() and game.programming.last_result.is_empty() and game.progress.xp==xp,"Obnova neprovede běh, ověření ani odměnu")
	check(editor.editor.get_caret_line()==int(py_view["main.py"].line) and editor.editor.has_selection(),"Obnova kurzoru a výběru")
	check(game.programming.restore_draft(web_key),"Webový koncept lze obnovit samostatně")
	editor.load_current(); await frames()
	check(game.programming.files==web and editor.file_name=="script.js","Přesné tři soubory a aktivní JS")
	check(game.programming.start("PY01","exam"),"Stejné ID v oddělené zkoušce")
	game.programming.edit("main.py","# zkouška\nprint(42)")
	var exam_key=game.programming.drafts.key(game.programming.draft_record())
	check(exam_key!=py_key and game.save()==OK,"Režimy nemají společný koncept ani pomoc")
	check(game.programming.start("DBG01","practice"),"Opravovací úloha")
	game.programming.edit("main.py","print(\n# oprava")
	var debug_key=game.programming.drafts.key(game.programming.draft_record()); game.save()
	check(game.programming.generate_series("python","beginner",3,7281),"Generovaná série")
	game.programming.edit("main.py","# vlastní řešení generované varianty\nprint(")
	var generated_id=game.programming.current.id
	var generated_tests=game.programming.current.tests.duplicate(true)
	var series_key=game.programming.drafts.key(game.programming.draft_record()); game.save()
	shell.enter_world("Rozcestník akademie")
	var restored=Game.new()
	check(restored.programming.progress.drafts.has(debug_key),"Opravovací koncept přežil nový GameManager")
	restored.enter_programming()
	check(restored.programming.restore_draft(series_key) and restored.programming.current.id==generated_id and restored.programming.current.tests==generated_tests,"Seed, pořadí a skutečné parametry série jsou přesně obnovené")
	check(restored.programming.mode=="practice" and restored.programming.last_result.is_empty(),"Série neobnoví staré úspěšné ověření")
	var bad=Saves.load_game(); bad.programming.drafts[py_key].files["../arbitrary.py"]="print(1)"
	check(not Saves.rules().valid(bad),"Logická cesta mimo povolené soubory odmítnuta")
	bad=Saves.load_game(); bad.programming.drafts[py_key].files["main.py"]="x".repeat(131073)
	check(not Saves.rules().valid(bad),"Nadměrný kód odmítnut bez zkrácení")
	bad=Saves.load_game(); bad.programming.drafts[py_key].content="zastaralý obsah"
	check(not Saves.rules().valid(bad),"Zastaralá verze konceptu odmítnuta")
	restored=null
	shell.enter_world("Hlavní serverovna"); game.resume_campaign()
	shell.open_app("Proxmox"); shell.ui.host="PVE-01"; shell.ui.selected_vm="100"; shell.ui.tab="VM / CT"; shell.ui.active_action="pve_resources"; shell.ui.draw_ui(); await frames()
	if not shell.ui.form_controls.has("pve_resources"):
		shell.ui.tab="VM / CT"; shell.ui.draw_ui(); await frames()
	check(shell.ui.form_controls.has("pve_resources"),"Skutečný IT formulář prostředků")
	if shell.ui.form_controls.has("pve_resources"):
		var number=shell.ui.form_controls.pve_resources.ram
		number.get_line_edit().text="6144x"; number.get_line_edit().text_changed.emit("6144x")
		shell.ui.capture_form_drafts(); game.save()
		check(game.sim.state.vms["100"].ram==original.state.vms["100"].ram,"Nepotvrzené číslo se neaplikuje v modelu")
		check(game.work.data.forms.size()>0,"Raw IT text je v oddělené větvi")
		var rebuilt=Game.new(); check(same(rebuilt.work.data.forms,game.work.data.forms),"Nový GameManager načte raw IT koncept")
		var saved_game=shell.ui.game; shell.ui.game=rebuilt; shell.ui.form_drafts.clear(); shell.ui.draft_revision=rebuilt.session_revision; shell.ui.draw_ui(); await frames()
		check(shell.ui.form_controls.pve_resources.ram.get_line_edit().text=="6144x","Skutečný nový formulář obnoví nepotvrzený číselný text")
		shell.ui.host="HV-01"; shell.ui.page="Hyper-V"; shell.ui.selected_vm="200"; shell.ui.draw_ui(); shell.ui.open_action("memory"); await frames()
		check(shell.ui.form_controls.has("memory") and shell.ui.form_controls.memory.ram.get_line_edit().text!="6144x","Skutečný formulář jiné VM/hostitele nepřevezme raw text VM100")
		shell.ui.game=saved_game; rebuilt=null
		shell.ui.draw_ui(); await frames()
	# Real second VM on the same host, not a fictitious selector ID.
	var creation={}
	for descriptor in game.actions:
		if descriptor.id=="create_vm":
			for field in descriptor.fields: creation[field.key]=field.get("default","")
	creation.id="101"; creation.name="DRAFT-SECOND"
	check(game.apply("create_vm",creation).ok,"Skutečné vytvoření druhé VM pro izolaci konceptu")
	shell.ui.page="Proxmox"; shell.ui.host="PVE-01"; shell.ui.selected_vm="101"; shell.ui.draw_ui(); shell.ui.open_action("pve_resources"); await frames()
	check(shell.ui.form_controls.pve_resources.ram.get_line_edit().text!="6144x","Stejná operace na druhé existující VM má vlastní koncept")
	var stale={"version":1,"session":game.attempt_id,"page":"Proxmox","host":"PVE-01","vm":"9999","action":"pve_resources","values":{"ram":{"value":4,"text":"6144x"}}}
	game.work.data.forms[game.work.form_key(stale)]=stale
	var model=game.sim.state.duplicate(true)
	check(preload("res://scripts/ui/FormDraftArchive.gd").restore(shell.ui,"Proxmox|PVE-01|9999|pve_resources","pve_resources").is_empty() and game.sim.state==model and shell.ui.notice.contains("Koncept odmítnut"),"Zaniklý cíl je bezpečně odmítnutý s vysvětlením")
	shell.ui.selected_vm="100"; shell.ui.draw_ui(); shell.ui.open_action("promote"); await frames()
	await click(shell.ui.form_buttons.promote)
	var confirm: ConfirmationDialog
	for child in shell.ui.get_children():
		if child is ConfirmationDialog and not child.is_queued_for_deletion(): confirm=child; break
	check(confirm!=null,"Rizikový zásah vyžaduje aktuální potvrzení")
	if confirm!=null:
		await click(confirm.get_cancel_button())
		check(game.sim.state==model,"Zamítnuté potvrzení neprovede operaci")
	await click(shell.ui.form_buttons.promote)
	for child in shell.ui.get_children():
		if child is ConfirmationDialog and not child.is_queued_for_deletion(): confirm=child; break
	game.start_mission(6,true); model=game.sim.state.duplicate(true)
	if is_instance_valid(confirm): confirm.confirmed.emit()
	check(game.sim.state==model,"Starý potvrzovací callback nesouhlasí za jinou relaci")
	shell.enter_world("Trénink")
	var solution_path="res://tests/lesson_solutions.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--lesson-solutions="): solution_path=argument.trim_prefix("--lesson-solutions=")
	var solutions=JSON.parse_string(FileAccess.get_file_as_string(solution_path))
	for mode in ["learn","practice","exam"]:
		game.start_lesson(1002,mode,false)
		if mode!="exam": game.lesson_hint()
		for entry in solutions["1002"].slice(0,5):
			if entry is Dictionary: game.notify_event(entry.event)
			else: check(game.apply(entry[0],entry[1]).ok,"Skutečný sandbox před obnovou / "+entry[0]+mode)
		check(game.sim.get_vm("101").get("iso","")=="debian.iso" and (mode!="learn" or int(game.tutorial.session.step)>=5),"Obnovuje se skutečný postup a VM, ne jen prázdný začátek / "+mode)
		check(not game.apply("vm_resources",{"vm":"9999","cpu":2,"ram_mib":4096}).ok,"Skutečná chyba se uloží pro férové dokončení / "+mode)
		var expected=game.snapshot().duplicate(true)
		shell.enter_world("Rozcestník akademie")
		check(not game.active and game.tutorial.session.is_empty() and game.education.sessions.is_empty(),"Odchod vyčistí živou výuku "+mode)
		var resumed=Game.new()
		var before=resumed.snapshot().duplicate(true)
		check(not resumed.resume_lesson(1002,mode) and resumed.snapshot()==before,"Mimo učebnu nelze obnovit "+mode)
		resumed.enter_training()
		check(resumed.resume_lesson(1002,mode) and same(resumed.snapshot(),expected),"Výslovná obnova sandboxu/kroku/chyb/pomoci "+mode)
		check(resumed.tutorial.session.mode==mode,"Režim obnovy zachován "+mode)
		resumed=null; shell.enter_world("Trénink")
	var last=game.last_saved_at
	var normal=Saves.path_override; Saves.path_override="user://missing-work-"+str(OS.get_process_id())+"/save.json"
	check(game.save()!=OK and game.last_saved_at==last and game.unsaved,"Chyba zápisu nezmění poslední úspěšný čas")
	Saves.path_override=normal; check(game.save()==OK and not game.unsaved,"Opakování zápisu existujícího stavu")
	var transfer="user://work-transfer-"+str(OS.get_process_id())+".json"
	check(Saves.export_progress(transfer)==OK and Saves.import_progress(transfer)==OK,"Export/import nových větví")
	check(Saves.rules().valid(Saves.load_game()),"Konečný save validní")
	# Optional damaged work is quarantined while the independently valid
	# campaign/results remain readable. Import still rejects the original bytes.
	var valid=Saves.load_game(); var broken=valid.duplicate(true)
	broken.programming.drafts[py_key].content="stará verze"
	var corrupt=JSON.stringify(broken)
	var file=FileAccess.open(normal,FileAccess.WRITE); file.store_string(corrupt); file.close()
	var recovered=Game.new()
	check(recovered.progress==valid.progress and recovered.load_warning!="" and recovered.programming.progress.drafts.is_empty(),"Vadný koncept nezničí načtení platných výsledků/kampaně")
	check(FileAccess.get_file_as_string(normal)==corrupt,"Samotné načtení nepřepíše vadný původní soubor")
	file=FileAccess.open(transfer,FileAccess.WRITE); file.store_string(corrupt); file.close()
	check(Saves.import_progress(transfer)!=OK and FileAccess.get_file_as_string(normal)==corrupt,"Odmítnutý import zachová přesné původní bajty")
	recovered=null
	file=FileAccess.open(normal,FileAccess.WRITE); file.store_string(JSON.stringify(valid)); file.close()
	shell.enter_world("Programming Academy"); game.programming.start("PY02","practice")
	game.programming.edit("main.py","x".repeat(131073))
	var over_key=game.programming.drafts.key(game.programming.draft_record())
	check(game.save()!=OK and game.unsaved and game.programming.files["main.py"].length()==131073,"Limit nezkrátí kód a zachová chybu zápisu")
	shell.enter_world("Rozcestník akademie")
	check(game.unsaved and game.programming.pending_drafts.has(over_key) and game.save()!=OK,"Odchod nezmění neuložený nadlimitní kód na údajně uložený")
	shell.enter_world("Programming Academy")
	check(game.programming.restore_draft(over_key),"Nadlimitní koncept lze vrátit k úpravě z paměti")
	game.programming.edit("main.py","# opravená délka\nprint(1)")
	check(game.save()==OK and game.programming.pending_drafts.is_empty(),"Po opravě limitu se uloží skutečný kratší text")
	editor=null; game=null; shell.queue_free(); shell=null; await frames(12)
	print("WORK PERSISTENCE: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
