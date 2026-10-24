extends CharacterBody3D

signal focus_changed(target)
signal interaction_requested(target)

@export var walk_speed = 3.1
@export var fast_speed = 5.0
@export var sensitivity = 0.0022
var enabled = false
var target
@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight

static func setup_inputs():
	var keys = {"walk_forward":KEY_W,"walk_back":KEY_S,"walk_left":KEY_A,"walk_right":KEY_D,"walk_fast":KEY_SHIFT,"interact":KEY_E,"task_list":KEY_TAB,"flashlight":KEY_F}
	for action in keys:
		if InputMap.has_action(action): continue
		InputMap.add_action(action)
		var event = InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action,event)

func _ready():
	setup_inputs()
	ray.add_exception(self)

func set_enabled(value: bool):
	enabled = value
	velocity = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if value else Input.MOUSE_MODE_VISIBLE
	if not value: update_focus(null)

func _unhandled_input(event):
	if not enabled: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x*sensitivity)
		camera.rotation.x = clampf(camera.rotation.x-event.relative.y*sensitivity,-1.45,1.45)
	if event.is_action_pressed("interact"):
		poll_target()
		if is_instance_valid(target): interaction_requested.emit(target)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("flashlight"): flashlight.visible = not flashlight.visible

func _physics_process(delta):
	if not enabled: return
	var input = Input.get_vector("walk_left","walk_right","walk_forward","walk_back")
	var direction = global_basis * Vector3(input.x,0,input.y)
	var speed = fast_speed if Input.is_action_pressed("walk_fast") else walk_speed
	velocity.x = move_toward(velocity.x,direction.x*speed,22.0*delta)
	velocity.z = move_toward(velocity.z,direction.z*speed,22.0*delta)
	if not is_on_floor(): velocity.y -= 18.0*delta
	else: velocity.y = -0.1
	move_and_slide()
	poll_target()

func poll_target():
	ray.force_raycast_update()
	var hit = ray.get_collider() if ray.is_colliding() else null
	update_focus(hit if is_instance_valid(hit) and hit.has_method("set_focus") else null)

func update_focus(next):
	if target == next: return
	if is_instance_valid(target): target.set_focus(false)
	target = next
	if is_instance_valid(target): target.set_focus(true)
	focus_changed.emit(target)
