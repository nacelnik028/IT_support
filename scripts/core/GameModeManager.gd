extends RefCounted

enum Mode { MAIN = 0, SERVER_TRAINING = 1, TRAINING = 1, PROGRAMMING_ACADEMY = 2, ENGLISH_LONDON = 3, HUB = 4, NETWORK_LAB = 5 }
var current: Mode = Mode.MAIN

func is_training() -> bool:
	return current == Mode.TRAINING

func is_programming() -> bool:
	return current == Mode.PROGRAMMING_ACADEMY

func is_english() -> bool:
	return current == Mode.ENGLISH_LONDON

func is_network_lab() -> bool:
	return current == Mode.NETWORK_LAB

func is_education() -> bool:
	return current in [Mode.TRAINING,Mode.PROGRAMMING_ACADEMY,Mode.ENGLISH_LONDON,Mode.NETWORK_LAB]

func is_hub() -> bool:
	return current == Mode.HUB

func is_away() -> bool:
	return current != Mode.MAIN

func switch_to(value: Mode) -> bool:
	if current == value: return false
	current = value
	return true
