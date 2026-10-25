extends RefCounted

enum Mode { MAIN, TRAINING }
var current: Mode = Mode.MAIN

func is_training() -> bool:
	return current == Mode.TRAINING

func switch_to(value: Mode) -> bool:
	if current == value: return false
	current = value
	return true
