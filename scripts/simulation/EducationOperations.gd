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
					vm.disk=p.size
					vm.filesystem=p.size
					vm.storage=p.storage
				"vm_network":
					if p.bridge!="vmbr0" or not sim.valid_ip(p.ip): return sim.reject("Připoj VM ke skutečnému Linux bridge a zadej platnou IP.")
					for key in ["bridge","vlan","ip"]: vm[key]=p[key]
					vm.nic="VirtIO"
					vm.isolated=false
				"vm_install":
					if vm.iso=="" or vm.disk<8: return sim.reject("Před instalací připoj správné ISO a vytvoř virtuální disk.")
					vm.provisioning=false
					vm.os_installed=true
					vm.boot="Disk"
					vm.agent=true
			return sim.success("Konfigurace VM%s uložena do společného modelu: %s." % [vm.id,action])
	return {}
