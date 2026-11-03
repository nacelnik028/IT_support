extends RefCounted

static var path_override = ""
var locomotion = "teleport"
var snap_degrees = 30
var speed = 1.8
var seated = false
var panel_scale = 1.0
var panel_distance = 1.25

func path() -> String:
	return path_override if path_override != "" else "user://vr_settings.cfg"

func load_settings():
	var cfg = ConfigFile.new()
	if cfg.load(path()) != OK: return
	var movement = cfg.get_value("comfort","locomotion","teleport")
	if movement in ["teleport","smooth"]: locomotion = movement
	var turn = cfg.get_value("comfort","snap_degrees",30)
	if turn in [15,30,45]: snap_degrees = turn
	var walk = cfg.get_value("comfort","speed",1.8)
	if typeof(walk) in [TYPE_INT,TYPE_FLOAT] and is_finite(walk): speed = clampf(walk,0.8,2.5)
	seated = cfg.get_value("comfort","seated",false) == true
	for item in [["panel_scale",0.8,1.4],["panel_distance",0.9,2.0]]:
		var value=cfg.get_value("comfort",item[0],get(item[0]))
		if typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(value): set(item[0],clampf(value,item[1],item[2]))

func save_settings() -> Error:
	var cfg = ConfigFile.new()
	for key in ["locomotion","snap_degrees","speed","seated","panel_scale","panel_distance"]: cfg.set_value("comfort",key,get(key))
	return cfg.save(path())
