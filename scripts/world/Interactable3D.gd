extends StaticBody3D

const Geo = preload("res://scripts/world/Geometry.gd")
var device_id = ""
var kind = "server"
var caption = ""
var slot = ""
var pool = "RAID"
var console = "Proxmox"
var outline: Node3D
var guide: Node3D
var indicator: MeshInstance3D
var visual: Node3D
var status = "Healthy"
var laboratory = false

func configure(id: String, title: String, type: String, dimensions: Vector3, color: Color):
	device_id = id
	caption = title
	kind = type
	Geo.collision(self, dimensions)
	visual = Node3D.new()
	add_child(visual)
	Geo.bevel(visual, Vector3.ZERO, dimensions, color, 0.55,0.012)
	outline = Geo.frame(self, dimensions+Vector3.ONE*0.025, Color("59f5dc"))
	outline.visible = false
	guide = Geo.frame(self, dimensions+Vector3.ONE*0.055, Color("ffd579"))
	guide.visible = false
	indicator = Geo.box(visual, Vector3(dimensions.x*0.42, 0, dimensions.z*0.5+0.008), Vector3(0.035,0.025,0.015), Color("43e5a0"),0,1.0)

func set_focus(enabled: bool):
	if is_instance_valid(outline): outline.visible = enabled

func set_guided(enabled: bool):
	if is_instance_valid(guide): guide.visible = enabled

func set_status(value: String):
	status = value
	var color = Color("4adea0")
	if value in ["Warning", "Degraded", "Recovering"]: color = Color("ffb94e")
	elif value in ["Critical", "Failed"]: color = Color("ff425f")
	elif value in ["Offline", "Missing"]: color = Color("151c23")
	indicator.material_override = Geo.material(color,0,1.0 if value not in ["Offline","Missing"] else 0.0)
