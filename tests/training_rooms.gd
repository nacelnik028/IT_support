extends SceneTree

func _init():
	call_deferred("run")

func run():
	var runner = preload("res://tests/training_rooms_runner.gd").new()
	root.add_child(runner)
	var result = await runner.finished
	quit(result)
