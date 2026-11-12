extends RefCounted
signal physical_event(kind: String, device: String)

# Closed classroom model. Each transmission updates the same switch and capture
# used by diagnostics. Campaign bridge and VM probes assume a different topology.
const IPS = {"pc04":"192.168.10.23","pc02":"192.168.10.24","printer":"192.168.10.50","router":"192.168.10.1","resolver":"192.168.10.2"}
const MACS = {"pc04":"02:00:00:00:10:23","pc02":"02:00:00:00:10:24","printer":"02:00:00:00:10:50","router":"02:00:00:00:10:01","resolver":"02:00:00:00:10:02"}
const NAMES = {"pc04":"PC 04","pc02":"PC 02","printer":"Tiskárna","router":"Brána / DHCP","resolver":"DNS resolver"}
const CLIENTS = ["pc04","pc02","printer"]
const WEB = "203.0.113.20"
const PORTAL = "portal.example.com"
const BROADCAST = "ff:ff:ff:ff:ff:ff"
const PHONE_IMEI = ["350000000000004","350000000000012"]
const IMSI = "001010000000023"
const MSISDN = "+420 000 000 023"

var ports: Dictionary
var vlans: Dictionary
var lease: Dictionary
var cache: Dictionary
var learned: Dictionary
var capture: Array[Dictionary]
var dns_record: String
var tcp_enabled: bool
var revision: int
var cable := ""
var sim_slot: int
var cell: int
var call_step: int
var last_path: Array
var last_message := ""
var access_fault := false

func reset(scenario: String):
	ports = {"router":1,"resolver":2,"pc02":3,"pc04":4,"printer":7}
	vlans = {1:10,2:10,3:10,4:10,5:10,6:10,7:10,8:10}
	if scenario in ["cable","journey"]: ports.pc04 = 0
	if scenario=="journey": ports.printer = 0
	if scenario=="vlan": vlans[4] = 20
	access_fault = scenario in ["access","wifi_ip"]
	dns_record = "" if scenario in ["dns","journey"] else WEB
	tcp_enabled = scenario!="transport"
	lease = {}
	cache = {}
	learned = {}
	capture = []
	last_path = []
	last_message = ""
	cable = ""
	sim_slot = 0
	cell = 0
	call_step = -1
	revision = 0

func change_network():
	revision += 1
	lease.clear()
	cache.clear()
	learned.clear()
	last_path.clear()
	capture.clear()

func occupant(port: int) -> String:
	for device in ports:
		if ports[device]==port: return device
	return ""

func link(device: String) -> bool:
	return int(ports.get(device,0)) in range(1,8)

func segment(device: String) -> int:
	return vlans.get(ports.get(device,0),0)

func reachable(source: String, target: String) -> bool:
	return link(source) and link(target) and segment(source)==segment(target)

func select_cable(device: String) -> bool:
	if device not in CLIENTS: return false
	cable = "" if cable==device else device
	last_message = "Vyber port na switchi." if cable!="" else "Konektor odložen."
	return true

func connect_cable(port: int) -> bool:
	if cable=="" or port not in range(3,9): return false
	if occupant(port) not in ["",cable]:
		last_message = "Port %02d už je obsazený. Vyber volný port." % port
		return false
	var device := cable
	cable = ""
	if ports[device]!=port:
		ports[device] = port
		change_network()
		physical_event.emit("cable_on",device)
	last_message = "%s · port %02d · %s" % [NAMES[device],port,"linka aktivní" if link(device) else "bez linky"]
	return true

func unplug(device: String):
	if device not in CLIENTS or ports[device]==0: return
	ports[device] = 0
	change_network()
	physical_event.emit("cable_off",device)
	last_message = "%s · kabel odpojen" % NAMES[device]

func set_vlan(port: int, vlan: int):
	if port not in range(3,9) or vlan not in [10,20] or vlans[port]==vlan: return
	vlans[port] = vlan
	change_network()
	last_message = "Port %02d přiřazen do VLAN %d." % [port,vlan]

func set_dns(address: String):
	if address not in ["",WEB,IPS.printer] or address==dns_record: return
	dns_record = address
	revision += 1
	last_path.clear()
	capture.clear()
	last_message = "Záznam A uložen." if address!="" else "Záznam A odstraněn."

func transmit(title: String, source: String, target: String, ether_type: String, ip: String, transport: String, application: String, source_mac: String = ""):
	# Source learning happens on ingress even when the frame has no reachable
	# receiver. Broadcast propagation is restricted to the source VLAN.
	if not link(source): return
	var vlan := segment(source)
	if not learned.has(vlan): learned[vlan] = {}
	var sender: String = MACS[source] if source_mac=="" else source_mac
	learned[vlan][sender] = ports[source]
	var destination: String = MACS.get(target,target)
	var receivers: Array = []
	if destination==BROADCAST or not learned[vlan].has(destination):
		for device in ports:
			if device!=source and reachable(source,device): receivers.append(device)
	elif reachable(source,target):
		receivers.append(target)
	last_path = [source,"switch"]+receivers
	capture.append({"title":title,"frame":"%s → %s   %s   VLAN %d" % [sender,destination,ether_type,vlan],
		"ip":ip,"transport":transport,"application":application,"path":last_path.duplicate()})
	if capture.size()>40: capture.pop_front()

func renew() -> bool:
	lease.clear()
	cache.clear()
	revision += 1
	if not link("pc04"):
		last_message = "PC 04 · linka neaktivní. Discover se nedostal na switch."
		return false
	transmit("DHCP Discover","pc04",BROADCAST,"0x0800","0.0.0.0 → 255.255.255.255","UDP 68 → 67","Klient hledá server DHCP.")
	if not reachable("pc04","router"):
		last_message = "DHCP · Discover bez Offer. PC 04 má náhradní adresu 169.254.10.23."
		return false
	transmit("DHCP Offer","router","pc04","0x0800","192.168.10.1 → 192.168.10.23","UDP 67 → 68","Server nabízí .23 z rozsahu .20–.49.")
	transmit("DHCP Request","pc04",BROADCAST,"0x0800","0.0.0.0 → 255.255.255.255","UDP 68 → 67","Klient vybírá nabídku serveru.")
	transmit("DHCP ACK","router","pc04","0x0800","192.168.10.1 → 192.168.10.23","UDP 67 → 68","Server potvrzuje pronájem.")
	lease = {"ip":IPS.pc04,"mask":"255.255.255.0","gateway":IPS.router,"dns":IPS.resolver}
	last_message = "DHCP ACK · %s/24 · brána %s · DNS %s" % [lease.ip,lease.gateway,lease.dns]
	return true

func arp(target: String, packet_ip: String, refresh: bool = false) -> bool:
	if not IPS.has(target) or lease.is_empty() or not link("pc04"):
		last_message = "ARP · PC 04 nemá funkční linku nebo IPv4 nastavení."
		return false
	if refresh: cache.erase(IPS[target])
	if not cache.has(IPS[target]):
		transmit("ARP Request","pc04",BROADCAST,"0x0806","—","—","Kdo má %s? Odpověz na %s." % [IPS[target],IPS.pc04])
		if not reachable("pc04",target):
			last_message = "ARP · bez odpovědi pro "+IPS[target]
			return false
		transmit("ARP Reply",target,"pc04","0x0806","—","—","%s je na %s." % [IPS[target],MACS[target]])
		cache[IPS[target]] = MACS[target]
	last_message = "První rámec → %s · paket → %s" % [cache[IPS[target]],packet_ip]
	return true

func observe_gateway_change(planned: bool):
	# Guided comparison of two independent observations in the ARP capture.
	var source := "router" if planned else "pc02"
	var replacement := "02:00:00:00:10:11" if planned else MACS.pc02
	var label := "Oznámení po výměně brány" if planned else "Nevyžádaná ARP odpověď"
	for _repeat in (1 if planned else 2):
		transmit(label,source,BROADCAST,"0x0806","—","—","%s → %s  /  vstup SW %02d" % [IPS.router,replacement,ports[source]],replacement)
	cache[IPS.router] = replacement

func dns_test() -> String:
	if not arp("resolver",IPS.resolver):
		last_message = "DNS · resolver nedostupný. Ověř linku, DHCP a ARP."
		return ""
	var answer := "NXDOMAIN" if dns_record=="" else dns_record
	transmit("DNS dotaz","pc04","resolver","0x0800","%s → %s" % [IPS.pc04,IPS.resolver],"UDP 52111 → 53","A "+PORTAL)
	transmit("DNS odpověď","resolver","pc04","0x0800","%s → %s" % [IPS.resolver,IPS.pc04],"UDP 53 → 52111",answer)
	last_message = "DNS A · "+answer
	return dns_record

func tcp_test() -> bool:
	if not arp("router",WEB):
		last_message = "TCP 443 · bez cesty k bráně. Ověř DHCP a ARP."
		return false
	var route := "%s → %s" % [IPS.pc04,WEB]
	var flow := "TCP 52345 → 443"
	transmit("TCP SYN","pc04","router","0x0800",route,flow,"Navázání spojení s webem.")
	if not tcp_enabled:
		last_message = "TCP 443 · SYN bez odpovědi."
		return false
	transmit("TCP SYN‑ACK","router","pc04","0x0800","%s → %s" % [WEB,IPS.pc04],"TCP 443 → 52345","Server potvrzuje SYN a žádá potvrzení.")
	transmit("TCP ACK","pc04","router","0x0800",route,flow,"Spojení je navázáno.")
	last_message = "TCP 443 · spojení navázáno."
	return true

func web_test() -> bool:
	if dns_test()!=WEB or not tcp_test(): return false
	transmit("TLS","pc04","router","0x0800","%s → %s" % [IPS.pc04,WEB],"TCP 52345 → 443","Navázání zabezpečeného přenosu.")
	transmit("HTTPS požadavek","pc04","router","0x0800","%s → %s" % [IPS.pc04,WEB],"TCP 52345 → 443","GET /materialy (po rozbalení TLS)")
	transmit("HTTPS odpověď","router","pc04","0x0800","%s → %s" % [WEB,IPS.pc04],"TCP 443 → 52345","HTTP 200 (po rozbalení TLS)")
	last_message = "HTTPS · HTTP 200 · materiály dostupné."
	return true

func access_test(kind: String):
	match kind:
		"DSL": last_message = "DSL · synchronizováno s DSLAM."
		"WLAN": last_message = "WLAN · připojeno k Ucebna."
		"IP notebooku": last_message = "Notebook · "+("169.254.10.23 · bez nabídky DHCP." if access_fault else "192.168.10.25/24 · pronájem DHCP.")
		"Web přes kabel": last_message = "Servisní PC · HTTP 200."
		"RTT": last_message = "Vzdálený cíl · RTT v klidu 18 ms → při záloze 180 ms."

func move_sim(phone: int) -> bool:
	if sim_slot==phone: sim_slot = -1
	elif sim_slot==-1: sim_slot = phone
	else:
		last_message = "Nejdřív vyjmi SIM z druhého telefonu."
		return false
	revision += 1
	last_message = ["SIM je v telefonu A.","SIM je v telefonu B."][sim_slot] if sim_slot>=0 else "Držíš SIM. Vyber cílový telefon."
	return true

func identities(phone: int) -> String:
	return "Telefon %s · IMEI %s\n%s" % ["A" if phone==0 else "B",PHONE_IMEI[phone],
		"IMSI %s · MSISDN %s" % [IMSI,MSISDN] if sim_slot==phone else "Bez SIM"]

func comparison() -> String:
	return "\n".join([identities(0),identities(1)])

func overview() -> String:
	var lines: PackedStringArray = []
	for device in ports:
		var port: int = ports[device]
		lines.append("%s  →  %s" % [NAMES[device], "SW %02d   VLAN %d   %s" % [port,vlans[port],"LINK" if link(device) else "BEZ LINKY"] if port else "ODPOJENO"])
	return "\n".join(lines)

func configuration() -> String:
	if not link("pc04"): return "PC 04  /  BEZ LINKY"
	if lease.is_empty(): return "PC 04  /  DHCP bez platného pronájmu"
	return "PC 04  /  %s/24\nMaska %s · brána %s · DNS %s" % [lease.ip,lease.mask,lease.gateway,lease.dns]

func tables() -> String:
	var lines: PackedStringArray = ["SWITCH · MAC → port"]
	for vlan in learned:
		for address in learned[vlan]:
			lines.append("VLAN %d · %s → %02d" % [vlan,address,learned[vlan][address]])
	if learned.is_empty(): lines.append("Zatím bez zachycených zdrojů")
	lines.append("\nARP CACHE PC 04 · IPv4 → MAC")
	for ip in cache: lines.append("%s → %s" % [ip,cache[ip]])
	if cache.is_empty(): lines.append("Prázdná")
	return "\n".join(lines)
