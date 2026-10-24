extends RefCounted

const Sim=preload("res://scripts/simulation/InfrastructureSimulator.gd")
const Eval=preload("res://scripts/evaluation/ObjectiveEvaluator.gd")
var rng=RandomNumberGenerator.new()
var missions: Array=[]
var solutions: Array=[]

func _init():
	missions=JSON.parse_string(FileAccess.get_file_as_string("res://data/missions/campaign.json"))
	solutions=JSON.parse_string(FileAccess.get_file_as_string("res://data/training/scenario_solutions.json"))

func generate(area: String,difficulty: String,count: int,seed_value: int=0) -> Array:
	if seed_value==0: rng.randomize()
	else: rng.seed=seed_value
	var candidates=[]
	for mission in missions:
		if (area=="Vše" or area in domains(mission)) and (difficulty=="Vše" or mission.difficulty==difficulty): candidates.append(mission)
	if candidates.is_empty() and area=="Zálohy" and difficulty=="Začátečník":
		var simple=missions[5].duplicate(true)
		simple.difficulty=difficulty
		simple.initial_state={"backup":{"configured":true,"records":{},"verified":false}}
		simple.title="První test obnovy z připraveného PBS"
		simple.description="PBS je již správně připravený. Zálohuj APP01, spusť Verify, obnov do900 v LAB, spusť kopii a ověř skutečná aplikační data."
		simple.reference=[["inspect",{"scope":"Backup"}],["backup",{"vm":"100"}],["backup_verify",{"operation":"Verify"}],["restore",{"vm":"100","id":"900","isolated":true}],["power",{"vm":"900","power":"Start"}],["verify",{}]]
		candidates.append(simple)
	if candidates.is_empty() and difficulty in ["Administrátor","Expert"]:
		var hv=area=="Hyper-V"
		var combined=missions[34 if hv else 3].duplicate(true)
		var id="200" if hv else "100"
		var size=[700,800,900][rng.randi_range(0,2)]
		combined.difficulty=difficulty
		combined.title="Propojený incident: síť a podkladové storage"
		combined.description="Po změně nefunguje%s. Oprav fyzický uplink/VLAN podle diagnostiky, obnov plný thin pool včetně metadat. Zdravé podkladové pole má4TB: rozšiř pool, logical disk a host filesystem na%dGiB. Pak spusť VM, proveď novou nezávislou zálohu a ověř službu." % ["FS01" if hv else "APP01",size]
		combined.initial_state.storage={"used":500,"metadata":100,"reclaimable":0}
		if not combined.initial_state.has("vms"): combined.initial_state.vms={}
		if not combined.initial_state.vms.has(id): combined.initial_state.vms[id]={}
		combined.initial_state.vms[id].status="Off"
		combined.initial_state.backup={"completed":false}
		combined.objectives.append(goal("storage.capacity",size))
		combined.objectives.append(goal("storage.host_fs",size))
		combined.objectives.append(goal("backup.completed",true))
		combined.objectives.append(goal("verified.capacity",true))
		combined.reference=[]
		for layer in ["Pool","Logical disk","Host filesystem"]: combined.reference.append(["capacity",{"layer":layer,"size":size,"vm":id}])
		combined.reference.append(["storage_cleanup",{"kind":"Thin metadata","checked":true}])
		combined.reference.append_array(solutions[34 if hv else 3].duplicate(true))
		combined.reference.append_array([["power",{"vm":id,"power":"Start"}],["backup",{"vm":id}],["verify",{}]])
		candidates.append(combined)
	var batch=[]
	var attempts=0
	while batch.size()<clampi(count,1,20) and attempts<200:
		attempts+=1
		var scenario={}
		var recipe=[]
		if difficulty in ["Vše","Začátečník","Pokročilý"] and rng.randf()<0.65:
			var kind=area if area!="Vše" else ["Proxmox","Hyper-V","RAID","Sítě"][rng.randi_range(0,3)]
			if kind in ["Proxmox","Hyper-V"]:
				var hv=kind=="Hyper-V"
				scenario=missions[10 if hv else 2].duplicate(true)
				var id=str(rng.randi_range(350,799))
				var ram=[2,4,8][rng.randi_range(0,2)]
				var cpu=[2,4][rng.randi_range(0,1)]
				var disk=[32,48,64,96][rng.randi_range(0,3)]
				var name=("WIN" if hv else "WEB")+str(rng.randi_range(10,99))
				var storage=["local-lvm","local-zfs"][rng.randi_range(0,1)]
				var params={"id":id,"name":name,"cpu":cpu,"ram":ram,"disk":disk,"bridge":"vSwitch-LAN" if hv else "vmbr0","vlan":20,"iso":"windows-server.iso" if hv else "debian.iso","agent":true}
				if hv: params.merge({"generation":"2","secure_boot":true,"dynamic":true,"minimum":1,"maximum":ram*2,"vhd_type":"Dynamic"})
				else: params.merge({"firmware":"UEFI","os":"Linux","storage":storage,"nic":"VirtIO","boot":"Disk"})
				scenario.initial_state={"vms":{"200" if hv else "100":{"exists":false,"status":"Off"}}}
				scenario.title="Nasazení "+name
				scenario.description="Vytvoř VMID%s / %s: %d vCPU, %d GiB RAM, %dGiB disk, %s, VLAN20. %s Spusť VM a ověř aplikaci." % [id,name,cpu,ram,disk,params.bridge,"Gen2/Secure Boot, Windows ISO, Dynamic Memory min1/max%d GiB a Dynamic VHDX." % (ram*2) if hv else "Debian ISO, UEFI, VirtIO, Guest Agent, storage%s a boot Disk." % storage]
				scenario.objectives=[goal("vms."+id+".name",name),goal("vms."+id+".cpu",cpu),goal("vms."+id+".ram",ram),goal("vms."+id+".disk",disk),goal("verified.vms."+id,true)]
				if not hv: scenario.objectives.append(goal("vms."+id+".storage",storage))
				recipe=[["inspect",{"scope":"Inventory"}],["hv_create" if hv else "create_vm",params],["power",{"vm":id,"power":"Start"}],["verify",{}]]
			elif kind=="Sítě":
				scenario=missions[3].duplicate(true)
				var bad_vlan=[30,40,99][rng.randi_range(0,2)]
				var bad_dns=["192.168.20.99","192.168.10.99","0.0.0.0"][rng.randi_range(0,2)]
				scenario.initial_state={"vms":{"100":{"vlan":bad_vlan,"dns":bad_dns,"prefix":[22,25,24][rng.randi_range(0,2)]}}}
				scenario.title="Nesoulad síťové konfigurace"
				scenario.description="APP01 má po změně VLAN%s a DNS%s. Cílová síť: vmbr0,VLAN20,IP192.168.20.100/24,gateway192.168.20.1,DNS192.168.20.10. Diagnostikuj jednotlivé vrstvy a ověř HTTPS." % [bad_vlan,bad_dns]
				recipe=solutions[3].duplicate(true)
			elif kind=="RAID":
				scenario=missions[16].duplicate(true)
				var level=["RAID 5","RAID 6","RAID 10"][rng.randi_range(0,2)]
				var n=[4,6,8][rng.randi_range(0,2)]
				var disk=[1000,2000][rng.randi_range(0,1)]
				var members=[]
				var disks={}
				for i in 8:
					disks[str(i)]={"pool":"","used":0,"capacity":disk,"spare":false}
					if i<n: members.append(str(i))
				var sizes=[]
				for _i in n: sizes.append(disk)
				var capacity=sim_raid_capacity(level,sizes)
				scenario.initial_state={"raid":{"members":[],"capacity":0,"initialized":false},"disks":disks}
				scenario.title="Kapacitní návrh "+level
				scenario.description="Založ %s ze slotů%s; každý má%dGB. Požadovaná využitelná kapacita před režií:%dGB. Dokonči inicializaci a ověř zdraví. Hot spare není zadán." % [level,", ".join(members),disk,int(capacity)]
				scenario.objectives=[goal("created_raid.level",level),goal("created_raid.members",members),goal("created_raid.capacity",capacity),goal("verified.created_raid",true)]
				recipe=[["inspect",{"scope":"Storage"}],["raid_create",{"name":"RANDOM-DATA","level":level,"members":members,"spare":"Žádný","controller":"Hardware RAID"}],["raid_initialize",{}],["verify",{}]]
		if scenario.is_empty():
			if candidates.is_empty(): break
			scenario=candidates[rng.randi_range(0,candidates.size()-1)].duplicate(true)
			recipe=scenario.reference.duplicate(true) if scenario.has("reference") else solutions[int(scenario.id)-1].duplicate(true)
		if not validate(scenario,recipe): continue
		scenario.id=20000+batch.size()
		if difficulty!="Vše": scenario.difficulty=difficulty
		scenario.available_actions=[]
		for operation in recipe:
			if not operation[0] in scenario.available_actions: scenario.available_actions.append(operation[0])
		scenario.hints=["Začni diagnostikou podle skutečného symptomu.",scenario.explanations,scenario.description]
		scenario.tags=domains(scenario)
		scenario.reference=recipe
		batch.append(scenario)
	return batch

static func validate(scenario: Dictionary,recipe: Array) -> bool:
	var sim=Sim.new()
	sim.reset(scenario.initial_state)
	var initially_done=true
	for result in Eval.evaluate(sim.state,scenario.objectives): initially_done=initially_done and result.passed
	if initially_done: return false
	for operation in recipe:
		if not sim.act(operation[0],operation[1]).ok: return false
	for result in Eval.evaluate(sim.state,scenario.objectives):
		if not result.passed: return false
	return true

static func domains(mission: Dictionary) -> Array:
	var result=mission.get("tags",[]).duplicate()
	var module="RAID" if mission.get("category","")=="Storage" else mission.get("category","")
	if not module in result: result.append(module)
	var topic=mission.get("topic","").to_lower()
	if "vlan" in topic or "dns" in topic or "switch" in topic or "síť" in topic:
		if not "Sítě" in result: result.append("Sítě")
	if "obnov" in topic or "backup" in topic or "checkpoint" in topic or "pbs" in topic:
		if not "Zálohy" in result: result.append("Zálohy")
	if not "Diagnostika" in result: result.append("Diagnostika")
	return result

static func goal(path,value) -> Dictionary:
	return {"path":path,"value":value,"label":path.replace("vms.","VM ")}

static func sim_raid_capacity(level,sizes):
	return preload("res://scripts/simulation/RAIDSimulator.gd").capacity(level,sizes)
