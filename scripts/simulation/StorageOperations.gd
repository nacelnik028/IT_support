extends RefCounted

const Raid = preload("res://scripts/simulation/RAIDSimulator.gd")

static func apply(sim, action: String, p: Dictionary) -> Dictionary:
	var s = sim.state
	match action:
		"storage_cleanup":
			if not p.checked: return sim.reject("Nejdřív ověř vlastníka snapshotů a obnovitelnou zálohu. Nemaž aktivní data naslepo.",true)
			if p.kind == "Thin metadata": s.storage.metadata = minf(s.storage.metadata,45)
			else:
				s.storage.used = maxf(s.storage.used-s.storage.reclaimable,0)
				s.storage.reclaimable = 0
			return sim.success("Ověřená údržba dokončena; aktivní VM data zachována.")
		"capacity":
			var size = float(p.size)
			if size <= 0: return sim.reject("Kapacita musí být kladná.")
			match p.layer:
				"Pool":
					if size <= s.storage.capacity or size > s.raid.capacity or s.raid.health != "Healthy": return sim.reject("Pool může růst pouze do dostupné kapacity zdravého podkladového pole.")
					s.storage.capacity = size
				"Logical disk":
					if size <= s.storage.logical or size > s.storage.capacity: return sim.reject("Logický disk musí růst v rámci již rozšířeného poolu.")
					s.storage.logical = size
				"Host filesystem":
					if size <= s.storage.host_fs or size > s.storage.logical: return sim.reject("Hostitelský filesystem potřebuje předem dostupný větší logický disk.")
					s.storage.host_fs = size
				"VM disk":
					var vm = sim.get_vm(str(p.vm))
					if vm.is_empty(): return sim.reject("VM neexistuje.")
					if vm.status == "Running": return sim.reject("Pro tento bezpečný laboratorní postup VM nejprve vypni. Online resize závisí na řadiči a platformě.")
					if not vm.get("checkpoints",[]).is_empty(): return sim.reject("Dokonči merge checkpointů; nezasahuj do aktivního AVHDX řetězce.")
					if not s.backup.records.has(str(p.vm)): return sim.reject("Před změnou velikosti chybí záloha této VM.")
					if size <= vm.disk or size-vm.disk > s.storage.host_fs-s.storage.used: return sim.reject("Disk lze pouze zvětšit; hostitel nemá dost rezervy pro požadovaný růst.")
					var growth=size-vm.disk
					s.storage.provisioned+=growth
					if vm.get("vhd_type","Dynamic")=="Fixed": s.storage.used+=growth
					vm.disk = size
				"Guest filesystem":
					var vm = sim.get_vm(str(p.vm))
					if vm.is_empty(): return sim.reject("VM neexistuje.")
					if vm.status != "Running": return sim.reject("Spusť guest OS a rozšiř oddíl uvnitř něj.")
					if size <= vm.filesystem or size > vm.disk: return sim.reject("Filesystem může růst jen do již zvětšeného virtuálního disku.")
					vm.filesystem = size
				_: return sim.reject("Neznámá kapacitní vrstva.")
			return sim.success("%s rozšířen na %.0f GB. Navazující vrstvy se automaticky nezvětšují." % [p.layer,size])
		"replace_disk":
			if not p.backup_checked: return sim.reject("Před výměnou ověř použitelnou zálohu a postup hot-swap.",true)
			if s.backup.records.is_empty(): return sim.reject("V evidenci není žádná nezávislá záloha. Nejprve zajisti ochranu dat před servisním zásahem.",true)
			var zfs = p.pool == "ZFS"
			var disks = s.zfs.disks if zfs else s.disks
			var pool = s.zfs if zfs else s.raid
			var slot = str(p.slot)
			if not disks.has(slot) or not slot in pool.members: return sim.reject("Slot není členem zvoleného pole.")
			var disk = disks[slot]
			if disk.serial != p.serial: return sim.reject("Sériové číslo neodpovídá slotu. V reálném serveru hrozí vytažení jiného disku.",true)
			if disk.health != "Failed": return sim.reject("Zvolený disk není vadný. Odebrání zdravého člena může způsobit ztrátu dostupnosti.",true)
			if p.size < disk.capacity: return sim.reject("Náhradní disk je menší než nahrazovaný člen.")
			if pool.health == "Failed": return sim.reject("Pole už ztratilo data. Rebuild nemá úplnou zdrojovou kopii; potřebuješ obnovu.")
			disk.health = "Recovering"
			disk.serial += "-R"
			pool.rebuilding = true
			pool.progress = 0
			pool.health = "Recovering"
			return sim.success("Nový člen vložen; spuštěn %s. Redundance zatím není obnovena." % ("resilver" if zfs else "rebuild"))
		"rebuild":
			var zfs = p.pool == "ZFS"
			var pool = s.zfs if zfs else s.raid
			var disks = s.zfs.disks if zfs else s.disks
			if not pool.rebuilding: return sim.reject("Žádný rebuild/resilver neběží. Nejprve identifikuj a nahraď vadný disk.")
			pool.progress = mini(int(pool.progress)+50,100)
			if pool.progress >= 100:
				for id in pool.members:
					if disks[id].health == "Recovering": disks[id].health = "Healthy"
				pool.rebuilding = false
				pool.health = Raid.health(pool.level,pool.members,disks)
			return sim.success("%s: průběh %d %% / %s" % [p.pool,int(pool.progress),pool.health])
		"scrub":
			s.zfs.scrubbed = true
			return sim.success("Scrub dokončen. Zdraví poolu: %s. Vadný disk je třeba vyměnit, nikoli jen znovu kontrolovat." % s.zfs.health)
		"raid_create":
			var members = p.members
			if not members is Array or members.size()<2: return sim.reject("Vyber alespoň dva fyzické disky.")
			var sizes = []
			var seen = []
			for id in members:
				if not s.disks.has(id) or id in seen: return sim.reject("Neplatný nebo duplicitní člen pole.")
				seen.append(id)
				var d = s.disks[id]
				if d.pool != "" or d.used > 0: return sim.reject("Disk %s obsahuje existující data/pool. Create není oprava; vyber pouze volné disky." % id,true)
				if d.health != "Healthy" or d.spare: return sim.reject("Člen musí být zdravý, volný a nesmí být hot spare.")
				sizes.append(d.capacity)
			var cap = Raid.capacity(p.level,sizes)
			if cap <= 0: return sim.reject("Počet členů není platný pro vybranou RAID úroveň. RAID10 vyžaduje sudý počet alespoň čtyři.")
			if p.level.begins_with("ZFS") or p.level.begins_with("RAIDZ"):
				if p.controller != "HBA / ZFS": return sim.reject("ZFS potřebuje přímý přístup k diskům přes HBA.")
			if p.level in ["Simple","Mirror","Parity"] and p.controller != "Storage Spaces": return sim.reject("Simple/Mirror/Parity zde patří do Storage Spaces nad přímými disky.")
			if p.spare != "Žádný":
				if p.spare in members or not s.disks.has(p.spare) or s.disks[p.spare].pool != "" or s.disks[p.spare].capacity < sizes.max(): return sim.reject("Hot spare musí být samostatný volný kompatibilní disk.")
			var array = {"name":p.name,"level":p.level,"members":members.duplicate(),"capacity":cap,"health":"Healthy","initialized":false,"cache":true,"rebuilding":false,"progress":0,"controller":p.controller}
			s.created_raid = array
			if s.raid.members.is_empty(): s.raid = array
			for id in members: s.disks[id].pool = p.name
			if p.spare != "Žádný": s.disks[p.spare].spare = true; s.disks[p.spare].pool = p.name
			return sim.success("Nové pole má %.0f GB = %.2f TiB před režií. Hot spare se nezapočítává. Dokonči inicializaci." % [cap,Raid.tb_to_tib(cap/1000.0)])
		"raid_initialize":
			if s.created_raid.is_empty() or s.created_raid.initialized: return sim.reject("Inicializovat lze pouze právě vytvořené prázdné pole. Existující pole se neinicializuje jako oprava.",true)
			s.created_raid.initialized = true
			if s.raid.members == s.created_raid.members: s.raid.initialized = true
			return sim.success("Inicializace nového prázdného pole dokončena; stav Healthy.")
		"raid_failure":
			if not str(p.slot) in s.raid.members: return sim.reject("Slot není členem aktivního produkčního pole.")
			s.disks[str(p.slot)].health = "Failed"
			s.raid.health = Raid.health(s.raid.level,s.raid.members,s.disks)
			if s.raid.health=="Degraded":
				for spare_id in s.disks:
					var spare=s.disks[spare_id]
					if spare.spare and spare.health=="Healthy" and spare.pool==s.disks[str(p.slot)].pool and spare.capacity>=s.disks[str(p.slot)].capacity:
						var position=s.raid.members.find(str(p.slot))
						s.raid.members[position]=spare_id
						spare.spare=false
						spare.health="Recovering"
						s.raid.rebuilding=true
						s.raid.progress=0
						s.raid.health="Recovering"
						return sim.success("Hot spare ze slotu%s automaticky převzal vadný člen%s. Rebuild probíhá; kapacita se nezvýšila." % [spare_id,p.slot])
			return sim.success("Simulovaná porucha slotu %s: pole %s. U RAID10 záleží na konkrétním páru." % [p.slot,s.raid.health])
		"foreign":
			if p.operation == "Clear Foreign": return sim.reject("Tato známá metadata patří původnímu poli. Clear by zhoršil obnovu; nejprve ověř původ a úplnost členů.",true)
			if not s.foreign.present or not s.foreign.complete: return sim.reject("Import vyžaduje nalezená metadata a úplnou známou sestavu.")
			s.foreign.present = false
			return sim.success("Původní Foreign konfigurace importována po ověření členů.")
		"cache":
			if p.policy == "Force write-back" or (p.policy == "Protected write-back" and not s.raid.cache): return sim.reject("Write-back bez zdravé ochrany cache může ztratit potvrzené zápisy při poruše.",true)
			s.raid.cache_policy = p.policy
			return sim.success("Cache policy: " + p.policy)
		"disk_online":
			if p.serial != s.disk.serial: return sim.reject("Identita disku nesouhlasí s inventářem.")
			s.disk.online = true
			return sim.success("DISK1 online. Před inicializací ověř, že je nový a prázdný.")
		"disk_initialize":
			if s.disk.old_data or not s.disk.new: return sim.reject("Původní datový disk ve stavu RAW neinicializuj ani neformátuj. Nejprve logy, spojení a plán obnovy.",true)
			if not s.disk.online: return sim.reject("Identifikuj disk a přepni jej Online.")
			if p.style != "GPT" and s.disk.capacity>2000: return sim.reject("Tato kapacita vyžaduje GPT; MBR má omezení kolem 2 TiB.")
			s.disk.style = p.style
			return sim.success("Nový prázdný disk inicializován jako " + p.style)
		"volume":
			if s.disk.old_data or s.disk.size>0: return sim.reject("Formátování původního svazku by zničilo data. Pro růst použij Extend Volume.",true)
			if not s.disk.online or s.disk.style == "RAW": return sim.reject("Disk musí být Online a inicializovaný.")
			if p.size > s.disk.capacity: return sim.reject("Oddíl je větší než podkladový disk.")
			for key in ["size","fs","letter"]: s.disk[key] = p[key]
			s.disk.new = false
			s.share.filesystem = p.fs
			return sim.success("Svazek %s: %s / %.0f GB vytvořen." % [p.letter,p.fs,p.size])
		"volume_extend":
			if not s.disk.online or s.disk.fs=="" or s.disk.new: return sim.reject("Rozšiřovat lze existující online svazek s filesystémem, nikoli nový RAW disk.")
			if not s.disk.adjacent or p.size > s.disk.capacity or p.size <= s.disk.size: return sim.reject("Extend potřebuje větší souvislé volné místo za oddílem na stejném disku. Recovery partition nemaž naslepo.")
			s.disk.size = p.size
			return sim.success("Existující svazek rozšířen bez formátování.")
		"share":
			if s.share.filesystem != "NTFS": return sim.reject("FSRM podporuje NTFS, nikoli ReFS. Volbu filesystemu řeš při návrhu; původní data neformátuj.")
			if p.group == "Everyone" or p.ntfs == "Everyone Full" or p.access == "Everyone Full": return sim.reject("Plošný přístup Everyone porušuje princip minimálních práv.",true)
			for key in ["name","group","ntfs","access","quota","mode"]: s.share[key] = p[key]
			s.share.allowed_test = false
			s.share.denied_test = false
			return sim.success("SMB, skupinové ACL a kvóta uloženy. Otestuj oprávněnou i nepovolenou skupinu.")
		"share_test":
			if s.share.name == "": return sim.reject("Nejprve vytvoř sdílení.")
			var allowed = p.group == s.share.group and s.share.ntfs == "Modify" and s.share.access == "Change"
			if p.group == "GG_Projekty_RW": s.share.allowed_test = allowed
			else: s.share.denied_test = not allowed
			return sim.success("Účet %s: %s. Hard quota %s GB; soft pouze upozorní." % [p.group,"čtení/zápis povolen" if allowed else "zápis zamítnut",s.share.quota],false)
		"quota_test":
			if s.share.name=="": return sim.reject("Nejprve vytvoř sdílení a kvótu.")
			var used=float(s.share.get("used",295))
			if s.share.mode=="Hard" and used+p.amount>s.share.quota:
				return sim.success("Hard quota: zápis %.0f GB zamítnut; %s / %s GB. Data zůstala zachována." % [float(p.amount),used,s.share.quota],false)
			if s.storage.used+p.amount>s.storage.capacity: return sim.reject("Fyzický pool nemá místo. Kvóta nepřidává fyzickou kapacitu.")
			s.share.used=used+p.amount
			s.storage.used+=p.amount
			return sim.success("Zápis proveden. %s / %s GB. %s" % [s.share.used,s.share.quota,"Soft quota pouze upozornila." if s.share.used>s.share.quota else "V rámci limitu."])
		"san":
			if p.target != "10.50.0.10" or p.initiator != "iqn.2026-10.lab:hv01" or p.lun != "LUN-01": return sim.reject("Target, IQN nebo LUN nesouhlasí s povoleným mappingem.")
			if p.writers == "HV-01 + HV-02" and not p.clustered: return sim.reject("Dva neclusterovaní hostitelé nesmějí nezávisle zapisovat na stejný běžný NTFS/ReFS LUN.",true)
			if p.clustered: return sim.reject("V této laboratoři není validovaný Hyper-V Failover Cluster. Samotné zaškrtnutí jej nevytvoří.",true)
			for key in ["target","initiator","lun","paths","mpio","clustered"]: s.san[key] = p[key]
			s.san.writers = ["HV-01"]
			s.san.tested = false
			return sim.success("iSCSI připojeno. Více cest musí být sjednoceno MPIO do jednoho LUN.")
		"san_test":
			if s.san.paths != 2 or not s.san.mpio: return sim.reject("Po výpadku jediné cesty LUN zmizí. Připrav dvě nezávislé cesty a MPIO.")
			s.san.tested = true
			return sim.success("Cesta A vypnuta, LUN-01 zůstává dostupný cestou B; cesta A obnovena. Stále jde o jednu kopii dat.",false)
	return {}
