extends RefCounted

static func apply(sim,action: String,p: Dictionary) -> Dictionary:
	var s=sim.state
	match action:
		"vm_identity":
			var id=str(p.id)
			if not id.is_valid_int() or int(id)<100 or int(id)>9999 or p.name.strip_edges().is_empty(): return sim.reject("VMID musí být jedinečné číslo100–9999 a název nesmí být prázdný.")
			var existing=sim.get_vm(id)
			if not existing.is_empty() and (existing.status=="Running" or not existing.get("provisioning",false)): return sim.reject("VMID už patří existující VM. Nejprve ověř identitu; nový server ji nesmí přepsat.",true)
			var vm=s.vms["100"].duplicate(true)
			vm.merge({"id":id,"identity":id,"name":p.name,"exists":true,"provisioning":true,"os_installed":false,"host":"PVE-01","status":"Off","iso":"","cpu":1,"ram":1,"ram_mib":1024,"disk":0,"filesystem":0,"ip":"192.168.20."+str(int(id)%150+50),"bridge":"LAB","isolated":true,"service":true,"disk_present":true,"boot":"ISO","data":"ACADEMY-DATA-v1"},true)
			vm.agent=false
			s.vms[id]=vm
			return sim.success("VMID%s / %s rezervováno v konfiguraci hostitele. OS zatím není nainstalovaný." % [id,p.name])
		"vm_media","vm_resources","vm_disk","vm_network","vm_install":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty(): return sim.reject("Nejdřív vytvoř konfiguraci s jedinečným VMID.")
			if action!="vm_install" and vm.status=="Running": return sim.reject("Konfiguraci tohoto průvodce měň při vypnuté VM.")
			match action:
				"vm_media":
					if p.iso!="debian.iso": return sim.reject("Tato výuková instalace Linuxu vyžaduje debian.iso z Directory storage pro ISO.")
					vm.iso=p.iso
					vm.os="Linux"
					vm.firmware="UEFI"
				"vm_resources":
					if p.cpu<1 or p.ram_mib<512 or p.ram_mib>61440: return sim.reject("Ponech prostředky hostiteli; RAM musí být512–61440 MiB.")
					vm.cpu=p.cpu
					vm.ram_mib=p.ram_mib
					vm.ram=float(p.ram_mib)/1024.0
				"vm_disk":
					if p.storage=="PBS" or p.size>s.storage.capacity-s.storage.used: return sim.reject("PBS není storage běžících VM. Ověř také fyzickou rezervu poolu.")
					if not vm.get("provisioning",false): return sim.reject("Disk existujícího OS se nepřevytváří jako nový prázdný disk.",true)
					s.storage.provisioned+=p.size-vm.disk
					vm.disk=p.size
					vm.filesystem=0
					vm.storage=p.storage
				"vm_network":
					if p.bridge!="vmbr0" or not sim.valid_ip(p.ip): return sim.reject("Připoj VM ke skutečnému Linux bridge a zadej platnou IP.")
					for key in ["bridge","vlan","ip"]: vm[key]=p[key]
					vm.nic="VirtIO"
					vm.isolated=false
				"vm_install":
					if vm.iso=="" or vm.disk<8: return sim.reject("Před instalací připoj správné ISO a vytvoř virtuální disk.")
					if not vm.get("os_installed",false):
						if s.storage.used+8>s.storage.capacity: return sim.reject("Pool nemá místo pro instalaci OS.")
						s.storage.used+=8
						vm.used=8
					vm.filesystem=vm.disk
					vm.provisioning=false
					vm.os_installed=true
					vm.boot="Disk"
					vm.agent=true
			return sim.success("Konfigurace VM%s uložena do společného modelu: %s." % [vm.id,action])
		"pve_resources":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty() or vm.status=="Running": return sim.reject("Vyber existující vypnutou VM pro změnu CPU/RAM.")
			if p.ram<1 or p.ram>60 or p.cpu<1: return sim.reject("RAM musí ponechat rezervu hostiteli.")
			vm.ram=p.ram
			vm.ram_mib=p.ram*1024
			vm.cpu=p.cpu
			return sim.success("Prostředky VM uloženy; dostupnost startup RAM se ještě ověří při startu.")
		"vm_options":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty() or vm.status=="Running": return sim.reject("Bootování a řadič měň po korektním vypnutí VM.")
			for key in ["boot","firmware","disk_bus","nic"]: vm[key]=p[key]
			return sim.success("Boot order, firmware a řadič uloženy. Změna řadiče vyžaduje ovladač uvnitř hosta.")
		"guest_driver":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty() or vm.status!="Running": return sim.reject("Nejprve spusť Windows na kompatibilním řadiči SATA.")
			if p.iso!="virtio-win.iso": return sim.reject("Potřebuješ ověřené VirtIO ovladače z virtio-win.iso.")
			vm.virtio_drivers=true
			vm.agent=true
			return sim.success("VirtIO storage i síťové ovladače a Guest Agent nainstalovány uvnitř Windows. Před přepnutím řadiče VM vypni.")
		"zfs_create":
			if not s.zfs.get("new",false) or not s.zfs.members.is_empty(): return sim.reject("ZFS Create smí použít jen nové prázdné disky, nikoli přepsat existující pool.",true)
			if p.disks!="A + B" or s.hosts["PVE-01"].mode!="HBA": return sim.reject("Mirror vyžaduje dva přímo dostupné disky A+B přes HBA.")
			s.zfs.members=["A","B"]
			s.zfs.capacity=minf(s.zfs.disks.A.capacity,s.zfs.disks.B.capacity)
			s.zfs.level="ZFS mirror"
			s.zfs.health="Healthy"
			s.zfs.new=false
			return sim.success("Nový datový ZFS mirror vytvořen. Kapacita odpovídá menšímu členu; mirror není backup.")
		"ct_app_backup":
			var id=str(p.ct)
			if not s.ct.has(id) or not s.backup.configured or not s.hosts["BACKUP-01"].online: return sim.reject("Chybí CT nebo nezávislý backup cíl.")
			var root_copy=s.ct[id].duplicate(true)
			root_copy.erase("data")
			s.ct_backups[id]={"root":root_copy,"application":s.ct[id].get("data","")}
			return sim.success("Rootfs a samostatná aplikační záloha bind mountu uloženy na PBS. Bind mount se nevydává za součást vzdump.")
		"ct_restore":
			var id=str(p.ct)
			var target=str(p.id)
			if not s.ct_backups.has(id) or s.ct.has(target): return sim.reject("Ověř zdrojový backup a volné CTID.")
			var restored=s.ct_backups[id].root.duplicate(true)
			restored.data=s.ct_backups[id].application if p.application else ""
			restored.isolated=true
			restored.status="Running"
			s.ct[target]=restored
			return sim.success("CT obnoven izolovaně. Aplikační data: "+("zahrnuta samostatnou obnovou" if p.application else "chybí, rootfs backup nezahrnul bind mount"))
		"backup_transport":
			s.backup_transport={"ip":p.ip,"vlan":p.vlan,"uplink":p.uplink,"tested":false}
			s.hosts["BACKUP-01"].online=p.uplink and int(p.vlan)==60 and p.ip=="10.60.0.10"
			return sim.success("Storage síť PBS uložena; dostupnost odpovídá uplinku, IP a VLAN60.")
		"backup_test":
			if not s.hosts["BACKUP-01"].online: return sim.reject("PBS TCP8007 nedostupný. Ověř uplink, VLAN60 a10.60.0.10.")
			if p.fingerprint!="AA:42": return sim.reject("Identita PBS nesouhlasí s ověřeným fingerprintem.",true)
			s.backup_transport.tested=true
			return sim.success("PBS TLS/8007, datastore a oprávnění otestovány. Nyní spusť skutečnou zálohu VM.",false)
		"hypervisor_boot":
			var h=s.hosts["HV-01"]
			h.boot_auto=p.auto
			h.rebooted=false
			h.vmms=false
			return sim.success("Hypervisor launch nastaven. Dokonči plánovaný restart a zkontroluj VMMS.")
		"hv_recreate":
			var old=sim.get_vm(str(p.vm))
			var id=str(p.id)
			if old.is_empty() or old.status=="Running" or not sim.get_vm(id).is_empty(): return sim.reject("Původní konfiguraci vypni a vyber volné nové VMID.")
			if str(p.generation)!="2" or old.get("disk_style","GPT")!="GPT": return sim.reject("Tento OS disk používá GPT/UEFI a vyžaduje novou Generation2 konfiguraci. Generaci původní VM nelze přepnout.")
			var copy=old.duplicate(true)
			copy.id=id
			copy.generation=2
			copy.firmware="UEFI"
			copy.secure_boot=true
			copy.required_generation=2
			s.vms[id]=copy
			return sim.success("Založena nová Gen2 konfigurace se správným původním GPT diskem. Původní konfigurace zůstává Off; identita OS i data jsou zachovány.")
		"cross_import":
			var source=s.migration.export
			var id=str(p.id)
			if source.is_empty() or not sim.get_vm(id).is_empty(): return sim.reject("Nejprve vypni a úplně exportuj zdrojovou Hyper-V VM; cílové VMID musí být volné.")
			if not p.isolated or p.storage!="local-lvm": return sim.reject("První start proveď izolovaně a na dostupném VM storage.",true)
			if source.disk>s.storage.capacity-s.storage.used: return sim.reject("Pro převod všech disků není dost cílové fyzické kapacity.")
			var copy=source.duplicate(true)
			copy.id=id
			copy.host="PVE-01"
			copy.bridge="LAB"
			copy.isolated=true
			copy.firmware=p.firmware
			copy.expected_firmware="UEFI" if int(source.get("generation",2))==2 else "SeaBIOS"
			copy.disk_bus=p.disk_bus
			copy.virtio_drivers=false
			copy.nic="E1000"
			copy.storage=p.storage
			copy.status="Off"
			copy.agent=false
			s.vms[id]=copy
			s.storage.used+=source.disk
			s.migration.cross_source=str(source.id)
			s.migration.all_disks_copied=true
			s.migration.isolated_tested=false
			return sim.success("Kompletní vypnuté VHDX převedeny a připojeny v nové PVE konfiguraci. Nastav odpovídající BIOS/UEFI a pro první Windows start kompatibilní SATA.")
		"cross_check":
			var vm=sim.get_vm(str(p.vm))
			var source=s.migration.export
			if vm.is_empty() or source.is_empty() or not vm.isolated or vm.status!="Running": return sim.reject("Test převodu potřebuje běžící izolovanou cílovou VM a úplný zdrojový export.")
			if vm.data!=source.data or vm.disk!=source.disk or vm.get("data_disk",{})!=source.get("data_disk",{}): return sim.reject("Disky nebo aplikační data neodpovídají původní instanci.")
			s.migration.isolated_tested=true
			s.migration.tested_revision=s.revision
			return sim.success("Ověřeny všechny disky, OS, identita a skutečný datový manifest v izolaci.",false)
		"cross_cutover":
			var vm=sim.get_vm(str(p.vm))
			var source=sim.get_vm(s.migration.get("cross_source",""))
			if vm.is_empty() or not s.migration.get("isolated_tested",false) or s.migration.get("tested_revision",-1)!=s.revision: return sim.reject("Po poslední změně proveď nový izolovaný test všech disků a dat.")
			if not source.is_empty() and source.status=="Running": return sim.reject("Původní OS stejné identity musí zůstat vypnutý.",true)
			if not vm.virtio_drivers or vm.disk_bus!="VirtIO": return sim.reject("Nejprve připrav ovladače a ověř start z VirtIO řadiče.")
			vm.bridge="vmbr0"
			vm.vlan=20
			vm.isolated=false
			s.migration.completed=true
			return sim.success("Provoz přepnut na PVE. Původní VM zůstává vypnutá pro řízený návrat; nejde o nativní Live Migration mezi platformami.")
		"data_resize":
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty() or not vm.has("data_disk"): return sim.reject("VM nemá připojený datový VHDX.")
			var d=vm.data_disk
			if p.layer=="VHDX":
				if vm.status=="Running" or not s.backup.records.has(str(p.vm)): return sim.reject("Pro tento postup ověř zálohu a VM korektně vypni.")
				if p.size<=d.capacity or p.size-d.capacity>s.storage.host_fs-s.storage.used: return sim.reject("VHDX potřebuje větší velikost a dostatek místa na hostiteli.")
				d.capacity=p.size
			else:
				if vm.status!="Running" or p.size>d.capacity or p.size<=d.filesystem: return sim.reject("Běžící guest rozšíří filesystem jen do většího podkladového VHDX.")
				d.filesystem=p.size
			return sim.success("Datová vrstva%s má nyní %s GB; druhá vrstva se nezvětšila automaticky." % [p.layer,p.size])
		"lab_update":
			var vm=sim.get_vm(str(p.vm))
			if not s.get("allow_fault_injection",false) or vm.is_empty() or vm.get("checkpoints",[]).is_empty(): return sim.reject("Simulovaná aktualizace je povolená jen v připravené lekci s bodem návratu.")
			vm.data="UPDATE-CORRUPTION"
			vm.service=false
			return sim.success("Simulovaná aktualizace rozbila aplikaci. Použij správný bod návratu; produkční pokrok je uložen odděleně.")
		"locate_disk":
			var id=str(p.slot)
			if not s.disks.has(id) or s.disks[id].serial!=p.serial: return sim.reject("Slot a serial nesouhlasí. Locate LED musí označit skutečný fyzický disk.",true)
			s.located={"slot":id,"serial":p.serial}
			return sim.success("Locate LED bliká na slotu%s / %s. Porovnej ji s poruchovým záznamem řadiče." % [id,p.serial],false)
		"raid_assess":
			var actual=sim.Raid.health(s.raid.level,s.raid.members,s.disks)
			if p.health!=actual: return sim.reject("Srovnej konkrétní mirror páry. Dva výpadky stejného páru znamenají Failed; různé páry mohou zůstat Degraded.")
			s.raid_assessment=actual
			s.diagnostic.viewed=true
			return sim.success("Dostupnost podle skutečných členů: "+actual+". Nyní bezpečně obnov redundanci.",false)
		"raid_plan":
			var sizes=[]
			for id in p.members:
				if not s.disks.has(id): return sim.reject("Neznámý fyzický disk.")
				sizes.append(s.disks[id].capacity)
			var cap=sim.Raid.capacity(p.level,sizes)
			if cap<=0: return sim.reject("Neplatný počet členů pro tuto úroveň.")
			s.designs[p.level]={"capacity":cap,"members":p.members.duplicate()}
			return sim.success("Návrh%s: %s GB = %.2f TiB. Návrh nemění existující disky." % [p.level,cap,sim.Raid.tb_to_tib(cap/1000.0)])
		"cache_service":
			if p.serial!="CACHE-01" or not p.tested: return sim.reject("Ověř identitu ochranného modulu a servisní test; write-back se nesmí vynutit bez ochrany.",true)
			s.raid.cache=true
			return sim.success("Ochrana cache opravena a otestována. Teprve nyní lze povolit Protected write-back.")
		"disk_diagnose":
			if p.serial!=s.disk.serial or not p.readonly: return sim.reject("Původní disk identifikuj a diagnostikuj pouze pro čtení.",true)
			s.disk.readonly=true
			s.diagnostic.RAW=true
			s.disk.preserved_hash=s.disk.get("data_hash","")
			return sim.success("Read-only diagnostika: metadata GPT zachovaná, I/O cesta SAS-PORT-A přerušovaná. Disk neformátuj.",false)
		"disk_reconnect":
			if not s.diagnostic.get("RAW",false) or p.serial!=s.disk.serial or p.port!="SAS-PORT-A": return sim.reject("Nejdřív read-only diagnostika identity a skutečné vadné cesty.")
			s.disk.connected=true
			s.disk.fs=s.disk.get("previous_fs","NTFS")
			s.disk.size=s.disk.capacity
			s.disk.online=true
			return sim.success("Vadná I/O cesta opravena, rescan znovu načetl původní filesystem. Data nebyla formátována.")
		"present_array":
			if s.created_raid.is_empty() or not s.created_raid.initialized: return sim.reject("Nejdřív vytvoř a inicializuj nové prázdné pole.")
			if s.disk.size>0 or s.disk.old_data: return sim.reject("Nový logický disk nesmí přepsat původní OS volume.",true)
			s.disk.capacity=s.created_raid.capacity
			s.disk.serial=p.serial
			s.disk.new=true
			s.disk.style="RAW"
			s.disk.fs=""
			return sim.success("OS rescan našel nový logický disk %s / %s GB. Ještě potřebuje GPT a filesystem." % [p.serial,s.disk.capacity])
		"san_expand":
			if s.raid.health!="Healthy" or p.size<=s.san.capacity or p.size>s.raid.capacity: return sim.reject("SAN rozšiřuj jen do dostupné kapacity zdravého podkladového pole.")
			s.san.capacity=p.size
			return sim.success("Fyzická kapacita SAN rozšířena. Zvětšení VHDX by chybějící místo na SAN nevyřešilo.")
		"san_monitor":
			if p.warning>=p.critical or p.critical>95: return sim.reject("Varování musí předcházet kritické hranici a ponechat čas na zásah.")
			s.san.warning=p.warning
			s.san.critical=p.critical
			s.san.monitored=true
			return sim.success("Monitoring skutečné kapacity SAN nastaven; volné místo ve VM není dostačující ukazatel.")
		"checkpoint_action":
			if p.get("operation","")!="Delete (merge)": return {}
			var vm=sim.get_vm(str(p.vm))
			if vm.is_empty(): return {}
			for i in vm.get("checkpoints",[]).size():
				var cp=vm.checkpoints[i]
				if cp.name==p.name and cp.has("footprint"):
					if minf(s.storage.capacity,s.storage.host_fs)-s.storage.used<cp.get("merge_reserve",30): return sim.reject("Pro merge chybí provozní rezerva. Rozšiř podkladový pool i hostitelský filesystem; AVHDX ručně nemaž.")
					s.storage.used=maxf(s.storage.used-cp.footprint,0)
					vm.checkpoints.remove_at(i)
					return sim.success("Manager dokončil konzistentní merge AVHDX; uvolněna obsazená kapacita checkpointu.")
	return {}

static func verify(sim):
	var s=sim.state
	s.verified.host_dns=s.hosts["PVE-01"].dns=="192.168.10.2" and s.hosts["PVE-01"].hostname=="pve01.lab.example"
	s.verified.ct_data=s.ct.get("301",{}).get("data","")=="ORDERS-v7" and s.ct.get("301",{}).get("isolated",false)
	s.verified.migrated=false
	for vm in s.vms.values():
		if vm.get("exists",false) and vm.get("id","")=="310": s.verified.migrated=sim.Network.probe(s,"310").app and vm.get("virtio_drivers",false) and s.migration.completed
	s.verified.raw_recovery=s.disk.get("readonly",false) and s.disk.fs=="NTFS" and s.disk.get("data_hash","")!="" and s.disk.get("data_hash")==s.disk.get("preserved_hash")
	s.verified.san_capacity=s.san.get("capacity",2000)>s.san.get("used",200) and s.san.get("monitored",false)
	s.verified.performance=s.raid.health=="Healthy" and s.raid.cache and s.raid.get("cache_policy","")=="Protected write-back"
	return {}
