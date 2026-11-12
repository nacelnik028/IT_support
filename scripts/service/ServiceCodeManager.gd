extends "res://scripts/programming/AcademyManager.gd"

var owner_ref: WeakRef

func checkpoint() -> Error:
	# The whole incident owns these files; never write a separate academy result.
	return OK if str(files.get("main.py","")).to_utf8_buffer().size()<=131072 else ERR_INVALID_DATA

func record(result: Dictionary):
	var owner = owner_ref.get_ref()
	if owner!=null: owner.record_analysis(result)

func start(_id: String, _learning_mode: String, _lesson: bool = false, _preserve_series: bool = false) -> bool:
	return false

func test_program() -> Dictionary:
	var owner = owner_ref.get_ref()
	if owner==null or not owner.analysis_input_current():
		last_result = {"ok":false,"score":0,"summary":"Vstup je zastaralý. Aktualizuj virtuální data incidentu.","text":"Vstup je zastaralý. Aktualizuj virtuální data incidentu.","checks":[],"diagnostics":[]}
		return last_result
	return super.test_program()

func hint() -> String:
	var text := super.hint()
	if changed.is_valid(): changed.call()
	return text
