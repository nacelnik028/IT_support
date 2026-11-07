extends RefCounted

const Network = preload("res://scripts/network_lab/LabNetwork.gd")
const MODES = {"learn":"Výuka","practice":"Procvičování","exam":"Zkouška"}
const MAX_RESULTS = 100

var catalog: Dictionary = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/network_lab/catalog.json"))
var attempts: Array = []
var network = Network.new()
var example = Network.new()
var task: Dictionary = {}
var mode := "learn"
var year := 1
var station := -1
var view := "home"
var answer: Array = []
var selected_row := 0
var selected_capture := -1
var selected_port := -1
var hints := 0
var errors := 0
var result: Dictionary = {}
var credited := false
var demo_step := -1
var demo_comment := ""
var evidence_before := ""
var persist := Callable()

func _init():
	network.reset("cable")

func cancel():
	task = {}
	view = "home"
	station = -1
	demo_step = -1
	network.reset("cable")

func start(definition: Dictionary):
	task = definition
	year = int(task.year)
	station = int(task.station)
	view = "task"
	network.reset(task.id)
	if task.id not in ["cable","vlan","dora","journey"]: network.renew()
	evidence_before = practical_measurement(task.id)
	answer = []
	if task.kind=="order":
		for index in task.options.size(): answer.append(index)
	elif task.kind=="match":
		answer.resize(task.rows.size())
		answer.fill(-1)
	elif task.kind=="diagnosis":
		answer = [-1,-1]
	elif task.has("answer"):
		answer = [-1]
	selected_row = 0
	selected_capture = -1
	selected_port = -1
	hints = 0
	errors = 0
	credited = false
	result = {}
	demo_step = -1

func restart():
	if not task.is_empty(): start(task)

func set_answer(index: int, value: int):
	if locked(): return
	answer[index] = value

func move_answer(direction: int):
	if locked(): return
	var target := selected_row+direction
	if target<0 or target>=answer.size(): return
	var previous = answer[selected_row]
	answer[selected_row] = answer[target]
	answer[target] = previous
	selected_row = target

func locked() -> bool:
	return mode=="exam" and credited

func stale() -> bool:
	return not result.is_empty() and (result.revision!=network.revision or result.answer!=answer)

func hint() -> bool:
	if task.is_empty() or mode=="exam" or hints>0 or credited: return false
	hints = 1
	return true

func practical_measurement(id: String) -> String:
	match id:
		"cable":
			return "PC 04 · %s" % ("linka aktivní na portu %02d" % network.ports.pc04 if network.link("pc04") else "linka neaktivní")
		"vlan":
			return "Port %02d · VLAN %d\n%s" % [network.ports.pc04,network.segment("pc04"),network.configuration()]
		"journey":
			return network.configuration()+"\n"+network.overview()+"\nDNS A · "+(network.dns_record if network.dns_record!="" else "NXDOMAIN po dosažení resolveru")
		"sim":
			return network.comparison()
	return ""

func evaluate_practical() -> Dictionary:
	var reason := ""
	match task.id:
		"cable":
			if not network.link("pc04"): reason = "PC 04 má stále neaktivní linku. Zkontroluj kabel a port."
		"vlan":
			if not network.reachable("pc04","router"): reason = "Linka nebo VLAN stále brání dosažení serveru DHCP."
			elif network.lease.is_empty(): reason = "Na PC 04 chybí potvrzený DHCP pronájem. Obnov DHCP."
		"journey":
			if not network.reachable("pc04","printer") or not network.reachable("pc04","pc02") or not network.reachable("pc04","router"):
				reason = "Tiskárna, obě PC a brána potřebují společný funkční segment."
			elif network.lease.is_empty(): reason = "PC 04 zatím nemá potvrzený pronájem."
			elif not network.cache.has(Network.IPS.printer) or not network.cache.has(Network.IPS.router):
				reason = "Zachyť cestu k tiskárně a vzdálenému webu. V cache zatím chybí některý soused."
			elif not network.web_test(): reason = network.last_message
		"sim":
			if network.sim_slot!=1: reason = "Telefon B zatím nemá původní fyzickou SIM."
			elif answer[0]!=int(task.answer): reason = "V přehledu obou telefonů ověř, který údaj se změnil."
	return {"passed":reason=="","reason":task.why if reason=="" else reason}

func verify() -> Dictionary:
	if task.is_empty() or locked() or (not result.is_empty() and not stale()): return result
	var assessment: Dictionary
	if task.kind=="practical":
		assessment = evaluate_practical()
	else:
		var expected: Array = task.answer if task.answer is Array else [task.answer]
		var passed := answer==expected.map(func(index): return int(index))
		var reason: String = task.why
		if not passed and mode!="exam":
			reason = "Tahle odpověď neodpovídá údajům. "+task.hint
			if mode=="learn": reason += "\n"+task.why
		assessment = {"passed":passed,"reason":reason}
	if not assessment.passed: errors += 1
	var score := maxi(0,100-10*errors-5*hints) if assessment.passed else 0
	var measured := practical_measurement(task.id)
	if assessment.passed and task.id=="journey": measured += "\n"+network.last_message
	if not measured.is_empty(): measured = "Před pokusem\n"+evidence_before+"\n\nTeď\n"+measured
	result = {"passed":assessment.passed,"reason":assessment.reason,"measurement":measured,
		"score":score,"revision":network.revision,"answer":answer.duplicate()}
	if not credited and (assessment.passed or mode=="exam"):
		credited = true
		attempts.append({"id":task.id,"mode":mode,"score":score,"passed":assessment.passed,
			"hints":hints,"errors":errors,"time":int(Time.get_unix_time_from_system())})
		if attempts.size()>MAX_RESULTS: attempts.pop_front()
		if persist.is_valid(): persist.call()
	return result

func current_network():
	return example if demo_step>=0 else network

func display_path() -> Array:
	var model = current_network()
	if view=="capture" and selected_capture>=0 and selected_capture<model.capture.size():
		return model.capture[selected_capture].path
	return model.last_path

func guide_targets() -> Array:
	if task.is_empty() or mode!="learn": return []
	if view=="capture" or demo_step>=0:
		var path := display_path()
		if not path.is_empty(): return path
	if task.kind=="match" and task.targets.size()==task.rows.size(): return [task.targets[selected_row]]
	return task.targets

func start_demo():
	if mode!="learn" or task.is_empty(): return
	example.reset("")
	demo_step = 0
	demo_comment = "Začni ukázku tlačítkem Další krok."

func next_demo():
	var key: String = task.demo
	match key:
		"link":
			if demo_step>=2: return
			if demo_step==0:
				example.unplug("pc04")
				demo_comment = "Kabel PC 04 je odpojený. Tiskárna a PC 02 mají vlastní spoje a zůstávají připojené."
			else:
				example.select_cable("pc04")
				example.connect_cable(5)
				demo_comment = "Po zapojení volného portu 05 se navázala linka PC 04. Tabule ukazuje nové spojení."
		"dhcp","printer","arp","web":
			if demo_step>=demo_limit(): return
			if demo_step==0:
				example.renew()
				demo_comment = "Discover, Offer, Request a ACK. Po potvrzení vidíš IPv4 konfiguraci PC 04. V analyzátoru můžeš rozkliknout každý rámec."
			elif demo_step==1 and key in ["printer","arp"]:
				example.arp("printer",Network.IPS.printer,true)
				demo_comment = "Tiskárna je na stejné lince. Sleduj broadcast Request, unicast Reply a novou dvojici v cache."
			elif key=="arp" and demo_step==3:
				example.observe_gateway_change(true)
				demo_comment = "Pondělí: správce vyměnil router. Po oznámení z portu brány se změnilo mapování 192.168.10.1 v ARP cache."
			elif key=="arp" and demo_step==4:
				example.observe_gateway_change(false)
				demo_comment = "Dnes bez zásahu přicházejí opakovaná nevyžádaná oznámení z klientského portu. Cache opět změnila MAC brány. Porovnej porty a kontext změny."
			elif key=="arp":
				example.arp("router",Network.WEB,true)
				demo_comment = "Pro vzdálený web si PC vyžádá MAC brány. Cílová IP paketu zůstává "+Network.WEB+"."
			elif demo_step==1:
				example.dns_test()
				demo_comment = "Ethernet obalí IPv4 a UDP s portem 53. Uvnitř je DNS dotaz typu A. Resolver vrátí adresu portálu."
			else:
				example.web_test()
				demo_comment = "TCP naváže spojení na 443, TLS chrání přenos a HTTPS vrátí HTTP 200. Rozklikni poslední rámec a sleduj linkovou i síťovou adresu."
		"dsl":
			if demo_step>=3: return
			demo_comment = ["Vedení jde do splitteru. Oddělená větev vede k telefonu a druhá k DSL modemu.",
				"Stabilní kontrolka DSL znamená synchronizaci s DSLAM. Přístupový bod připojuje notebook do místní sítě.",
				"Notebook je na Ucebna. Adresa 169.254.10.23 ukazuje, že očekávaný pronájem nedostal. Kabelový servisní PC web otevře."][demo_step]
		"latency":
			if demo_step>=2: return
			demo_comment = ["Klid · RTT ke vzdálenému cíli 18 ms. Přípojka 200 / 20 Mb/s.",
				"Probíhá záloha · RTT 180 ms. Odchozí fronta čeká na odeslání. Srovnej místní bránu a vzdálený cíl."][demo_step]
		"gsm":
			if demo_step>=3: return
			example.call_step = demo_step
			example.cell = 1 if demo_step==2 else 0
			demo_comment = ["Telefon má aktivní hovor přes BTS A. BSC řídí rádio a MSC drží cestu hovoru.",
				"Signál BTS A slábne. Telefon předává měření sousední BTS B a síť připraví vhodný kanál.",
				"Handover dokončen. Hovor běží přes BTS B a stejný BSC. Telefonní číslo se nezměnilo."][demo_step]
	demo_step += 1

func demo_limit() -> int:
	return 1 if task.demo=="dhcp" else 5 if task.demo=="arp" and task.id=="spoof" else 3 if task.demo in ["arp","web","dsl","gsm"] else 2
