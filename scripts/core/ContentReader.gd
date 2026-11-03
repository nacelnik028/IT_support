extends RefCounted

# Authored content stays plain UTF-8. The Windows export may store the same
# bytes using Godot's native, lossless FileAccess compression container.
static func text(path: String) -> String:
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null: return ""
	var compressed=file.get_buffer(4).get_string_from_ascii()=="GCPF"
	file.close()
	if not compressed: return FileAccess.get_file_as_string(path)
	file=FileAccess.open_compressed(path,FileAccess.READ)
	if file==null: return ""
	var result=file.get_as_text()
	file.close()
	return result
