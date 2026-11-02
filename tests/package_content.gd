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
	await process_frame
	check(world.hub.floor_point(Vector3(4,0,-11)),"Skutečný nový hub uvnitř balíčku")
	var labels=world.find_children("*","Label3D",true,false)
	check(labels.all(func(l): return not l.double_sided),"Opravené jednostranné cedule uvnitř balíčku")
	check(labels.any(func(l): return l.text.contains("LONDON QUIZ")),"Kvízová tabule v zabalené scéně")
	if output!="":
		var file=FileAccess.open(output,FileAccess.WRITE); file.store_string(JSON.stringify(inventory,"\t")); file.close()
	world.queue_free(); await process_frame; game=null
	print("PACK CONTENT: %d checks, %d failures; %d packaged files" % [checks,failures,inventory.size()]); quit(1 if failures else 0)
