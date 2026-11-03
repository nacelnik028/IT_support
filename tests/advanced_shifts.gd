extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
var game
var checks=0
var failures=0

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://advanced_shifts_"+tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://advanced_shifts_"+tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override="user://advanced_shifts_"+tag+"_vr.cfg"
	Saves.save_game({},true); call_deferred("run")

func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; push_error(text)

func same(a,b) -> bool: return JSON.parse_string(JSON.stringify(a))==JSON.parse_string(JSON.stringify(b))

func act(action: String, params: Dictionary = {}):
	var result=game.apply(action,params)
	check(result.ok,"Operace "+action+": "+result.text)
	check(result.get("saved",false) and not game.unsaved,"Zápis "+action+": "+game.save_message)

func choose(index: int):
	var before=game.sim.state.duplicate(true)
	check(game.shifts.select_ticket(index),"Výběr otevřeného incidentu "+str(index))
	check(same(before,game.sim.state),"Výběr nepřepíše svět ani ověření")

func handoff(index: int):
	choose(index)
	var revision=game.session_revision
	var result=game.complete(revision)
	check(result.ok and result.saved,"Předání skutečného stavu "+str(index)+": "+result.text)
	check(not game.complete(revision).ok,"Dvojí/staré předání odmítnuto")

func fix_network():
	act("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true})

func fix_fs():
	act("memory",{"vm":"200","cpu":2,"ram":4,"minimum":2,"maximum":8,"dynamic":true})
	act("power",{"vm":"200","power":"Start"})

func fix_pbs():
	act("physical_inspect",{"device":"BACKUP-01"})
	act("physical_cable",{"device":"BACKUP-01","port":6,"connected":true})

func fresh_backups():
	act("backup",{"vm":"100"}); act("backup",{"vm":"200"}); act("backup_verify",{"operation":"Verify"}); act("verify")

func run():
	game=Game.new(); game.start_mission(3,true)
	var campaign=game.snapshot().duplicate(true)
	var impacts=[]
	for order in 2:
		check(game.shifts.start("SHIFT-RECOVERY"),"Pokročilá obnova / pořadí "+str(order))
		check(game.shifts.definition("SHIFT-RECOVERY").tickets.size()==5 and game.shifts.data.session.metrics.size()==5,"Pět současných skutečných kontextů")
		check(not game.complete().ok,"Předčasné předání ukáže nesplněný stav")
		if order==0:
			check(not game.apply("backup",{"vm":"100"}).ok and game.unsaved==false,"Předčasná záloha odmítnuta a chyba uložena")
			fix_network()
			check(game.sim.Network.probe(game.sim.state,"100").app and not game.sim.Network.probe(game.sim.state,"200").app,"První priorita obnovila pouze APP01")
			act("shift_wait",{"minutes":1}); fix_fs()
		else:
			choose(1); fix_fs()
			check(game.sim.Network.probe(game.sim.state,"200").app and not game.sim.Network.probe(game.sim.state,"100").app,"Alternativní priorita obnovila pouze FS01")
			fix_network(); act("shift_wait",{"minutes":1})
		impacts.append(int(game.sim.state.shift_runtime.outage_minutes))
		act("physical_spare",{"spare":"SPARE-2T"})
		act("verify")
		check(game.sim.state.shift_runtime.fired==["REC-PBS-LINK"] and not game.sim.state.world.devices["BACKUP-01"].cable_connected,"Podmíněný uplink skutečně selhal jednou")
		check(game.sim.state.world.held=="SPARE-2T" and game.sim.state.vms["200"].ram==4,"Plánovaný incident nevrátil inventář ani RAM do baseline")
		game=Game.new()
		check(game.session_kind=="shift" and game.sim.state.shift_runtime.fired==["REC-PBS-LINK"] and game.sim.state.world.held=="SPARE-2T","Restart obnovil incident i konkrétní inventář")
		act("verify")
		check(game.sim.state.shift_runtime.events.size()==1,"Opakované ověření neaktivuje druhý výpadek")
		choose(2); fix_pbs(); act("physical_return_spare")
		fresh_backups()
		for index in ([0,1,2,3,4] if order==0 else [1,0,2,4,3]): handoff(index)
		check(game.shifts.data.session.finished and game.shifts.data.session.results.size()==5,"Celá pětiticketová obnova dokončena oběma pořadími")
		var xp=game.progress.xp; var best=game.shifts.data.best.duplicate(true)
		game=Game.new()
		check(game.progress.xp==xp and same(game.shifts.data.best,best) and not game.complete().ok,"Znovunačtení hotové směny neodměňuje")
		game.resume_campaign(); check(same(game.snapshot(),campaign),"Kampaň po pokročilé obnově přesně zachována")
	check(impacts==[1,0],"Volba oprav a explicitního času změnila reálný sledovaný provozní dopad")
	for order in 2:
		check(game.shifts.start("SHIFT-RESILIENCE"),"Pokročilý storage / pořadí "+str(order))
		if order==0: fix_pbs()
		choose(2); act("integration",{"vm":"200","agent":true,"vss":true,"auto_start":"StartIfRunning","auto_stop":"ShutDown"})
		if order==1: fix_pbs()
		choose(1)
		act("physical_identify",{"pool":"RAID","slot":"2","serial":"DC-002"})
		act("physical_remove",{"pool":"RAID","slot":"2","serial":"DC-002","backup_checked":true,"confirmed":true})
		act("physical_spare",{"spare":"SPARE-2T"})
		act("physical_insert",{"pool":"RAID","slot":"2","backup_checked":true})
		if order==1:
			DirAccess.make_dir_absolute(ProjectSettings.globalize_path(Saves.path_override+".tmp"))
			var result=game.apply("rebuild",{"pool":"RAID"})
			check(result.ok and not result.saved and game.sim.state.shift_runtime.events.size()==1,"Plánovaný incident při selhání zápisu vznikne pouze jednou")
			DirAccess.remove_absolute(ProjectSettings.globalize_path(Saves.path_override+".tmp"))
			check(game.save()==OK and game.sim.state.shift_runtime.events.size()==1,"Retry zápisu znovu neaktivuje incident")
		else: act("rebuild",{"pool":"RAID"})
		check(not game.sim.state.raid.cache and game.sim.state.shift_runtime.fired==["STO-CACHE-POWER"],"50 % rebuildu aktivovalo skutečnou poruchu ochrany cache")
		check(game.undo() and game.sim.state.shift_runtime.fired.is_empty() and game.sim.state.raid.cache and int(game.sim.state.raid.progress)==0,"Undo vrátí model i plánovač do stejného bodu")
		act("rebuild",{"pool":"RAID"})
		var held_serial=game.sim.state.disks["2"].serial
		game=Game.new()
		check(game.sim.state.disks["2"].serial==held_serial and not game.sim.state.world.stock["SPARE-2T"].available and game.sim.state.shift_runtime.events.size()==1,"Nový GameManager zachoval použitý díl a jedinou aktivaci")
		act("rebuild",{"pool":"RAID"})
		choose(3); act("cache",{"policy":"Write-through"})
		fresh_backups(); act("physical_monitor")
		for index in ([0,1,2,3,4] if order==0 else [2,0,3,1,4]): handoff(index)
		check(game.shifts.data.session.finished and game.sim.state.raid.health=="Healthy" and game.sim.state.shift_runtime.events.size()==1,"Celý storage dokončen alternativním pořadím bez opakovaného incidentu")
		game.resume_campaign(); check(same(game.snapshot(),campaign),"Kampaň po storage zachována")
	game.shifts.start("SHIFT-RESILIENCE")
	act("physical_remove",{"pool":"RAID","slot":"3","serial":"DC-003","backup_checked":true,"confirmed":true})
	check(game.sim.state.raid.health=="Failed" and game.sim.state.world.data_loss.RAID and not game.sim.Network.probe(game.sim.state,"100").app,"Chybné pořadí/výběr zdravého člena skutečně vyřadí RAID10 a aplikaci")
	check(not game.complete().ok and not game.apply("rebuild",{"pool":"RAID"}).ok,"Předání ani samotný rebuild ztrátu dat nespraví")
	check(game.restart_current() and game.sim.state.raid.health=="Degraded" and game.sim.state.shift_runtime.fired.is_empty() and game.sim.state.world.stock["SPARE-2T"].available,"Výslovný restart obnoví pokus i plánovač/inventář, ne odměnu")
	var state=game.sim.state.duplicate(true)
	game.enter_hub(); game.enter_training(); game.start_lesson(1002,"exam",false); game.enter_programming(); game.enter_english(); game.leave_training()
	check(same(game.sim.state,state) and same(game.suspended_campaign,campaign),"Souběžná směna a kampaň přežily všechny oblasti")
	var runtime=game.sim.state.shift_runtime.duplicate(true)
	await create_timer(0.15).timeout
	check(game.sim.state.shift_runtime==runtime,"Bez výslovného posunu nepřibývá čas nebo incident")
	var data=Saves.load_game()
	for mutation in ["duplicate","event","metrics","index"]:
		var bad=data.duplicate(true)
		match mutation:
			"duplicate": bad.shifts.session.state.shift_runtime.fired=["STO-CACHE-POWER","STO-CACHE-POWER"]
			"event": bad.shifts.session.state.shift_runtime.events=[{"id":"UNKNOWN","revision":0,"clock":0}]
			"metrics": bad.shifts.session.metrics["0"].hints=-1
			"index": bad.shifts.session.index=5
		check(not Saves.rules().valid(bad),"Neplatný plánovač/kontext odmítnut / "+mutation)
	check(Saves.rules().valid(Saves.load_game()),"Konečný pokročilý save validní")
	var ui=load("res://scenes/main_menu/Main.tscn").instantiate(); ui.game=game; root.add_child(ui)
	ui.page="Souvislé směny"; ui.draw_ui()
	for i in 6: await process_frame
	var choice: Button
	for button in ui.root_box.find_children("*","Button",true,false):
		if button.text=="Vybrat incident / STO-VSS": choice=button; break
	check(choice!=null,"Fronta skutečně nabízí otevřený incident s prioritou a závislostí")
	if choice!=null:
		for scroll in ui.get_scroll_ancestors(choice): scroll.ensure_control_visible(choice)
		for i in 6: await process_frame
		var before=game.sim.state.duplicate(true)
		var at=choice.get_global_rect().get_center()
		var motion=InputEventMouseMotion.new(); motion.position=at; root.push_input(motion,true)
		for down in [true,false]:
			var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; root.push_input(event,true); await process_frame
		for i in 6: await process_frame
		check(int(game.shifts.data.session.index)==2 and same(before,game.sim.state),"Úplný press/release vybírá prioritu bez modelové opravy")
	ui.queue_free(); ui=null
	for i in 6: await process_frame
	game=null
	print("ADVANCED SHIFTS: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
