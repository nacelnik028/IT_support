extends RefCounted

const PATH = "user://academy_save.json"

static func load_game() -> Dictionary:
	if not FileAccess.file_exists(PATH): return {}
	var result = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return result if result is Dictionary and result.get("schema",0) == 1 else {}

static func save_game(data: Dictionary) -> Error:
	var payload = data.duplicate(true)
	payload.schema = 1
	var f = FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	if f == null: return FileAccess.get_open_error()
	f.store_string(JSON.stringify(payload, "\t"))
	f.flush()
	f.close()
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(PATH + ".tmp"), ProjectSettings.globalize_path(PATH))
