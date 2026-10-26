extends RefCounted

const Validator = preload("res://scripts/progression/SaveValidator.gd")
const PATH = "user://academy_save.json"
static var path_override = ""
static var last_message = ""
static var validator

static func rules():
	if validator==null: validator=Validator.new()
	return validator

static func save_path() -> String:
	return path_override if path_override != "" else PATH

static func load_game() -> Dictionary:
	last_message=""
	if not FileAccess.file_exists(save_path()): return {}
	var file=FileAccess.open(save_path(),FileAccess.READ)
	if file==null:
		last_message="Uložený postup nelze přečíst. Původní soubor zůstává chráněný."
		return {}
	var parser=JSON.new()
	var error=parser.parse(file.get_as_text())
	file.close()
	if error!=OK or not rules().valid(parser.data):
		last_message="Uložený postup má poškozený JSON nebo neplatnou strukturu. Nebyl načten ani přepsán."
		return {}
	return parser.data

static func valid_session(data: Dictionary) -> bool:
	return rules().session(data)

static func export_progress(destination: String) -> Error:
	var data=load_game()
	if data.is_empty(): return ERR_INVALID_DATA
	if ProjectSettings.globalize_path(destination)==ProjectSettings.globalize_path(save_path()): return ERR_INVALID_PARAMETER
	var file=FileAccess.open(destination,FileAccess.WRITE)
	if file==null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data,"\t"))
	file.flush()
	var error=file.get_error()
	file.close()
	return error

static func import_progress(source: String) -> Error:
	var parser=JSON.new()
	if parser.parse(FileAccess.get_file_as_string(source))!=OK or not rules().valid(parser.data): return ERR_INVALID_DATA
	if FileAccess.file_exists(save_path()):
		var backup=save_path()+".before-import-"+str(Time.get_unix_time_from_system())+".bak"
		var error=DirAccess.copy_absolute(ProjectSettings.globalize_path(save_path()),ProjectSettings.globalize_path(backup))
		if error!=OK: return error
	return save_game(parser.data)

static func failed(error: Error, message: String) -> Error:
	last_message=message+". Aktuální změny jsou pouze v paměti. Zkontroluj místo na disku a přístup ke složce, potom zkus uložení znovu."
	return error

static func save_game(data: Dictionary, recover_invalid: bool = false) -> Error:
	last_message=""
	var payload = data.duplicate(true)
	payload.schema = 2
	if not rules().valid(payload): return failed(ERR_INVALID_DATA,"Postup nelze uložit: neplatná struktura dat")
	var path = save_path()
	var had_valid_save=false
	if FileAccess.file_exists(path):
		var previous=load_game()
		had_valid_save=not previous.is_empty()
		if previous.is_empty() and last_message!="":
			if not recover_invalid: return failed(ERR_FILE_CORRUPT,"Původní nečitelný nebo vadný soubor je chráněný před přepsáním")
			var archive=path+".invalid-"+str(Time.get_ticks_usec())+".bak"
			var archive_error=DirAccess.copy_absolute(ProjectSettings.globalize_path(path),ProjectSettings.globalize_path(archive))
			if archive_error!=OK: return failed(archive_error,"Zálohu vadného souboru se nepodařilo vytvořit")
		if int(previous.get("schema",0))==1 and not FileAccess.file_exists(path+".v1.bak"):
			var backup_error=DirAccess.copy_absolute(ProjectSettings.globalize_path(path),ProjectSettings.globalize_path(path+".v1.bak"))
			if backup_error!=OK: return failed(backup_error,"Migrační zálohu se nepodařilo vytvořit")
	var f = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if f == null: return failed(FileAccess.get_open_error(),"Postup se nepodařilo zapsat")
	f.store_string(JSON.stringify(payload, "\t"))
	f.flush()
	var write_error=f.get_error()
	f.close()
	if write_error!=OK: return failed(write_error,"Zápis postupu nebyl dokončen")
	# Verify the temporary file before replacing the last valid save.
	var parser=JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path+".tmp"))!=OK or not rules().valid(parser.data): return failed(ERR_FILE_CORRUPT,"Kontrola zapsaného postupu selhala")
	# Keep a rollback copy too: on platforms that remove the target before
	# renaming, even a failed replacement must not discard the last valid file.
	var rollback=path+".last-good.bak"
	if had_valid_save:
		var backup_error=DirAccess.copy_absolute(ProjectSettings.globalize_path(path),ProjectSettings.globalize_path(rollback))
		if backup_error!=OK: return failed(backup_error,"Poslední platný postup se nepodařilo zálohovat")
	var rename_error=DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),ProjectSettings.globalize_path(path))
	if rename_error!=OK:
		if had_valid_save and not FileAccess.file_exists(path):
			var rollback_error=DirAccess.copy_absolute(ProjectSettings.globalize_path(rollback),ProjectSettings.globalize_path(path))
			if rollback_error!=OK: return failed(rename_error,"Nový postup se nepodařilo potvrdit. Poslední platný postup je v "+rollback)
		return failed(rename_error,"Nový postup se nepodařilo potvrdit; poslední soubor zůstal zachován")
	last_message=""
	return OK
