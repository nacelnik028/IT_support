extends RefCounted

# Called only by the explicit --test-world / --export-smoke entry point or
# the isolated MCP fixture. Never runs against a player's ordinary profile.
static func run(shell) -> bool:
	var game = shell.ui.game
	shell.enter_world("Počítačové sítě")
	shell.world.player.position = Vector3(5.7,0.02,-30.2)
	for frame in 3: await shell.get_tree().physics_frame
	var service = game.service_missions
	var okay := true
	for id in ["SERVICE-PORTAL","SERVICE-MOVE"]:
		okay = service.start(id,"practice") and okay
		var s = service.session
		for key in s.task.before: s.measure(key)
		if id=="SERVICE-MOVE":
			s.tester.take()
			s.tester.source = "pc04"
			s.tester.port = int(s.network.ports.pc04)
			s.measure_tester()
			s.vlan(7,10)
			s.select_cable("pc04")
			s.connect_port(6)
		s.vlan(int(s.network.ports.pc04),10)
		s.measure("dhcp")
		s.measure("dns")
		s.edit("dns",s.network.WEB)
		s.edit("flush")
		for key in s.task.goals: s.measure(key)
		if id=="SERVICE-MOVE":
			s.tester.port = int(s.network.ports.pc04)
			s.measure_tester()
		service.refresh_input()
		service.programming.edit("main.py",service.reference_code())
		okay = service.programming.test_program().ok and okay
		for key in ["what","since","services"]: s.dialogue.select("ask:"+key,int(s.dialogue.data.revision),s)
		for key in (["vlan","dns"] if id=="SERVICE-PORTAL" else ["cable","vlan"]):
			s.dialogue.select("cause:"+key,int(s.dialogue.data.revision),s)
			s.dialogue.select("action:"+key,int(s.dialogue.data.revision),s)
		s.dialogue.select("verify",int(s.dialogue.data.revision),s)
		s.dialogue.select("confirm",int(s.dialogue.data.revision),s)
		okay = service.submit().passed and game.last_save_error==OK and okay
	shell.open_network_workshop("review")
	for frame in 12: await shell.get_tree().process_frame
	var pcm := true
	for stream in shell.service_audio.streams.values():
		var playback = stream.instantiate_playback()
		playback.start()
		var nonzero := false
		for sample in playback.mix_audio(1.0,2048):
			if absf(sample.x)>0.0001: nonzero = true
		playback.stop()
		pcm = pcm and nonzero
	if DisplayServer.get_name()!="headless":
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--service-shot="):
				await RenderingServer.frame_post_draw
				shell.get_viewport().get_texture().get_image().save_png(argument.trim_prefix("--service-shot="))
	print("SERVICE_SMOKE missions=2 passed=",okay," pcm_nonzero=",pcm," clips=",shell.service_audio.streams.size()," isolated=true")
	if not okay or not pcm: push_error("Embedded service mission/audio verification failed")
	return okay and pcm
