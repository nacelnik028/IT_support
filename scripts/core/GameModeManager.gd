extends RefCounted

enum Mode { MAIN = 0, SERVER_TRAINING = 1, TRAINING = 1, PROGRAMMING_ACADEMY = 2 }
var current: Mode = Mode.MAIN

func is_training() -> bool:
	return current == Mode.TRAINING

func is_programming() -> bool:
	return current == Mode.PROGRAMMING_ACADEMY

func is_education() -> bool:
	return current != Mode.MAIN

func switch_to(value: Mode) -> bool:
	if current == value: return false
	current = value
	return true
