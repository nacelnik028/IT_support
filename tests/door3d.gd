extends SceneTree

var shell
var failures = 0
var checks = 0

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_door3d.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_door3d.cfg"
	call_deferred("run")

func check(value, description):
	checks += 1
	if not value: failures += 1; push_error(description)

func wait_motion():
	for i in 50: await physics_frame

func use_control(id: String, at: Vector3):
	var p = shell.world.player
	p.position = at
	p.rotation = Vector3.ZERO
	p.camera.rotation = Vector3.ZERO
	p.camera.look_at(shell.world.devices[id].global_position)
	for i in 3: await physics_frame
	p.poll_target()
	check(p.target==shell.world.devices[id],"Pevný ovladač lze zaměřit: "+id)
	var key = InputEventKey.new()
	key.keycode = KEY_E
	key.physical_keycode = KEY_E
	key.pressed = true
	root.push_input(key,true)
	await wait_motion()

func run():
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	shell.ui.game.start_mission(0,true)
	shell.enter_world()
	var world = shell.world
	var original = world.devices["DOOR-CONTROL-OPS"].position
	await use_control("DOOR-CONTROL-OPS",Vector3(7.4,0.02,1.65))
	check(world.door_open,"Panel v serverovně otevře dveře")
	check(world.devices["ACADEMY-DOOR"].position.z>6,"Křídlo je skutečně zasunuté za stěnou")
	check(world.devices["DOOR-CONTROL-OPS"].position==original,"Ovladač zůstane na místě")
	await use_control("DOOR-CONTROL-OPS",Vector3(7.4,0.02,1.65))
	check(not world.door_open and is_equal_approx(world.devices["ACADEMY-DOOR"].position.z,3.5),"Stejný dostupný panel dveře znovu zavře")
	await use_control("DOOR-CONTROL-ACADEMY",Vector3(10.6,0.02,1.65))
	check(world.door_open,"Dveře lze otevřít z akademie")
	await use_control("DOOR-CONTROL-ACADEMY",Vector3(10.6,0.02,1.65))
	check(not world.door_open,"Dveře lze zavřít z akademie")
	world.move_door(true)
	await wait_motion()
	world.player.position = Vector3(9,0.02,3.5)
	check(not world.toggle_door() and world.door_open,"Bezpečnostní čidlo blokuje zavření do hráče")
	check(world.door_status.text.contains("OBSAZENÝ"),"Čidlo vysvětluje odmítnutí")
	world.player.position = Vector3(7.4,0.02,1.65)
	check(world.toggle_door(),"Zavření je dostupné vedle průchodu")
	world.player.position = Vector3(9,0.02,3.5)
	for i in 3: await physics_frame
	check(world.door_open,"Vstup během zavírání automaticky vrátí křídlo")
	await wait_motion()
	check(world.devices["ACADEMY-DOOR"].position.z>6,"Čidlo dveře skutečně znovu otevřelo")
	shell.queue_free()
	await process_frame
	print("DOOR3D: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
