extends SceneTree

func _initialize():
	var paths=[]
	walk("res://data",paths)
	var before=0; var after=0
	for path in paths:
		var original=FileAccess.get_file_as_bytes(path)
		before+=original.size()
		var file=FileAccess.open_compressed(path+".packed",FileAccess.WRITE,FileAccess.COMPRESSION_ZSTD)
		if file==null: quit(1); return
		file.store_buffer(original); file.close()
		file=FileAccess.open_compressed(path+".packed",FileAccess.READ)
		if file==null or file.get_buffer(file.get_length())!=original: quit(2); return
		file.close()
		var packed_size=FileAccess.get_file_as_bytes(path+".packed").size()
		if packed_size<original.size():
			if DirAccess.rename_absolute(path+".packed",path)!=OK: quit(3); return
			after+=packed_size
		else:
			DirAccess.remove_absolute(path+".packed"); after+=original.size()
	print("CONTENT COMPRESSION: %d -> %d B; exact bytes verified" % [before,after])
	quit()

func walk(path: String, paths: Array):
	for name in DirAccess.get_files_at(path):
		if name.ends_with(".json"): paths.append(path.path_join(name))
	for name in DirAccess.get_directories_at(path): walk(path.path_join(name),paths)
