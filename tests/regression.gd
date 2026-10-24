extends SceneTree

const Sim = preload("res://scripts/simulation/InfrastructureSimulator.gd")
const Raid = preload("res://scripts/simulation/RAIDSimulator.gd")
const Net = preload("res://scripts/simulation/NetworkSimulator.gd")
const Terminal = preload("res://scripts/simulation/TerminalParser.gd")
const Game = preload("res://scripts/core/GameManager.gd")
const Saves = preload("res://scripts/progression/SaveManager.gd")
var failures=0
var checks=0

func check(ok, message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func _init():
	Saves.path_override="user://academy_test_regression.json"
	# The last assertion intentionally corrupts this file; each run starts fresh.
	Saves.save_game({},true)
	var evaluator=preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
	var mixed=evaluator.evaluate({"value":[]},[{"path":"value","value":"SYS-A + SYS-B","label":"Instalační cíl"}])
	check(not mixed[0].passed,"Počáteční Array proti cílovému String nesmí vyvolat runtime chybu")
	check(evaluator.equal_values(4,4.0),"Čísla z JSON a SpinBox se porovnají hodnotou")
	check(not evaluator.equal_values(true,1),"Bool není číselný splněný cíl")
	check(not evaluator.evaluate({},[{"path":"missing","value":20,"label":"Chybějící kapacita","op":"gte"}])[0].passed,"Chybějící číselný stav nesplní cíl")
	check(not evaluator.evaluate({"value":42},[{"path":"value","value":"disk","label":"Neplatný contains","op":"contains"}])[0].passed,"Contains na čísle je nesplněný cíl bez pádu")
	for row in [["RAID 0",[2000,2000],4000],["RAID 1",[2000,2000],2000],["RAID 5",[2000,2000,2000],4000],["RAID 6",[2000,2000,2000,2000,2000,2000],8000],["RAID 10",[2000,2000,2000,2000],4000],["RAID 10",[2000,2000,2000],0],["RAID 6",[1000,2000,3000,4000],2000]]:
		check(Raid.capacity(row[0],row[1])==float(row[2]),"Kapacita "+row[0])
	check(absf(Raid.tb_to_tib(8)-7.27596)<0.0001,"TB vs TiB")
	var sim=Sim.new()
	sim.reset({})
	sim.state.disks["0"].health="Failed"
	sim.state.disks["2"].health="Failed"
	check(Raid.health("RAID 10",["0","1","2","3"],sim.state.disks)=="Degraded","RAID10 různé páry přežijí")
	sim.state.disks["2"].health="Healthy"
	sim.state.disks["1"].health="Failed"
	check(Raid.health("RAID 10",["0","1","2","3"],sim.state.disks)=="Failed","RAID10 stejný pár selže")
	check(Raid.health("RAID 6",["0","1","2","3"],sim.state.disks)=="Degraded","RAID6 přežije dva")
	sim.state.disks["2"].health="Failed"
	check(Raid.health("RAID 6",["0","1","2","3"],sim.state.disks)=="Failed","RAID6 nepřežije tři")
	sim.reset({})
	check(Net.probe(sim.state,"100").app,"Výchozí aplikace")
	sim.act("network",network_params(30))
	check(not Net.probe(sim.state,"100").link,"Chybná VLAN poruší L2")
	check(Net.probe(sim.state,"200").app,"VLAN APP01 neovlivní FS01")
	var params=network_params(20)
	params.dns="192.168.20.99"
	sim.act("network",params)
	check(Net.probe(sim.state,"100").ip and not Net.probe(sim.state,"100").dns and not Net.probe(sim.state,"100").app,"IP není DNS ani aplikace")
	sim.act("network",network_params(20))
	sim.state.vms["100"].service=false
	check(Net.probe(sim.state,"100").ip and not Net.probe(sim.state,"100").app,"Ping není HTTPS")
	sim.state.vms["100"].service=true
	for kind in ["External","Internal","Private"]:
		sim.act("switch",{"name":"TEST","type":kind,"adapter":"Ethernet2","management":true})
		var cfg=network_params(20)
		cfg.vm="200"
		cfg.ip="192.168.20.200"
		cfg.bridge="TEST"
		sim.act("network",cfg)
		check(Net.probe(sim.state,"200","application").app==(kind=="External"),kind+" internet")
		check(Net.probe(sim.state,"200","host").ip==(kind!="Private"),kind+" host connectivity")
	sim.state.vms["201"]=sim.state.vms["200"].duplicate(true)
	sim.state.vms["201"].id="201"
	sim.state.vms["201"].ip="192.168.20.201"
	check(Net.probe(sim.state,"200","peer").ip,"Private VM peer na stejném hostiteli")
	sim.state.vms["201"].vlan=99
	check(not Net.probe(sim.state,"200","peer").link,"Private různé VLAN nepropojí")
	sim.reset({})
	var before=JSON.stringify(sim.state.disks)
	check(not sim.act("raid_create",{"name":"BAD","level":"RAID 10","members":["0","1","2","3"],"spare":"Žádný","controller":"Hardware RAID"}).ok,"Nelze přepsat původní pole")
	check(before==JSON.stringify(sim.state.disks),"Odmítnutí nesmí změnit původní disky")
	check(not sim.act("replace_disk",{"pool":"RAID","slot":"0","serial":"DC-000","size":2000,"backup_checked":true}).ok,"Zdravý disk se nevyměňuje jako vadný")
	sim.reset({"disks":{"2":{"health":"Failed"}},"raid":{"health":"Degraded"}})
	check(not sim.act("replace_disk",{"pool":"RAID","slot":"2","serial":"WRONG","size":2000,"backup_checked":true}).ok,"Serial musí odpovídat")
	check(sim.act("replace_disk",{"pool":"RAID","slot":"2","serial":"DC-002","size":2000,"backup_checked":true}).ok,"Bezpečná výměna")
	check(sim.state.raid.health=="Recovering","Vložení není dokončení rebuildu")
	sim.act("rebuild",{"pool":"RAID"})
	check(sim.state.raid.health!="Healthy","Poloviční rebuild nestačí")
	sim.act("rebuild",{"pool":"RAID"})
	check(sim.state.raid.health=="Healthy","Dokončený rebuild")
	sim.reset({"disk":{"old_data":true,"new":false,"online":true}})
	check(not sim.act("disk_initialize",{"style":"GPT"}).ok,"RAW původního disku se neinicializuje")
	check(not sim.act("volume",{"size":1000,"fs":"NTFS","letter":"D"}).ok,"RAW původního disku se neformátuje")
	check(not sim.act("foreign",{"operation":"Clear Foreign"}).ok,"Clear známých původních metadat blokováno")
	check(not sim.act("cache",{"policy":"Force write-back"}).ok,"Nechráněná cache blokována")
	check(not sim.act("san",{"target":"10.50.0.10","initiator":"iqn.2026-10.lab:hv01","lun":"LUN-01","paths":2,"mpio":true,"writers":"HV-01 + HV-02","clustered":false}).ok,"Nebezpečný multiwriter blokován")
	sim.reset({})
	check(not sim.act("restore",{"vm":"100","id":"900","isolated":false}).ok,"Konfliktní produkční restore blokován")
	check(not sim.act("failover",{}).ok,"Bez fencing není HA")
	check(not sim.act("live_migrate",{"vm":"200","target":"PVE-02","auth":"Kerberos","storage":true}).ok,"Smíšený nativní cluster/migrace blokován")
	sim.state.vms["100"].locked=true
	check(not sim.act("power",{"vm":"100","power":"Start"}).ok,"VM lock respektován")
	sim.reset({})
	var old_fs=sim.state.vms["200"].filesystem
	sim.act("power",{"vm":"200","power":"Shutdown"})
	check(sim.act("capacity",{"layer":"VM disk","size":150,"vm":"200"}).ok,"Resize VHDX")
	check(sim.state.vms["200"].filesystem==old_fs,"Resize VHDX nesmí zvětšit guest FS")
	sim.state.storage.used=sim.state.storage.capacity
	check(not sim.act("power",{"vm":"200","power":"Start"}).ok,"Plný pool zabrání startu")
	sim.reset({})
	for cmd in ["qm list","qm config 100","pct list","pvesm status","pveversion -v","zpool status","zpool list","lsblk","df -h","ip -br address","ip route","pvecm status"]:
		check(Terminal.execute(sim,cmd,"PVE-01").length()>0,"PVE příkaz "+cmd)
	check("Off" in Terminal.execute(sim,"qm shutdown 100"),"Terminál mění sdílený stav")
	check("Off" in Terminal.execute(sim,"qm list"),"Terminál čte změnu")
	check("Running" in Terminal.execute(sim,"qm start 100"),"Terminál start")
	for cmd in ["Get-VM","Get-VMHost","Get-VMSwitch","Get-VMNetworkAdapter -VMName 'FS01'","Get-VMHardDiskDrive -VMName FS01","Get-VMMemory","Get-VMIntegrationService","Get-VMSnapshot","Get-Disk","Get-Volume","Get-PhysicalDisk","Get-Service vmms"]:
		check(Terminal.execute(sim,cmd,"HV-01").length()>0,"PS příkaz "+cmd)
	check("FS01" in Terminal.execute(sim,'get-vm -Name "FS01"',"HV-01"),"PS bez ohledu na velikost písmen a s uvozovkami")
	check("řetězení" in Terminal.execute(sim,"qm list; rm -rf /"),"Shell injection odmítnuta")
	check("Neznámý" in Terminal.execute(sim,"rm -rf /"),"Neznámý příkaz je bezpečná chyba")
	var game=Game.new()
	game.start_mission(3,false)
	game.apply("inspect",{"scope":"Network"})
	game.apply("network",network_params(20))
	check(not game.complete().ok,"Bez závěrečného ověření se nedokončí")
	game.apply("verify",{})
	var result=game.complete()
	check(result.ok and result.score==100,"Správná práce má 100 bodů")
	var xp=game.progress.xp
	game.start_mission(3,false)
	game.apply("inspect",{"scope":"Network"})
	game.apply("network",network_params(20))
	game.apply("verify",{})
	game.complete()
	check(game.progress.xp==xp,"Opakování stejného skóre nesmí farmit XP")
	game.start_mission(4,true)
	game.apply("storage_cleanup",{"kind":"Orphan snapshots","checked":true})
	var saved_used=game.sim.state.storage.used
	check(game.save()==OK,"Uložení pozice")
	var loaded=Game.new()
	check(loaded.active and loaded.current.id==5 and loaded.sim.state.storage.used==saved_used,"Načtení rozpracované mise a změn")
	loaded.start_mission(4,true)
	check(loaded.sim.state.storage.used==495,"Restart obnoví počáteční stav")
	loaded.apply("storage_cleanup",{"kind":"Orphan snapshots","checked":true})
	loaded.undo()
	check(loaded.sim.state.storage.used==495,"Undo ve výukovém režimu")
	var f=FileAccess.open(Saves.save_path(),FileAccess.WRITE)
	f.store_string("invalid JSON")
	f.close()
	check(Saves.load_game().is_empty(),"Poškozený save je ošetřen")
	print("REGRESSION: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)

func network_params(vlan):
	return {"vm":"100","bridge":"vmbr0","vlan":vlan,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true}
