extends "res://tests/support_dialogue.gd"

const Game = preload("res://scripts/core/GameManager.gd")

func complete(service):
	var s = service.session
	for key in s.task.before: s.measure(key)
	if service.id=="SERVICE-MOVE":
		s.tester.take()
		s.tester.source = "pc04"
		s.tester.port = int(s.network.ports.pc04)
		s.measure_tester()
	# Two equally valid orders: the printer can be corrected before the PC.
	if service.id=="SERVICE-MOVE": s.vlan(int(s.network.ports.printer),10)
	if not s.network.link("pc04"):
		for port in range(3,9):
			if s.network.occupant(port)=="" and port not in s.network.bad_ports and s.network.vlans[port]==10:
				s.select_cable("pc04")
				s.connect_port(port)
				break
	s.vlan(int(s.network.ports.pc04),10)
	s.measure("dhcp")
	s.measure("dns")
	s.edit("dns",s.network.WEB)
	s.edit("flush")
	for key in s.task.goals: s.measure(key)
	if service.id=="SERVICE-MOVE":
		s.tester.port = int(s.network.ports.pc04)
		s.measure_tester()
	service.refresh_input()
	service.programming.edit("main.py",service.reference_code())
	check(service.programming.test_program().ok,"Actual input Python analysis "+service.id)
	handover(s)

func run():
	var game = Game.new()
	game.game_mode.switch_to(game.Modes.Mode.NETWORK_LAB)
	var service = game.service_missions
	for mode_value in ["learn","practice","exam"]:
		for mission_id in ["SERVICE-PORTAL","SERVICE-MOVE"]:
			check(service.start(mission_id,mode_value),"Start "+mission_id+mode_value)
			check(game.last_save_error==OK,"Valid initial draft "+str(game.save_message))
			check(not service.technical().passed,"Unrepaired mission rejected")
			service.programming.edit("main.py","def "+str(service.definition(mission_id).function)+"(rows):\n    return ['invented']\n")
			check(not service.programming.test_program().ok,"Wrong program rejected")
			check(not service.verify().passed,"Communication cannot replace repair")
			complete(service)
			check(service.analysis_current(),"Analysis bound to current attempt and revision")
			check(service.verify().passed,"Whole mission "+mission_id+mode_value+str(service.verify()))
			check(game.save()==OK,"Complete draft validates "+game.save_message)
			var count: int = service.data.history.size()
			service.submit()
			var xp: int = game.progress.xp
			service.submit()
			check(service.data.history.size()==count+1 and game.progress.xp==xp,"One result and reward")
			check(game.last_save_error==OK,"Result saves "+game.save_message)
	check(Saves.rules().service_missions(service.data),"Service result schema")
	# Whole-incident persistence, actual stale data, and suspended main work.
	service.suspend()
	game.leave_training()
	game.start_mission(0)
	game.sim.state.hosts["PVE-01"].hostname = "service-protected-campaign"
	var campaign: Dictionary = game.snapshot().duplicate(true)
	game.enter_network_lab()
	service.start("SERVICE-PORTAL","exam")
	var s = service.session
	for key in s.task.before: s.measure(key)
	service.programming.edit("main.py",service.reference_code())
	check(service.programming.test_program().ok and service.analysis_current(),"Useful analysis of actual initial failure log")
	s.vlan(int(s.network.ports.pc04),10)
	check(not service.analysis_current() and not service.programming.test_program().ok,"Network change invalidates prior input and analysis")
	service.refresh_input()
	check(service.programming.test_program().ok,"Changed actual inputs evaluated")
	s.undo()
	check(not service.analysis_current(),"Undo invalidates analysis as a new revision")
	check(game.save()==OK,"Partial exam saved")
	var attempt: String = service.attempt_id
	var network_hash: String = service.content_hash(service.stripped(s.network.snapshot()))
	var restored = Game.new()
	check(restored.sim.state.hosts["PVE-01"].hostname=="service-protected-campaign" and not restored.service_missions.active,"Restart restores campaign, offers mission explicitly")
	restored.enter_network_lab()
	var resumed = restored.service_missions
	check(resumed.resume("SERVICE-PORTAL"),"Explicit resume")
	check(resumed.attempt_id==attempt and resumed.session.mode=="exam" and resumed.programming.files==service.programming.files,"Exact attempt, mode and code across restart")
	check(resumed.content_hash(resumed.stripped(resumed.session.network.snapshot()))==network_hash,"Exact saved network revision and evidence")
	complete(resumed)
	check(resumed.verify().passed,"Complete resumed incident")
	resumed.session.network.measurements.erase("control")
	check(not resumed.technical().passed,"Working service without required proof rejected")
	resumed.session.measure("control")
	resumed.programming.edit("main.py","def failed_checks(rows):\n    return []\n")
	check(not resumed.programming.test_program().ok,"Hardcoded empty answer fails actual initial dataset even after full repair")
	resumed.programming.edit("main.py","def failed_checks(rows):\n    result = []\n    index = 0\n    while index < len(rows):\n        row = rows[index]\n        if row['ok'] == False:\n            result.append(row['check'])\n        index += 1\n    return result\n")
	check(resumed.programming.test_program().ok,"Alternative while implementation accepted")
	resumed.session.dialogue.data.confirmed = false
	check(not resumed.verify().passed and resumed.verify().technical.passed,"Communication independent of successful technical result")
	say(resumed.session,"confirm")
	resumed.submit()
	restored.leave_training()
	check(service.content_hash(restored.snapshot())==service.content_hash(campaign),"Campaign preserved exactly")
	check(restored.shifts.start("SHIFT-NET"),"Start protected shift")
	var shift_state: Dictionary = restored.sim.state.duplicate(true)
	var shift: Dictionary = restored.shifts.data.session.duplicate(true)
	restored.enter_network_lab()
	resumed.start("SERVICE-MOVE","practice")
	resumed.session.select_cable("pc04")
	resumed.session.connect_port(6)
	restored.save()
	resumed.suspend()
	var parked: Dictionary = resumed.data.drafts["SERVICE-MOVE"].duplicate(true)
	restored.enter_programming()
	restored.leave_training()
	check(service.content_hash(shift_state)==service.content_hash(restored.sim.state) and service.content_hash(shift)==service.content_hash(restored.shifts.data.session),"Other classroom preserves exact suspended shift")
	restored.enter_network_lab()
	resumed.start("SERVICE-PORTAL","learn")
	check(resumed.data.drafts["SERVICE-MOVE"]==parked,"Starting another mission preserves parked mission")
	attempt = resumed.attempt_id
	resumed.programming.edit("main.py","print('draft')")
	resumed.start("SERVICE-PORTAL","learn")
	check(attempt!=resumed.attempt_id and resumed.programming.files["main.py"]==resumed.starter() and resumed.session.variant_seed==1,"Explicit restart resets entire mission, preserves variant")
	var profile_before: int = restored.progress.xp
	var summary: Array = restored.Profile.skills(restored)
	check(summary.filter(func(row): return row.skill=="Python")[0].count>=6,"Mission evidence reaches shared profile")
	restored.Profile.skills(restored)
	check(restored.progress.xp==profile_before,"Reading profile gives no second reward")
	# A real unwritable/missing parent: memory keeps one result until retry.
	var original_path: String = Saves.path_override
	Saves.path_override = original_path+".retry.json"
	var retry_game = Game.new()
	retry_game.enter_network_lab()
	var retry_service = retry_game.service_missions
	retry_service.start("SERVICE-PORTAL","practice")
	complete(retry_service)
	var previous := FileAccess.get_file_as_bytes(Saves.path_override)
	var writable: String = Saves.path_override
	Saves.path_override = "user://missing-service-"+str(OS.get_process_id())+"/save.json"
	retry_service.submit()
	var reward: int = retry_game.progress.xp
	check(retry_game.unsaved and reward==200 and retry_service.data.history.size()==1,"Real write failure preserves a single rewarded result in memory")
	check(FileAccess.get_file_as_bytes(writable)==previous,"Failed write preserves original bytes")
	Saves.path_override = writable
	retry_service.submit()
	check(not retry_game.unsaved and retry_game.progress.xp==reward and retry_service.data.history.size()==1,"Retry writes same result and reward once")
	var reloaded = Game.new()
	check(reloaded.service_missions.data.history.size()==1 and reloaded.progress.xp==reward,"Result survives real restart")
	# Old schema data contain no invented evidence, seed, help or grading.
	Saves.path_override = original_path+".legacy.json"
	check(Saves.save_game({"progress":{"xp":17,"scores":{},"mistakes":{},"achievements":[],"last_mission":1}})==OK,"Old minimal profile accepted")
	var legacy = Game.new()
	check(legacy.progress.xp==17 and legacy.service_missions.data.history.is_empty() and legacy.service_missions.data.drafts.is_empty(),"Legacy data unchanged without invented service evidence")
	Saves.path_override = original_path
	print("SERVICE MISSIONS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
