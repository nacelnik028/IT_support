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
