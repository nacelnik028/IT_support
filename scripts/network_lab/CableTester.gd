extends RefCounted

# A bounded route tester. It cannot infer VLAN, IP, DNS or application faults.
var held := false
var source := ""
var port := 0
var result := {}
var hand: WeakRef

func take(controller: Node3D = null):
	held = true
	hand = weakref(controller) if controller!=null else null

func put_back():
	held = false
	hand = null
	source = ""
	port = 0

func release_hand():
	hand = null

func select_source(device: String):
	source = "" if source==device else device
	port = 0

func measure(network) -> Dictionary:
	if not held or source not in network.CLIENTS or port not in range(1,9):
		result = {"detail":"Připoj oba konce: konektor zařízení a konkrétní SW port.","revision":-1,"passed":false}
		return result
	var actual: int = network.ports[source]
	var state := "complete"
	if actual==0: state = "open"
	elif actual!=port: state = "wrong_endpoint"
	elif port in network.bad_ports: state = "unavailable"
	var status: String = {"complete":"ÚPLNÁ TRASA / port dostupný","open":"NEDOKONČENÁ TRASA","wrong_endpoint":"KONCE NETVOŘÍ STEJNOU TRASU","unavailable":"TRASA ZAPOJENÁ / PORT NEDOSTUPNÝ"}[state]
	var detail: String = "%s → %s → SW %02d\n%s\nMěří fyzickou trasu a dostupnost portu; neměří VLAN, DNS ani HTTPS." % [network.NAMES[source],network.patch_map[source],port,status]
	result = {"kind":"tester","source":source,"target":"SW %02d" % port,"passed":state=="complete","detail":detail,"revision":network.revision,"path":[source,"switch"],"frames":[],"state":state}
	network.measurements.tester = result.duplicate(true)
	network.journal.append(result.duplicate(true))
	# Correctly chosen endpoints also establish the same link observation as
	# the panel. A measurement of the wrong endpoints never credits a link.
	if actual==port or actual==0:
		var link_proof: Dictionary = result.duplicate(true)
		link_proof.kind = "link"
		network.measurements.link = link_proof
		network.journal.append(link_proof)
	while network.journal.size()>60: network.journal.pop_front()
	network.last_message = detail
	return result

func display(network) -> String:
	var text := "TESTER TRASY\n"
	if source=="": return text+"1 / Vyber konektor zařízení"
	text += network.NAMES[source]+" → "+("SW %02d" % port if port>0 else "vyber SW port")+"\n"
	if result.is_empty(): return text+"2 / SW port: vyber; opakuj pro měření"
	return text+("! ZASTARALÉ\n" if result.get("revision",-1)!=network.revision else "")+str(result.detail)

func screen(network) -> String:
	if source=="": return "TESTER TRASY\nVyber konektor\na SW port"
	var route: String = network.NAMES[source]+"\n"+("SW %02d" % port if port>0 else "Vyber SW port")
	if result.is_empty(): return route+"\nOpakuj port:\nZMĚŘIT"
	if result.get("revision",-1)!=network.revision: return route+"\n! ZASTARALÉ\nZměř znovu"
	return route+"\n"+str({"complete":"TRASA OK","open":"PŘERUŠENO","wrong_endpoint":"JINÁ TRASA","unavailable":"PORT\nNEDOSTUPNÝ"}.get(result.get("state",""),"Připoj sondy"))
