extends SceneTree

func _init():
	var actions = OpenXRActionMap.new()
	actions.create_default_action_sets()
	var error = ResourceSaver.save(actions,"res://scenes/xr/academy_actions.tres")
	print("XR action map (PICO 4 and PC profiles): ",error)
	quit(error)
