extends SceneTree

var shell
var checks=0
var failures=0
const Saves=preload("res://scripts/progression/SaveManager.gd")
const Display=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")

func _init():
	var tag="user://academy_test_architecture_"+str(OS.get_process_id())
	Saves.path_override=tag+".json"; Display.path_override=tag+".cfg"; Comfort.path_override=tag+"_vr.cfg"
	Saves.save_game({},true); call_deferred("run")

func check(ok: bool, title: String):
	checks+=1
	if not ok: failures+=1; push_error(title)

func frames(n: int = 5):
	for i in n: await process_frame

func sample_motion(leaf, duration: int):
	var shape=leaf.get_children().filter(func(n): return n is CollisionShape3D)[0].shape.duplicate()
	shape.size-=Vector3.ONE*0.004
	for i in duration:
		await physics_frame
		var query=PhysicsShapeQueryParameters3D.new(); query.shape=shape; query.transform=leaf.global_transform; query.collision_mask=1; query.exclude=[leaf.get_rid()]; query.margin=0
		var contacts=leaf.get_world_3d().direct_space_state.intersect_shape(query,32)
		check(contacts.is_empty(),"Celý pohyb křídla je uvnitř skutečné prázdné kapsy: "+str(leaf.name)+" "+str(contacts.map(func(c): return str(c.collider.get_path()))))
		for mesh in leaf.find_children("*","MeshInstance3D",true,false):
			if mesh.is_visible_in_tree():
				var bounds=mesh.global_transform*mesh.get_aabb()
				check(bounds.end.z<7,"Ani dekorace dveří nepřesahuje do Londýna")

func capture(label: String, at: Vector3, target: Vector3):
	if DisplayServer.get_name()=="headless" or "--screenshots" not in OS.get_cmdline_user_args(): return
	var p=shell.world.player; p.position=at; p.rotation=Vector3.ZERO; p.camera.rotation=Vector3.ZERO
	shell.ui.game.reconcile_room(); shell.return_to_world(); p.enabled=false; p.camera.look_at(target); await frames(12)
	if shell.mode=="pause": shell.return_to_world(); p.enabled=false; await frames()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/ui-review/2026-11-04-interface/"+label+"-"+RenderingServer.get_current_rendering_method()+".png")

func run():
	DirAccess.make_dir_recursive_absolute("res://docs/ui-review/2026-11-04-interface")
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	shell.ui.game.english.progress.intro_seen=true
	shell.ui.apply_display_settings(Vector2i(1920,1080),false)
	shell.enter_world("Hlavní serverovna")
	var world=shell.world; var room=world.programming_room; var p=world.player
	p.position=Vector3(7,0.02,1)
	for cycle in 3:
		world.move_door(true); await sample_motion(world.devices["ACADEMY-DOOR"],50)
		check(is_equal_approx(world.devices["ACADEMY-DOOR"].position.z,0.5),"IT křídlo končí v severní kapse")
		world.move_door(false); await sample_motion(world.devices["ACADEMY-DOOR"],50)
		room.move_door(true); await sample_motion(room.door,28)
		room.move_door(false); await sample_motion(room.door,28)
	world.move_door(true); room.move_door(true); await create_timer(0.8).timeout
	# Reversal when someone enters an already closing opening, on both doors.
	world.move_door(false); p.position=Vector3(9,0.02,3.5)
	for i in 3: await physics_frame
	check(world.door_open,"IT čidlo znovu otevře při vstupu během zavírání")
	p.position=room.to_global(Vector3(-6.5,0.02,-6))
	room.move_door(false); p.position=room.to_global(Vector3(-6.5,0.02,-7))
	for i in 3: await physics_frame
	check(room.door_open,"Programovací čidlo znovu otevře při vstupu během zavírání")
	p.position=Vector3(7,0.02,1); await create_timer(0.8).timeout
	for id in ["LONDON-QUIZ","LONDON-LISTENING"]:
		var board=world.devices[id]
		check(board.get_meta("supported_board",false),"Tabule má skutečný stojan: "+id)
		check(board.get_children().filter(func(n): return n is CollisionShape3D).size()==5,"Kolize tabule, nohou a podstavců odpovídají vzhledu")
		for mesh in board.visual.get_children():
			if mesh is MeshInstance3D and mesh.mesh is BoxMesh:
				var bounds=mesh.global_transform*mesh.get_aabb()
				check(bounds.position.y>=-0.001,"Stojan nezačíná pod podlahou")
	for opened in [false,true]:
		world.move_door(opened); room.move_door(opened); await create_timer(0.8).timeout
		var state="open" if opened else "closed"
		await capture("it-door-ops-"+state,Vector3(6.5,0.02,4),Vector3(9,1.6,2.7))
		await capture("it-door-academy-"+state,Vector3(11.8,0.02,4),Vector3(9,1.6,2.7))
		await capture("london-north-"+state,Vector3(13,0.02,8.8),Vector3(9,1.5,7))
		await capture("program-door-ops-"+state,Vector3(-6,0.02,0),Vector3(-9,1.6,1))
		await capture("program-door-room-"+state,Vector3(-12,0.02,0),Vector3(-9,1.6,1))
	await capture("london-boards",Vector3(4,0.02,8.3),Vector3(2,1.3,11))
	await capture("server-finished-wall",Vector3(5,0.02,3.5),Vector3(4,1.8,7))
	await capture("hub-portals",Vector3(5,0.02,-13),Vector3(6,2,-7))
	await capture("it-instructor",Vector3(18,0.02,1),Vector3(19.7,1.4,-0.3))
	await capture("program-instructor",room.to_global(Vector3(-5,0.02,-18)),room.to_global(Vector3(-5,1.4,-20)))
	await capture("program-dashboard",room.to_global(Vector3(3,0.02,-18)),room.to_global(Vector3(4,1.9,-20.6)))
	await capture("server-monitor",Vector3(4.5,0.02,-4),Vector3(4.5,2.5,-6.65))
	if "--matrix" in OS.get_cmdline_user_args():
		for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
			for scale_value in [1.0,1.3]:
				shell.ui.apply_display_settings(resolution,false); shell.ui.save_preference("text_scale",scale_value)
				var prefix="physical-%d-%d-" % [resolution.x,roundi(scale_value*100)]
				await capture(prefix+"quiz",Vector3(3,0.02,10.5),Vector3(3,1.5,12.5))
				await capture(prefix+"listening",Vector3(1,0.02,7.2),Vector3(1,1.5,9.3))
				await capture(prefix+"door",Vector3(6.5,0.02,4),Vector3(9,1.6,2.7))
				await capture(prefix+"wall",Vector3(5,0.02,3.5),Vector3(4,1.8,7))
	shell.queue_free(); await frames()
	print("ARCHITECTURE REPAIR: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
