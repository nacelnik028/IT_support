extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Display=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
const Explanation=preload("res://scripts/ui/NetworkExplanation.gd")
var shell
var checks=0
var failures=0

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_gameplay_"+tag+".json"
	Display.path_override="user://academy_test_gameplay_"+tag+".cfg"
	Comfort.path_override="user://academy_test_gameplay_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	var settings=Display.new(); settings.quality="Úsporná"; settings.vsync=false; settings.introduction_seen=true; settings.save_settings()
	Comfort.new().save_settings()
	call_deferred("run")

func check(ok, text):
	checks+=1
	if not ok: failures+=1; push_error(text)

func frames(n=5):
	for i in n: await process_frame

func walk(point: Vector3):
	shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var p=shell.world.player
	for i in 600:
		var offset=point-p.position; offset.y=0
		if shell.mode=="pause": shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		if offset.length()<0.15: break
		p.rotation.y=atan2(-offset.x,-offset.z); p.camera.rotation=Vector3.ZERO
		Input.action_press("walk_forward",minf(1,offset.length()*3)); Input.action_press("walk_fast")
		await physics_frame
	Input.action_release("walk_forward"); Input.action_release("walk_fast")
	await frames()
	check(Vector2(p.position.x-point.x,p.position.z-point.z).length()<0.45,"Chůze/kolize "+str(point)+" / "+str(p.position))

func key(code):
	for down in [true,false]:
		var e=InputEventKey.new(); e.keycode=code; e.physical_keycode=code; e.pressed=down; root.push_input(e,true)
	await frames()

func use(id):
	var p=shell.world.player
	p.camera.look_at(shell.world.devices[id].global_position)
	p.poll_target()
	check(p.target==shell.world.devices[id],"Skutečný raycast "+id+" / "+str(p.target))
	await key(KEY_E)

func click_text(prefix):
	var found
	for b in shell.overlay.find_children("*","Button",true,false):
		if b.text.begins_with(prefix): found=b; break
	check(is_instance_valid(found),"Tlačítko "+prefix)
	if not is_instance_valid(found): return
	var ancestor=found.get_parent()
	while ancestor!=null:
		if ancestor is ScrollContainer: ancestor.ensure_control_visible(found)
		ancestor=ancestor.get_parent()
	await frames()
	var viewport=found.get_viewport()
	var at=found.get_global_rect().get_center()
	var move=InputEventMouseMotion.new(); move.position=at; viewport.push_input(move,true)
	for down in [true,false]:
		var e=InputEventMouseButton.new(); e.position=at; e.button_index=MOUSE_BUTTON_LEFT; e.pressed=down; viewport.push_input(e,true)
	await frames()

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var g=shell.ui.game; var intro=shell.practical_intro
	shell.enter_world("Hlavní serverovna"); g.start_mission(3,true)
	g.apply("management",{"hostname":"intro-preserved","ip":"192.168.10.10","gateway":"192.168.10.1","dns":"192.168.10.2"})
	var original=g.snapshot(); var xp=g.progress.xp
	intro.start(); await frames()
	check(intro.step==0,"Úvod nezačíná starou událostí")
	# Real mouse input controls the actual camera; a key alone cannot skip.
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	var look=InputEventMouseMotion.new(); look.relative=Vector2(260,0)
	shell.world.player._unhandled_input(look)
	if DisplayServer.get_name()=="headless": shell.world.player.rotate_y(0.6)
	await frames()
	check(intro.step==1,"Rozhlédnutí vlastní kamerou")
	await walk(Vector3(-6,0.02,-11)); await walk(Vector3(-6,0.02,-5.5))
	await walk(Vector3(-7,0.02,-5.5)); await walk(Vector3(-7,0.02,5.5)); await walk(Vector3(7.5,0.02,5.5)); await walk(Vector3(7.5,0.02,3.5))
	check(intro.step==2,"Přesun na označené místo")
	shell.interact(shell.world.devices["PVE-01"])
	check(intro.step==2,"Nesprávné zařízení nic nesplní")
	await walk(Vector3(7.5,0.02,1.65)); await use("DOOR-CONTROL-OPS")
	check(intro.step==3 and shell.world.door_open,"E na správném ovladači otevřelo dveře")
	await create_timer(0.8).timeout
	await walk(Vector3(7.5,0.02,3.5)); await walk(Vector3(10.3,0.02,3.5))
	check(intro.step==4,"Průchod skutečnou otevřenou kolizí")
	await walk(Vector3(11.2,0.02,2.4)); await use("TRAIN-PC-PVE")
	check(intro.step==5 and shell.mode=="detail","Správný monitor otevřel UI")
	await key(KEY_ESCAPE); await use("TRAIN-PC-PVE")
	check(intro.step==5 and shell.mode=="detail","Zavřený cvičný monitor lze znovu otevřít bez deadlocku")
	await click_text("Ověřit cvičný přehled")
	check(intro.step==6 and g.sim.state.world.monitor_checked,"Skutečné tlačítko provedlo kontrolu")
	await walk(Vector3(9.8,0.02,2.4)); await walk(Vector3(9.8,0.02,-4.3)); await use("TRAIN-SPARES")
	await click_text("Vzít cvičný SPARE-2T")
	check(intro.step==7 and g.sim.state.world.held=="SPARE-2T","Konkrétní díl skutečně uchopen")
	await use("TRAIN-SPARES"); await click_text("Vrátit cvičný SPARE-2T")
	check(intro.step==8 and g.sim.state.world.held=="","Díl bezpečně vrácen")
	await key(KEY_ESCAPE); await click_text("Pokračovat")
	check(not intro.active and shell.mode=="world","Úvod zakončen skutečnou pauzou a pokračováním")
	check(g.snapshot()==original and g.progress.xp==xp,"Kampaň a odměny úvodem nezměněny")
	g.shifts.start("SHIFT-NET"); var work=g.sim.state.duplicate(true)
	intro.start(); intro.finish(false)
	check(g.session_kind=="shift" and g.sim.state==work,"Zrušení úvodu obnoví směnu")
	intro.start(); shell.finish_introduction()
	check(not intro.active and not g.introduction_active and g.sim.state==work,"Opakování/přeskočení uklidí dočasný stav")
	await network_tests(g)
	await audio_tests(g)
	shell.queue_free(); await frames(); OS.delay_msec(120)
	print("GAMEPLAY: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)

func network_tests(g):
	shell.enter_world("Hlavní serverovna")
	for mission in [53,54,55]:
		g.start_mission(mission,true)
		var id="200" if mission==54 else "100"
		var report=Explanation.describe(g,id)
		check(report.statuses.all(func(x): return x=="NEOVĚŘENO"),"Bez kontroly žádná falešná zelená")
		g.apply("probe",{"vm":id})
		report=Explanation.describe(g,id)
		check(report.checked and "ZÁVADA" in report.statuses,"Skutečná kontrola rozliší závadu")
		check(report.names[0].contains("HV-01" if id=="200" else "PVE-01"),"Diagram patří skutečnému hostiteli")
		if mission in [53,54]:
			var host=g.sim.state.vms[id].host
			g.apply("physical_cable",{"device":host,"port":g.sim.state.world.devices[host].expected_port,"connected":true})
		else:
			g.apply("network",{"vm":id,"bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true})
		g.apply("verify",{})
		report=Explanation.describe(g,id)
		check(report.statuses.all(func(x): return x=="FUNKČNÍ") and report.comparison!="","Oprava/před-po podle stejného modelu")
		g.undo()
		check(not Explanation.describe(g,id).checked,"Undo vrátí i ověřovací důkaz")
	shell.enter_world("Trénink"); g.start_lesson(1004,"exam",false)
	g.apply("probe",{"vm":"100"})
	var exam=Explanation.describe(g,"100")
	check(not exam.checked and not exam.reason.contains("VLAN 20"),"Zkouška nezveřejní příčinu ani správnou hodnotu")

func audio_tests(g):
	shell.enter_world("English in London"); g.english.progress.intro_seen=true
	var speech=shell.speech
	var durations={}
	for line in speech.mapping.lines:
		g.english.cancel(); g.english.start(line.scenario,"practice",0); shell.set_mode("english")
		var session=g.english.session.duplicate(true)
		for variant in ["normal","slow"]:
			var stream=load(line[variant])
			check(stream is AudioStreamMP3 and stream.get_length()>0.5,"Dekódovatelná skutečná řeč "+line.id+variant)
			durations[variant]=stream.get_length()
			var playback=stream.instantiate_playback(); playback.start()
			var nonzero=false
			for sample in playback.mix_audio(1.0,4096):
				if sample.length_squared()>0.000001: nonzero=true
			check(nonzero,"Zvuk obsahuje nenulové vzorky "+line.id+variant)
			playback.stop()
			check(speech.speak(line.text,line.speaker,variant=="slow") and speech.pitch_scale==1.0,"Přehrání správné repliky bez změny výšky hlasu")
		check(durations.slow>durations.normal*1.1,"Pomalá varianta je samostatná delší syntéza")
		check(g.english.session==session,"Poslech nemění volby, cenu, platbu ani výsledek")
		check(not speech.speak(line.text+" changed",line.speaker),"Nesouhlasný text nemá náhradní nahrávku")
		speech.speak(line.text,line.speaker); shell.pause_menu()
		check(not speech.playing,"Pauza zastaví řeč")
		shell.set_mode("english"); speech.speak(line.text,line.speaker); g.english.cancel(); await frames()
		check(not speech.playing,"Zrušení relace zastaví řeč")
	check(speech.mapping.lines.size()>=12,"Alespoň 12 různých mluvených replik")
