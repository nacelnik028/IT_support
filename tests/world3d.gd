extends SceneTree

const Saves = preload("res://scripts/progression/SaveManager.gd")
var failures = 0
var checks = 0
var shell

func _init():
	Saves.path_override = "user://academy_test_world3d.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world3d.cfg"
	call_deferred("run")

func check(value, message: String):
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func run():
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	shell.ui.game.start_mission(0,true)
	shell.enter_world()
	var p = shell.world.player
	check(p is CharacterBody3D and p.camera is Camera3D and p.ray is RayCast3D,"Skutečný FPS controller")
	check(p.enabled and shell.mode == "world","Přechod z menu do světa")
	var before = p.position
	Input.action_press("walk_forward")
	for i in 20: await physics_frame
	Input.action_release("walk_forward")
	check(p.position.z < before.z-0.4,"W posouvá skutečné těleso")
	p.position = Vector3(0,0.02,-0.9)
	p.rotation = Vector3.ZERO
	p.camera.rotation.x = -0.1
	for i in 3: await physics_frame
	p.poll_target()
	check(p.target == shell.world.devices["PVE-01"],"RayCast vybere konkrétní PVE-01")
	check(p.target.outline.visible,"Zvýraznění cíle")
	var key = InputEventKey.new()
	key.physical_keycode = KEY_E
	key.keycode = KEY_E
	key.pressed = true
	root.push_input(key,true)
	await process_frame
	check(shell.mode == "detail" and not p.enabled,"E otevře server a zablokuje chůzi")
	shell.open_app("Proxmox")
	await process_frame
	check(shell.ui.visible and not p.enabled and shell.ui.form_controls.size()>0,"Původní funkční konzole na monitoru")
	check(shell.ui.game.apply("prepare",{"vt":true,"mode":"HBA","ups":true,"console":true}).ok,"Konzole mění společný model")
	shell.return_to_world()
	check(p.enabled and not shell.ui.visible,"Návrat od počítače")
	# Walk into the rear wall, including at fast speed; collision must stop us.
	p.position = Vector3(7,0.02,-5)
	p.rotation = Vector3.ZERO
	Input.action_press("walk_forward")
	Input.action_press("walk_fast")
	for i in 50: await physics_frame
	Input.action_release("walk_forward")
	Input.action_release("walk_fast")
	check(p.position.z > -6.7 and p.position.y > -0.1,"Kolize podlahy a stěny")
	shell.pause_menu()
	var fixed = p.position
	Input.action_press("walk_forward")
	for i in 5: await physics_frame
	Input.action_release("walk_forward")
	check(p.position == fixed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE,"Pauza zastaví chůzi a uvolní kurzor")
	check(shell.ui.game.save() == OK,"3D relace se ukládá izolovaně")
	# The academy is connected by a real doorway with a moving collider.
	shell.return_to_world()
	p.position = Vector3(7,0.02,3.5)
	p.rotation.y = -PI/2
	p.camera.rotation.x = 0
	for i in 3: await physics_frame
	p.poll_target()
	check(p.target==shell.world.devices["ACADEMY-DOOR"],"Dveře akademie lze zaměřit fyzickým raycastem")
	root.push_input(key,true)
	for i in 45: await physics_frame
	check(shell.world.door_open,"E skutečně otevře průchozí dveře")
	Input.action_press("walk_forward")
	for i in 65: await physics_frame
	Input.action_release("walk_forward")
	check(p.position.x>9.3,"Do akademie lze fyzicky dojít bez teleportu")
	shell.ui.game.sim.state.world.identified["RAID:2"] = true
	shell.world.sync_state()
	check(shell.world.devices["RAID:2"].outline.visible,"Ruční identifikace zapne fyzickou značku slotu")
	for lesson_mode in ["learn","practice","exam"]:
		shell.ui.begin_lesson(1002,lesson_mode,false)
		shell.world.sync_state()
		check(not shell.world.devices["RAID:2"].outline.visible,"Identifikace z předchozí relace nepřejde do lekce: "+lesson_mode)
		shell.update_guidance()
		check(p.enabled and p.position.x>9,"Lekce začíná ve skutečné akademii: "+lesson_mode)
		var highlighted = false
		for object in shell.world.devices.values(): highlighted = highlighted or object.guide.visible
		check(highlighted==(lesson_mode=="learn"),"3D vedení pouze v režimu Učím se: "+lesson_mode)
		check((shell.direction.text!="")== (lesson_mode=="learn"),"Směrový ukazatel respektuje režim: "+lesson_mode)
		if lesson_mode=="learn":
			check(not shell.ui.game.sim.state.world.tutorial_arrived and int(shell.ui.game.tutorial.session.step)==0,"Pouhé zahájení neprovede kroky")
			p.position = Vector3(11.5,0.02,-1.6)
			shell.update_guidance()
			check(shell.ui.game.sim.state.world.tutorial_arrived,"Příchod je ověřen vzdáleností skutečného hráče")
			shell.interact(shell.world.devices["PVE-TRAIN-01"])
			check(int(shell.ui.game.tutorial.session.step)==1,"Interakce se skutečným cvičným serverem validuje původní krok")
			shell.open_app("Proxmox")
			await process_frame
			check(shell.ui.game.tutorial.guided() and not p.enabled,"Průvodce pokračuje do původního administračního UI")
			shell.return_to_world()
	# Direct disk targeting and LEDs use the same simulator that the UI uses.
	shell.ui.game.start_mission(0,true)
	shell.ui.game.sim.reset({"disks":{"2":{"health":"Failed"}},"raid":{"health":"Degraded"}})
	shell.enter_world()
	shell.world.sync_state()
	check(shell.world.devices["RAID:2"].status=="Failed" and shell.world.devices["NAS-01"].status=="Degraded","LED disku i zařízení odpovídají modelu")
	p.position = Vector3(3.35,0.02,-0.8)
	p.rotation = Vector3.ZERO
	p.camera.look_at(shell.world.devices["RAID:2"].global_position)
	for i in 3: await physics_frame
	p.poll_target()
	check(p.target==shell.world.devices["RAID:2"],"Konkrétní diskový slot je skutečný raycast cíl")
	root.push_input(key,true)
	await process_frame
	check(shell.mode=="detail" and shell.selected.slot=="2","E otevře servis správného slotu")
	if "--screenshots" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		shell.return_to_world()
		p.position = Vector3(3,0.02,4)
		p.look_at(Vector3(0,0.02,-3))
		p.camera.rotation.x = -0.03
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-output/world3d-stage2.png")
	shell.queue_free()
	await process_frame
	print("WORLD3D: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
