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
			if mesh.is_visible_in_tree() and leaf.visual.is_ancestor_of(mesh):
				var bounds=mesh.global_transform*mesh.get_aabb()
				check(bounds.end.z<7,"Ani dekorace dveří nepřesahuje do Londýna")
				var box=BoxShape3D.new(); var local=mesh.get_aabb(); box.size=local.size-Vector3.ONE*0.002
				var detail_query=PhysicsShapeQueryParameters3D.new(); detail_query.shape=box; detail_query.transform=mesh.global_transform*Transform3D(Basis(),local.get_center()); detail_query.exclude=[leaf.get_rid()]; detail_query.margin=0; detail_query.collision_mask=1
				var detail_contacts=leaf.get_world_3d().direct_space_state.intersect_shape(detail_query,8)
				check(detail_contacts.is_empty(),"Také obložení křídla projde kapsou v každém snímku: "+str(mesh.get_path())+" "+str(local)+" "+str(detail_contacts.map(func(c): return c.collider.get_path())))

func programming_controls(room):
	var p=shell.world.player
	for panel in room.door_panels:
		for opened in [true,false]:
			var at=panel.object.position; at.y=0.02
			if at.z> -7: at.x-=0.85 # Stand clear of the service cabinet in the server room.
			at.z+=1.2 if at.z> -7 else -1.2
			p.position=room.to_global(at); shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
			p.camera.look_at(panel.object.global_position)
			for tick in 3: await physics_frame
			p.camera.look_at(panel.object.global_position)
			p.poll_target(); check(p.target==panel.object,"Programovací ovladač je dosažitelný z obou stran i při otevřeném křídle: "+str(p.position)+" target="+str(p.target)+" panel="+str(panel.object.global_position))
			for down in [true,false]:
				var event=InputEventKey.new(); event.keycode=KEY_E; event.physical_keycode=KEY_E; event.pressed=down; root.push_input(event,true)
			await sample_motion(room.door,28)
			check(room.door_open==opened,"Skutečné E ovládá programovací dveře z obou stran")

func capture(label: String, at: Vector3, target: Vector3):
	if DisplayServer.get_name()=="headless" or "--screenshots" not in OS.get_cmdline_user_args(): return
	var p=shell.world.player; p.position=at; p.rotation=Vector3.ZERO; p.camera.rotation=Vector3.ZERO
	shell.ui.game.reconcile_room(); shell.return_to_world(); p.enabled=false; p.camera.look_at(target); await frames(12)
	if shell.mode=="pause": shell.return_to_world(); p.enabled=false; await frames()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/ui-review/2026-11-05-alex-portals-editor/"+label+"-"+RenderingServer.get_current_rendering_method()+".png")

func run():
	DirAccess.make_dir_recursive_absolute("res://docs/ui-review/2026-11-05-alex-portals-editor")
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	shell.ui.game.english.progress.intro_seen=true
	shell.ui.apply_display_settings(Vector2i(1920,1080),false)
	shell.enter_world("Hlavní serverovna")
	var world=shell.world; var room=world.programming_room; var p=world.player
	var portals=[]
	for node in world.find_children("*","Node3D",true,false):
		if node.get_meta("academy_portal",false): portals.append(node)
	check(portals.size()==8,"Společná konstrukce je u pěti vstupů hubu, obou dveří a vstupu Londýna")
	await programming_controls(room)
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
	for entry in [["01",Vector3(-6,0,-7),Vector3(0,0,1)],["02",Vector3(16,0,-7),Vector3(0,0,1)],["03",Vector3(-9,0,-12),Vector3(-1,0,0)],["04",Vector3(21,0,-11.5),Vector3(1,0,0)],["london",Vector3(21,0,9.5),Vector3(-1,0,0)]]:
		for side in [-1,1]:
			await capture("portal-"+entry[0]+("-entry" if side<0 else "-return"),entry[1]+entry[2]*side*2.7+Vector3(0.45,0.02,0.25),entry[1]+Vector3(0,2.3,0))
	await capture("alex-sign",Vector3(6,0.02,10),Vector3(6.65,1.55,12.8))
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
