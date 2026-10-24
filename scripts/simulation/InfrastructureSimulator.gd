extends RefCounted

const Network = preload("res://scripts/simulation/NetworkSimulator.gd")
const Raid = preload("res://scripts/simulation/RAIDSimulator.gd")
const PveOps = preload("res://scripts/simulation/ProxmoxOperations.gd")
const HvOps = preload("res://scripts/simulation/HyperVOperations.gd")
const StorageOps = preload("res://scripts/simulation/StorageOperations.gd")
const EducationOps = preload("res://scripts/simulation/EducationOperations.gd")
const PhysicalOps = preload("res://scripts/simulation/PhysicalOperations.gd")
var state: Dictionary = {}

func reset(patch: Dictionary):
	state = JSON.parse_string(FileAccess.get_file_as_string("res://data/infrastructure/baseline.json"))
	if FileAccess.file_exists("res://data/infrastructure/academy_defaults.json"):
		merge(state,JSON.parse_string(FileAccess.get_file_as_string("res://data/infrastructure/academy_defaults.json")))
	merge(state,patch)
	state.verified = {}
	state.diagnostic = {"viewed":false}
	state.journal = []
	state.errors = 0
	state.risks = 0
	state.revision = 0
	refresh_incidents()

static func merge(target: Dictionary, patch: Dictionary):
	for key in patch:
		if patch[key] is Dictionary and not patch[key].is_empty() and target.get(key) is Dictionary: merge(target[key],patch[key])
		else: target[key] = patch[key].duplicate(true) if patch[key] is Dictionary or patch[key] is Array else patch[key]

func reject(message: String, risk: bool = false) -> Dictionary:
	state.errors += 1
	if risk: state.risks += 1
	var text = message + "\nZměna nebyla provedena. Ověř identitu, závislosti a podmínky operace; potom ji zopakuj bezpečně."
	state.journal.append("ODMÍTNUTO • " + message)
	return {"ok":false,"text":text}

func success(message: String, change: bool = true) -> Dictionary:
	if change:
		state.revision += 1
		state.verified.clear()
	refresh_incidents()
	state.journal.append(message)
	return {"ok":true,"text":message}

func refresh_incidents():
	state.incidents=[]
	for id in state.vms:
		var vm=state.vms[id]
		vm.ram_mib=int(round(float(vm.ram)*1024.0))
		if not vm.get("exists",false): continue
		var health="Healthy"
		var reason="Služba v provozu"
		if vm.status!="Running": health="Offline"; reason="VM neběží"
		elif state.storage.used>=state.storage.capacity: health="Critical"; reason="Pool je plný"
		elif not Network.probe(state,id).app and not vm.get("isolated",false): health="Warning"; reason=Network.probe(state,id).reason
		state.incidents.append({"device":vm.name,"state":health,"cause":reason})
	for pair in [["RAID",state.raid.health],["ZFS",state.zfs.health]]:
		state.incidents.append({"device":pair[0],"state":pair[1],"cause":"Stav fyzických členů a obnovy redundance"})

func act(action: String, p: Dictionary = {}) -> Dictionary:
	for handler in [PhysicalOps,EducationOps,PveOps,HvOps,StorageOps]:
		var handled = handler.apply(self,action,p)
		if not handled.is_empty(): return handled
	match action:
		"inspect":
			state.diagnostic.viewed = true
			state.diagnostic[p.get("scope","Inventory")] = true
			return success("Diagnostika: " + p.get("scope","Inventory") + "\n" + diagnose(p.get("scope","Inventory")),false)
		"prepare":
			var h = state.hosts["PVE-01"]
			if not p.get("vt",false): return reject("Bez VT-x/AMD-V nelze provozovat KVM VM.")
			if p.get("mode","RAID") != "HBA": return reject("ZFS potřebuje disky přímo. RAID řadič s cache není vhodný podklad.")
			h.vt = p.vt
			h.iommu = p.get("iommu",false)
			h.mode = p.mode
			h.ups = p.get("ups",false)
			h.console = p.get("console",false)
			return success("Firmware a provozní příprava serveru uloženy. IOMMU slouží pro PCIe passthrough.")
		"management":
			if not valid_ip(p.get("ip","")) or not valid_ip(p.get("gateway","")) or not valid_ip(p.get("dns","")): return reject("Neplatná IPv4 adresa.")
			var h = state.hosts["PVE-01"]
			for k in ["ip","gateway","dns","hostname"]: h[k] = p[k]
			return success("Management konfigurace uložena na bridge vmbr0.")
		"verify":
			var vm_checks={}
			for vm_id in state.vms: vm_checks[vm_id]=Network.probe(state,vm_id).app
			var h = state.hosts["PVE-01"]
			var rid = state.restored_id
			var restored = state.vms.get(rid,{})
			var restore_ok = not restored.is_empty() and restored.get("isolated",false) and restored.status == "Running" and restored.service and restored.data == "ACADEMY-DATA-v1" and restored.disk_present
			state.verified = {"preflight":h.vt and h.mode == "HBA" and h.ups and h.console and h.ip == "192.168.10.10" and h.gateway == "192.168.10.1" and h.dns == "192.168.10.2", "service_pve":Network.probe(state,"100").app, "service_hv":Network.probe(state,"200").app,"capacity":state.storage.used <= state.storage.capacity*0.9 and state.storage.metadata < 80,"restore":restore_ok,"zfs":state.zfs.health == "Healthy" and not state.zfs.rebuilding,"raid":state.raid.health == "Healthy" and state.raid.initialized and not state.raid.rebuilding,"created_raid":not state.created_raid.is_empty() and state.created_raid.get("initialized",false) and state.created_raid.get("health","") == "Healthy","hypervisor":state.hosts["HV-01"].vmms and state.hosts["HV-01"].rebooted,"volume":state.disk.online and state.disk.style == "GPT" and state.disk.fs != "" and state.disk.size > 0,"share":state.share.get("allowed_test",false) and state.share.get("denied_test",false),"san":state.san.tested and state.san.mpio and state.san.paths == 2}
			state.verified.vms=vm_checks
			EducationOps.verify(self)
			return success("Ověření dokončeno. Kontroly odrážejí aktuální konfiguraci.\n" + JSON.stringify(state.verified,"  "),false)
		_: return reject("Operace není implementována: " + action)

func get_vm(id: String) -> Dictionary:
	var vm = state.vms.get(id,{})
	return vm if vm.get("exists",false) else {}

func can_start(vm: Dictionary) -> String:
	if vm.is_empty(): return "VM neexistuje."
	if not PhysicalOps.link_ok(state,vm.host): return "Fyzická síť nebo napájení hostitele není v pořádku."
	if not state.hosts["NAS-01"].online: return "Podkladové úložiště NAS-01 je vypnuté."
	if vm.get("provisioning",false): return "Nejprve dokonči instalaci OS v průvodci VM."
	if vm.get("expected_firmware",vm.get("firmware","UEFI"))!=vm.get("firmware","UEFI"): return "Boot selhal: BIOS/UEFI neodpovídá původnímu systémovému disku."
	if vm.get("os","")=="Windows Server" and vm.get("disk_bus","")=="VirtIO" and not vm.get("virtio_drivers",true): return "INACCESSIBLE_BOOT_DEVICE: Windows nemá ovladač VirtIO storage. Nejdřív kompatibilní SATA a instalace ovladačů."
	if vm.get("required_generation",0)>0 and vm.get("generation",0)!=vm.required_generation: return "Generation neodpovídá OS obrazu. Vytvoř novou správnou konfiguraci; generaci nelze přepnout."
	if vm.get("dynamic",false) and (vm.get("minimum",0)>vm.ram or vm.ram>vm.get("maximum",vm.ram)): return "Dynamic Memory: Minimum ≤ Startup ≤ Maximum není splněno."
	if vm.get("storage","")=="SAN-LUN-01" and state.san.used>=state.san.capacity: return "SAN thin pool je plný, přestože guest filesystem má volné místo."
	var h = state.hosts[vm.host]
	if not h.online: return "Hostitel je Offline."
	if vm.host.begins_with("PVE") and state.cluster.configured and 1+int(state.cluster.peer_online)+int(state.cluster.qdevice)<2: return "Cluster nemá quorum. Obnov většinu hlasů; neobcházej ochranu split-brain."
	if vm.locked: return "VM je zamčená probíhající úlohou. Neodemykej ji násilně."
	if not vm.disk_present: return "Systémový disk není dostupný. Ověř cestu a logy, disk neformátuj."
	if state.storage.used >= state.storage.capacity or state.storage.metadata >= 100: return "Storage pool nemá místo pro zápisy."
	if state.raid.health == "Failed": return "Podkladové pole selhalo. Obnov data ze zálohy."
	if vm.host.begins_with("HV") and not h.get("vmms",false): return "Hypervisor / VMMS neběží; ověř roli a restart."
	var used_ram = 4.0
	if vm.host.begins_with("HV"): used_ram = h.get("reserve",4) + h.get("other_ram",0)
	for other in state.vms.values():
		if other.get("exists",false) and other.host == vm.host and other.id != vm.id and other.status == "Running": used_ram += float(other.ram)
	if used_ram + float(vm.ram) > float(h.ram): return "Nedostatek startup RAM při zachování rezervy hostitele. Dynamic Memory nevytváří fyzickou RAM."
	if vm.get("boot","Disk") != "Disk": return "VM bootuje z ISO. Po instalaci přepni boot order na Disk."
	return ""

func diagnose(scope: String) -> String:
	match scope:
		"Network":
			return "APP01: " + Network.probe(state,"100").reason + "\nFS01: " + Network.probe(state,"200").reason
		"Storage": return "Pool %s: fyzicky %s/%s GB, přislíbeno %s GB; metadata %s %%\nRAID %s %s; ZFS %s\n" % [state.storage.type,state.storage.used,state.storage.capacity,state.storage.provisioned,state.storage.metadata,state.raid.level,state.raid.health,state.zfs.health] + JSON.stringify(state.disks)
		"Backup": return "Nezávislý cíl: %s; job: %s; body VM: %s; Verify: %s" % [state.backup.target,state.backup.configured,str(state.backup.records.keys()),state.backup.verified]
		"Cluster": return "Hlasy %d/3; QDevice %s; fencing %s; shared storage %s" % [1+int(state.cluster.peer_online)+int(state.cluster.qdevice),state.cluster.qdevice,state.cluster.fenced,state.cluster.shared]
		"Events":
			var logs = []
			for vm in state.vms.values():
				if not vm.get("exists",false): continue
				var error = can_start(vm)
				logs.append("VM %s %s: %s" % [vm.id,vm.name,error if error != "" else "Heartbeat / storage OK"])
			return "\n".join(logs)
	return "PVE-01: 64 GB RAM, VT %s, IOMMU %s, %s\nSYS-A + SYS-B: prázdné SSD 1000 GB; ARCHIVE-9: původní účetní data.\nHV-01: 32 GB RAM; hostitel 4 GB, jiné služby 8 GB.\nPBS fingerprint: AA:42\nZFS disk A: PVE-A, disk B: PVE-B.\nSAN: 10.50.0.10, LUN-01, IQN iqn.2026-10.lab:hv01" % [state.hosts["PVE-01"].vt,state.hosts["PVE-01"].iommu,state.hosts["PVE-01"].mode]

static func valid_ip(address: String) -> bool:
	var pieces = address.split(".")
	if pieces.size() != 4: return false
	for part in pieces:
		if not part.is_valid_int() or int(part) < 0 or int(part) > 255: return false
	return true
