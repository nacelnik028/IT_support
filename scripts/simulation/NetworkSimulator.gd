extends RefCounted

# Link, IP, DNS and application checks intentionally remain separate.
static func probe(s: Dictionary, id: String, destination: String = "application") -> Dictionary:
	var vm = s.vms.get(id, {})
	if vm.is_empty() or not vm.get("exists",false): return result(false, false, false, false, "VM neexistuje.")
	var host = s.hosts.get(vm.host, {})
	if not host.get("online", false) or vm.status != "Running":
		return result(false, false, false, false, "Hostitel nebo VM neběží.")
	var sw = s.network.switches.get(vm.bridge, {})
	if sw.get("owner","")=="Hyper-V" and sw.get("type","")=="External" and sw.get("adapter","Ethernet2")!="Ethernet2": return result(false,false,false,false,"External switch je navázaný na nesprávnou fyzickou NIC.")
	if sw.is_empty(): return result(false, false, false, false, "Síťový adaptér není připojen k existujícímu switchi.")
	if destination == "peer":
		for other in s.vms.values():
			if other.get("exists",false) and other.id!=id and other.host==vm.host and other.bridge==vm.bridge and other.status=="Running" and other.vlan==vm.vlan:
				var same_subnet=vm.ip.begins_with("192.168.20.") and other.ip.begins_with("192.168.20.") and vm.prefix==other.prefix and vm.ip!=other.ip
				return result(true,same_subnet,false,false,"VM na stejném switchi a VLAN nalezena; aplikaci a DNS testuj samostatně.")
		return result(false,false,false,false,"Na tomto hostiteli/switchi/VLAN není další běžící VM.")
	if destination == "host":
		if sw.type == "Private" or not sw.get("management",true): return result(false, false, false, false, "Tento switch nepropojuje management OS hostitele.")
		var local_ip=vm.ip.begins_with("192.168.20.") and int(vm.prefix)==24 and int(vm.vlan)==20
		return result(true,local_ip,false,false,"Hostitelský testovací adaptér 192.168.20.1/24; tento test neověřuje DNS ani aplikaci v LAN.")
	if sw.type != "External" and destination != "host":
		return result(true, false, false, false, "%s switch nemá fyzický uplink ani automatický NAT." % sw.type)
	if not sw.uplink or int(vm.vlan) != 20 or not sw.vlan_aware:
		return result(false, false, false, false, "L2: zkontroluj uplink, VLAN-aware bridge a VLAN 20 na kartě VM.")
	var ip_ok = vm.ip.begins_with("192.168.20.") and vm.ip != "192.168.20.0" and vm.ip != "192.168.20.255" and int(vm.prefix) == 24 and vm.gateway == "192.168.20.1"
	if not ip_ok: return result(true, false, false, false, "L3: IP/prefix nebo výchozí gateway neodpovídá síti 192.168.20.0/24.")
	var dns_ok = vm.dns == "192.168.20.10"
	for other in s.vms.values():
		if other.get("exists",false) and other.id!=id and other.status=="Running" and other.ip==vm.ip and other.vlan==vm.vlan and not other.get("isolated",false):
			return result(true,false,false,false,"Konflikt IP: další aktivní produkční VM používá stejnou adresu.")
	var disk_ok = vm.disk_present and s.storage.used < s.storage.capacity and s.storage.metadata < 100 and s.raid.health != "Failed"
	if vm.get("storage","")=="SAN-LUN-01": disk_ok=disk_ok and s.san.used<s.san.capacity
	if vm.get("os","")=="Windows Server" and vm.nic=="VirtIO" and not vm.get("virtio_drivers",true): return result(false,false,false,false,"Windows postrádá VirtIO síťové ovladače.")
	if vm.host=="PVE-02" and s.cluster.failed_over: disk_ok=disk_ok and s.cluster.shared
	if vm.get("storage","")=="local-zfs": disk_ok = disk_ok and s.zfs.health!="Failed"
	var app_ok = dns_ok and vm.service and vm.firewall and disk_ok and vm.get("data","")=="ACADEMY-DATA-v1"
	return result(true, true, dns_ok, app_ok, "HTTPS 443 a data aplikace ověřeny." if app_ok else ("DNS server nepřekládá app.lab.example." if not dns_ok else "Ping odpovídá; aplikace selhává. Zkontroluj službu, disk, pool a cílené pravidlo firewallu."))

static func result(link, ip, dns, app, reason) -> Dictionary:
	return {"link":link,"ip":ip,"dns":dns,"app":app,"reason":reason}
