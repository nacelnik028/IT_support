extends RefCounted

const Raid = preload("res://scripts/simulation/RAIDSimulator.gd")
const Storage = preload("res://scripts/simulation/StorageOperations.gd")

static func link_ok(s: Dictionary, id: String) -> bool:
	var device = s.get("world",{}).get("devices",{}).get(id,{})
	return device.get("power_connected",true) and device.get("cable_connected",true) and device.get("port",1)==device.get("expected_port",1)

static func disks_for(s: Dictionary, pool: String) -> Dictionary:
	return s.zfs.disks if pool == "ZFS" else s.disks

static func array_for(s: Dictionary, pool: String) -> Dictionary:
	return s.zfs if pool == "ZFS" else s.raid

static func apply(sim, action: String, p: Dictionary) -> Dictionary:
	if not action.begins_with("physical_"): return {}
	var s = sim.state
	var w = s.world
	var id = str(p.get("device","PVE-01"))
	if action in ["physical_inspect","physical_power","physical_cable","physical_supply"] and not s.hosts.has(id): return sim.reject("Neznámá identita zařízení.")
	match action:
		"physical_inspect":
			w.inspected[id] = true
			s.diagnostic.viewed = true
			return sim.success("Fyzická kontrola %s: napájení %s, kabel %s, port %d / požadován %d.\n%s" % [id,"připojeno" if w.devices[id].power_connected else "odpojeno","připojen" if w.devices[id].cable_connected else "odpojen",w.devices[id].port,w.devices[id].expected_port,sim.diagnose("Storage" if id=="NAS-01" else "Events")],false)
		"physical_power":
			var operation = p.get("operation","Start")
			if not operation in ["Start","Shutdown","Restart"]: return sim.reject("Zvol zapnutí, bezpečné vypnutí nebo restart.")
			if not w.devices[id].power_connected: return sim.reject("Nejprve připoj napájecí kabel zařízení.")
			var host = s.hosts[id]
			if operation == "Start" and host.online: return sim.reject("Zařízení již běží.")
			if operation != "Start" and not host.online: return sim.reject("Vypnuté zařízení nelze bezpečně restartovat ani vypnout.")
			if operation != "Start":
				for vm in s.vms.values():
					if vm.get("exists",false) and vm.host == id: vm.status = "Off"
			host.online = operation != "Shutdown"
			if operation == "Restart":
				w.restarted[id] = true
				if id.begins_with("HV"): host.rebooted = true; host.vmms = host.role
			return sim.success("%s: %s. Virtuální stroje po servisu spouštěj a ověřuj samostatně." % [id,{"Start":"zapnuto","Shutdown":"bezpečně vypnuto","Restart":"bezpečně restartováno"}[operation]])
		"physical_cable":
			var connected = p.get("connected",true)
			var port = int(p.get("port",1))
			if not connected is bool or port < 1 or port > 12: return sim.reject("Port switche musí být1–12.")
			if connected:
				for other in w.devices:
					if other != id and w.devices[other].cable_connected and int(w.devices[other].port)==port: return sim.reject("Port už používá "+other+". Vyber volný port podle štítku.")
			w.devices[id].cable_connected = connected
			w.devices[id].port = port
			return sim.success("%s: kabel %s, SW-CORE port%d. Ověř shodu se štítkem a síťovou cestu." % [id,"připojen" if connected else "odpojen",port])
		"physical_supply":
			var connected = p.get("connected",true)
			if not connected is bool: return sim.reject("Neplatný stav napájení.")
			if not connected and s.hosts[id].online: return sim.reject("Nejprve zařízení bezpečně vypni. Výpadky napájení jsou připravené scénářem.",true)
			w.devices[id].power_connected = connected
			return sim.success(id+": napájení "+("připojeno; zařízení nyní zapni" if connected else "odpojeno"))
		"physical_spare":
			var spare_id = str(p.get("spare","SPARE-2T"))
			if w.held != "": return sim.reject("Již držíš náhradní disk. Vrať jej do skříně nebo vlož do slotu.")
			if not w.stock.has(spare_id) or not w.stock[spare_id].available: return sim.reject("Náhradní disk není ve skříni.")
			w.held = spare_id
			w.stock[spare_id].available = false
			return sim.success("Neseš disk %s / %d GB / %s." % [w.stock[spare_id].serial,w.stock[spare_id].capacity,w.stock[spare_id].interface],false)
		"physical_return_spare":
			if w.held == "": return sim.reject("Nedržíš žádný náhradní disk.")
			w.stock[w.held].available = true
			w.held = ""
			return sim.success("Náhradní disk vrácen do servisní skříně.",false)
		"physical_identify":
			var pool_name = str(p.get("pool","RAID"))
			if not pool_name in ["RAID","ZFS"]: return sim.reject("Neznámý řadič.")
			var disks = disks_for(s,pool_name)
			var slot = str(p.get("slot",""))
			if not disks.has(slot) or disks[slot].serial!=str(p.get("serial","")): return sim.reject("Slot a sériové číslo nesouhlasí.",true)
			w.identified[pool_name+":"+slot] = true
			s.diagnostic.viewed = true
			return sim.success("Identifikační LED: %s / slot%s / %s / %s." % [pool_name,slot,disks[slot].serial,disks[slot].health],false)
		"physical_remove", "physical_insert":
			var pool_name = str(p.get("pool","RAID"))
			if not pool_name in ["RAID","ZFS"]: return sim.reject("Neznámý řadič.")
			var disks = disks_for(s,pool_name)
			var pool = array_for(s,pool_name)
			var slot = str(p.get("slot",""))
			if not disks.has(slot) or not slot in pool.members: return sim.reject("Slot není členem zvoleného pole.")
			var disk = disks[slot]
			var key = pool_name+":"+slot
			var device_id = "PVE-01" if pool_name=="ZFS" else "NAS-01"
			if s.hosts[device_id].online and not w.devices[device_id].hot_swap: return sim.reject("Hardware nepodporuje hot-swap. Nejprve bezpečně vypni server.",true)
			if action == "physical_remove":
				if w.removed.has(key): return sim.reject("Slot je již prázdný.")
				if str(p.get("serial","")) != disk.serial: return sim.reject("Sériové číslo nesouhlasí se štítkem zvoleného slotu.",true)
				if not p.get("backup_checked",false) or s.backup.records.is_empty(): return sim.reject("Před vytažením ověř nezávislou zálohu a servisní postup.",true)
				if not p.get("confirmed",false): return sim.reject("Vytažení vyžaduje potvrzení identity slotu.")
				w.removed[key] = disk.duplicate(true)
				disk.health = "Missing"
				pool.health = Raid.health(pool.level,pool.members,disks)
				pool.rebuilding = false
				if pool.health == "Failed": w.data_loss[pool_name] = true
				if w.removed[key].health == "Healthy":
					s.risks += 1
					s.errors += 1
				return sim.success("Slot%s fyzicky prázdný; pole %s. %s" % [slot,pool.health,"Pole ztratilo dostupnost dat; samotná nová jednotka data nevrátí." if pool.health=="Failed" else "Redundance je snížená; nevytahuj další zdravé členy."])
			if not w.removed.has(key): return sim.reject("Nejprve fyzicky vyjmi vadný disk ze slotu.")
			if w.held == "": return sim.reject("Vezmi kompatibilní náhradní disk ze servisní skříně.")
			var spare = w.stock[w.held]
			if spare.capacity < disk.capacity or spare.interface != ("SATA" if pool_name=="ZFS" else "SAS"): return sim.reject("Nekompatibilní disk: kapacita nebo rozhraní neodpovídá. Vrať jej a vyber správnou náhradu.")
			if pool.health == "Failed" or w.data_loss.get(pool_name,false): return sim.reject("Pole nemá úplnou zdrojovou kopii. Je nutná obnova dat, nikoli rebuild.")
			# Reuse the existing validated replacement and rebuild implementation.
			disk.health = "Failed"
			var result = Storage.apply(sim,"replace_disk",{"pool":pool_name,"slot":slot,"serial":disk.serial,"size":spare.capacity,"backup_checked":p.get("backup_checked",false)})
			if not result.ok: disk.health = "Missing"; return result
			disk.serial = spare.serial
			disk.capacity = spare.capacity
			w.held = ""
			w.removed.erase(key)
			w.replaced[key] = true
			return result
		"physical_monitor":
			w.monitor_checked = true
			w.observed_vms = {}
			for vm in s.vms.values():
				if vm.get("exists",false): w.observed_vms[vm.id] = vm.status
			return sim.success("Monitorovací konzole načetla skutečné hostitele, VM, kapacitu a stav polí.",false)
		"physical_commission":
			for device_id in s.hosts:
				if not w.inspected.get(device_id,false) or not s.hosts[device_id].online or not link_ok(s,device_id): return sim.reject("Chybí fyzická kontrola nebo dostupnost zařízení "+device_id)
			if s.raid.health != "Healthy" or s.zfs.health != "Healthy" or s.storage.used >= s.storage.capacity*0.9: return sim.reject("Nejdříve vyřeš stav storage a kapacitní rezervu.")
			if not s.verified.get("service_pve",false) or not s.verified.get("service_hv",false): return sim.reject("Chybí aktuální softwarové ověření obou služeb.")
			w.commissioned = true
			return sim.success("Fyzická i softwarová přejímka dokončena.",false)
	return sim.reject("Neznámý fyzický zásah.")
