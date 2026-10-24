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
	return result if result is Dictionary and int(result.get("schema",0)) in [1,2] else {}

static func save_game(data: Dictionary) -> Error:
	var payload = data.duplicate(true)
	payload.schema = 2
	var path = save_path()
	if FileAccess.file_exists(path) and not FileAccess.file_exists(path+".v1.bak"):
		var previous=load_game()
		if int(previous.get("schema",0))==1:
			var backup_error=DirAccess.copy_absolute(ProjectSettings.globalize_path(path),ProjectSettings.globalize_path(path+".v1.bak"))
			if backup_error!=OK: return backup_error
	var f = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if f == null: return FileAccess.get_open_error()
	f.store_string(JSON.stringify(payload, "\t"))
	f.flush()
	f.close()
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path))
