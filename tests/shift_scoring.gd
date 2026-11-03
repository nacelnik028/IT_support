extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Game=preload("res://scripts/core/GameManager.gd")
var checks=0
var failures=0
var ui
var game
var baseline=false

func _init():
	root.gui_embed_subwindows=true
	var tag=str(OS.get_process_id())
	Saves.path_override="user://shift_scoring_"+tag+".json"
	Settings.path_override="user://shift_scoring_"+tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override="user://shift_scoring_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	var settings=Settings.new(); settings.resolution=Vector2i(1600,900); settings.save_settings()
	baseline="--baseline" in OS.get_cmdline_user_args()
	call_deferred("run")

func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; push_error(text)

func frames():
	for i in 5: await process_frame

func act(action: String, params: Dictionary = {}):
	var result=game.apply(action,params)
	check(result.ok and result.saved,"Skutečná operace a zápis / "+action+": "+result.text)

func run():
	ui=load("res://scenes/main_menu/Main.tscn").instantiate(); root.add_child(ui); await frames(); game=ui.game
	game.shifts.start("SHIFT-NET"); ui.page="Serverovna"; ui.draw_ui(); ui.context_open=true; ui.draw_ui(); await frames()
	var hint: Button
	for button in ui.root_box.find_children("*","Button",true,false):
		if button.text.begins_with("Nápověda"): hint=button; break
	check(hint!=null,"Skutečné tlačítko nápovědy směny")
	if hint==null: ui.queue_free(); quit(1); return
	var callback=hint.pressed.get_connections()[0].callable
	var at=hint.get_global_rect().get_center()
	var motion=InputEventMouseMotion.new(); motion.position=at; root.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; root.push_input(event,true); await process_frame
	await frames()
	check(game.hints_used==1,"Jedna skutečná nápověda má jedno použití")
	if not baseline:
		callback.call(); callback.call()
		check(game.hints_used==1,"Starý callback ani druhý trigger nepřičte další stupeň")
	var restored=Game.new(); game=restored
	check(game.hints_used==(0 if baseline else 1),"Obnova počítadla; baseline dokládá původní chybu")
	act("physical_inspect",{"device":"PVE-01"}); act("physical_cable",{"device":"PVE-01","port":1,"connected":true})
	var revision=game.session_revision; var first=game.complete(revision)
	check(first.ok and first.score==(100 if baseline else 96),"Baseline ignoruje nápovědu / opravená metodika odečte přesně 4 body")
	check(not game.complete(revision).ok,"Starý token předání se odmítne")
	if not baseline:
		check(first.breakdown.hints==1 and first.breakdown.hint_penalty==4 and first.breakdown.score==96,"Jednotný uložený rozpis hodnocení")
		check(game.hints_used==0 and game.shifts.data.session.results[0].breakdown.hints==1,"Nový ticket má vlastní nápovědy a zachová předchozí")
	act("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true})
	act("verify"); var second=game.complete()
	check(second.ok and second.score==100,"Druhý ticket znovu neodečítá nápovědu prvního")
	act("backup",{"vm":"100"}); act("backup_verify",{"operation":"Verify"}); act("verify")
	var before=FileAccess.get_file_as_string(Saves.path_override)
	DirAccess.make_dir_absolute(ProjectSettings.globalize_path(Saves.path_override+".tmp"))
	var final=game.complete(); var xp=game.progress.xp
	check(final.ok and not final.saved and game.unsaved,"Výsledek vznikne jednou i při chybě zápisu")
	check(FileAccess.get_file_as_string(Saves.path_override)==before,"Chyba zápisu chrání poslední úspěšný soubor")
	check(not game.complete().ok and game.progress.xp==xp,"Opakované odevzdání nevydělá další XP")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Saves.path_override+".tmp"))
	check(game.save()==OK and game.progress.xp==xp,"Retry zapisuje existující odměnu")
	game=Game.new()
	check(game.progress.xp==xp and game.shifts.data.session.finished,"Restart zachová jedinou odměnu")
	if not baseline:
		game.shifts.start("SHIFT-VM")
		check(not game.apply("power",{"vm":"unknown","power":"Start"}).ok,"Chybný zásah je skutečně odmítnutý")
		act("physical_inspect",{"device":"HV-01"}); act("inspect",{"scope":"Events"})
		check(game.complete().score==92,"Chyba patří ticketu, ve kterém vznikla")
		act("memory",{"vm":"200","cpu":2,"ram":4,"minimum":2,"maximum":8,"dynamic":true}); act("power",{"vm":"200","power":"Start"}); act("verify")
		check(game.complete().score==100,"Stará chyba se v dalším ticketu znovu neodečte")
		var old=Saves.load_game(); old.shifts.session.erase("score_version"); old.shifts.session.erase("hints"); old.shifts.session.erase("error_base"); old.shifts.session.erase("risk_base")
		check(Saves.rules().valid(old),"Platný starý rozpracovaný formát je stále přijímaný")
		for record in old.shifts.session.results: record.erase("breakdown"); record.erase("time")
		var known=old.shifts.session.results.duplicate(true); var known_xp=old.progress.xp
		var file=FileAccess.open(Saves.path_override,FileAccess.WRITE); file.store_string(JSON.stringify(old)); file.close()
		game=Game.new()
		check(game.shifts.data.session.get("score_version",1)==1 and game.shifts.data.session.results==known and game.progress.xp==known_xp,"Skutečný starý rozpracovaný save neodhaduje nápovědy, nepřepočítá výsledky ani XP")
	ui.queue_free(); ui=null; game=null; restored=null; await frames()
	print("SHIFT SCORING%s: %d checks, %d failures" % [" BASELINE" if baseline else "",checks,failures]); quit(1 if failures else 0)
