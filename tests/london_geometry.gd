extends SceneTree

# Isolated saves/settings, real production geometry and CharacterBody movement.
const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
const Visuals=preload("res://scripts/world/WorldVisuals.gd")
var shell
var checks=0
var failures=0
var folder="res://docs/ui-review/2026-11-04-london-geometry"

func _init():
	var tag="user://academy_test_london_geometry_"+str(OS.get_process_id())
	Saves.path_override=tag+".json"
	Settings.path_override=tag+".cfg"
	Comfort.path_override=tag+"_vr.cfg"
	Saves.save_game({},true)
	call_deferred("run")

func check(ok: bool, title: String):
	checks+=1
	if not ok: failures+=1; push_error(title)

func frames(n: int = 5):
	for i in n: await process_frame

func audit_corridor():
	# Inspect the creator before batching removes mesh identities. The two side
	# walls have inner faces x=-7.73/-1.27, not the integer loop's -8/0 limits.
	var fixture=Node3D.new(); root.add_child(fixture)
	var visuals=Visuals.new(); visuals.world=fixture; visuals.corridor()
	var slats=0
	for mesh in fixture.find_children("*","MeshInstance3D",true,false):
		if not mesh.material_override is StandardMaterial3D: continue
		if not mesh.material_override.albedo_color.is_equal_approx(Color("947c65")): continue
		slats+=1
		var bounds=mesh.global_transform*mesh.get_aabb()
		check(bounds.position.x>=-7.73 and bounds.end.x<=-1.27,"Lamela patří dovnitř chodby: "+str(bounds))
		check(bounds.position.z>=10.375-0.08 and bounds.end.z<=10.375,"Lamela navazuje na zadní stěnu chodby")
	check(slats>0,"Dekor chodby zůstává skutečně vytvořený")
	fixture.queue_free(); await frames()

func ray(a: Vector3, b: Vector3) -> Dictionary:
	return shell.world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a,b,1))

func walk(point: Vector3):
	var p=shell.world.player
	shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	p.enabled=true
	for i in 1100:
		if shell.mode=="pause": shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		var offset=point-p.position; offset.y=0
		if offset.length()<0.12: break
		p.rotation.y=atan2(-offset.x,-offset.z)
		Input.action_press("walk_forward",minf(1,offset.length()*3)); Input.action_press("walk_fast")
		await physics_frame
	Input.action_release("walk_forward"); Input.action_release("walk_fast")
	await frames()
	check(Vector2(p.position.x-point.x,p.position.z-point.z).length()<0.35,"Skutečná chůze k "+str(point)+", dosaženo "+str(p.position))
	print("WALK: ",point," -> ",p.position)

func capture(label: String, at: Vector3, target: Vector3):
	if DisplayServer.get_name()=="headless" or "--screenshots" not in OS.get_cmdline_user_args(): return
	var p=shell.world.player
	p.position=at; p.rotation=Vector3.ZERO; p.camera.rotation=Vector3.ZERO
	shell.ui.game.reconcile_room(); shell.return_to_world(); p.enabled=false
	p.camera.look_at(target)
	await frames(12)
	if shell.mode=="pause": shell.return_to_world(); p.enabled=false; await frames()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder+"/"+label+"-"+RenderingServer.get_current_rendering_method()+".png")

func check_seams():
	# Empty former slat footprint: neither a solid nor an interactable remains.
	for x in [-0.83,-0.71,-0.4]:
		for y in [0.3,1.4,2.8]:
			check(ray(Vector3(x,y,9.9),Vector3(x,y,10.8)).is_empty(),"Žádná skrytá kolize/interakce u lamel "+str(Vector2(x,y)))
	# Continuous north wall, including the removed direct doorway and IT side.
	for x in [0,2,5,7,10,15,20]:
		for y in [0.4,1.7,3.7,6,10]:
			for direction in [-1,1]:
				var hit=ray(Vector3(x,y,7+direction*0.7),Vector3(x,y,7-direction*0.7))
				check(not hit.is_empty(),"Souvislá severní stěna z obou stran "+str(Vector3(x,y,direction)))

func run():
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	await audit_corridor()
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	shell.ui.game.english.progress.intro_seen=true
	shell.ui.apply_display_settings(Vector2i(1920,1080),false)
	shell.enter_world("English in London")
	var p=shell.world.player
	var stage="before" if "--before" in OS.get_cmdline_user_args() else "after"
	for opened in [false,true]:
		p.position=Vector3(3,0.02,8)
		shell.world.move_door(opened)
		if shell.world.programming_room.door_open!=opened: shell.world.programming_room.toggle_door()
		await create_timer(0.5).timeout
		check_seams()
		var state="open" if opened else "closed"
		await capture(stage+"-west-"+state,Vector3(1.4,0.02,12),Vector3(-0.8,1.5,10.34))
		await capture(stage+"-server-corridor-"+state,Vector3(-4.5,0.02,5.2),Vector3(-2,1.7,10.34))
		# This independent strip is away from ACADEMY-DOOR (world x=9).
		p.position=Vector3(-0.4,0.02,8); await walk(Vector3(-0.4,0.02,18.8)); await walk(Vector3(-0.4,0.02,8))
	# Reach all accessible sides of the pavilion using actual input and collision.
	# Return around the tower and planter rather than walking through furniture.
	for point in [Vector3(8,0.02,8),Vector3(8,0.02,18.8),Vector3(8,0.02,24),Vector3(0,0.02,24),Vector3(0,0.02,28.3),Vector3(0,0.02,24),Vector3(20.45,0.02,24),Vector3(20.45,0.02,28.3),Vector3(20.45,0.02,24),Vector3(8,0.02,24),Vector3(8,0.02,18.8),Vector3(20.45,0.02,18.8),Vector3(20.45,0.02,9.5),Vector3(23,0.02,9.5),Vector3(23,0.02,-11.5),Vector3(19,0.02,-11.5),Vector3(16,0.02,-5),Vector3(16,0.02,6.3),Vector3(10,0.02,6.3)]:
		await walk(point)
	# Check the sealed direct doorway with actual movement from either face.
	for side in [-1,1]:
		p.position=Vector3(5,0.02,7+side*1.5); await frames()
		p.rotation.y=0 if side>0 else PI; p.enabled=true
		shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		for i in 60:
			if shell.mode=="pause": shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
			Input.action_press("walk_forward"); await physics_frame
		Input.action_release("walk_forward")
		check(p.position.z>7.3 if side>0 else p.position.z<6.7,"Zazděný průchod fyzicky blokuje stranu "+str(side))
	# Survey the full shell, including faces without an exterior walking floor.
	for view in [["north-london",Vector3(18,0.02,8),Vector3(3,2,7)],["north-training",Vector3(19,0.02,5.8),Vector3(11,2,7)],["west-inside",Vector3(0,0.02,18.5),Vector3(-1,3,13)],["west-outside",Vector3(-3,0.02,16),Vector3(-1,3,18)],["south-inside",Vector3(14,0.02,25),Vector3(14,4,29)],["south-outside",Vector3(14,0.02,32),Vector3(14,4,29)],["east-inside",Vector3(19,0.02,24),Vector3(21,4,25)],["east-outside",Vector3(24,0.02,24),Vector3(21,4,25)],["entry",Vector3(23,0.02,8.5),Vector3(20,1.7,9.5)]]:
		await capture(stage+"-"+view[0],view[1],view[2])
	if "--matrix" in OS.get_cmdline_user_args():
		for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
			for scale_value in [1.0,1.3]:
				shell.ui.apply_display_settings(resolution,false); shell.ui.save_preference("text_scale",scale_value)
				await capture(stage+"-west-%d-%d" % [resolution.x,roundi(scale_value*100)],Vector3(1.4,0.02,12),Vector3(-0.8,1.5,10.34))
	shell.queue_free(); await frames()
	print("LONDON GEOMETRY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
