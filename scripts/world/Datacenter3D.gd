extends Node3D

const Geo = preload("res://scripts/world/Geometry.gd")
const Item = preload("res://scripts/world/Interactable3D.gd")
var game
var devices: Dictionary = {}
var player
var monitoring: Label3D
var fans: Array = []
var cable_meshes: Dictionary = {}
var port_objects: Array = []

func _ready():
	build_room()
	for entry in [[0.0,"A01"],[-3.2,"A02"],[3.2,"B01"],[6.2,"B02"]]: build_rack(Vector3(entry[0],0,-3),entry[1])
	build_server("PVE-01",Vector3(0,1.4,-3),"Proxmox")
	build_server("PVE-02",Vector3(0,0.65,-3),"Proxmox")
	build_server("HV-01",Vector3(-3.2,1.4,-3),"Hyper-V")
	build_server("HV-02",Vector3(-3.2,0.65,-3),"Hyper-V")
	build_server("NAS-01",Vector3(3.2,1.35,-3),"Storage",0.9)
	build_server("BACKUP-01",Vector3(6.2,1.4,-3),"Storage")
	build_disks()
	build_switch()
	build_workstation(Vector3(-5,0,2),"ADMIN-01","Proxmox")
	build_workstation(Vector3(-2.3,0,2),"ADMIN-02","Hyper-V")
	item("SPARES","Servisní skříň — náhradní disky","spares",Vector3(-7.6,0.9,-2),Vector3(1,1.8,0.65),"Storage")
	Geo.text(devices.SPARES.visual,"SERVIS\nNÁHRADNÍ DISKY",Vector3(0,0.5,0.34),38,0.003)
	build_details()
	player = preload("res://scenes/world/Player.tscn").instantiate()
	add_child(player)
	player.position = Vector3(0,0.02,3)
	var screen = item("MONITOR","Monitorovací konzole — živý stav","monitor",Vector3(4.5,2.5,-6.65),Vector3(5.1,1.5,0.12),"Storage")
	Geo.box(screen.visual,Vector3(0,0,0.07),Vector3(4.95,1.35,0.03),Color("07313b"),0,0.25)
	monitoring = Geo.text(screen.visual,"NORTHSTAR / PROVOZNÍ DOHLED",Vector3(0,0,0.095),38,0.003)

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
	Geo.text(self,"NORTHSTAR  /  DATACENTER ACADEMY",Vector3(-3,3.4,-6.8),60,0.004)
	Geo.text(self,"SERVEROVNA 01     •     FYZICKÝ PŘÍSTUP",Vector3(-3,3.05,-6.8),32,0.003)

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
	# Blank panels and perforated intake make unoccupied rack units readable.
	for y in [0.3,1.95,2.15]:
		Geo.box(rack,Vector3(0,y,0.49),Vector3(1.2,0.13,0.06),Color("263746"),0.7)
		for x in range(-11,12): Geo.box(rack,Vector3(x*0.046,y,0.525),Vector3(0.012,0.06,0.007),Color("0b1720"))
	Geo.box(rack,Vector3(-0.78,1.35,0.6),Vector3(0.018,2.6,0.02),Color("308caa"),0,0.8)

func build_workstation(at: Vector3, id: String, console: String):
	Geo.solid(self,at+Vector3(0,0.78,0),Vector3(2,0.1,1.1),Color("536374"),0.3)
	for x in [-0.85,0.85]: Geo.solid(self,at+Vector3(x,0.38,0),Vector3(0.08,0.76,0.8),Color("192731"),0.6)
	Geo.box(self,at+Vector3(0,1.02,-0.2),Vector3(0.08,0.4,0.1),Color("111c26"),0.6)
	var monitor = item(id,id+" — "+console,"computer",at+Vector3(0,1.38,-0.2),Vector3(1.2,0.7,0.08),console)
	Geo.box(monitor.visual,Vector3(0,0,0.05),Vector3(1.1,0.6,0.01),Color("083b48"),0,0.4)
	Geo.text(monitor.visual,console+"\nADMINISTRACE",Vector3(0,0,0.062),32,0.002)
	Geo.box(self,at+Vector3(0,0.85,0.25),Vector3(0.65,0.025,0.24),Color("111a25"))
	Geo.box(self,at+Vector3(0.55,0.85,0.25),Vector3(0.09,0.04,0.13),Color("0d1b29"))
	Geo.solid(self,at+Vector3(0,0.47,1.1),Vector3(0.55,0.12,0.55),Color("182533"))
	Geo.solid(self,at+Vector3(0,0.88,1.37),Vector3(0.55,0.7,0.08),Color("182533"))
	Geo.solid(self,at+Vector3(0,0.22,1.1),Vector3(0.1,0.44,0.1),Color("687b88"),0.8)

func build_server(id: String, at: Vector3, console: String, height: float = 0.4):
	var server = item(id,id+" — "+("úložiště" if id=="NAS-01" else console+" server"),"server",at,Vector3(1.25,height,0.95),console)
	Geo.text(server.visual,id+" / "+console.to_upper(),Vector3(-0.12,height*0.28,0.486),34,0.0016)
	for x in [-0.56,0.56]:
		Geo.box(server.visual,Vector3(x,0,0.51),Vector3(0.045,height*0.65,0.06),Color("8e9da7"),0.8)
	for i in 13: Geo.box(server.visual,Vector3(-0.42+i*0.055,-height*0.22,0.482),Vector3(0.018,0.045,0.01),Color("0b1520"))
	var nic = item("NIC:"+id,id+" — síťový konektor / štítek SW-CORE port"+str(["PVE-01","PVE-02","HV-01","HV-02","NAS-01","BACKUP-01"].find(id)+1),"cable",at+Vector3(0.81,0,0.55),Vector3(0.14,0.14,0.16),console)
	nic.slot = id
	var power = item("PSU:"+id,id+" — napájecí přívod","supply",at+Vector3(-0.83,0,0.5),Vector3(0.14,0.14,0.13),console)
	power.slot = id
	cable_meshes[id] = Geo.box(self,at+Vector3(0.82,0.75,-0.35),Vector3(0.025,1.5,0.025),Color("2faab5"))
	var fan = Node3D.new()
	server.visual.add_child(fan)
	fan.position = Vector3(0.36,0.02,0.488)
	for angle in [0,60,120]:
		var blade = Geo.box(fan,Vector3.ZERO,Vector3(0.12,0.018,0.012),Color("62788a"),0.7)
		blade.rotation.z = deg_to_rad(angle)
	fans.append({"node":fan,"host":id})

func build_disks():
	for pool in ["RAID","ZFS"]:
		var slots = ["A","B"] if pool=="ZFS" else ["0","1","2","3","4","5","6","7"]
		for i in slots.size():
			var at = Vector3(-0.25+i*0.5,1.35,-2.46) if pool=="ZFS" else Vector3(2.75+(i%4)*0.3,1.34-floorf(float(i)/4.0)*0.26,-2.46)
			var disk = item(pool+":"+slots[i],("PVE-01" if pool=="ZFS" else "NAS-01")+" — diskový slot "+slots[i],"disk",at,Vector3(0.26,0.19,0.1),"Storage")
			disk.pool = pool
			disk.slot = slots[i]
			Geo.box(disk.visual,Vector3(0,-0.035,0.065),Vector3(0.2,0.027,0.05),Color("879aa6"),0.8)
			Geo.text(disk.visual,slots[i],Vector3(-0.06,0.03,0.057),36,0.0013)

func build_switch():
	var sw = item("SW-CORE","SW-CORE — síťová laboratoř / fyzické porty","switch",Vector3(-6.1,1.5,-5.8),Vector3(2.8,0.5,0.8),"Síť")
	Geo.text(sw.visual,"SW-CORE  /  12 PORTŮ",Vector3(0,0.16,0.415),32,0.002)
	for i in 12:
		var port = item("PORT:"+str(i+1),"SW-CORE — port "+str(i+1),"port",Vector3(-7.3+i*0.215,1.43,-5.32),Vector3(0.17,0.13,0.1),"Síť")
		port.slot = str(i+1)
		Geo.text(port.visual,str(i+1),Vector3(0,-0.1,0.06),24,0.0016)
		port_objects.append(port)
	Geo.solid(self,Vector3(-6.1,0.65,-5.8),Vector3(3,1.3,0.85),Color("182733"),0.5)

func build_details():
	# Overhead cable tray, cooling units, floor air intakes, and safety markings.
	for z in [-3.8,-3.3]: Geo.box(self,Vector3(1.5,3.35,z),Vector3(13.8,0.12,0.04),Color("72818d"),0.8)
	for x in range(-5,9): Geo.box(self,Vector3(x,3.35,-3.55),Vector3(0.04,0.08,0.6),Color("526673"),0.8)
	for i in 6: Geo.box(self,Vector3(1.5,3.4+i*0.02,-3.55+i*0.035),Vector3(13.8,0.018,0.018),Color("239ba9") if i%2==0 else Color("db9d46"))
	for x in [-7.5,7.5]:
		Geo.solid(self,Vector3(x,1.4,-6.4),Vector3(1.1,2.8,0.6),Color("617788"),0.65)
		Geo.text(self,"CHLAZENÍ",Vector3(x,2.5,-6.06),28,0.002)
		for y in 20: Geo.box(self,Vector3(x,0.4+y*0.09,-6.065),Vector3(0.9,0.025,0.02),Color("182a36"))
	for x in [-3.2,0.0,3.2,6.2]:
		Geo.box(self,Vector3(x,0.009,-1.6),Vector3(1.6,0.012,0.6),Color("152936"),0.5)
		for i in 15: Geo.box(self,Vector3(x-0.7+i*0.1,0.02,-1.6),Vector3(0.024,0.008,0.54),Color("607888"),0.6)
	Geo.box(self,Vector3(0.7,0.012,0),Vector3(13,0.008,0.045),Color("d4ad54"))
	Geo.text(self,"PROVOZNÍ ZÓNA  /  A01–B02",Vector3(0.2,0.028,0.8),50,0.004,Color("c6e9ec")).rotation_degrees.x = -90
	Geo.text(self,"ADMINISTRACE",Vector3(-4.5,2.7,2),44,0.004)

func sync_state():
	if game == null or game.sim.state.is_empty(): return
	for id in devices:
		var object = devices[id]
		var s = game.sim.state
		match object.kind:
			"server":
				var status = "Healthy"
				if not s.hosts[id].online: status = "Offline"
				elif not preload("res://scripts/simulation/PhysicalOperations.gd").link_ok(s,id): status = "Warning"
				elif id=="NAS-01": status = s.raid.health
				elif id=="PVE-01": status = s.zfs.health
				if status=="Healthy" and s.storage.used>=s.storage.capacity: status = "Critical"
				object.set_status(status)
			"disk":
				var disk = s.zfs.disks[object.slot] if object.pool=="ZFS" else s.disks[object.slot]
				var host_id = "PVE-01" if object.pool=="ZFS" else "NAS-01"
				object.set_status(disk.health if s.hosts[host_id].online else "Offline")
				object.visual.position.z = -0.08 if disk.health=="Missing" else 0.0
				object.visual.get_child(0).visible = disk.health!="Missing"
			"cable":
				var plugged = s.world.devices[object.slot].cable_connected
				cable_meshes[object.slot].visible = plugged
				object.set_status("Healthy" if plugged and preload("res://scripts/simulation/PhysicalOperations.gd").link_ok(s,object.slot) else "Warning")
			"supply": object.set_status("Healthy" if s.world.devices[object.slot].power_connected else "Offline")
	for port in port_objects:
		var used = false
		for d in game.sim.state.world.devices.values():
			if d.cable_connected and int(d.port)==int(port.slot): used = true
		port.set_status("Healthy" if used else "Offline")
	var lines = ["PROVOZNÍ DOHLED / ŽIVÁ DATA"]
	for vm in game.sim.state.vms.values():
		if vm.get("exists",false): lines.append("%s  %s  /  %s" % [vm.id,vm.name,"BĚŽÍ" if vm.status=="Running" else "VYPNUTO"])
	lines.append("RAID: %s  %d%%   /   ZFS: %s" % [game.sim.state.raid.health,game.sim.state.raid.progress,game.sim.state.zfs.health])
	lines.append("POOL: %d / %d GB" % [game.sim.state.storage.used,game.sim.state.storage.capacity])
	monitoring.text = "\n".join(lines)

func _process(delta):
	if game == null or game.sim.state.is_empty(): return
	for fan in fans:
		if game.sim.state.hosts[fan.host].online: fan.node.rotate_z(delta*4.5)
