extends RefCounted

# Replaced by the structural web renderer in the web implementation stage.
func load_files(_files: Dictionary) -> Dictionary:
	return {"ok":false,"error":"Webový náhled se připravuje."}
func validate(_task: Dictionary, _files: Dictionary) -> Array:
	return [{"ok":false,"text":"Webový náhled se připravuje."}]
