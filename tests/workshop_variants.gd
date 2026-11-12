extends SceneTree

const Session = preload("res://scripts/network_lab/WorkshopSession.gd")
const Saves = preload("res://scripts/progression/SaveManager.gd")
var checks := 0
var failures := 0

func _init():
	var tag := "user://academy_test_variants_"+str(OS.get_process_id())
	Saves.path_override = tag+".json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = tag+".cfg"
	preload("res://scripts/xr/VRSettings.gd").path_override = tag+"_vr.cfg"
	call_deferred("run")

func check(value: bool, title: String):
	checks += 1
	if not value:
		failures += 1
		push_error(title)

func repair(s):
	var n = s.network
	if not n.link("pc04"):
		for port in range(3,9):
			if n.occupant(port)=="" and port not in n.bad_ports and n.vlans[port]==10:
				s.select_cable("pc04")
				s.connect_port(port)
				break
	s.vlan(n.ports.pc04,10)
	s.edit("pool",true)
	s.measure("dhcp")
	# H requires observing the wrong name after restoring the physical/IP path.
	if s.task.id=="H": s.measure("dns")
	s.edit("arp")
	s.edit("dns",n.WEB)
	s.edit("flush")
	s.edit("tcp",true)
	s.edit("https_rule",true)
	s.edit("ap","center")
	for kind in s.task.goals: s.measure(kind)
	if s.task.id=="H":
		for key in s.task.get("required_causes",["vlan","dns"]): s.causes[key] = true
		s.evidence_summary = {"dhcp":true,"services":true}

func run():
	var s = Session.new()
	for mode_value in ["learn","practice","exam","free"]:
		for id in ["A","B","C","D","E","F","G","H"]:
			var distinct := {}
			for seed_value in range(4):
				s.mode = mode_value
				s.start(id,seed_value)
				var context: String = id+" / "+mode_value+" / "+str(seed_value)
				var initial: Dictionary = s.network.snapshot()
				distinct[JSON.stringify(s.task.initial)] = true
				check(not s.assessment().passed,"Unrepaired "+context)
				for proof in s.task.before: s.measure(proof)
				# Wrong shortcuts do not fix the actual incident.
				s.edit("management",true)
				for proof in s.task.goals: s.measure(proof)
				check(not s.assessment().passed,"Shortcut rejected "+context)
				s.reset_attempt()
				check(initial==s.network.snapshot() and s.variant_seed==seed_value,"Reset same variant "+context)
				for proof in s.task.before: s.measure(proof)
				repair(s)
				check(s.assessment().passed,"Reference "+context+str(s.assessment()))
				if mode_value=="learn":
					var state: Dictionary = s.network.snapshot()
					s.start_demo()
					for step in 5: s.demo_next()
					check(s.example.web_test() and s.network.snapshot()==state,"Isolated matching demo "+context)
					s.demo = false
				var count: int = s.attempts.size()
				s.submit()
				s.submit()
				check(s.attempts.size()==mini(100,count+1) if mode_value!="free" else s.attempts.size()==count,"Single result "+context)
				if mode_value!="free": check(s.attempts[-1].variant.seed==seed_value,"Stored identity "+context)
				s.start(id,seed_value)
				check(s.network.snapshot()==initial,"Reproducible "+context)
				s.edit("tcp",not s.network.tcp_enabled)
				s.undo()
				check(s.network.ports==initial.ports and s.variant_seed==seed_value and s.network.revision>initial.revision,"Undo identity "+context)
			check(distinct.size()==4,"Four distinct initial states "+id)
	# Alternative repair: reassign VLAN or move the cable, both state based.
	for seed_value in range(4):
		s.mode = "practice"
		s.start("B",seed_value)
		s.measure("dhcp")
		for port in range(3,9):
			if s.network.occupant(port)=="" and port not in s.network.bad_ports and s.network.vlans[port]==10:
				s.select_cable("pc04")
				s.connect_port(port)
				break
		for proof in s.task.goals: s.measure(proof)
		check(s.assessment().passed,"Alternative port "+str(seed_value))
		s.verify()
		s.edit("tcp",false)
		check(s.stale() and not s.network.fresh("control"),"Evidence invalidation "+str(seed_value))
	check(Saves.rules().workshop_attempts(s.attempts),"Saved new results validate")
	var old_record: Dictionary = s.attempts[0].duplicate(true)
	old_record.erase("variant")
	check(Saves.rules().workshop_attempts([old_record]) and not old_record.has("variant"),"Old results unaltered")
	var classroom = preload("res://scripts/network_lab/LabNetwork.gd").new()
	classroom.reset("")
	classroom.select_cable("pc04")
	classroom.connect_cable(8)
	check(not classroom.link("pc04"),"Classroom port 08 unchanged")
	print("WORKSHOP VARIANTS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
