extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
var shell
var folder=""
var materials={}
var failures=0
var walls=[]

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_material_"+tag+".json"
	Settings.path_override="user://academy_test_material_"+tag+".cfg"
	Comfort.path_override="user://academy_test_material_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	call_deferred("run")

func inspect(node):
	if node is CollisionShape3D and node.shape is BoxShape3D and node.get_parent() is StaticBody3D:
		var size_value=node.global_basis.x.abs()*node.shape.size.x+node.global_basis.y.abs()*node.shape.size.y+node.global_basis.z.abs()*node.shape.size.z
		if size_value.y>=3 and minf(size_value.x,size_value.z)<0.4 and maxf(size_value.x,size_value.z)>1:
			walls.append({"path":str(node.get_path()),"box":AABB(node.global_position-size_value*0.5,size_value)})
	if node is MeshInstance3D or node is MultiMeshInstance3D:
		var mat=node.material_override
		if mat==null:
			failures+=1; push_error("Chybějící materiál: "+str(node.get_path()))
		else:
			var key=str(mat.get_instance_id())
			if not materials.has(key): materials[key]={"type":mat.get_class(),"resource":mat.resource_path,"uses":0,"example":str(node.get_path())}
			materials[key].uses+=1
			if mat is ShaderMaterial: materials[key].shader=mat.shader.resource_path
			if mat is StandardMaterial3D: materials[key].color=str(mat.albedo_color)
	for child in node.get_children(): inspect(child)

func check_walls():
	var overlaps=[]
	for i in walls.size():
		for j in range(i+1,walls.size()):
			var a=walls[i].box; var b=walls[j].box
			var axis=0 if a.size.x<a.size.z else 2
			if axis!=(0 if b.size.x<b.size.z else 2): continue
			for side in [0,1]:
				if absf((a.position[axis]+side*a.size[axis])-(b.position[axis]+side*b.size[axis]))>0.0001: continue
				var horizontal=2-axis
				var width=minf(a.end[horizontal],b.end[horizontal])-maxf(a.position[horizontal],b.position[horizontal])
				var height=minf(a.end.y,b.end.y)-maxf(a.position.y,b.position.y)
				if width>0.02 and height>0.02: overlaps.append([walls[i].path,walls[j].path,width*height])
	var file=FileAccess.open(folder+"/wall-faces.json",FileAccess.WRITE); file.store_string(JSON.stringify(overlaps,"\t")); file.close()
	print("WALL FACES: ",walls.size()," structural walls, ",overlaps.size()," coplanar overlaps")
	if not overlaps.is_empty(): failures+=1; push_error("Překryté strukturální stěny: "+str(overlaps))

func capture(label: String, at: Vector3, target: Vector3):
	var p=shell.world.player
	p.position=at; p.rotation=Vector3.ZERO; p.camera.rotation=Vector3.ZERO
	shell.ui.game.reconcile_room(); shell.set_mode("world"); p.enabled=false
	p.camera.look_at(target)
	for i in 18: await process_frame
	# A native window may lose focus while the audit positions its camera.
	# Resume only this isolated capture; the application's pause stays intact.
	if shell.mode=="pause":
		shell.return_to_world(); p.enabled=false
		for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder+"/"+label+".png")

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell)
	shell.ui.display_settings.quality="Vysoká"
	shell.ui.display_settings.apply_world(shell.world)
	shell.ui.apply_display_settings(Vector2i(1600,900),false)
	shell.ui.game.english.progress.intro_seen=true
	folder="res://test-output/material-"+("before" if "--before" in OS.get_cmdline_user_args() else "after")+"-"+RenderingServer.get_current_rendering_method()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	await capture("01-server",Vector3(6.6,0.02,4.2),Vector3(0,1.5,-3))
	await capture("02-rack",Vector3(1.2,0.02,-0.6),Vector3(0,1.35,-3))
	await capture("03-cabinet",Vector3(-5.5,0.02,-0.2),Vector3(-7.6,1,-2))
	await capture("04-it-door-closed",Vector3(6.1,0.02,3.8),Vector3(9,1.7,2.7))
	shell.world.move_door(true); await create_timer(0.5).timeout
	await capture("05-it-door-open",Vector3(11,0.02,4),Vector3(9,1.5,3.5))
	await capture("06-training",Vector3(15.5,0.02,5.5),Vector3(14.8,1.5,-3.5))
	await capture("07-program-door-closed",Vector3(-6,0.02,0),Vector3(-9,1.5,0))
	shell.world.programming_room.toggle_door(); await create_timer(0.5).timeout
	await capture("08-program-door-open",Vector3(-11,0.02,0),Vector3(-9,1.5,0))
	await capture("09-programming",Vector3(-11,0.02,-6),Vector3(-19,1.5,-6))
	await capture("10-london-entry-north",Vector3(5,0.02,4.5),Vector3(5,1.9,7))
	await capture("11-london-entry-south",Vector3(5,0.02,9.5),Vector3(5,1.9,7))
	await capture("12-london",Vector3(8,0.02,8.5),Vector3(15,4,15))
	await capture("13-counter",Vector3(12,0.02,8.5),Vector3(12,1.8,10.2))
	await capture("14-bridge",Vector3(8,0.02,18),Vector3(5,4,26))
	await capture("15-tower",Vector3(8,0.02,24),Vector3(4,5.5,27))
	if shell.world.get("hub")!=null:
		await capture("16-hub",Vector3(2,0.02,-10),Vector3(4,2,-15.7))
		await capture("17-hub-south",Vector3(5,0.02,-14),Vector3(6,2,-7))
		await capture("18-london-corridor",Vector3(23,0.02,-5),Vector3(23,1.7,10))
		await capture("19-hub-overview",Vector3(17,0.02,-14),Vector3(-6,1.8,-10))
	if "--matrix" in OS.get_cmdline_user_args():
		for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
			for scale_value in [1.0,1.3]:
				shell.ui.apply_display_settings(resolution,false); shell.ui.save_preference("text_scale",scale_value)
				var prefix="%d-%d-" % [resolution.x,roundi(scale_value*100)]
				for view in [["hub",Vector3(4,0.02,-11),Vector3(4,2,-15.7)],["server",Vector3(6.6,0.02,4.2),Vector3(0,1.5,-3)],["training",Vector3(15.5,0.02,5.5),Vector3(14.8,1.5,-3.5)],["programming",Vector3(-11,0.02,-6),Vector3(-19,1.5,-6)],["london",Vector3(8,0.02,8.5),Vector3(15,4,15)]]:
					await capture(prefix+view[0],view[1],view[2])
	inspect(shell.world)
	check_walls()
	var file=FileAccess.open(folder+"/materials.json",FileAccess.WRITE); file.store_string(JSON.stringify(materials.values(),"\t")); file.close()
	print("MATERIAL AUDIT: ",materials.size()," materials, ",failures," missing; ",folder)
	shell.queue_free(); await process_frame; quit(1 if failures else 0)
