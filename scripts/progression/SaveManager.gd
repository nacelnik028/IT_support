extends RefCounted

const PATH = "user://academy_save.json"
static var path_override = ""

static func save_path() -> String:
	return path_override if path_override != "" else PATH

static func load_game() -> Dictionary:
	if not FileAccess.file_exists(save_path()): return {}
	var parser=JSON.new()
	if parser.parse(FileAccess.get_file_as_string(save_path()))!=OK: return {}
	var result = parser.data
	return result if result is Dictionary and result.get("schema",0) == 1 else {}

static func save_game(data: Dictionary) -> Error:
	var payload = data.duplicate(true)
	payload.schema = 1
	var path = save_path()
	var f = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if f == null: return FileAccess.get_open_error()
	f.store_string(JSON.stringify(payload, "\t"))
	f.flush()
	f.close()
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path))
