extends RefCounted

# Original generated geometry; small meshes and materials are shared.
static var materials: Dictionary = {}
static var meshes: Dictionary = {}
static var metal_normal: NoiseTexture2D

static func material(color: Color, metal: float = 0.0, glow: float = 0.0) -> StandardMaterial3D:
	var key = str(color)+str(metal)+str(glow)
	if materials.has(key): return materials[key]
	var result = StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metal
	result.roughness = 0.36 if metal > 0 else 0.78
	if metal>0.3 and glow==0 and DisplayServer.get_name()!="headless":
		if metal_normal==null:
			var noise = FastNoiseLite.new()
			noise.seed = 2042
			noise.frequency = 0.06
			metal_normal = NoiseTexture2D.new()
			metal_normal.width = 256
			metal_normal.height = 256
			metal_normal.noise = noise
			metal_normal.seamless = true
			metal_normal.as_normal_map = true
			metal_normal.bump_strength = 0.12
		result.normal_enabled = true
		result.normal_texture = metal_normal
		result.normal_scale = 0.18
		result.uv1_triplanar = true
		result.uv1_world_triplanar = true
		result.uv1_scale = Vector3(5,5,5)
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
	if glow > 0.0 or minf(dimensions.x,minf(dimensions.y,dimensions.z))<0.05:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	return node

static func bevel(parent: Node3D, at: Vector3, dimensions: Vector3, color: Color, metal: float = 0.0, radius: float = 0.015) -> MeshInstance3D:
	radius = minf(radius,minf(dimensions.x,minf(dimensions.y,dimensions.z))*0.45)
	var key = "bevel:"+str(dimensions)+":"+str(radius)
	if not meshes.has(key):
		var vertices = PackedVector3Array()
		var normals = PackedVector3Array()
		var uv = PackedVector2Array()
		var indices = PackedInt32Array()
		var half = dimensions*0.5
		for axis in 3:
			for direction in [-1,1]:
				var normal = Vector3.ZERO
				normal[axis] = direction
				var u = Vector3.ZERO
				u[(axis+1)%3] = 1
				var v = normal.cross(u)
				var hu = absf(u.dot(half))
				var hv = absf(v.dot(half))
				var us = [-hu,-hu+radius,hu-radius,hu]
				var vs = [-hv,-hv+radius,hv-radius,hv]
				var start = vertices.size()
				for y in 4:
					for x in 4:
						var cube = normal*half[axis]+u*us[x]+v*vs[y]
						var inner = cube.clamp(-half+Vector3.ONE*radius,half-Vector3.ONE*radius)
						var n = (cube-inner).normalized()
						vertices.append(inner+n*radius)
						normals.append(n)
						uv.append(Vector2(float(x)/3.0,float(y)/3.0))
				for y in 3:
					for x in 3:
						var a = start+y*4+x
						indices.append_array(PackedInt32Array([a,a+4,a+1,a+1,a+4,a+5]))
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uv
		arrays[Mesh.ARRAY_INDEX] = indices
		var mesh = ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		meshes[key] = mesh
	var node = MeshInstance3D.new()
	node.mesh = meshes[key]
	node.position = at
	node.material_override = material(color,metal)
	parent.add_child(node)
	return node

static func cylinder(parent: Node3D, at: Vector3, radius: float, height: float, color: Color, metal: float = 0.0, segments: int = 16) -> MeshInstance3D:
	var key = "cylinder:"+str(radius)+":"+str(height)+":"+str(segments)
	if not meshes.has(key):
		var mesh = CylinderMesh.new()
		mesh.top_radius = radius
		mesh.bottom_radius = radius
		mesh.height = height
		mesh.radial_segments = segments
		meshes[key] = mesh
	var node = MeshInstance3D.new()
	node.mesh = meshes[key]
	node.position = at
	node.material_override = material(color,metal)
	parent.add_child(node)
	return node

static func tube(parent: Node3D, points: Array, radius: float, color: Color, metal: float = 0.0) -> MeshInstance3D:
	var curve = Curve3D.new()
	curve.bake_interval = 0.06
	for i in points.size():
		var tangent = (points[mini(i+1,points.size()-1)]-points[maxi(i-1,0)])*0.16
		curve.add_point(points[i],-tangent if i>0 else Vector3.ZERO,tangent if i<points.size()-1 else Vector3.ZERO)
	var path = curve.get_baked_points()
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	for i in path.size():
		var tangent = (path[mini(i+1,path.size()-1)]-path[maxi(i-1,0)]).normalized()
		var side = tangent.cross(Vector3.UP if absf(tangent.y)<0.95 else Vector3.RIGHT).normalized()
		var up = side.cross(tangent).normalized()
		for j in 8:
			var angle = TAU*j/8.0
			var n = side*cos(angle)+up*sin(angle)
			vertices.append(path[i]+n*radius)
			normals.append(n)
			if i>0:
				var a = (i-1)*8+j
				var b = (i-1)*8+(j+1)%8
				indices.append_array(PackedInt32Array([a,b,a+8,b,b+8,a+8]))
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var node = MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material(color,metal)
	parent.add_child(node)
	return node

static func ring(parent: Node3D, at: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var key = "ring:"+str(radius)
	if not meshes.has(key):
		var mesh = TorusMesh.new()
		mesh.inner_radius = radius*0.84
		mesh.outer_radius = radius
		mesh.rings = 24
		mesh.ring_segments = 8
		meshes[key] = mesh
	var node = MeshInstance3D.new()
	node.mesh = meshes[key]
	node.position = at
	node.rotation.x = PI/2
	node.material_override = material(color,0.65)
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

static func batch_static(root: Node3D) -> int:
	var groups: Dictionary = {}
	collect_static(root,groups)
	var saved = 0
	for group in groups.values():
		if group.size()<8: continue
		var first = group[0]
		var multi = MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = first.mesh
		multi.instance_count = group.size()
		var instance = MultiMeshInstance3D.new()
		instance.multimesh = multi
		instance.material_override = first.material_override
		instance.cast_shadow = first.cast_shadow
		root.add_child(instance)
		for i in group.size():
			multi.set_instance_transform(i,root.global_transform.affine_inverse()*group[i].global_transform)
			group[i].visible = false
			group[i].queue_free()
		saved += group.size()-1
	return saved

static func collect_static(node: Node, groups: Dictionary):
	if node is Node3D and not node.visible: return
	if node.has_method("set_focus") or node.get_meta("dynamic",false): return
	if node is MeshInstance3D and node.mesh != null and node.material_override != null:
		# Keep all three rooms as separate culling groups.
		var room = "programming" if node.global_position.z < -7 else "academy" if node.global_position.x>9 else "operations"
		var key = room+str(node.mesh.get_instance_id())+":"+str(node.material_override.get_instance_id())
		if not groups.has(key): groups[key] = []
		groups[key].append(node)
	for child in node.get_children(): collect_static(child,groups)
