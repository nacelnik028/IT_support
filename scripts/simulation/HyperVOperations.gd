extends RefCounted

static func apply(sim, action: String, p: Dictionary) -> Dictionary:
	var s = sim.state
	var h = s.hosts["HV-01"]
	match action:
		"hv_prepare":
			if not p.vt or not p.slat or not p.dep: return sim.reject("Hyper-V potřebuje 64bit CPU, VT-x/AMD-V, SLAT a DEP/NX.")
			for key in ["vt","slat","dep"]: h[key] = p[key]
			return sim.success("Požadavky Hyper-V ověřeny v BIOS/UEFI a systeminfo.")
		"hv_role":
			if not h.vt or not h.slat or not h.dep: return sim.reject("Nesplněné hardwarové požadavky. Samotný Manager nenainstaluje hypervisor.")
			h.role = true
			h.rebooted = false
			h.vmms = false
			return sim.success("Role Hyper-V nainstalována. K dokončení je nutný restart hostitele.")
		"hv_restart":
			if not p.window: return sim.reject("Restart hostitele odstaví všechny jeho VM. Nejprve naplánuj odstávku.")
			if not h.role: return sim.reject("Role Hyper-V není nainstalovaná.")
			h.rebooted = true
			h.vmms = h.vt and h.slat and h.dep and h.get("boot_auto",true)
			return sim.success("Restart dokončen; VMMS " + ("Running" if h.vmms else "Stopped") + ".")
		"switch":
			if p.name.strip_edges().is_empty(): return sim.reject("Switch potřebuje název.")
			var external = p.type == "External"
			if external and p.adapter != "Ethernet2": return sim.reject("External switch vyžaduje správný fyzický uplink Ethernet2.")
			s.network.switches[p.name] = {"type":p.type,"uplink":external,"vlan_aware":true,"management":p.management,"host":"HV-01","owner":"Hyper-V","adapter":p.adapter}
			return sim.success("vSwitch %s (%s) vytvořen. Neposkytuje automaticky DHCP ani NAT." % [p.name,p.type])
		"memory":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VM neexistuje.")
			if vm.status == "Running": return sim.reject("Pro tento laboratorní postup VM nejprve korektně vypni.")
			if p.minimum > p.ram or p.ram > p.maximum: return sim.reject("Minimum musí být ≤ Startup ≤ Maximum.")
			if p.ram + h.reserve + h.other_ram > h.ram or p.maximum > h.ram-h.reserve: return sim.reject("Startup/maximum RAM porušuje rozpočet hostitele. Hostiteli ponech 4 GB a ostatním službám 8 GB.")
			for key in ["minimum","ram","maximum","dynamic"]: vm[key] = p[key]
			return sim.success("Paměťový plán uložen. Startup je potřeba při startu; maximum není rezervovaná fyzická RAM.")
		"integration":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VM neexistuje.")
			if p.auto_stop == "TurnOff": return sim.reject("Pro běžné ukončení použij ShutDown. TurnOff znamená ztrátu neuložených dat.",true)
			for key in ["agent","vss","auto_start","auto_stop"]: vm[key] = p[key]
			return sim.success("Heartbeat, VSS a automatické akce aktualizovány.")
		"attach_vhd":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VM neexistuje.")
			var parent=str(p.get("parent","Žádný"))
			if p.type == "Differencing" and (not s.images.has(parent) or not s.images[parent].read_only or p.size!=s.images[parent].capacity): return sim.reject("Differencing vyžaduje existující neměnný rodič a jeho logickou kapacitu (BASE-WINDOWS.vhdx:80GB).")
			if vm.get("data_disk",{}).get("path","") == p.path: return sim.reject("Cesta už existuje. Nepřepisuj aktivní VHDX.",true)
			if p.size > s.storage.host_fs-s.storage.used: return sim.reject("Hostitelský filesystem nemá potřebnou rezervu.")
			if vm.has("data_disk"): return sim.reject("Tento datový slot už je obsazený. Nepřepisuj existující VHDX.",true)
			var footprint=float(p.size) if p.type=="Fixed" else 1.0
			if footprint>s.storage.capacity-s.storage.used: return sim.reject("Pool nemá fyzické místo pro tuto alokaci.")
			vm.data_disk = {"path":p.path,"capacity":p.size,"type":p.type,"filesystem":0,"new":p.type!="Differencing","parent":parent,"used":footprint}
			s.storage.used+=footprint
			s.storage.provisioned+=p.size
			return sim.success("Differencing disk připojen; data závisí na neměnném rodiči, který nesmíš smazat." if p.type=="Differencing" else "Datový VHDX připojen na SCSI. Uvnitř VM je zatím bez oddílu.")
		"guest_volume":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty() or not vm.has("data_disk"): return sim.reject("Nejprve připoj nový datový VHDX.")
			if vm.status!="Running": return sim.reject("Disk Management uvnitř guest OS potřebuje běžící VM.")
			if not vm.data_disk.new: return sim.reject("Disk už obsahuje oddíl nebo původní data. Formátování není diagnostika.",true)
			vm.data_disk.filesystem=vm.data_disk.capacity
			vm.data_disk.style=p.style
			vm.data_disk.fs=p.fs
			vm.data_disk.letter=p.letter
			vm.data_disk.new=false
			return sim.success("Nový datový disk uvnitř VM připraven: %s: / %s / %s GB." % [p.letter,p.fs,vm.data_disk.capacity])
		"replica":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty() or not vm.host.begins_with("HV"): return sim.reject("Replica vyžaduje Hyper-V VM.")
			if p.target!="HV-02" or vm.host==p.target: return sim.reject("Cílem musí být jiný kompatibilní Hyper-V hostitel; PVE není nativní Replica target.")
			if not s.hosts[p.target].online or not vm.disk_present: return sim.reject("Chybí dostupný cílový hostitel nebo zdrojový disk.")
			if not int(p.interval) in [30,300,900]: return sim.reject("Podporované intervaly v laboratoři:30,300,900 sekund.")
			var snapshot=vm.duplicate(true)
			snapshot.erase("replica")
			vm.replica={"target":p.target,"interval":p.interval,"points":p.points,"health":"Healthy","snapshot":snapshot}
			return sim.success("Prvotní synchronizace Replica dokončena. RPO závisí na intervalu i poslední úspěšné synchronizaci.")
		"replica_test":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty() or not vm.has("replica"): return sim.reject("Nejprve nakonfiguruj a synchronizuj repliku.")
			if not sim.get_vm("902").is_empty(): return sim.reject("Testovací902 už existuje; nejprve restartuj laboratoř nebo použij existující kopii.")
			var copy=vm.replica.snapshot.duplicate(true)
			copy.id="902"
			copy.name+="-REPLICA-TEST"
			copy.host=vm.replica.target
			copy.bridge="LAB"
			copy.isolated=true
			copy.status="Off"
			s.vms["902"]=copy
			s.restored_id="902"
			return sim.success("Test Failover vytvořil izolovanou902. Spusť ji a ověř data; produkce běží dál. Replika není nezávislá záloha.")
		"checkpoint":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VM neexistuje.")
			if p.type == "Production" and (not vm.vss or not vm.agent): return sim.reject("ProductionOnly: VSS / Integration Services nejsou zdravé; žádný tichý fallback na Standard.")
			if s.storage.used+10 >= s.storage.capacity: return sim.reject("Pro AVHDX a pozdější merge není dost místa.")
			for cp in vm.checkpoints:
				if cp.name == p.name: return sim.reject("Checkpoint tohoto jména již existuje.")
			vm.checkpoints.append({"name":p.name,"type":p.type,"service":vm.service,"data":vm.data,"ram_saved":p.type=="Standard"})
			return sim.success("%s checkpoint vytvořen; stále závisí na původním storage." % p.type)
		"checkpoint_action":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VM neexistuje.")
			if p.operation == "Ruční smazání AVHDX": return sim.reject("Ruční smazání AVHDX poruší diskový řetězec a může zničit aktuální data. Delete přes Manager provede merge.",true)
			for i in vm.checkpoints.size():
				var cp = vm.checkpoints[i]
				if cp.name != p.name: continue
				if p.operation == "Apply":
					vm.service = cp.service
					vm.data = cp.data
					s.checkpoint_applied = cp.type
					return sim.success("Checkpoint aplikován. Novější změny zahozeny; službu a data teď ověř.")
				vm.checkpoints.remove_at(i)
				return sim.success("Checkpoint odstraněn přes Manager; AVHDX bezpečně sloučen.")
			return sim.reject("Checkpoint se zadaným jménem neexistuje.")
		"live_migrate":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VM neexistuje.")
			if p.target != "HV-02": return sim.reject("Hyper-V a Proxmox nemají společnou nativní Live Migration. Potřebuješ offline převod disků.")
			if not s.hosts[p.target].online or not s.hosts[vm.host].online: return sim.reject("Plánovaná Live Migration vyžaduje oba funkční hostitele.")
			if p.auth != "Kerberos" or not s.migration.cpu_compatible or not p.storage: return sim.reject("Ověř Kerberos delegaci, kompatibilitu CPU a dostupnost úplných disků.")
			if float(vm.ram)+4 > s.hosts[p.target].ram: return sim.reject("Cílový hostitel nemá dost RAM.")
			vm.host = p.target
			s.migration.authenticated = true
			s.migration.completed = true
			return sim.success("VM přesunuta na HV-02 se zachovanou identitou, pamětí a disky. Ověř aplikaci.")
		"export":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty() or not vm.disk_present: return sim.reject("Chybí VM nebo disk.")
			if vm.status == "Running": return sim.reject("Pro tento první postup nejprve VM korektně vypni.")
			s.migration.export = vm.duplicate(true)
			return sim.success("Úplný export konfigurace a disků dokončen.")
		"import":
			if s.migration.export.is_empty(): return sim.reject("Nejprve proveď úplný export.")
			if p.target != "HV-02": return sim.reject("Hyper-V export nelze nativně importovat do PVE konfigurace.")
			var vm = s.migration.export.duplicate(true)
			if p.mode == "Copy":
				if not p.isolated: return sim.reject("Nové VM ID samo nezmění IP ani identitu OS. Kopii izoluj.",true)
				vm.id = "901"
				vm.bridge = "LAB"
				vm.isolated = true
			else:
				if sim.get_vm(str(p.vm)).get("status","") == "Running": return sim.reject("Původní VM stejné identity musí zůstat vypnutá.",true)
			vm.host = p.target
			s.vms[vm.id] = vm
			s.migration.completed = true
			return sim.success("Import %s dokončen: %s. Ověř cesty disků a identitu OS." % [p.mode,vm.id])
	return {}
