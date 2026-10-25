extends RefCounted

const PATH="user://display_settings.cfg"
const DESIGN_SIZE=Vector2i(1600,900)
const RESOLUTIONS=[Vector2i(1280,720),Vector2i(1600,900),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3200,1800),Vector2i(3840,2160)]
static var path_override=""
var resolution=DESIGN_SIZE
var fullscreen=false
var mouse_sensitivity=0.0022
const DEFAULT_KEYS = {"walk_forward":KEY_W,"walk_back":KEY_S,"walk_left":KEY_A,"walk_right":KEY_D,"walk_fast":KEY_SHIFT,"interact":KEY_E,"task_list":KEY_TAB,"flashlight":KEY_F}
const KEY_LABELS = {"walk_forward":"Vpřed","walk_back":"Vzad","walk_left":"Vlevo","walk_right":"Vpravo","walk_fast":"Rychlá chůze","interact":"Interakce","task_list":"Zadání","flashlight":"Baterka"}
var bindings = DEFAULT_KEYS.duplicate()
var volume = 0.75
var muted = false
var text_scale = 1.0
var quality = "Vysoká"
var vsync = true
var fps_limit = 0

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
	var sensitivity=config.get_value("input","mouse_sensitivity",0.0022)
	if typeof(sensitivity) in [TYPE_INT,TYPE_FLOAT] and is_finite(sensitivity) and sensitivity>=0.0005 and sensitivity<=0.005: mouse_sensitivity=sensitivity
	var level=config.get_value("audio","volume",0.75)
	if typeof(level) in [TYPE_INT,TYPE_FLOAT] and is_finite(level): volume=clampf(level,0.0,1.0)
	var mute=config.get_value("audio","muted",false)
	if mute is bool: muted=mute
	var text=config.get_value("interface","text_scale",1.0)
	if typeof(text) in [TYPE_INT,TYPE_FLOAT] and text in [1.0,1.15,1.3]: text_scale=text
	var preset=config.get_value("display","quality","Vysoká")
	if preset in ["Úsporná","Vyvážená","Vysoká"]: quality=preset
	var sync=config.get_value("display","vsync",true)
	if sync is bool: vsync=sync
	var limit=config.get_value("display","fps_limit",0)
	if limit in [0,30,60,120,144]: fps_limit=limit
	var keys=config.get_value("input","bindings",{})
	if keys is Dictionary and keys.size()==DEFAULT_KEYS.size():
		var valid=true
		var used=[]
		for action in DEFAULT_KEYS:
			var key=keys.get(action,0)
			if not key is int or key<=0 or key in used or key in [KEY_ESCAPE,KEY_F11]: valid=false
			used.append(key)
		if valid: bindings=keys.duplicate()

func save_settings() -> Error:
	var config=ConfigFile.new()
	config.set_value("display","width",resolution.x)
	config.set_value("display","height",resolution.y)
	config.set_value("display","fullscreen",fullscreen)
	config.set_value("input","mouse_sensitivity",mouse_sensitivity)
	config.set_value("input","bindings",bindings)
	config.set_value("audio","volume",volume)
	config.set_value("audio","muted",muted)
	config.set_value("interface","text_scale",text_scale)
	config.set_value("display","quality",quality)
	config.set_value("display","vsync",vsync)
	config.set_value("display","fps_limit",fps_limit)
	return config.save(settings_path())

func apply_preferences():
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(volume,0.0001)))
	AudioServer.set_bus_mute(0,muted)
	Engine.max_fps=fps_limit
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	for action in bindings:
		if not InputMap.has_action(action): InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event=InputEventKey.new()
		event.physical_keycode=bindings[action]
		InputMap.action_add_event(action,event)

func apply_world(world: Node):
	world.player.sensitivity=mouse_sensitivity
	var forward=RenderingServer.get_current_rendering_method()=="forward_plus"
	world.get_viewport().msaa_3d=Viewport.MSAA_DISABLED if quality=="Úsporná" else (Viewport.MSAA_2X if quality=="Vyvážená" else Viewport.MSAA_4X)
	for node in world.find_children("*","WorldEnvironment",true,false):
		node.environment.ssao_enabled=forward and quality!="Úsporná"
		node.environment.ssil_enabled=forward and quality=="Vysoká"
		node.environment.ssr_enabled=forward and quality=="Vysoká"
	for node in world.find_children("*","Light3D",true,false):
		if not node.has_meta("original_shadow"): node.set_meta("original_shadow",node.shadow_enabled)
		node.shadow_enabled=node.get_meta("original_shadow") and quality!="Úsporná"

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
