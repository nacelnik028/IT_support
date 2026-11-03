extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
var checks=0
var failures=0
var inventory=[]

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_pack_content_"+tag+".json"
	Settings.path_override="user://academy_test_pack_content_"+tag+".cfg"
	Comfort.path_override="user://academy_test_pack_content_"+tag+"_vr.cfg"
	call_deferred("run")

func check(ok: bool, message: String):
	checks+=1
	if not ok: failures+=1; push_error(message)

func files(path: String):
	var directory=DirAccess.open(path)
	if directory==null: return
	directory.include_hidden=true
	for name in directory.get_files(): inventory.append(path.path_join(name))
	for name in directory.get_directories(): files(path.path_join(name))

func run():
	var reference=""
	var output=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--reference="): reference=arg.trim_prefix("--reference=")
		if arg.begins_with("--inventory-out="): output=arg.trim_prefix("--inventory-out=")
	check(reference!="","Explicitní referenční zdroje pro kontrolu obsahu")
	files("res://")
	for path in inventory:
		for banned in ["res://build/","res://builds/","res://tests/","res://tools/","res://test-output/","res://docs/"]:
			check(not path.begins_with(banned),"Export neobsahuje "+banned)
		if path.begins_with("res://data/") and path.ends_with(".json"):
			var actual=JSON.parse_string(FileAccess.get_file_as_string(path))
			var expected=JSON.parse_string(FileAccess.get_file_as_string(reference+"/"+path.trim_prefix("res://")))
			check(actual==expected,"Skutečný zabalený JSON zachoval každé ID a hodnotu: "+path)
	var game=preload("res://scripts/core/GameManager.gd").new()
	check(game.missions.size()==65 and game.tutorial.lessons.size()==21,"IT katalogy uvnitř balíčku")
	check(game.english.catalog.content_version==2 and game.english.quiz.catalog.questions.size()==20,"Nové B1–B2 a 20 otázek uvnitř balíčku")
	var world=load("res://scenes/world/Datacenter3D.tscn").instantiate(); root.add_child(world)
	# Let generated textures and SubViewports finish their first uploads before
	# destroying the audited world; quitting during a queued GL upload leaks RIDs.
	for frame in 10: await process_frame
	await create_timer(0.2).timeout
	check(world.hub.floor_point(Vector3(4,0,-11)),"Skutečný nový hub uvnitř balíčku")
	var labels=world.find_children("*","Label3D",true,false)
	check(labels.all(func(l): return not l.double_sided),"Opravené jednostranné cedule uvnitř balíčku")
	check(labels.any(func(l): return l.text.contains("LONDON QUIZ")),"Kvízová tabule v zabalené scéně")
	var materials={}
	for mesh in world.find_children("*","GeometryInstance3D",true,false):
		if not (mesh is MeshInstance3D or mesh is MultiMeshInstance3D): continue
		check(mesh.material_override!=null,"Zabalený mesh má materiál: "+str(mesh.get_path()))
		if mesh.material_override!=null: materials[str(mesh.material_override.get_instance_id())]=mesh.material_override
	var shaders=[]
	for material in materials.values():
		if material is ShaderMaterial:
			check(material.shader!=null,"Zabalený shaderový materiál má platný shader")
			if material.shader!=null:
				var path=material.shader.resource_path
				var expected=FileAccess.get_file_as_string(reference+"/"+path.trim_prefix("res://"))
				check(material.shader.code.replace("\r\n","\n")==expected.replace("\r\n","\n"),"Skutečný shader v balíčku odpovídá zdrojům: "+path)
				if not shaders.has(path): shaders.append(path)
		elif material is StandardMaterial3D and material.normal_enabled:
			check(material.normal_texture!=null and material.normal_texture.get_image()!=null,"Vygenerovaná normálová textura je dostupná")
	if output!="":
		var file=FileAccess.open(output,FileAccess.WRITE); file.store_string(JSON.stringify(inventory,"\t")); file.close()
		file=FileAccess.open(output.trim_suffix(".json")+"-materials.json",FileAccess.WRITE)
		file.store_string(JSON.stringify({"material_instances":materials.size(),"shaders":shaders,"renderer":RenderingServer.get_current_rendering_method()},"\t")); file.close()
	world.queue_free(); game=null
	for frame in 6: await process_frame
	await create_timer(0.1).timeout
	print("PACK CONTENT: %d checks, %d failures; %d packaged files; %d materials" % [checks,failures,inventory.size(),materials.size()]); quit(1 if failures else 0)
