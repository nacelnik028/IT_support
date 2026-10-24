extends RefCounted

const PATH="user://display_settings.cfg"
const DESIGN_SIZE=Vector2i(1600,900)
const RESOLUTIONS=[Vector2i(1280,720),Vector2i(1600,900),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3200,1800),Vector2i(3840,2160)]
static var path_override=""
var resolution=DESIGN_SIZE
var fullscreen=false

func load_settings():
	var config=ConfigFile.new()
	if config.load(settings_path())!=OK: return
	var width=config.get_value("display","width",DESIGN_SIZE.x)
	var height=config.get_value("display","height",DESIGN_SIZE.y)
	var enabled=config.get_value("display","fullscreen",false)
	if typeof(width) in [TYPE_INT,TYPE_FLOAT] and typeof(height) in [TYPE_INT,TYPE_FLOAT]:
		var saved=Vector2i(int(width),int(height))
		if saved in RESOLUTIONS: resolution=saved
	if enabled is bool: fullscreen=enabled

func save_settings() -> Error:
	var config=ConfigFile.new()
	config.set_value("display","width",resolution.x)
	config.set_value("display","height",resolution.y)
	config.set_value("display","fullscreen",fullscreen)
	return config.save(settings_path())

func apply(window: Window):
	# The viewport really renders at the selected resolution in both modes.
	window.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
	window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	window.content_scale_factor=1.0
	window.content_scale_size=resolution
	if fullscreen:
		window.mode=Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		window.mode=Window.MODE_WINDOWED
		var bounds=DisplayServer.screen_get_usable_rect(window.current_screen)
		window.size=fitted_window_size(resolution,bounds.size)
		if bounds.has_area(): window.position=bounds.position+(bounds.size-window.size)/2

static func fitted_window_size(requested: Vector2i,available: Vector2i) -> Vector2i:
	if available.x<=0 or available.y<=0: return requested
	# Keep the title bar accessible even when rendering 4K on a smaller display.
	var usable=available-Vector2i(32,64)
	var multiple=int(floor(minf(float(requested.x)/16.0,minf(float(usable.x)/16.0,float(usable.y)/9.0))))
	multiple=maxi(80,multiple)
	return Vector2i(multiple*16,multiple*9)

static func settings_path() -> String:
	return path_override if path_override!="" else PATH
