extends RefCounted

static func run(shell):
	var g=shell.ui.game
	var ok=g.shifts.start("SHIFT-NET")
	for action in [["physical_inspect",{"device":"PVE-01"}],["physical_cable",{"device":"PVE-01","port":1,"connected":true}]]: ok=g.apply(action[0],action[1]).ok and ok
	ok=g.complete().ok and ok
	ok=g.apply("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true}).ok and ok
	g.apply("verify",{}); ok=g.complete().ok and ok
	ok=g.apply("backup",{"vm":"100"}).ok and ok
	g.apply("backup_verify",{"operation":"Verify"}); g.apply("verify",{}); ok=g.complete().ok and ok
	var restored=preload("res://scripts/core/GameManager.gd").new()
	print("EXPORT_SMOKE shifts=",ok," restored_shift=",restored.session_kind=="shift" and restored.shifts.data.session.finished)
	var report=preload("res://scripts/ui/NetworkExplanation.gd").describe(g,"100")
	print("EXPORT_SMOKE network=",report.checked and report.statuses.all(func(status): return status=="FUNKČNÍ"))
	shell.practical_intro.start(); shell.practical_intro.finish(false)
	print("EXPORT_SMOKE introduction=",not g.introduction_active and g.session_kind=="shift")
	var clips=0
	for line in shell.speech.mapping.lines:
		for variant in ["normal","slow"]:
			var stream=load(line[variant])
			if stream is AudioStreamMP3 and stream.get_length()>0.5: clips+=1
	print("EXPORT_SMOKE speech_clips=",clips)

	# Actual exported-content roundtrip, never the player's save/config.
	shell.enter_world("Programming Academy")
	g.programming.start("PY01","practice"); g.programming.edit("main.py","# export concept\nprint(")
	var key=g.programming.drafts.key(g.programming.draft_record()); g.save()
	var reloaded=preload("res://scripts/core/GameManager.gd").new(); reloaded.enter_programming()
	var draft_ok=reloaded.programming.restore_draft(key) and reloaded.programming.files["main.py"]=="# export concept\nprint(" and reloaded.programming.last_result.is_empty()
	print("EXPORT_SMOKE work_roundtrip=",draft_ok)
	shell.enter_world("Hlavní serverovna"); g.shifts.start("SHIFT-NET"); shell.ui.hint()
	g.apply("physical_inspect",{"device":"PVE-01"}); g.apply("physical_cable",{"device":"PVE-01","port":1,"connected":true})
	var scored=g.complete()
	print("EXPORT_SMOKE score_v2=",scored.ok and scored.score==96 and scored.breakdown.hints==1)
	g.shifts.start("SHIFT-RECOVERY"); g.apply("shift_wait",{"minutes":1}); var clock=g.sim.state.shift_runtime.clock
	g.shifts.select_ticket(1); g.save(); reloaded=preload("res://scripts/core/GameManager.gd").new()
	print("EXPORT_SMOKE advanced=",reloaded.shifts.data.session.id=="SHIFT-RECOVERY" and reloaded.sim.state.shift_runtime.clock==clock and reloaded.shifts.definition("SHIFT-RESILIENCE").tickets.size()==5)
	print("EXPORT_SMOKE debrief=",g.work.data.reviews.any(func(review): return review.score==96 and not review.events.is_empty()))
	shell.enter_world("English in London"); g.english.listening.start("LONL01","practice",71); g.english.listening.transcript(g.english.listening.revision)
	var answer=g.english.listening.answer("ticket_options",g.english.listening.revision)
	print("EXPORT_SMOKE listening=",answer and g.english.listening.progress.results.LONL01.helped and g.english.listening.catalog.tasks.size()==12)
	print("EXPORT_SMOKE knowledge=",g.Profile.skills(g).size()==13)
