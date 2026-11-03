extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
var game
var checks=0
var failures=0

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_shifts_"+tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://academy_test_shifts_"+tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override="user://academy_test_shifts_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	call_deferred("run")

func check(value, text):
	checks+=1
	if not value: failures+=1; push_error(text)

func act(action, params={}):
	var result=game.apply(action,params)
	check(result.ok,"Operace "+action+": "+result.text)
	check(not game.unsaved,"Uložení "+action+": "+game.save_message)

func submit():
	var revision=game.session_revision
	var result=game.complete(revision)
	check(result.ok,"Předání: "+result.text)
	check(result.get("saved",false),"Předání se skutečně uložilo")
	check(not game.complete(revision).ok,"Opakovaný trigger původního ticketu odmítnut")

func network(vm="100"):
	act("network",{"vm":vm,"bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true})

func run():
	game=Game.new(); game.start_mission(54,true)
	act("management",{"hostname":"preserved-campaign","ip":"192.168.10.10","gateway":"192.168.10.1","dns":"192.168.10.2"})
	var campaign=game.snapshot()
	for id in ["SHIFT-NET","SHIFT-VM","SHIFT-DISK"]:
		check(game.shifts.start(id),"Zahájení "+id)
		check(equivalent(game.suspended_campaign,campaign),"Zachována upravená kampaň")
		check(not game.complete().ok,"Předčasné odevzdání odmítnuto")
		if id=="SHIFT-NET":
			check(not game.apply("backup",{"vm":"100"}).ok,"Záloha bez sítě odmítnuta")
			# Correct later conditions first: accepting ticket 2 must retain them.
			network()
			act("physical_inspect",{"device":"PVE-01"}); act("physical_cable",{"device":"PVE-01","port":1,"connected":true})
			submit()
			check(game.sim.state.vms["100"].gateway=="192.168.20.1","Dřívější oprava přetrvala do ticketu 2")
			check(not game.complete().ok,"Další ticket vyžaduje aktuální ověření")
			act("verify"); submit()
			act("backup",{"vm":"100"}); act("backup_verify",{"operation":"Verify"}); act("verify")
			var old_xp=game.progress.xp
			var before=FileAccess.get_file_as_string(Saves.path_override)
			DirAccess.make_dir_absolute(ProjectSettings.globalize_path(Saves.path_override+".tmp"))
			var result=game.complete()
			check(result.ok and not result.saved and game.unsaved,"Odevzdání v paměti rozliší selhání zápisu")
			var paid_xp=game.progress.xp
			check(paid_xp>old_xp and FileAccess.get_file_as_string(Saves.path_override)==before,"Při chybě zápisu zůstane původní soubor")
			check(not game.complete().ok and game.progress.xp==paid_xp,"Opakování odevzdání při chybě zápisu neduplikuje odměnu")
			DirAccess.remove_absolute(ProjectSettings.globalize_path(Saves.path_override+".tmp"))
			check(game.save()==OK and game.progress.xp==paid_xp,"Opakovaný zápis zachová jedinou odměnu")
		elif id=="SHIFT-VM":
			act("physical_inspect",{"device":"HV-01"}); act("inspect",{"scope":"Events"}); submit()
			act("memory",{"vm":"200","cpu":2,"ram":4,"minimum":2,"maximum":8,"dynamic":true})
			act("power",{"vm":"200","power":"Start"}); act("verify"); submit()
			act("backup",{"vm":"200"}); act("backup_verify",{"operation":"Verify"}); act("verify"); submit()
		else:
			act("physical_inspect",{"device":"NAS-01"}); act("physical_identify",{"pool":"RAID","slot":"2","serial":"DC-002"}); submit()
			act("physical_remove",{"pool":"RAID","slot":"2","serial":"DC-002","backup_checked":true,"confirmed":true})
			act("physical_spare",{"spare":"SPARE-2T"})
			# Re-create GameManager, including inventory and removed serial.
			game=Game.new()
			check(game.session_kind=="shift" and game.sim.state.world.held=="SPARE-2T" and game.sim.state.world.removed.has("RAID:2"),"Nová aplikace obnoví konkrétní servis i inventář")
			act("physical_insert",{"pool":"RAID","slot":"2","backup_checked":true}); submit()
			act("rebuild",{"pool":"RAID"}); act("rebuild",{"pool":"RAID"}); act("verify"); act("physical_monitor"); submit()
		check(game.shifts.data.session.finished and game.shifts.data.session.results.size()==3,"Celá směna hotová")
		var xp=game.progress.xp
		check(not game.complete().ok and game.progress.xp==xp,"Dvojí odevzdání bez další odměny")
		game=Game.new()
		check(game.shifts.data.session.finished and game.session_kind=="shift","Hotová směna obnovena po restartu")
		game.resume_campaign()
		check(equivalent(game.snapshot(),campaign),"Výslovná kampaň vrací původní stav")
		check(game.progress.scores.is_empty(),"Směna neodemkla kampaň")
	game.shifts.start("SHIFT-NET"); network(); act("physical_spare",{"spare":"SPARE-2T"})
	var shift_state=game.sim.state.duplicate(true)
	for mode in ["learn","practice","exam"]:
		for cycle in 2:
			game.enter_hub(); game.enter_training(); game.start_lesson(1002,mode,false)
			game.enter_programming(); game.enter_english(); game.enter_hub(); game.leave_training()
			check(game.session_kind=="shift" and equivalent(game.sim.state,shift_state),"Přechody zachovají směnu / "+mode)
			check(equivalent(game.suspended_campaign,campaign),"Přechody zachovají kampaň / "+mode)
	game=Game.new()
	check(equivalent(game.sim.state,shift_state) and game.session_kind=="shift","Restart po přechodech obnoví směnu")
	check(game.shifts.start("SHIFT-NET") and game.undo_states.is_empty(),"Restart izoluje undo")
	check(game.sim.state.world.held=="" and game.sim.state.vms["100"].vlan==30,"Restart obnoví jen směnu")
	var valid=Saves.load_game()
	for mutation in ["id","version","index","results","state"]:
		var bad=valid.duplicate(true)
		match mutation:
			"id": bad.shifts.session.id="UNKNOWN"
			"version": bad.shifts.session.version=99
			"index": bad.shifts.session.index=3
			"results": bad.shifts.session.results=[{"ticket":2,"score":100}]
			"state": bad.shifts.session.state.world.held="UNKNOWN"
		check(not Saves.rules().valid(bad),"Neplatná větev odmítnuta / "+mutation)
	check(Saves.export_progress("user://academy_test_shift_transfer.json")==OK,"Export směny")
	game.resume_campaign(); check(Saves.import_progress("user://academy_test_shift_transfer.json")==OK,"Import směny")
	game=Game.new(); check(game.session_kind=="shift","Import obnoví směnu v nové aplikaci")
	var path=Saves.path_override
	var before=FileAccess.get_file_as_string(path)
	DirAccess.make_dir_absolute(ProjectSettings.globalize_path(path+".tmp"))
	act_without_save()
	check(game.unsaved and FileAccess.get_file_as_string(path)==before,"Selhání zápisu zachová poslední soubor")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path+".tmp"))
	check(game.save()==OK and not game.unsaved,"Opakování zápisu uspěje")
	var old=valid.duplicate(true); old.erase("shifts")
	check(Saves.rules().valid(old),"Starý platný save bez směn je přijímán")
	print("SHIFTS: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)

func act_without_save():
	game.apply("physical_inspect",{"device":"PVE-01"})

func equivalent(a,b):
	return JSON.parse_string(JSON.stringify(a))==JSON.parse_string(JSON.stringify(b))
