extends RefCounted

const Model = preload("res://scripts/network_lab/WorkshopNetwork.gd")
var catalog: Dictionary = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/service_missions.json"))
var data := {"asked":[],"causes":{},"interventions":{},"verification":false,"confirmed":false,"confirmation_revision":-1,"history":[],"assisted":false,"errors":0,"revision":0,"npc":""}

func copy_network(state: Dictionary):
	var model = Model.new()
	model.restore(state)
	return model

func expected(session) -> Array:
	var n = copy_network(session.before)
	var result: Array = []
	if not n.link("pc04"): result.append("cable")
	if n.segment("pc04") not in [0,10] or n.segment("printer")!=10: result.append("vlan")
	if not n.dhcp_pool: result.append("dhcp")
	if n.cache.has(n.IPS.router) and n.cache[n.IPS.router]!=n.gateway_mac: result.append("arp")
	if n.dns_record!=n.WEB or n.dns_cache not in ["",n.WEB]: result.append("dns")
	if not n.tcp_enabled or not n.rules.https: result.append("https")
	if n.ap_position!="center": result.append("wifi")
	return result

func service_ok(session) -> bool:
	var n = copy_network(session.network.snapshot())
	var okay: bool = n.web_test() and n.reachable("pc02","router") and n.reachable("printer","pc04")
	if session.task.id=="G": okay = okay and n.probe("near").passed and n.probe("far").passed
	return okay

func observe(session, question: String) -> String:
	var n = copy_network(session.before)
	match question:
		"what":
			return "At the start, the connection dropped when I moved between the two work areas." if session.task.id=="G" else "At the start, I could not open the company portal from this workstation."
		"since": return ["I first noticed it this morning.","It started after lunch.","I noticed it after the maintenance visit."][posmod(session.variant_seed,3)]
		"others": return "My colleague can still use the other workstation." if n.reachable("pc02","router") else "My colleague also reports a problem on the other workstation."
		"change": return "The support team worked on the network or moved the equipment before I noticed it. I do not know which settings they changed."
		"services":
			if session.task.id=="G": return "Printing and the portal work at my wired desk, but the wireless connection drops as I move."
			return "At the start, local printing worked, but the portal did not." if n.arp("printer",n.IPS.printer) else "At the start, I could not print from this workstation either."
	return "Could you explain what you mean, please?"

func select(id: String, token: int, session) -> bool:
	if session.locked() or token!=int(data.revision): return false
	data.revision += 1
	if id.begins_with("ask:"):
		var question := id.trim_prefix("ask:")
		if not question in ["what","since","others","change","services"]: return false
		if not question in data.asked: data.asked.append(question)
		data.npc = observe(session,question)
	elif id.begins_with("cause:"):
		var key := id.trim_prefix("cause:")
		if not catalog.causes.has(key): return false
		data.causes[key] = not data.causes.get(key,false)
		data.npc = "Thank you. Please also explain what you changed and how you checked it."
	elif id.begins_with("action:"):
		var key := id.trim_prefix("action:")
		if not catalog.interventions.has(key): return false
		data.interventions[key] = not data.interventions.get(key,false)
	elif id=="verify": data.verification = true
	elif id=="confirm":
		data.confirmed = service_ok(session)
		data.confirmation_revision = session.network.revision
		data.npc = "Yes, I can use the portal and print again. Thank you for checking." if data.confirmed else "I have just tried again, and I still cannot use everything I need. Please keep investigating."
	elif id=="blame":
		data.errors += 1
		data.npc = "I would appreciate a clear explanation and some help, please."
	elif id=="translate" and session.mode!="exam":
		data.assisted = true
		data.npc = "Ptejte se na příznaky, dobu vzniku, další zařízení a změny. Po opravě vysvětlete příčinu, zásah a skutečná ověření; požádejte o vyzkoušení služby."
	else: return false
	data.history.append({"intent":id,"reply":data.npc,"revision":session.network.revision})
	if data.history.size()>40: data.history.pop_front()
	return true

func assessment(session) -> Dictionary:
	var expected_keys := expected(session)
	var cause_ok := true
	var action_ok := true
	for key in catalog.causes:
		if data.causes.get(key,false)!=(key in expected_keys): cause_ok = false
		if data.interventions.get(key,false) and not key in expected_keys and not (key=="cable" and "vlan" in expected_keys): action_ok = false
	for key in expected_keys:
		if not data.interventions.get(key,false) and not (key=="vlan" and data.interventions.get("cable",false) and session.before.ports!=session.network.ports): action_ok = false
	# Every selected intervention must be supported by an actual state change.
	var n = session.network
	var old: Dictionary = session.before
	var changes := {"cable":old.ports!=n.ports and n.link("pc04"),"vlan":old.vlans!=n.vlans and n.segment("pc04")==10 and n.segment("printer")==10,
		"dhcp":not old.dhcp_pool and n.dhcp_pool and n.lease_source=="dhcp" and not n.lease.is_empty(),
		"arp":old.cache!=n.cache and n.cache.get(n.IPS.router)==n.gateway_mac,
		"dns":(old.dns_record!=n.dns_record or old.dns_cache!=n.dns_cache) and n.dns_record==n.WEB and n.dns_cache==n.WEB,
		"https":(old.tcp_enabled!=n.tcp_enabled or old.rules!=n.rules) and n.tcp_enabled and n.rules.https,
		"wifi":old.ap_position!=n.ap_position and n.ap_position=="center"}
	for key in data.interventions:
		if data.interventions[key] and not changes.get(key,false): action_ok = false
	var verified: bool = data.verification and session.task.goals.all(func(kind): return session.network.fresh(kind))
	var confirmed: bool = data.confirmed and int(data.confirmation_revision)==session.network.revision and service_ok(session)
	var score := 20*(int(data.asked.size()>=3)+int(cause_ok)+int(action_ok)+int(verified)+int(confirmed))
	score = maxi(0,score-int(data.errors)*5)
	return {"score":score,"passed":score==100,"confirmed":confirmed,"assisted":data.assisted,"questions":data.asked.size(),"cause_accurate":cause_ok,"intervention_accurate":action_ok,"verified":verified,"errors":data.errors}
