extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var shell
var checks=0
var failures=0

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://programming_location_"+tag+".json"
	Settings.path_override="user://programming_location_"+tag+".cfg"
	Saves.save_game({},true)
	call_deferred("run")

func check(ok: bool, message: String):
	checks+=1
	if not ok: failures+=1; push_error(message)

func walk_to(target: Vector3) -> bool:
	for frame in 400:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		shell.world.player.rotation=Vector3.ZERO
		var offset=target-shell.world.player.position
		for action in ["walk_left","walk_right","walk_forward","walk_back"]: Input.action_release(action)
		if Vector2(offset.x,offset.z).length()<0.13: return true
		if absf(offset.x)>0.06: Input.action_press("walk_right" if offset.x>0 else "walk_left")
		if absf(offset.z)>0.06: Input.action_press("walk_back" if offset.z>0 else "walk_forward")
		await physics_frame
	for action in ["walk_left","walk_right","walk_forward","walk_back"]: Input.action_release(action)
	print("Blocked at ",shell.world.player.position," toward ",target)
	return false

func use(object):
	var player=shell.world.player
	player.camera.look_at(object.global_position)
	for frame in 3: await physics_frame
	player.poll_target()
	check(player.target==object,"Ray reaches "+object.device_id)
	if player.target!=object: return
	for down in [true,false]:
		var key=InputEventKey.new(); key.physical_keycode=KEY_E; key.pressed=down
		root.push_input(key,true); await process_frame

func click(control):
	var at=control.get_global_rect().get_center()
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down
		root.push_input(event,true); await process_frame

func capture(title: String):
	if DisplayServer.get_name()=="headless" or "--screenshots" not in OS.get_cmdline_user_args(): return
	for frame in 3: await process_frame
	if "--manual-capture" in OS.get_cmdline_user_args(): RenderingServer.force_draw()
	else: await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/location-"+title+".png")

func run():
	shell=preload("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell)
	await process_frame
	shell.enter_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var room=shell.world.programming_room
	var game=shell.ui.game
	var separated=true
	for node in shell.world.get_children():
		if not node is MultiMeshInstance3D: continue
		var west=false; var main=false
		for index in node.multimesh.instance_count:
			var point=node.to_global(node.multimesh.get_instance_transform(index).origin)
			west=west or point.x < -9.1
			main=main or point.x > -8.9
		if west and main: separated=false
	check(separated,"Static batches keep the relocated classroom separate from server-room culling")
	check(room.door.global_position.is_equal_approx(Vector3(-9,1.4,0)),"Classroom is west of server racks")
	check(shell.safe_saved_position(Vector3(-6.5,0.02,-14))==Vector3(-7,0.02,0),"Legacy north-room pose safely moves to main aisle")
	check(shell.safe_saved_position(Vector3(2,0.02,1))==Vector3(2,0.02,1),"Unchanged safe pose stays intact")
	check(await walk_to(Vector3(0,0.02,4.4)),"Exit desks")
	check(await walk_to(Vector3(-6.5,0.02,4.4)),"Reach left aisle")
	check(await walk_to(Vector3(-6.5,0.02,0)),"Reach west entrance")
	await use(room.door)
	await create_timer(0.5).timeout
	var campaign=game.sim.state.duplicate(true)
	for visit in 2:
		check(await walk_to(room.entrance_position()),"Enter west classroom by walking")
		check(game.game_mode.is_programming(),"Entry activates classroom")
		for station in [["PYTHON-PC",-6.5,"PY01"],["WEB-PC",-1.4,"WEB28"]]:
			check(await walk_to(room.to_global(Vector3(-6.5,0.02,-14))),"Walk along classroom aisle")
			check(await walk_to(room.to_global(Vector3(station[1],0.02,-14))),"Cross aisle behind chairs")
			check(await walk_to(room.to_global(Vector3(station[1],0.02,-16.7))),"Reach station without crossing furniture")
			await use(shell.world.devices[station[0]])
			check(shell.mode=="coding","E opens actual station editor")
			if shell.mode=="coding":
				shell.code_editor.launch(station[2],false)
				for filename in game.programming.current.example: game.programming.edit(filename,game.programming.current.example[filename])
				shell.code_editor.load_current()
				for frame in 3: await process_frame
				await click(shell.code_editor.test_button)
				check(game.programming.last_result.get("ok",false),"Mouse click evaluates real "+station[0]+" source")
				shell.return_to_world()
			check(await walk_to(room.to_global(Vector3(station[1],0.02,-14))),"Leave workstation")
		check(await walk_to(room.to_global(Vector3(-6.5,0.02,-14))),"Return to entrance aisle")
		check(await walk_to(room.entrance_position()),"Return to doorway")
		check(await walk_to(Vector3(-6.5,0.02,0)),"Walk back to server room")
		check(not game.game_mode.is_education() and game.programming.current.is_empty(),"Exit cancels temporary lesson")
		for key in campaign:
			if key=="world": continue
			check(game.sim.state[key]==campaign[key],"Campaign preserved: "+key)
	var progress=game.progress.duplicate(true)
	var results=game.programming.progress.duplicate(true)
	game.sim.state.world.player={"x":-6.5,"z":-7.0,"yaw":0.0,"pitch":0.0}
	check(game.save()==OK,"Supported legacy doorway pose saves successfully")
	check(not Saves.load_game().is_empty(),"Legacy doorway save remains valid")
	shell.pose_revision=-1; shell.enter_world()
	check(shell.world.player.position==Vector3(-7,0.02,0),"Restoring a pose at the sealed old door moves only the player")
	check(game.progress==progress and game.programming.progress==results,"Pose repair preserves XP and completed programming results")
	await create_timer(6.2).timeout # Let the real departure notice fade before documenting the view.
	# Same view as visual_capture.gd baseline, then a frontal server view.
	shell.world.player.position=Vector3(6.6,0.02,4.2)
	shell.world.player.camera.look_at(Vector3(-0.7,1.45,-3))
	await capture("server-room-after")
	shell.world.player.position=Vector3(0,0.02,0.8)
	shell.world.player.camera.look_at(Vector3(-3,1.5,-2.5))
	await capture("west-classroom")
	print("PROGRAMMING LOCATION: %d checks, %d failures" % [checks,failures])
	shell.queue_free(); await process_frame
	quit(1 if failures else 0)
