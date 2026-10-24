extends RefCounted

# Original generated geometry; small meshes and materials are shared.
static var materials: Dictionary = {}
static var meshes: Dictionary = {}

static func material(color: Color, metal: float = 0.0, glow: float = 0.0) -> StandardMaterial3D:
	var key = str(color)+str(metal)+str(glow)
	if materials.has(key): return materials[key]
	var result = StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metal
	result.roughness = 0.36 if metal > 0 else 0.78
	if glow > 0:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = glow
	materials[key] = result
	return result

static func box(parent: Node3D, at: Vector3, dimensions: Vector3, color: Color, metal: float = 0.0, glow: float = 0.0) -> MeshInstance3D:
	var key = str(dimensions)
	if not meshes.has(key):
		var mesh = BoxMesh.new()
		mesh.size = dimensions
		meshes[key] = mesh
	var node = MeshInstance3D.new()
	node.mesh = meshes[key]
	node.material_override = material(color, metal, glow)
	node.position = at
	parent.add_child(node)
	return node

static func solid(parent: Node3D, at: Vector3, dimensions: Vector3, color: Color, metal: float = 0.0) -> StaticBody3D:
	var body = StaticBody3D.new()
	body.position = at
	parent.add_child(body)
	box(body, Vector3.ZERO, dimensions, color, metal)
	collision(body, dimensions)
	return body

static func collision(body: CollisionObject3D, dimensions: Vector3, at: Vector3 = Vector3.ZERO):
	var shape = BoxShape3D.new()
	shape.size = dimensions
	var node = CollisionShape3D.new()
	node.shape = shape
	node.position = at
	body.add_child(node)

static func text(parent: Node3D, words: String, at: Vector3, font_size: int = 40, pixel_size: float = 0.003, color: Color = Color("d4e8ed")) -> Label3D:
	var label = Label3D.new()
	label.text = words
	label.font_size = font_size
	label.pixel_size = pixel_size
	label.modulate = color
	label.outline_size = 0
	label.position = at
	parent.add_child(label)
	return label

static func frame(parent: Node3D, dimensions: Vector3, color: Color) -> Node3D:
	var holder = Node3D.new()
	parent.add_child(holder)
	for axis in 3:
		for a in [-1, 1]:
			for b in [-1, 1]:
				var at = Vector3.ZERO
				var size = Vector3.ONE * 0.012
				size[axis] = dimensions[axis]
				at[(axis+1)%3] = dimensions[(axis+1)%3]*a*0.5
				at[(axis+2)%3] = dimensions[(axis+2)%3]*b*0.5
				box(holder, at, size, color, 0.0, 1.2)
	return holder
