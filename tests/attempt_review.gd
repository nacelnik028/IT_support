extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
const Review=preload("res://scripts/evaluation/AttemptReview.gd")
var game
var checks=0
var failures=0

func _init():
	root.gui_embed_subwindows=true
	var tag=str(OS.get_process_id())
	Saves.path_override="user://attempt_review_"+tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://attempt_review_"+tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override="user://attempt_review_"+tag+"_vr.cfg"
	Saves.save_game({},true); call_deferred("run")

func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; push_error(text)

func act(action: String, params: Dictionary = {}):
	var result=game.apply(action,params)
	check(result.ok and result.saved,"Skutečný zásah / "+action+": "+game.save_message)

func change_in(record: Dictionary, path: String, before, after) -> bool:
	for event in record.events:
		for change in event.changes:
			if change.path==path and typeof(change.before)==typeof(before) and typeof(change.after)==typeof(after) and change.before==before and change.after==after: return true
	return false

func network(dns: String = "192.168.20.10"):
	act("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":dns,"firewall":true})

func run():
	game=Game.new(); game.start_mission(3,true)
	check(not game.complete().ok and game.work.data.reviews.is_empty(),"Neodevzdaný pokus není hotový rozbor")
	act("physical_inspect",{"device":"PVE-01"}); network(); act("probe",{"vm":"100"})
	check(not game.apply("power",{"vm":"UNKNOWN","power":"Start"}).ok,"Odmítnutá operace vznikne skutečným vstupem")
	var rejected=game.sim.state._trace.events.back()
	check(rejected.kind=="rejected" and rejected.changes.is_empty(),"Odmítnutí není vykázáno jako oprava")
	act("verify")
	var proof_revision=game.sim.state.revision
	network("192.168.20.11")
	check(game.sim.state.revision>proof_revision and not game.sim.state.verified.get("service_pve",false),"Změna po ověření zneplatní důkaz")
	check(game.sim.state._trace.events.filter(func(event): return event.kind=="verification").back().revision<game.sim.state.revision,"Strukturovaný důkaz má vlastní revizi")
	check(game.undo(),"Skutečné undo poslední konfigurace")
	check(not game.sim.state._trace.events.any(func(event): return event.changes.any(func(change): return change.path=="vms.100.dns" and str(change.after)=="192.168.20.11")),"Undo neukáže vrácenou změnu jako provedenou opravu")
	var result=game.complete()
	check(result.ok and result.saved and result.has("review"),"Předání vytvoří uložený konkrétní rozbor")
	var record=result.review
	check(change_in(record,"vms.100.vlan",30.0,20),"Rozbor má skutečnou VLAN před/po")
	check(record.events.any(func(event): return event.action=="network" and event.target=="100 / PVE-01"),"Správný stroj a skutečný hostitel")
	check(not record.initial_probes["100"].app and record.probes["100"].app and record.verified.service_pve,"Příčina a současný výsledek vycházejí z modelu")
	check(record.recommendations.size()>0 and record.recommendations.all(func(lesson): return not game.Saves.rules().lesson_by_id(int(lesson.id)).is_empty()),"Doporučení odkazuje na skutečná ID lekcí")
	var xp=game.progress.xp; var id=record.id
	game=Game.new()
	check(game.work.data.reviews.any(func(item): return item.id==id) and game.progress.xp==xp,"Rozbor přežil nový GameManager bez odměny")
	var ui=load("res://scenes/main_menu/Main.tscn").instantiate(); ui.game=game; root.add_child(ui)
	preload("res://scripts/ui/DebriefPresentation.gd").show(ui,game.work.data.reviews[0])
	for i in 6: await process_frame
	var answer: Button
	for button in ui.find_children("*","Button",true,false):
		if button.text==Review.question(record).options[0][1]: answer=button; break
	check(answer!=null,"Dobrovolná otázka je skutečné tlačítko")
	if answer!=null:
		for scroll in ui.get_scroll_ancestors(answer): scroll.ensure_control_visible(answer)
		for i in 6: await process_frame
		var viewport=answer.get_viewport(); var at=answer.get_global_rect().get_center()+Vector2(viewport.position)
		var motion=InputEventMouseMotion.new(); motion.position=at; root.push_input(motion,true)
		for down in [true,false]:
			var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; root.push_input(event,true); await process_frame
		for i in 6: await process_frame
		check(game.work.data.reviews[0].answer=="verify_current" and game.progress.xp==xp,"Press/release otázky zachová výsledek a neudělí XP")
	ui.queue_free(); ui=null
	for i in 6: await process_frame
	game.shifts.start("SHIFT-DISK")
	act("physical_inspect",{"device":"NAS-01"}); act("physical_identify",{"pool":"RAID","slot":"2","serial":"DC-002"}); game.complete()
	act("physical_remove",{"pool":"RAID","slot":"2","serial":"DC-002","backup_checked":true,"confirmed":true}); act("physical_spare",{"spare":"SPARE-2T"}); act("physical_insert",{"pool":"RAID","slot":"2","backup_checked":true})
	result=game.complete(); record=result.review
	check(result.ok and record.events.any(func(event): return event.action=="physical_insert" and event.target=="RAID / slot 2"),"Storage rozbor patří konkrétnímu slotu")
	check(record.events.any(func(event): return event.changes.any(func(change): return change.path=="disks.2.serial" and change.before=="DC-002" and change.after!="DC-002")),"Skutečný serial před/po fyzické výměně")
	act("rebuild",{"pool":"RAID"}); act("rebuild",{"pool":"RAID"}); act("verify"); act("physical_monitor"); result=game.complete()
	check(result.review.final["raid.health"]=="Healthy" and result.review.verified.raid,"Storage rozbor ukáže ověřený Healthy")
	game.shifts.start("SHIFT-VM"); act("physical_inspect",{"device":"HV-01"}); act("inspect",{"scope":"Events"}); game.complete()
	act("memory",{"vm":"200","cpu":2,"ram":4,"minimum":2,"maximum":8,"dynamic":true}); act("power",{"vm":"200","power":"Start"}); act("verify"); result=game.complete()
	check(change_in(result.review,"vms.200.ram",24.0,4) and result.review.events.any(func(event): return event.target=="200 / HV-01"),"VM rozbor ukáže správnou RAM i hostitele")
	act("backup",{"vm":"200"}); act("backup_verify",{"operation":"Verify"}); act("verify"); result=game.complete()
	check(result.review.events.any(func(event): return event.action=="backup" and event.changes.any(func(change): return change.path=="backup.records.200.ram")),"Záloha má vlastní skutečnou změnu uloženého bodu")
	check(result.review.final["backup.verified"] and result.review.probes["200"].app,"Verify zálohy a živá aplikace jsou samostatné důkazy")
	game.start_mission(3,true)
	check(game.sim.state._trace.events.is_empty() and game.sim.state._trace.session==game.attempt_id,"Nový pokus nemá cizí živou historii")
	var bad=Saves.load_game(); bad.session.state._trace.session="jiná-relace"
	check(not Saves.rules().valid(bad),"Cizí identita strukturované historie odmítnuta")
	check(Saves.rules().valid(Saves.load_game()),"Nové rozbory jsou validní v save")
	game.enter_programming(); game.programming.start("PY01","practice")
	game.programming.edit("main.py","print('částečný výstup')\nprint(unknown_name)")
	var failed=game.programming.test_program()
	check(not failed.ok and failed.saved,"Skutečný chybný program má uložený testový výsledek")
	var last=game.programming.progress.attempts.back()
	check(last.diagnostics.any(func(diagnostic): return diagnostic.get("file")=="main.py" and int(diagnostic.get("line",0))==2),"Programovací rozbor zachová skutečný soubor a známý řádek chyby")
	game=Game.new()
	check(game.programming.progress.attempts.back().detail==last.detail and game.programming.dashboard().contains("main.py:2"),"Konkrétní programovací diagnostika je dostupná po restartu")
	game=null
	print("ATTEMPT REVIEW: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
