extends Node3D

const Geo = preload("res://scripts/world/Geometry.gd")
const Item = preload("res://scripts/world/Interactable3D.gd")
var game
var devices: Dictionary = {}
var player
var monitoring: Label3D

func _ready():
	build_room()
	build_rack(Vector3(0,0,-3),"A01")
	var server = item("PVE-01","PVE-01 — Proxmox server","server",Vector3(0,1.4,-3),Vector3(1.25,0.3,0.95))
	Geo.text(server.visual,"PVE-01   /   PROXMOX VE",Vector3(0,0,0.49),28,0.0016)
	build_workstation(Vector3(-5,0,2),"ADMIN-01","Proxmox")
	player = preload("res://scenes/world/Player.tscn").instantiate()
	add_child(player)
	player.position = Vector3(0,0.02,3)
	monitoring = Geo.text(self,"NORTHSTAR / PROVOZNÍ DOHLED",Vector3(4,2,-6.75),34,0.004)

func build_room():
	Geo.solid(self,Vector3(0,-0.16,0),Vector3(18,0.3,14),Color("343f4b"),0.25)
	Geo.solid(self,Vector3(0,2,-7),Vector3(18,4,0.25),Color("293844"))
	Geo.solid(self,Vector3(-9,2,0),Vector3(0.25,4,14),Color("374753"))
	Geo.solid(self,Vector3(9,2,0),Vector3(0.25,4,14),Color("374753"))
	Geo.solid(self,Vector3(0,2,7),Vector3(18,4,0.25),Color("293844"))
	Geo.box(self,Vector3(0,4,0),Vector3(18,0.15,14),Color("192530"))
	for x in range(-9,10): Geo.box(self,Vector3(x,0.002,0),Vector3(0.012,0.005,14),Color("1a2933"))
	for z in range(-7,8): Geo.box(self,Vector3(0,0.002,z),Vector3(18,0.005,0.012),Color("1a2933"))
	for x in [-5,0,5]:
		Geo.box(self,Vector3(x,3.85,0),Vector3(0.65,0.06,9),Color("c2eeff"),0,1.3)
		var light = OmniLight3D.new()
		light.position = Vector3(x,3,0)
		light.light_color = Color("bee7ff")
		light.light_energy = 2.0
		light.omni_range = 10
		add_child(light)
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("142330")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("9bb1c4")
	env.environment.ambient_light_energy = 0.65
	env.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	add_child(env)
	var key = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-65,-20,0)
	key.light_energy = 0.6
	key.shadow_enabled = true
	add_child(key)
	Geo.text(self,"NORTHSTAR  /  DATACENTER ACADEMY",Vector3(-3,3.25,-6.8),50,0.004)
	Geo.text(self,"SERVEROVNA 01     •     FYZICKÝ PŘÍSTUP",Vector3(-3,2.9,-6.8),28,0.003)

func item(id: String, title: String, type: String, at: Vector3, dimensions: Vector3, console: String = "Proxmox"):
	var object = Item.new()
	object.name = id.replace(":","_")
	object.position = at
	add_child(object)
	object.configure(id,title,type,dimensions,Color("22313f"))
	object.console = console
	devices[id] = object
	return object

func build_rack(at: Vector3, id: String):
	var rack = Node3D.new()
	rack.position = at
	add_child(rack)
	for x in [-0.73,0.73]: Geo.solid(rack,Vector3(x,1.35,0),Vector3(0.1,2.7,1.25),Color("0e1821"),0.8)
	for y in [0.1,2.65]: Geo.solid(rack,Vector3(0,y,0),Vector3(1.55,0.14,1.25),Color("1a2531"),0.8)
	Geo.solid(rack,Vector3(0,1.35,-0.61),Vector3(1.55,2.6,0.05),Color("131f29"),0.8)
	for y in range(4,25):
		for x in [-0.63,0.63]: Geo.box(rack,Vector3(x,y*0.1,0.63),Vector3(0.035,0.025,0.015),Color("5b6c7b"),0.8)
	Geo.text(rack,"RACK "+id,Vector3(0,2.5,0.66),40,0.0025)

func build_workstation(at: Vector3, id: String, console: String):
	Geo.solid(self,at+Vector3(0,0.78,0),Vector3(2,0.1,1.1),Color("536374"),0.3)
	for x in [-0.85,0.85]: Geo.solid(self,at+Vector3(x,0.38,0),Vector3(0.08,0.76,0.8),Color("192731"),0.6)
	Geo.box(self,at+Vector3(0,1.02,-0.2),Vector3(0.08,0.4,0.1),Color("111c26"),0.6)
	var monitor = item(id,id+" — "+console,"computer",at+Vector3(0,1.38,-0.2),Vector3(1.2,0.7,0.08),console)
	Geo.box(monitor.visual,Vector3(0,0,0.05),Vector3(1.1,0.6,0.01),Color("083b48"),0,0.4)
	Geo.text(monitor.visual,console+"\nADMINISTRACE",Vector3(0,0,0.062),32,0.002)
	Geo.box(self,at+Vector3(0,0.85,0.25),Vector3(0.65,0.025,0.24),Color("111a25"))

func sync_state():
	if game == null or game.sim.state.is_empty(): return
	for id in devices:
		var object = devices[id]
		if object.kind == "server": object.set_status("Healthy" if game.sim.state.hosts[id].online else "Offline")
	var lines = ["PROVOZNÍ DOHLED / ŽIVÁ DATA"]
	for vm in game.sim.state.vms.values():
		if vm.get("exists",false): lines.append("%s  %s  /  %s" % [vm.id,vm.name,"BĚŽÍ" if vm.status=="Running" else "VYPNUTO"])
	monitoring.text = "\n".join(lines)
