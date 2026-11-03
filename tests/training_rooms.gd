extends SceneTree

func _init():
	preload("res://scripts/xr/VRSettings.gd").path_override="user://academy_test_training_rooms_"+str(OS.get_process_id())+"_vr.cfg"
	call_deferred("run")

func run():
	var runner = preload("res://tests/training_rooms_runner.gd").new()
	root.add_child(runner)
	var result = await runner.finished
	quit(result)
