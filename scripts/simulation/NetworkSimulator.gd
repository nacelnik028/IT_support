extends RefCounted

# Link, IP, DNS and application checks intentionally remain separate.
static func probe(s: Dictionary, id: String, destination: String = "application") -> Dictionary:
	var vm = s.vms.get(id, {})
	if vm.is_empty(): return result(false, false, false, false, "VM neexistuje.")
	var host = s.hosts.get(vm.host, {})
	if not host.get("online", false) or vm.status != "Running":
		return result(false, false, false, false, "Hostitel nebo VM neběží.")
	var sw = s.network.switches.get(vm.bridge, {})
	if sw.is_empty(): return result(false, false, false, false, "Síťový adaptér není připojen k existujícímu switchi.")
	if destination == "peer":
		return result(true, vm.ip.begins_with("192.168.20."), true, false, "Komunikace VM na stejném switchi a VLAN; aplikaci je třeba testovat zvlášť.")
	if destination == "host" and sw.type == "Private":
		return result(false, false, false, false, "Private switch nepropojuje hostitelský OS.")
	if sw.type != "External" and destination != "host":
		return result(true, false, false, false, "%s switch nemá fyzický uplink ani automatický NAT." % sw.type)
	if not sw.uplink or int(vm.vlan) != 20 or not sw.vlan_aware:
		return result(false, false, false, false, "L2: zkontroluj uplink, VLAN-aware bridge a VLAN 20 na kartě VM.")
	var ip_ok = vm.ip.begins_with("192.168.20.") and vm.ip != "192.168.20.0" and vm.ip != "192.168.20.255" and int(vm.prefix) == 24 and vm.gateway == "192.168.20.1"
	if not ip_ok: return result(true, false, false, false, "L3: IP/prefix nebo výchozí gateway neodpovídá síti 192.168.20.0/24.")
	var dns_ok = vm.dns == "192.168.20.10"
	var app_ok = dns_ok and vm.service and vm.firewall and vm.disk_present and s.storage.used < s.storage.capacity and s.raid.health != "Failed"
	return result(true, true, dns_ok, app_ok, "HTTPS 443 a data aplikace ověřeny." if app_ok else ("DNS server nepřekládá app.lab.example." if not dns_ok else "Ping odpovídá; aplikace selhává. Zkontroluj službu, disk, pool a cílené pravidlo firewallu."))

static func result(link, ip, dns, app, reason) -> Dictionary:
	return {"link":link,"ip":ip,"dns":dns,"app":app,"reason":reason}
