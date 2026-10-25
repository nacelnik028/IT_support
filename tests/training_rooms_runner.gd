extends Node

signal finished(code: int)
const Saves = preload("res://scripts/progression/SaveManager.gd")
const Game = preload("res://scripts/core/GameManager.gd")
var shell
var checks = 0
var failures = 0
var transitions = 0

func check(ok, description: String):
	checks += 1
	if not ok:
		failures += 1
		push_error(description)

func persisted_equal(a, b) -> bool:
	# JSON restores numbers as floats; compare the same serialized types.
	return JSON.parse_string(JSON.stringify(a)) == JSON.parse_string(JSON.stringify(b))

func _ready():
	Saves.path_override = "user://academy_test_training_rooms.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_training_rooms.cfg"
	Saves.save_game({},true)
	call_deferred("run")

func frames(count: int = 3):
	for i in count: await get_tree().physics_frame

func move_to(at: Vector3):
	shell.world.player.position = at
	shell.world.player.velocity = Vector3.ZERO
	await frames()

func capture(label: String):
	if DisplayServer.get_name() == "headless": return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://test-output/training-room-"+label+".png")

func all_guides_hidden() -> bool:
	for object in shell.world.devices.values():
		if object.guide.visible: return false
	return shell.instruction.text.is_empty() and shell.direction.text.is_empty() and not shell.instruction_plate.visible and not is_instance_valid(shell.ui.tutorial_overlay)

func run():
	shell = preload("res://scenes/world/Game.tscn").instantiate()
	add_child(shell)
	await frames()
	var game = shell.ui.game
	game.room_changed.connect(func(_training): transitions += 1)
	# Earn real career XP, then pause a different, partially configured ticket.
	game.start_mission(0)
	var solutions = JSON.parse_string(FileAccess.get_file_as_string("res://tests/solutions.json"))
	for operation in solutions[0]: game.apply(operation[0],operation[1])
	check(game.complete().ok and game.progress.xp>0,"D: career XP fixture earned through a real mission")
	game.start_mission(3)
	game.sim.state.vms["100"].vlan = 39
	game.save()
	var career = game.progress.duplicate(true)
	var main = game.main_sim.state.duplicate(true)
	shell.enter_world()
	var player = shell.world.player
	check(not game.start_lesson(1002,"learn",false),"F: lesson rejected in MAIN")
	check(not game.start_random("Sítě","Začátečník",1,true,91),"F: random training rejected in MAIN")
	check(game.main_sim.state==main,"F: rejected starts do not change main infrastructure")
	check(shell.world.training_zone is Area3D and shell.world.training_zone.get_child(0) is CollisionShape3D,"A: real training Area3D with collision shape")
	# Walk through the existing sliding door using the real FPS controller.
	shell.world.move_door(true)
	await frames(48)
	await move_to(Vector3(8,0.02,3.5))
	player.rotation.y = -PI/2
	Input.action_press("walk_forward")
	await frames(35)
	Input.action_release("walk_forward")
	check(game.game_mode.is_training(),"A: walking through door enters TRAINING")
	check(not game.active and game.suspended_campaign.id==4,"A: working mission paused before selecting lesson")
	check(shell.room_notice.text.contains("Vstoupil jsi do tréninkového centra."),"A: entry notification")
	check(not game.start_mission(0) and not game.complete().ok,"A: campaign cannot start or complete in training room")
	await capture("entry")
	for lesson_mode in ["learn","practice","exam"]:
		shell.ui.begin_lesson(1002,lesson_mode,false)
		check(game.active and game.tutorial.session.mode==lesson_mode and game.sim==game.training_sim,"A: isolated lesson mode "+lesson_mode)
		check(game.notify_event({"type":"server_selected","host":"PVE-01"})==(lesson_mode=="learn"),"A: lesson event validation "+lesson_mode)
	# Damage an actual sandbox disk; verify both main model and rendered LEDs.
	var disk = game.sim.state.disks["0"]
	check(game.apply("physical_remove",{"pool":"RAID","slot":"0","serial":disk.serial,"backup_checked":true,"confirmed":true}).ok,"E: remove training disk through real physical operation")
	shell.world.sync_state()
	check(game.sim.state.disks["0"].health=="Missing" and game.main_sim.state==main,"E: sandbox damage leaves main infrastructure untouched")
	check(shell.world.devices["TRAIN-RAID:0"].status=="Missing" and shell.world.devices["RAID:0"].status==main.disks["0"].health,"E: separate training and production LEDs")
	var unfinished = game.snapshot()
	shell.ui.begin_lesson(1002,"learn",false)
	shell.update_guidance()
	check(not shell.direction.text.is_empty(),"B: guided lesson visibly active before exit")
	await capture("lesson")
	player.rotation.y = PI/2
	Input.action_press("walk_forward")
	await frames(40)
	Input.action_release("walk_forward")
	check(not game.game_mode.is_training() and not game.tutorial.active(),"B: walking back through the door cancels guided lesson")
	await move_to(Vector3(10,0.02,3.5))
	check(not game.active,"C: physical return presents fresh lesson selection")
	shell.ui.begin_lesson(1002,"learn",false)
	shell.open_app("Proxmox")
	await frames()
	# Teleport while a form/dialog could still be open. The next action must
	# reject it even before the next physics notification.
	player.position = Vector3(7,0.02,3.5)
	check(not game.apply("vm_identity",{"id":"101","name":"STALE"}).ok,"G: teleport rejects stale training action immediately")
	check(not game.game_mode.is_training() and game.session_kind=="campaign" and game.current.id==4,"B: exit restores MAIN and previous working ticket")
	check(not game.tutorial.active() and game.education.sessions.is_empty() and all_guides_hidden(),"B: tutorial state, UI and arrows removed")
	check(shell.mode=="world" and shell.pending_cable.is_empty(),"B: open app and temporary interactions closed")
	check(game.training_sim.state.disks["0"].health!="Missing" and game.undo_states.is_empty(),"B: training infrastructure, faults and undo reset")
	check(game.progress==career and not game.education.lessons.has("1002"),"B: unfinished lesson creates no result and preserves career")
	check(not game.restore_session(unfinished),"F: restoring training snapshot in MAIN rejected")
	check(shell.room_notice.text.contains("Trénink ukončen."),"B: exit notification")
	await capture("exit")
	await move_to(Vector3(10,0.02,3.5))
	check(game.game_mode.is_training() and not game.active and not game.tutorial.active(),"C: returning to room does not restart unfinished lesson")
	check(game.start_lesson(1002,"exam"),"D: fresh examination can start")
	var lesson_solutions = JSON.parse_string(FileAccess.get_file_as_string("res://tests/lesson_solutions.json"))
	for operation in lesson_solutions["1002"]:
		if operation is Dictionary: game.notify_event(operation.event)
		else: check(game.apply(operation[0],operation[1]).ok,"D: real lesson operation "+operation[0])
	check(game.complete().ok,"D: examination completed against real objectives")
	var result = game.education.lessons["1002"].duplicate(true)
	var attempts = game.education.attempts.duplicate(true)
	await move_to(Vector3(7,0.02,3.5))
	var loaded = Game.new()
	check(persisted_equal(loaded.education.lessons["1002"],result) and persisted_equal(loaded.education.attempts,attempts) and persisted_equal(loaded.progress,career),"D: completed result, exams, statistics and earned XP survive disk reload")
	check(loaded.sim.state.vms["100"].vlan==39,"D: main mission configuration persisted")
	# Stable door seam: no time-based debounce that could miss a quick exit.
	var before = transitions
	for cycle in 4:
		await move_to(Vector3(9.3,0.02,3.5))
		check(game.game_mode.is_training(),"H: repeated entry "+str(cycle))
		game.start_lesson(1002,"learn",false)
		for x in [9.03,8.99,9.04,9.0]: await move_to(Vector3(x,0.02,3.5))
		check(game.game_mode.is_training() and game.active and game.tutorial.session.step==0,"H: seam jitter preserves training mode and active lesson")
		await move_to(Vector3(8.65,0.02,3.5))
		check(not game.game_mode.is_training(),"H: repeated exit "+str(cycle))
	check(transitions-before==8,"H: exactly one transition per actual crossing")
	await move_to(Vector3(15,0.02,5.5))
	game.start_lesson(1002,"learn",false)
	var outside_save = game.snapshot()
	outside_save.state.world.player = {"x":0.0,"z":3.0,"yaw":0.0,"pitch":0.0}
	shell.open_app("Proxmox")
	check(game.restore_session(outside_save),"G: valid saved training snapshot loaded")
	shell.return_to_world()
	check(not game.game_mode.is_training() and not game.tutorial.active() and player.position.x<9,"G: applying saved outside position cancels training")
	await move_to(Vector3(15,0.02,5.5))
	game.start_lesson(1002,"learn",false)
	var training_save = game.snapshot()
	player.position = Vector3(7,0.02,3.5)
	check(not game.restore_session(training_save) and not game.game_mode.is_training(),"G: restoring a lesson after teleport is rejected before next physics frame")
	# Restoring an outside saved pose and leaving by another wall/height.
	for outside in [Vector3(0,0.02,3),Vector3(16,0.02,9),Vector3(16,8,0)]:
		await move_to(Vector3(15,0.02,5.5))
		game.start_lesson(1002,"practice",false)
		game.sim.state.world.player = {"x":outside.x,"z":outside.z,"yaw":0.0,"pitch":0.0}
		await move_to(outside)
		check(not game.game_mode.is_training() and not game.tutorial.active(),"G: outside/loaded pose cancels training "+str(outside))
	shell.enter_world("Trénink")
	game.start_lesson(1002,"learn",false)
	shell.set_mode("menu")
	check(shell.mode=="menu" and shell.ui.page=="menu" and not game.game_mode.is_training() and not game.tutorial.active(),"G: returning to main menu cancels training and displays menu")
	shell.enter_world()
	await move_to(Vector3(15,0.02,5.5))
	game.start_lesson(1002,"learn",false)
	# Freeing the real world exercises scene teardown, not just a mocked flag.
	shell.queue_free()
	await get_tree().process_frame
	check(not game.game_mode.is_training() and not game.tutorial.active(),"G: unloading scene cancels lesson")
	loaded = Game.new()
	check(loaded.session_kind=="campaign" and persisted_equal(loaded.progress,career) and persisted_equal(loaded.education.lessons["1002"],result),"G: scene exit saves main campaign and permanent results")
	for operation in solutions[3]: check(loaded.apply(operation[0],operation[1]).ok,"MAIN: resumed mission accepts production operation "+operation[0])
	check(loaded.complete().ok and loaded.progress.xp>career.xp,"MAIN: resumed working mission completes and awards career XP")
	print("TRAINING ROOMS A-H: %d checks, %d failures" % [checks,failures])
	finished.emit(0 if failures==0 else 1)
	# The MCP scene is a finite graphical verification run.
	if get_tree().current_scene == self:
		await get_tree().create_timer(20.0).timeout
		get_tree().quit(0 if failures==0 else 1)
