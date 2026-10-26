extends Node3D

const PIXELS = Vector2i(1600,1200)
const DIMENSIONS = Vector2(1.76,1.32)
var viewport: SubViewport
var screen: MeshInstance3D
var keyboard
var cursor: ColorRect
var last_pixel = Vector2(-1,-1)
var pointer_down = false

func _ready():
	viewport = SubViewport.new()
	viewport.name = "AdministrationViewport"
	viewport.size = PIXELS
	viewport.transparent_bg = false
	viewport.disable_3d = true
	viewport.gui_embed_subwindows = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	add_child(viewport)
	screen = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = DIMENSIONS
	screen.mesh = quad
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = viewport.get_texture()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	screen.material_override = material
	screen.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(screen)
	var layer=CanvasLayer.new()
	layer.layer=2
	viewport.add_child(layer)
	keyboard = preload("res://scripts/xr/VirtualKeyboard.gd").new()
	keyboard.viewport = viewport
	layer.add_child(keyboard)
	keyboard.position = Vector2(170,920)
	keyboard.size = Vector2(1260,270)
	cursor = ColorRect.new()
	cursor.color = Color("ffe18b")
	cursor.size = Vector2(10,10)
	cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(cursor)

func place_in_front(head: Camera3D):
	global_position = head.global_position-head.global_basis.z*1.25
	global_position.y = maxf(global_position.y,0.85)
	# A world anchored screen stays still when the player turns their head.
	look_at(head.global_position,Vector3.UP,true)

func pixel_at(ray_origin: Vector3, ray_direction: Vector3) -> Vector2:
	var from = to_local(ray_origin)
	var direction = global_basis.inverse()*ray_direction
	if direction.z >= -0.0001: return Vector2(-1,-1)
	var distance = -from.z/direction.z
	if distance < 0.0 or distance > 4.0: return Vector2(-1,-1)
	var point = from+direction*distance
	var uv = Vector2(point.x/DIMENSIONS.x+0.5,0.5-point.y/DIMENSIONS.y)
	if uv.x < 0 or uv.y < 0 or uv.x > 1 or uv.y > 1: return Vector2(-1,-1)
	return uv*Vector2(PIXELS)

func point(pixel: Vector2):
	cursor.visible = pixel.x >= 0
	if pixel.x < 0:
		if not pointer_down: last_pixel=pixel
		return
	cursor.position = pixel-Vector2(5,5)
	var event = InputEventMouseMotion.new()
	event.position = pixel
	event.global_position = pixel
	event.relative = pixel-last_pixel if last_pixel.x >= 0 else Vector2.ZERO
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pointer_down else 0
	last_pixel = pixel
	viewport.push_input(event,true)

func click(pressed: bool):
	if last_pixel.x < 0: return
	pointer_down = pressed
	var event = InputEventMouseButton.new()
	event.position = last_pixel
	event.global_position = last_pixel
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	viewport.push_input(event,true)

func scroll(amount: float):
	if last_pixel.x < 0: return
	for pressed in [true,false]:
		var event = InputEventMouseButton.new()
		event.position = last_pixel
		event.button_index = MOUSE_BUTTON_WHEEL_UP if amount > 0 else MOUSE_BUTTON_WHEEL_DOWN
		event.pressed = pressed
		viewport.push_input(event,true)

func _process(_delta):
	if visible: keyboard.track_focus()
