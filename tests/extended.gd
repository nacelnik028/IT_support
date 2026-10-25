extends SceneTree

const Sim=preload("res://scripts/simulation/InfrastructureSimulator.gd")
var failures=0
var count=0

func check(ok,message):
	count+=1
	if not ok: failures+=1; push_error(message)

func _init():
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://academy_test_extended.cfg"
	preload("res://scripts/progression/SaveManager.gd").path_override="user://academy_test_extended.json"
	var sim=Sim.new()
	sim.reset({})
	check(sim.act("create_ct",{"id":"300","name":"MON01","template":"debian-12.tar.zst","cpu":1,"ram":1,"disk":8,"unprivileged":true,"mount":"Bind","backup_mount":false}).ok,"LXC unprivileged")
	check(sim.state.ct["300"].mount=="Bind","Mount zachován")
	check(not sim.act("create_ct",{"id":"301","name":"BAD","unprivileged":false}).ok,"Privileged bez potřeby blokován")
	check(sim.act("security",{"role":"PVEVMUser","mfa":true,"restricted":true}).ok,"MFA a omezená práva")
	check(not sim.act("repositories",{"repo":"Enterprise","subscription":false,"environment":"Lab"}).ok,"Enterprise bez subscription")
	check(sim.act("repositories",{"repo":"No-subscription","subscription":false,"environment":"Lab"}).ok,"Lab repo")
	check(sim.act("update",{"window":true}).ok,"Aktualizace po kontrole")
	check(sim.act("checkpoint",{"vm":"200","name":"BadVSS","type":"Production"}).ok,"Výchozí VSS je funkční")
	sim.state.vms["200"].vss=false
	check(not sim.act("checkpoint",{"vm":"200","name":"Broken","type":"Production"}).ok,"VSS chyba bez fallback")
	check(sim.act("checkpoint",{"vm":"200","name":"RAM","type":"Standard"}).ok,"Standard checkpoint")
	check(sim.state.vms["200"].checkpoints.back().ram_saved,"Standard zachytí RAM")
	sim.reset({})
	var before=sim.state.storage.used
	check(sim.act("attach_vhd",{"vm":"200","path":"D:/fixed.vhdx","size":50,"type":"Fixed","parent":"Žádný"}).ok,"Fixed VHDX")
	check(sim.state.storage.used==before+50,"Fixed fyzicky alokuje místo")
	check(sim.act("guest_volume",{"vm":"200","style":"GPT","fs":"ReFS","letter":"E"}).ok,"Nový datový svazek uvnitř VM")
	check(sim.state.vms["200"].data_disk.filesystem==50,"Guest vidí nový svazek")
	check(not sim.act("guest_volume",{"vm":"200","style":"GPT","fs":"NTFS","letter":"F"}).ok,"Znovu neformátuje původní data")
	sim.reset({})
	before=sim.state.storage.used
	check(sim.act("attach_vhd",{"vm":"200","path":"D:/dynamic.vhdx","size":100,"type":"Dynamic","parent":"Žádný"}).ok,"Dynamic VHDX")
	check(sim.state.storage.used==before+1,"Dynamic alokuje pouze obsazený začátek")
	sim.reset({})
	check(not sim.act("attach_vhd",{"vm":"200","path":"D:/diff.vhdx","size":80,"type":"Differencing","parent":"Žádný"}).ok,"Differencing potřebuje rodiče")
	check(sim.act("attach_vhd",{"vm":"200","path":"D:/diff.vhdx","size":80,"type":"Differencing","parent":"BASE-WINDOWS.vhdx"}).ok,"Differencing s read-only rodičem")
	check(not sim.act("guest_volume",{"vm":"200","style":"GPT","fs":"NTFS","letter":"E"}).ok,"Differencing původní image se neformátuje")
	sim.reset({})
	check(sim.act("replica",{"vm":"200","target":"HV-02","interval":300,"points":6}).ok,"Replica synchronizace")
	check(sim.act("replica_test",{"vm":"200"}).ok,"Test Failover")
	check(sim.state.vms["902"].host=="HV-02" and sim.state.vms["902"].isolated,"Test replika je izolovaná na targetu")
	check(sim.act("power",{"vm":"902","power":"Start"}).ok,"Start testovací repliky")
	check(sim.state.vms["200"].status=="Running","Produkce pokračuje")
	sim.reset({"raid":{"members":[],"capacity":0,"initialized":false}})
	for d in sim.state.disks.values(): d.pool=""; d.used=0
	check(sim.act("raid_create",{"name":"TEST","level":"RAID 10","members":["0","1","2","3"],"spare":"4","controller":"Hardware RAID"}).ok,"RAID s hot spare")
	check(sim.state.raid.capacity==4000,"Spare nepřidá kapacitu")
	sim.act("raid_initialize",{})
	check(sim.act("raid_failure",{"slot":"0"}).ok,"Výpadek člena s hot spare")
	check(sim.state.raid.rebuilding and "4" in sim.state.raid.members and not sim.state.disks["4"].spare,"Spare automaticky zahájí rebuild")
	sim.act("rebuild",{"pool":"RAID"})
	sim.act("rebuild",{"pool":"RAID"})
	check(sim.state.raid.health=="Healthy","Rebuild spare dokončen")
	sim.reset({})
	check(sim.act("share",{"name":"Projekty","group":"GG_Projekty_RW","ntfs":"Modify","access":"Change","quota":300,"mode":"Hard"}).ok,"SMB hard quota")
	before=sim.state.storage.used
	check(sim.act("quota_test",{"amount":10}).ok,"Očekávané odmítnutí zápisu není chyba administrátora")
	check(sim.state.storage.used==before,"Hard quota zabrání zápisu")
	sim.state.share.mode="Soft"
	check(sim.act("quota_test",{"amount":10}).ok and sim.state.storage.used==before+10,"Soft quota jen upozorní")
	print("EXTENDED: %d checks, %d failures" % [count,failures])
	quit(0 if failures==0 else 1)
