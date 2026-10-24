extends RefCounted

static func apply(sim, action: String, p: Dictionary) -> Dictionary:
	var s = sim.state
	match action:
		"install":
			if s.hosts["PVE-01"].installed: return sim.reject("PVE už je nainstalovaný. Reinstalace není běžná diagnostika.",true)
			if p.disks == "ARCHIVE-9": return sim.reject("ARCHIVE-9 obsahuje účetnictví. Instalátor by přepsal původní data; ověř prázdná SSD podle inventáře.",true)
			if p.type == "ZFS mirror" and p.disks != "SYS-A + SYS-B": return sim.reject("Mirror vyžaduje dva prázdné disky.")
			if p.type == "ZFS mirror" and s.hosts["PVE-01"].mode != "HBA": return sim.reject("Pro ZFS zajisti přímý přístup k diskům přes HBA.")
			if not sim.valid_ip(p.ip) or not sim.valid_ip(p.gateway) or not sim.valid_ip(p.dns): return sim.reject("Neplatná IP konfigurace instalátoru.")
			if not s.hosts["PVE-01"].vt: return sim.reject("Nejdřív zapni VT-x/AMD-V v přípravě.")
			for key in ["hostname","ip","gateway","dns"]: s.hosts["PVE-01"][key] = p[key]
			s.hosts["PVE-01"].installed = true
			s.install = {"disks":p.disks,"type":p.type,"nic":p.nic,"web":false}
			return sim.success("PVE nainstalován. ISO odpojeno, restart dokončen. Archiv nebyl změněn.")
		"web":
			var h = s.hosts["PVE-01"]
			if not h.installed or not h.online or s.install.nic != "eno1": return sim.reject("Web nedostupný: ověř instalaci, online stav a management NIC eno1.")
			if p.url != "https://%s:8006" % h.ip: return sim.reject("PVE web používá HTTPS na management IP a TCP 8006.")
			s.install.web = true
			return sim.success("Web PVE dostupný přes TLS / port 8006. Identita serveru ověřena.")
		"repositories":
			if p.repo == "Enterprise" and not p.subscription: return sim.reject("Enterprise vyžaduje platné předplatné.")
			if p.environment == "Production" and p.repo != "Enterprise": return sim.reject("Tato produkční politika vyžaduje ověřené Enterprise balíčky. No-subscription je v laboratoři povolen.")
			s.hosts["PVE-01"].repo = p.repo
			s.hosts["PVE-01"].environment = p.environment
			return sim.success("Repozitáře pro tuto hlavní verzi zkontrolovány; Debian repozitáře zachovány.")
		"update":
			if not p.window or s.backup.records.is_empty(): return sim.reject("Před aktualizací ověř zálohu, repozitáře a servisní okno.")
			if s.hosts["PVE-01"].repo == "Test": return sim.reject("Test repozitář není vhodný pro tuto provozní aktualizaci.")
			s.hosts["PVE-01"].updated = true
			return sim.success("Simulované apt update / full-upgrade dokončeny. Restart kernelu naplánován.")
		"create_vm", "hv_create":
			var id = str(p.id)
			if not id.is_valid_int() or int(id)<100 or int(id)>9999: return sim.reject("ID musí být celé číslo 100–9999.")
			if not sim.get_vm(id).is_empty() or s.ct.has(id): return sim.reject("ID už používá existující VM nebo CT.")
			if p.name.strip_edges().is_empty(): return sim.reject("Název nesmí být prázdný.")
			var hv = action == "hv_create"
			if hv and str(p.generation)=="1" and p.secure_boot: return sim.reject("Generation1 používá BIOS a Secure Boot nepodporuje. Použij vhodný Gen2 obraz nebo vypni tuto volbu u Gen1.")
			if hv and not s.hosts["HV-01"].vmms: return sim.reject("Nejdřív nainstaluj roli a restartuj hostitele.")
			if not hv and not s.hosts["PVE-01"].installed: return sim.reject("Na hostiteli není nainstalován Proxmox.")
			if not hv and not s.hosts["PVE-01"].vt: return sim.reject("KVM VM vyžaduje dostupnou CPU virtualizaci VT-x/AMD-V.")
			if not hv and p.storage == "PBS": return sim.reject("PBS je backup storage, nikoli diskové úložiště běžící VM.")
			if not hv and ((p.os == "Linux" and p.iso != "debian.iso") or (p.os == "Windows Server" and p.iso != "windows-server.iso")): return sim.reject("Typ OS a instalační ISO si neodpovídají.")
			if hv and (p.minimum > p.ram or p.ram > p.maximum): return sim.reject("Minimum ≤ Startup ≤ Maximum RAM.")
			if hv and p.vhd_type == "Differencing": return sim.reject("Chybí ověřený neměnný rodič differencing disku.")
			if p.ram <= 0 or p.cpu <= 0 or p.disk <= 0: return sim.reject("CPU, RAM a disk musí být kladné.")
			if p.disk > s.storage.capacity-s.storage.used: return sim.reject("Pro bezpečné vytvoření rezervuj skutečné místo, nikoli pouze thin příslib.")
			var vm = s.vms["200" if hv else "100"].duplicate(true)
			for key in p: vm[key] = p[key]
			vm.id = id
			vm.exists = true
			vm.host = "HV-01" if hv else "PVE-01"
			vm.status = "Off"
			vm.filesystem = p.disk
			vm.disk_present = true
			vm.service = true
			vm.isolated = p.bridge == "LAB"
			vm.ip = "192.168.20.200" if hv else "192.168.20.100"
			vm.vlan = p.vlan
			vm.boot = "Disk" if hv else p.boot
			vm.identity = id
			if hv: vm.generation = int(p.generation); vm.firmware = "UEFI" if vm.generation == 2 else "BIOS"
			s.vms[id] = vm
			s.storage.provisioned += p.disk
			s.storage.used += float(p.disk) if hv and p.vhd_type=="Fixed" else minf(p.disk,8.0)
			return sim.success("VM %s / %s vytvořena; instalace OS simulována. Nyní spusť VM a ověř aplikaci." % [id,p.name])
		"power":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VMID neexistuje.")
			if p.power == "Start":
				var error = sim.can_start(vm)
				if error != "": return sim.reject(error)
				vm.status = "Running"
			else:
				if vm.locked: return sim.reject("Počkej na dokončení běžící úlohy; zámek chrání konzistenci.")
				vm.status = "Off"
			return sim.success("VM %s: %s" % [p.vm,vm.status])
		"create_ct":
			if not str(p.id).is_valid_int() or int(p.id) < 100 or not sim.get_vm(p.id).is_empty() or s.ct.has(p.id): return sim.reject("CTID je neplatné nebo obsazené.")
			if not p.unprivileged: return sim.reject("Pro tuto službu používej unprivileged CT; privilegovaný kontejner zbytečně rozšiřuje dopad kompromitace.",true)
			s.ct[p.id] = p.duplicate(true)
			s.ct[p.id].status = "Running"
			return sim.success("LXC vytvořen se sdíleným kernelem. " + ("Bind mount potřebuje samostatný backup." if p.mount == "Bind" else "Spravovaný mount: zahrnutí do zálohy %s." % p.backup_mount))
		"network":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("VM neexistuje.")
			if not s.network.switches.has(p.bridge): return sim.reject("Zvolený switch ještě neexistuje. Vytvoř jej ve Switch Manageru.")
			var owner=s.network.switches[p.bridge].get("owner","Hyper-V")
			if owner!="SharedLab" and ((vm.host.begins_with("PVE") and owner!="Proxmox") or (vm.host.begins_with("HV") and owner!="Hyper-V")): return sim.reject("Virtuální switch patří jinému hypervisoru. Platformy propojuje fyzická síť, nikoli jeden nativní bridge.")
			for key in ["ip","gateway","dns"]:
				if not sim.valid_ip(str(p[key])): return sim.reject("Neplatná IPv4 adresa v poli " + key)
			if not p.firewall: return sim.reject("Vypnutí ochrany není oprava VLAN. Nastav cílené povolení služby 443.",true)
			for key in ["bridge","vlan","ip","prefix","gateway","dns","firewall"]: vm[key] = p[key]
			vm.isolated = s.network.switches[p.bridge].type == "Private"
			return sim.success("Síť VM %s uložena. Teď ověř L2, IP, DNS a HTTPS odděleně." % p.vm)
		"bridge":
			s.network.switches.vmbr0.uplink = p.uplink
			s.network.switches.vmbr0.vlan_aware = p.vlan_aware
			return sim.success("vmbr0: konfigurace aplikována přes servisní konzoli; management IP zůstává na bridge.")
		"probe":
			s.diagnostic.viewed = true
			var probe = sim.Network.probe(s,str(p.vm),p.get("destination","application"))
			return sim.success("L2 %s | IP %s | DNS %s | HTTPS %s\n%s" % [probe.link,probe.ip,probe.dns,probe.app,probe.reason],false)
		"backup_config":
			if p.target != "PBS": return sim.reject("Lokální snapshot není nezávislá záloha.")
			if p.fingerprint != "AA:42": return sim.reject("Fingerprint nesouhlasí s konzolí BACKUP-01. Neobcházej ověření identity cíle.",true)
			if p.interval < 1 or p.retention < 1: return sim.reject("Interval a retence musí být kladné.")
			for key in ["target","fingerprint","interval","retention"]: s.backup[key] = p[key]
			s.backup.configured = true
			return sim.success("Backup job připraven na samostatném BACKUP-01.")
		"backup":
			var vm = sim.get_vm(str(p.vm))
			if vm.is_empty() or not vm.disk_present: return sim.reject("Nelze zálohovat neexistující nebo chybějící disk.")
			if not s.backup.configured or not s.hosts["BACKUP-01"].online: return sim.reject("Nezávislý backup cíl není připraven.")
			if vm.locked: return sim.reject("Na VM běží jiná úloha. Počkej na její dokončení.")
			if vm.host.begins_with("HV") and not vm.vss: return sim.reject("VSS writer selhal; oprav aplikační konzistenci před zálohou.")
			s.backup.records[str(p.vm)] = vm.duplicate(true)
			s.backup.verified = false
			s.backup.completed = true
			return sim.success("Nezávislá záloha VM %s dokončena včetně konfigurace a aplikačních dat." % p.vm)
		"backup_verify":
			if s.backup.records.is_empty(): return sim.reject("Žádné zálohové body k údržbě.")
			match p.operation:
				"Verify": s.backup.verified = true
				"Prune": s.backup.pruned = true
				"Garbage collection": s.backup.gc = true
			return sim.success("PBS %s dokončeno. GC respektuje ochrannou lhůtu; test aplikace je samostatný krok." % p.operation)
		"restore":
			if not s.backup.records.has(str(p.vm)): return sim.reject("Pro tuto VM není dostupná samostatná záloha.")
			if not p.isolated: return sim.reject("Obnova se stejnou IP/identitou do produkce způsobí konflikt. Použij LAB / Private.",true)
			if not str(p.id).is_valid_int() or int(p.id)<100 or not sim.get_vm(str(p.id)).is_empty(): return sim.reject("Nové VMID musí být volné číslo ≥100.")
			var copy = s.backup.records[str(p.vm)].duplicate(true)
			copy.id = str(p.id)
			copy.name += "-RESTORE"
			copy.bridge = "LAB"
			copy.isolated = true
			copy.exists = true
			copy.status = "Off"
			copy.disk_present = true
			copy.host = "HV-01" if str(p.vm) == "200" else "PVE-01"
			s.vms[str(p.id)] = copy
			s.restored_id = str(p.id)
			return sim.success("VM %s obnovena izolovaně. Spusť ji a ověř službu i datový manifest." % p.id)
		"promote":
			if not s.verified.get("restore",false): return sim.reject("Nejprve spusť izolovanou kopii a proveď Ověření dat aplikace.")
			var copy = sim.get_vm(str(p.id))
			var old = sim.get_vm(str(p.vm))
			if copy.is_empty() or copy.id == str(p.vm): return sim.reject("Ověřená kopie a cílová produkční identita musí být odlišné.")
			if str(copy.identity)!=str(p.vm): return sim.reject("Obnova pochází z jiné služby/identity. Ověř zdrojový backup; APP01 nelze vydávat za FS01.",true)
			if not old.is_empty() and old.status == "Running": return sim.reject("Původní instance ještě běží. Dvě stejné identity nesmějí do produkce.",true)
			copy = copy.duplicate(true)
			copy.id = str(p.vm)
			copy.name = "FS01" if str(p.vm) == "200" else "APP01"
			copy.bridge = "vSwitch-LAN" if str(p.vm) == "200" else "vmbr0"
			copy.isolated = false
			s.vms[str(p.vm)] = copy
			s.vms.erase(str(p.id))
			s.restored_id = ""
			s.recovery_promoted = true
			return sim.success("Původní instance nahrazena otestovanou obnovou; nyní ověř produkční službu.")
		"cluster":
			s.cluster.qdevice = p.qdevice
			s.cluster.fenced = p.fenced
			s.cluster.shared = p.shared
			return sim.success("Clusterové závislosti aktualizovány. Hlasy: %d / 3." % [1+int(s.cluster.peer_online)+int(p.qdevice)])
		"failover":
			if 1+int(s.cluster.peer_online)+int(s.cluster.qdevice) < 2: return sim.reject("Bez většiny hlasů není quorum. Neobcházej ochranu split-brain.",true)
			if not s.cluster.fenced or not s.cluster.shared: return sim.reject("HA vyžaduje fencing původního hostitele a skutečně dostupné VM disky.",true)
			if not s.hosts["PVE-02"].online: return sim.reject("Cílový uzel neběží.")
			s.vms["100"].host = "PVE-02"
			var error = sim.can_start(s.vms["100"])
			if error != "": s.vms["100"].host = "PVE-01"; return sim.reject(error)
			s.vms["100"].status = "Running"
			s.cluster.failed_over = true
			return sim.success("HA restartoval APP01 na PVE-02. Původní běžící RAM nebyla obnovena.")
		"security":
			if p.role != "PVEVMUser" or not p.mfa or not p.restricted: return sim.reject("Helpdesk potřebuje minimální práva, MFA a omezený token; ne globálního administrátora.",true)
			s.hosts["PVE-01"].role = p.role
			s.hosts["PVE-01"].mfa = p.mfa
			s.hosts["PVE-01"].restricted = p.restricted
			return sim.success("Omezená role, MFA a API token nastaveny.")
	return {}
