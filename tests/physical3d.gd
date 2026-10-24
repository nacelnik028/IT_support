extends SceneTree

const Game = preload("res://scripts/core/GameManager.gd")
const Saves = preload("res://scripts/progression/SaveManager.gd")
const Network = preload("res://scripts/simulation/NetworkSimulator.gd")
var count = 0
var failures = 0
var game

func _init():
	Saves.path_override = "user://academy_test_physical3d.json"
	game = Game.new()
	game.start_mission(0,true)
	game.sim.reset({"disks":{"2":{"health":"Failed"}},"raid":{"health":"Degraded"}})
	var p = {"pool":"RAID","slot":"2","serial":"DC-002","backup_checked":true,"confirmed":true}
	check(not game.apply("physical_remove",{"pool":"RAID","slot":"2","serial":"WRONG","backup_checked":true,"confirmed":true}).ok,"Nesprávný serial odmítnut")
	check(game.sim.state.disks["2"].health=="Failed","Chybný serial disk nevytáhne")
	p.backup_checked = false
	check(not game.apply("physical_remove",p).ok,"Záloha je povinná")
	p.backup_checked = true
	game.sim.state.world.devices["NAS-01"].hot_swap = false
	check(not game.apply("physical_remove",p).ok,"Hardware bez hot-swap vyžaduje vypnutí")
	check(game.apply("physical_power",{"device":"NAS-01","operation":"Shutdown"}).ok,"Bezpečné vypnutí NAS")
	check(game.apply("physical_remove",p).ok,"Fyzické vytažení vadného člena")
	check(game.sim.state.disks["2"].health=="Missing" and game.sim.state.raid.health=="Degraded","Prázdný slot snižuje redundanci")
	check(game.last_save_error==OK,"Prázdný slot uložen")
	game = Game.new()
	check(game.sim.state.world.removed.has("RAID:2") and game.sim.state.disks["2"].health=="Missing","Obnova fyzicky vytaženého disku po restartu")
	check(game.apply("physical_spare",{"spare":"SPARE-1T"}).ok,"Vzít konkrétní náhradu")
	check(not game.apply("physical_insert",{"pool":"RAID","slot":"2","backup_checked":true}).ok,"Menší náhradní disk se odmítne")
	check(game.apply("physical_return_spare",{}).ok,"Vrátit náhradu")
	game.apply("physical_spare",{"spare":"SPARE-SATA"})
	check(not game.apply("physical_insert",{"pool":"RAID","slot":"2","backup_checked":true}).ok,"Nesprávné rozhraní se odmítne")
	game.apply("physical_return_spare",{})
	game.apply("physical_spare",{"spare":"SPARE-2T"})
	check(game.apply("physical_insert",{"pool":"RAID","slot":"2","backup_checked":true}).ok,"Kompatibilní náhrada spustí existující rebuild")
	check(game.sim.state.disks["2"].serial=="SP-SAS-2000" and game.sim.state.raid.rebuilding,"Identita disku i pole se změní")
	check(game.apply("rebuild",{"pool":"RAID"}).ok and game.sim.state.raid.progress==50,"Rebuild pokračuje skutečným časem simulátoru")
	game = Game.new()
	check(game.sim.state.raid.rebuilding and game.sim.state.raid.progress==50,"Rozběhnutý rebuild se obnoví ze save")
	game.apply("rebuild",{"pool":"RAID"})
	game.apply("verify",{})
	check(game.sim.state.verified.raid and game.sim.state.raid.health=="Healthy","Konečný stav pole skutečně zdravý")
	game.sim.reset({})
	for slot in ["0","1"]:
		check(game.apply("physical_remove",{"pool":"RAID","slot":slot,"serial":"DC-00"+slot,"backup_checked":true,"confirmed":true}).ok,"Potvrzené vytažení zdravého disku má následky")
	check(game.sim.state.raid.health=="Failed" and game.sim.state.world.data_loss.RAID,"Dva členové stejného RAID10 páru způsobí selhání")
	check(not Network.probe(game.sim.state,"100").app,"Selhané fyzické RAID vyřadí službu VM")
	game.apply("physical_spare",{"spare":"SPARE-2T"})
	check(not game.apply("physical_insert",{"pool":"RAID","slot":"0","backup_checked":true}).ok,"Bez zdrojové kopie nelze předstírat obnovu")
	game.sim.reset({})
	check(Network.probe(game.sim.state,"100").app,"Výchozí služba běží")
	game.apply("physical_cable",{"device":"PVE-01","connected":false,"port":1})
	check(not Network.probe(game.sim.state,"100").link,"Odpojený fyzický kabel přeruší linku VM")
	check(not game.apply("physical_cable",{"device":"PVE-01","connected":true,"port":2}).ok,"Obsazený port nelze přepsat")
	game.apply("physical_cable",{"device":"PVE-01","connected":true,"port":8})
	check(not Network.probe(game.sim.state,"100").app,"Nesprávný volný port nedá správnou síť")
	game.apply("physical_cable",{"device":"PVE-01","connected":true,"port":1})
	check(Network.probe(game.sim.state,"100").app,"Správný fyzický port obnoví službu")
	game.apply("physical_power",{"device":"PVE-01","operation":"Shutdown"})
	check(not game.sim.state.hosts["PVE-01"].online and game.sim.state.vms["100"].status=="Off","Bezpečné vypnutí hostitele vypne jeho VM")
	game.apply("physical_supply",{"device":"PVE-01","connected":false})
	check(not game.apply("physical_power",{"device":"PVE-01","operation":"Start"}).ok,"Bez přívodu se server nespustí")
	game.apply("physical_supply",{"device":"PVE-01","connected":true})
	game.apply("physical_power",{"device":"PVE-01","operation":"Start"})
	check(game.apply("power",{"vm":"100","power":"Start"}).ok,"Start VM po fyzické opravě hostitele")
	check(game.last_save_error==OK,"Fyzické zařízení i mise zůstávají uložitelné")
	# The old campaign must be preserved through all three education modes.
	for mode in ["learn","practice","exam"]:
		game.start_mission(3,true)
		game.apply("physical_cable",{"device":"PVE-01","connected":false,"port":1})
		game.start_lesson(1002,mode,false)
		check(game.sim.state.world.devices["PVE-01"].cable_connected,"Lekce má vlastní fyzickou infrastrukturu: "+mode)
		game.resume_campaign()
		check(not game.sim.state.world.devices["PVE-01"].cable_connected,"Lekce zachovala fyzický stav kampaně: "+mode)
	print("PHYSICAL3D: %d checks, %d failures" % [count,failures])
	quit(0 if failures==0 else 1)

func check(value, message: String):
	count += 1
	if not value: failures += 1; push_error(message)
