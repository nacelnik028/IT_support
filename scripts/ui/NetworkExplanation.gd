extends RefCounted

const Network=preload("res://scripts/simulation/NetworkSimulator.gd")
const Physical=preload("res://scripts/simulation/PhysicalOperations.gd")
const Sim=preload("res://scripts/simulation/InfrastructureSimulator.gd")

static func describe(game, id: String) -> Dictionary:
	var s=game.sim.state
	var vm=game.sim.get_vm(id)
	if vm.is_empty(): return {}
	var exam=game.session_kind=="lesson" and game.tutorial.session.mode=="exam" and not game.finished
	var checked=s.diagnostic.get("network_checks",{}).get(id,-1)==s.revision
	var probe=Network.probe(s,id)
	var device=s.world.devices[vm.host]
	var known=checked and not exam
	var statuses=[]
	# Network.probe is the authoritative service path. Later layers remain
	# unknown after an upstream failure rather than inventing failed packets.
	var reachable=known
	for ok in [s.hosts[vm.host].online and vm.status=="Running",Physical.link_ok(s,vm.host),probe.link,probe.ip,probe.app]:
		statuses.append(("FUNKČNÍ" if ok else "ZÁVADA") if reachable else "NEOVĚŘENO")
		if not ok: reachable=false
	var names=["VM %s / %s @ %s" % [id,vm.name,vm.host],"Fyzická NIC %s / kabel / SW-CORE port %d" % [vm.host,int(device.port)],"Virtuální switch %s / VLAN %d" % [vm.bridge,int(vm.vlan)],"Brána %s / IP %s/%d" % [vm.gateway,vm.ip,int(vm.prefix)],"app.lab.example / HTTPS 443 / data"]
	if exam: names=["VM %s / %s @ %s" % [id,vm.name,vm.host],"Fyzické rozhraní hostitele","Virtuální síť","Brána","Cílová služba"]
	var before=Sim.new(); before.reset(game.current.get("initial_state",{}))
	var original=before.get_vm(id)
	var comparison=""
	if known and not original.is_empty():
		comparison="Před opravou → nyní: VLAN %d → %d · IP %s/%d → %s/%d · brána %s → %s · port %d → %d" % [int(original.vlan),int(vm.vlan),original.ip,int(original.prefix),vm.ip,int(vm.prefix),original.gateway,vm.gateway,int(before.state.world.devices[original.host].port),int(device.port)]
		comparison+=" · kabel %s → %s" % ["připojen" if before.state.world.devices[original.host].cable_connected else "odpojen","připojen" if device.cable_connected else "odpojen"]
	return {"names":names,"statuses":statuses,"checked":known,"reason":probe.reason if known else "Proveď kontrolu VM nebo ověření infrastruktury. Změna konfigurace předchozí kontrolu zneplatní." if not exam else "Zkouška: rozbor příčin se zobrazí až po odevzdání.","impact":("Služba a data dostupné." if probe.app else "Služba tímto ověřením nedostupná.") if known else "Dopad dosud neověřen.","comparison":comparison}

static func draw(ui, parent: Node, id: String):
	var report=describe(ui.game,id)
	if report.is_empty(): return
	var c=ui.card(parent,"Vysvětlení cesty / VM "+id,"Stav laboratorního modelu; nejde o simulaci skutečných paketů ani OS.")
	for i in report.names.size():
		c.add_child(ui.label(("↓ " if i>0 else "")+report.names[i]+"  /  "+report.statuses[i],16,ui.CYAN if report.statuses[i]=="FUNKČNÍ" else ui.ORANGE if report.statuses[i]=="ZÁVADA" else ui.MUTED))
	c.add_child(ui.label("Co bylo zjištěno: "+report.reason,16))
	c.add_child(ui.label("Dopad na službu: "+report.impact,16))
	if report.comparison!="": c.add_child(ui.label(report.comparison,14,ui.MUTED))
	c.add_child(ui.button("Provést kontrolu cesty VM "+id,func(): ui.game.apply("probe",{"vm":id,"destination":"application"}); ui.draw_ui()))
