extends Area3D

# The boundary runs through the centre of the existing sliding door. A small
# spatial dead band prevents repeated transitions while standing on its seam.
const BOUNDS = AABB(Vector3(9.0,-0.35,-6.9),Vector3(11.9,4.4,13.8))
const SEAM = 0.16
var player: CharacterBody3D
var game

func _ready():
	name = "TrainingZone"
	collision_layer = 0
	collision_mask = 1
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = BOUNDS.size
	shape.shape = box
	shape.position = BOUNDS.get_center()
	add_child(shape)
	body_entered.connect(func(body):
		if body == player: reconcile())
	body_exited.connect(func(body):
		if body == player: reconcile())

func contains_player() -> bool:
	if not is_instance_valid(player) or not player.is_inside_tree(): return false
	var point = to_local(player.global_position)
	var bounds = BOUNDS
	# MAIN owns the outer half; TRAINING owns the inner half of the seam.
	if game != null and game.game_mode.is_training():
		bounds.position.x -= SEAM
		bounds.size.x += SEAM
	else:
		bounds.position.x += SEAM
		bounds.size.x -= SEAM
	return bounds.has_point(point)

func reconcile():
	if game != null: game.reconcile_room()

func _physics_process(_delta):
	# Area signals alone can miss a teleport, a disabled body or a scene change.
	reconcile()

func _exit_tree():
	if game != null:
		game.room_probe = Callable()
		game.leave_training()
