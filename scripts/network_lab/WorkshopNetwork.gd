extends "res://scripts/network_lab/LabNetwork.gd"

# A separate instance of the classroom switch, with service faults and probes.
# No host networking or real terminal commands are used.
const FIELDS = ["ports","vlans","lease","cache","learned","capture","dns_record","tcp_enabled","revision","cable","last_path","last_message","dhcp_pool","dns_cache","gateway_mac","ap_position","rules","measurements","journal","patch_map","lease_source"]
var dhcp_pool := true
var dns_cache := ""
var gateway_mac := MACS.router
var ap_position := "front"
var rules := {"https":true,"management":false,"guest_isolated":true}
var patch_map := {"pc04":"Z04 / PP04","pc02":"Z02 / PP02","printer":"Z07 / PP07"}
var measurements := {}
var journal: Array = []
var lease_source := "dhcp"

func setup(id: String):
	reset("")
	vlans[5] = 20
	dhcp_pool = true
	dns_cache = ""
	gateway_mac = MACS.router
	ap_position = "center"
	rules = {"https":true,"management":false,"guest_isolated":true}
	lease_source = "dhcp"
	measurements = {}
	journal = []
	renew()
	match id:
		"A": ports.pc04 = 8
		"B","H": vlans[4] = 20
		"C": dhcp_pool = false
		"D":
			gateway_mac = "02:00:00:00:10:11"
			cache[IPS.router] = MACS.router
		"E": dns_cache = "203.0.113.19"
		"F": tcp_enabled = false
		"G": ap_position = "front"
	if id=="H": dns_record = "203.0.113.19"
	if id in ["A","B","C","H"]: lease.clear()
	capture.clear()
	last_path.clear()
	last_message = "Vyber zařízení a proveď výchozí měření."
	revision = 0

func snapshot() -> Dictionary:
	var state := {}
	for key in FIELDS:
		var value = get(key)
		state[key] = value.duplicate(true) if value is Dictionary or value is Array else value
	return state

func restore(state: Dictionary):
	for key in FIELDS:
		var value = state[key]
		set(key,value.duplicate(true) if value is Dictionary or value is Array else value)

func change_network():
	revision += 1
	lease.clear()
	cache.clear()
	learned.clear()
	last_path.clear()

func connect_cable(port: int) -> bool:
	if port not in range(3,9) or cable=="":
		last_message = "Nejdřív vyber konektor a klientský port 03–08. Uplinky 01/02 nelze přepojit."
		return false
	return super.connect_cable(port)

func set_vlan(port: int, vlan: int):
	if port not in range(3,9) or vlan not in [10,20]:
		last_message = "Vyber klientský port 03–08 a VLAN 10 nebo 20. Původní nastavení zůstalo zachované."
		return
	super.set_vlan(port,vlan)

func set_dns(address: String):
	if address not in [WEB,"203.0.113.19",""] or dns_record==address:
		last_message = "Záznam beze změny; zvol platnou laboratorní adresu."
		return
	dns_record = address
	revision += 1
	last_message = "Autoritativní záznam A uložen; cache klienta zůstává samostatná."

func renew() -> bool:
	lease_source = "dhcp"
	if not dhcp_pool:
		lease.clear()
		if link("pc04"): transmit("DHCP Discover","pc04",BROADCAST,"0x0800","0.0.0.0 → 255.255.255.255","UDP 68 → 67","Požadavek na pronájem.")
		last_message = "PC 04 → DHCP · bez nabídky; rozsah .20–.49 nemá volné adresy."
		return false
	return super.renew()

func arp(target: String, packet_ip: String, refresh := false) -> bool:
	if target=="router" and cache.has(IPS.router) and not refresh and cache[IPS.router]!=gateway_mac:
		transmit("Rámec na starou MAC","pc04","router","0x0800",packet_ip,"—","Bez odpovědi; cache používá "+str(cache[IPS.router]))
		last_message = "Brána · rámec na MAC z cache bez odpovědi."
		return false
	var okay := super.arp(target,packet_ip,refresh)
	if okay and target=="router":
		cache[IPS.router] = gateway_mac
		if refresh: transmit("ARP po výměně brány","router","pc04","0x0806","—","—",IPS.router+" → "+gateway_mac)
	return okay

func dns_test() -> String:
	if not arp("resolver",IPS.resolver):
		last_message = "DNS · resolver nedostupný."
		return ""
	if dns_cache=="": dns_cache = super.dns_test()
	last_message = "PC 04 → "+PORTAL+" · cache "+dns_cache+" / DNS záznam "+dns_record
	return dns_cache

func tcp_test() -> bool:
	if not rules.https:
		transmit("TCP SYN / pravidlo","pc04","router","0x0800",WEB,"TCP → 443","Laboratorní pravidlo zahodilo požadavek.")
		last_message = "TCP 443 · bez odpovědi podle pravidla HTTPS."
		return false
	return super.tcp_test()

func device_status(device: String) -> String:
	if not link(device): return NAMES[device]+"\nBEZ LINKY"
	if device=="pc04":
		return "PC 04 / VLAN %d\n%s" % [segment(device),str(lease.get("ip","DHCP nepřiděleno"))]
	return NAMES[device]+"\nVLAN %d / %s" % [segment(device),IPS[device]]

func edit(kind: String, value = null) -> bool:
	if kind in ["pool","tcp","https_rule","management"] and not value is bool:
		last_message = "Neplatná předvolba; původní konfigurace zůstává."
		return false
	var before := snapshot()
	match kind:
		"pool":
			dhcp_pool = bool(value)
			revision += 1
		"dns": set_dns(str(value))
		"flush":
			dns_cache = ""
			revision += 1
		"arp":
			cache.erase(IPS.router)
			revision += 1
		"tcp":
			tcp_enabled = bool(value)
			revision += 1
		"https_rule":
			rules.https = bool(value)
			revision += 1
		"management":
			rules.management = bool(value)
			revision += 1
		"ap":
			if value not in ["front","center"]:
				last_message = "AP lze ukotvit vpředu nebo uprostřed dílny."
				return false
			ap_position = value
			revision += 1
		"static":
			lease_source = "static"
			lease = {"ip":IPS.pc04,"mask":"255.255.255.0","gateway":IPS.router,"dns":IPS.resolver}
			revision += 1
		_: return false
	if revision==before.revision: return false
	last_message = "Konfigurace změněna. Opakuj dotčená měření."
	return true

func probe(kind: String, device := "pc04") -> Dictionary:
	# Only PC 04 is a DHCP client in this model. The other two endpoints have
	# fixed addresses, so their service probes must never reuse PC 04's result.
	if kind=="control": device = "pc02"
	if kind in ["dhcp","arp","printer","dns","tcp","https","near","far"]: device = "pc04"
	var okay := false
	var detail := ""
	last_path = []
	match kind:
		"link":
			okay = link(device)
			detail = "%s → %s → SW %02d / VLAN %d · %s" % [NAMES[device],patch_map.get(device,"uplink"),ports[device],segment(device),"LINK" if okay else "BEZ LINKY"]
			last_path = [device,"switch"]
		"dhcp":
			okay = renew()
			detail = last_message
		"gateway":
			if device=="pc04":
				okay = arp("router",WEB)
				detail = last_message
			else:
				okay = reachable(device,"router")
				detail = NAMES[device]+" → brána · "+("odpovídá" if okay else "nedostupná")
		"arp":
			okay = arp("router",WEB,false)
			detail = "ARP cache "+str(cache)+" / štítek nové brány "+gateway_mac
		"printer":
			okay = arp("printer",IPS.printer,true)
			detail = last_message
		"control":
			okay = reachable("pc02","router")
			if okay: transmit("Kontrolní PC → brána","pc02","router","0x0800",IPS.router,"ICMP","Odpověď brány.")
			detail = "PC 02 → brána · "+("odpovídá" if okay else "nedostupná")
		"dns":
			okay = dns_test()==WEB
			detail = last_message
		"tcp":
			okay = tcp_test()
			detail = last_message
		"https":
			okay = web_test()
			detail = last_message
		"near","far":
			var rssi := -45 if kind=="near" else -58 if ap_position=="center" else -84
			okay = rssi> -75 and dhcp_pool and reachable("pc04","router")
			detail = "%s → AP / %d dBm · %s · IP %s · HTTPS %s" % ["W1" if kind=="near" else "W2",rssi,"připojeno" if rssi> -75 else "slabý signál / odpojeno","192.168.10.25/24" if okay else "nepřidělena","200" if okay and tcp_enabled and rules.https and dns_record==WEB else "nedostupné"]
			okay = okay and tcp_enabled and rules.https and dns_record==WEB
			last_path = ["pc04","switch","router"] if okay else ["pc04"]
		_: detail = "Neznámé měření."
	var result := {"kind":kind,"source":device,"target":kind,"passed":okay,"detail":detail,"revision":revision,"path":last_path.duplicate(),"frames":capture.duplicate(true)}
	measurements[kind] = result
	journal.append(result.duplicate(true))
	if journal.size()>60: journal.pop_front()
	last_message = NAMES.get(device,device)+" → "+kind+" · "+detail
	return result

func fresh(kind: String) -> bool:
	return measurements.has(kind) and measurements[kind].passed and measurements[kind].revision==revision and measurements[kind].source==("pc02" if kind=="control" else "pc04")
