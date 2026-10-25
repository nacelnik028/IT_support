extends Node3D

const Geo = preload("res://scripts/world/Geometry.gd")
const Item = preload("res://scripts/world/Interactable3D.gd")
const Visuals = preload("res://scripts/world/WorldVisuals.gd")
var game
var devices: Dictionary = {}
var player
var monitoring: Label3D
var fans: Array = []
var cable_meshes: Dictionary = {}
var port_objects: Array = []
var door_open = false
var door_tween: Tween
var door_panels: Array = []
var door_status: Label3D
var door_feedback = ""
var academy_targets: Dictionary = {}
var batched_instances = 0
var carried_disk: Node3D
var carried_label: Label3D
var racks: Array = []
var workstations: Array = []
var visuals = Visuals.new()
var screen_time = 0.0
var training_zone

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
	build_academy()
	player = preload("res://scenes/world/Player.tscn").instantiate()
	add_child(player)
	player.position = Vector3(0,0.02,3)
	training_zone = preload("res://scripts/world/TrainingZone.gd").new()
	training_zone.player = player
	add_child(training_zone)
	carried_disk = Node3D.new()
	player.camera.add_child(carried_disk)
	carried_disk.position = Vector3(0.32,-0.3,-0.65)
	carried_disk.rotation_degrees = Vector3(-15,-10,8)
	Geo.box(carried_disk,Vector3.ZERO,Vector3(0.2,0.045,0.3),Color("9aabb4"),0.75)
	Geo.box(carried_disk,Vector3(0,0,0.15),Vector3(0.21,0.055,0.025),Color("213544"),0.6)
	carried_label = Geo.text(carried_disk,"",Vector3(0,0.025,0),20,0.00035,Color("182432"))
	carried_label.rotation_degrees.x = -90
	carried_disk.visible = false
	var screen = item("MONITOR","Monitorovací konzole — živý stav","monitor",Vector3(4.5,2.5,-6.65),Vector3(5.1,1.5,0.12),"Storage")
	Geo.box(screen.visual,Vector3(0,0,0.07),Vector3(4.95,1.35,0.03),Color("07313b"),0,0.25)
	monitoring = Geo.text(screen.visual,"NORTHSTAR / PROVOZNÍ DOHLED",Vector3(0,0,0.095),38,0.003)
	visuals.build(self)
	batched_instances = Geo.batch_static(self)

func build_room():
	Geo.solid(self,Vector3(0,-0.16,0),Vector3(18,0.3,14),Color("343f4b"),0.25)
	Geo.solid(self,Vector3(0,2,-7),Vector3(18,4,0.25),Color("293844"))
	Geo.solid(self,Vector3(-9,2,0),Vector3(0.25,4,14),Color("374753"))
	# A real opening joins the server room and the training room.
	Geo.solid(self,Vector3(9,2,-2.5),Vector3(0.25,4,9),Color("374753"))
	Geo.solid(self,Vector3(9,2,6),Vector3(0.25,4,2),Color("374753"))
	Geo.solid(self,Vector3(9,3.5,3.5),Vector3(0.25,1,3),Color("374753"))
	Geo.solid(self,Vector3(-8.5,2,7),Vector3(1,4,0.25),Color("293844"))
	Geo.solid(self,Vector3(4,2,7),Vector3(10,4,0.25),Color("293844"))
	Geo.solid(self,Vector3(-4.5,3.65,7),Vector3(7,0.7,0.25),Color("293844"))
	Geo.solid(self,Vector3(-4.5,0.45,7),Vector3(7,0.9,0.25),Color("293844"))
	Geo.box(self,Vector3(0,4,0),Vector3(18,0.15,14),Color("192530"))
	for x in range(-9,10): Geo.box(self,Vector3(x,0.002,0),Vector3(0.012,0.005,14),Color("1a2933"))
	for z in range(-7,8): Geo.box(self,Vector3(0,0.002,z),Vector3(18,0.005,0.012),Color("1a2933"))
	for x in [-5,0,5]:
		for z in [-4,0,4]:
			Geo.box(self,Vector3(x,3.82,z),Vector3(0.85,0.1,2.05),Color("657d89"),0.5)
			Geo.box(self,Vector3(x,3.75,z),Vector3(0.65,0.025,1.85),Color("b8e4ee"),0,0.65)
		var light = OmniLight3D.new()
		light.position = Vector3(x,3,0)
		light.light_color = Color("bee7ff")
		light.light_energy = 2.5
		light.omni_range = 10
		add_child(light)
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("142330")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("9bb1c4")
	env.environment.ambient_light_energy = 0.85
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
	rack.set_meta("rack_id",id)
	racks.append(rack)
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
	workstations.append({"at":at,"id":id,"console":console})
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
	cable_meshes[id].set_meta("dynamic",true)
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

func build_switch(at: Vector3 = Vector3(-6.1,1.5,-5.8), prefix: String = ""):
	var sw = item(prefix+"SW-CORE",("Cvičný " if prefix!="" else "")+"SW-CORE — fyzické porty","switch",at,Vector3(2.8,0.5,0.8),"Síť")
	sw.laboratory = prefix!=""
	Geo.text(sw.visual,"SW-CORE  /  12 PORTŮ",Vector3(0,0.16,0.415),32,0.002)
	for i in 12:
		var port = item(prefix+"PORT:"+str(i+1),"SW-CORE — port "+str(i+1),"port",at+Vector3(-1.2+i*0.215,-0.07,0.48),Vector3(0.17,0.13,0.1),"Síť")
		port.slot = str(i+1)
		port.laboratory = prefix!=""
		Geo.text(port.visual,str(i+1),Vector3(0,-0.1,0.06),24,0.0016)
		port_objects.append(port)
	Geo.solid(self,at+Vector3(0,-0.85,0),Vector3(3,1.3,0.85),Color("182733"),0.5)

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
	for x in range(0,9):
		Geo.box(self,Vector3(x,1.55,6.84),Vector3(0.045,3.1,0.06),Color("5e788a"),0.7)
	Geo.box(self,Vector3(0,0.38,6.8),Vector3(17.7,0.045,0.04),Color("267c94"),0,0.4)
	Geo.box(self,Vector3(0,2.9,6.8),Vector3(17.7,0.045,0.04),Color("267c94"),0,0.4)
	Geo.text(self,"01  /  IT OPERATIONS",Vector3(-5.4,2.4,6.75),52,0.004).rotation.y = PI
	# Inset entrance door and safety signage, kept inside the bounded building.
	Geo.box(self,Vector3(4,1.35,6.78),Vector3(1.55,2.7,0.12),Color("172c39"),0.5)
	Geo.box(self,Vector3(4.55,1.2,6.69),Vector3(0.06,0.32,0.05),Color("c6d6df"),0.8)
	Geo.text(self,"VSTUP / PROVOZ",Vector3(4,2.9,6.65),36,0.003,Color("79e4bc")).rotation.y = PI

func build_academy():
	Geo.solid(self,Vector3(15,-0.16,0),Vector3(12,0.3,14),Color("586271"),0.15)
	Geo.solid(self,Vector3(21,2,0),Vector3(0.25,4,14),Color("354b58"))
	for z in [-7,7]: Geo.solid(self,Vector3(15,2,z),Vector3(12,4,0.25),Color("405768"))
	Geo.box(self,Vector3(15,4,0),Vector3(12,0.15,14),Color("24333c"))
	for x in range(10,21): Geo.box(self,Vector3(x,0.002,0),Vector3(0.01,0.005,14),Color("354551"))
	for z in range(-7,8): Geo.box(self,Vector3(15,0.002,z),Vector3(12,0.005,0.01),Color("354551"))
	var door = item("ACADEMY-DOOR","Dveře — IT Training Academy","door",Vector3(9,1.4,3.5),Vector3(0.15,2.8,2.9))
	var door_label = Geo.text(door.visual,"IT TRAINING\nACADEMY\n[E] OTEVŘÍT",Vector3(-0.09,0.35,0),44,0.003)
	door_label.rotation.y = -PI/2
	Geo.box(self,Vector3(8.82,2.95,3.5),Vector3(0.035,0.06,3.15),Color("f4c472"),0,1)
	for side in [-1,1]:
		var panel_id = "DOOR-CONTROL-"+("OPS" if side<0 else "ACADEMY")
		var panel = item(panel_id,"Otevřít dveře — IT Training Academy","door",Vector3(9+side*0.28,1.35,1.65),Vector3(0.14,0.48,0.32))
		var face = Node3D.new()
		panel.visual.add_child(face)
		face.rotation.y = side*PI/2
		face.position.x = side*0.08
		Geo.box(face,Vector3.ZERO,Vector3(0.27,0.4,0.025),Color("073e47"),0,0.6)
		var words = Geo.text(face,"DVEŘE\n[E] OTEVŘÍT",Vector3(0,0,0.018),28,0.0014)
		door_panels.append({"object":panel,"label":words})
	door_status = Geo.text(self,"IT TRAINING ACADEMY",Vector3(8.8,3.25,3.5),36,0.003)
	door_status.rotation.y = -PI/2
	Geo.text(self,"IT TRAINING ACADEMY",Vector3(15,3.2,-6.8),64,0.005,Color("ffd392"))
	Geo.text(self,"UČÍM SE  /  PROCVIČOVÁNÍ  /  ZKOUŠKA",Vector3(15,2.75,-6.8),36,0.0035)
	for x in [12,18]:
		for z in [-4,0,4]:
			Geo.box(self,Vector3(x,3.8,z),Vector3(0.85,0.08,2),Color("8e908b"),0.4)
			Geo.box(self,Vector3(x,3.74,z),Vector3(0.65,0.03,1.8),Color("f2dfb8"),0,0.5)
		var light = OmniLight3D.new()
		light.position = Vector3(x,3,0)
		light.light_color = Color("ffe5bb")
		light.light_energy = 2
		light.omni_range = 9
		add_child(light)
	build_workstation(Vector3(11.2,0,0.6),"TRAIN-PC-PVE","Proxmox")
	build_workstation(Vector3(14,0,0.6),"TRAIN-PC-HV","Hyper-V")
	build_workstation(Vector3(18,0,3.5),"EXAM-PC","Trénink")
	for id in ["TRAIN-PC-PVE","TRAIN-PC-HV"]: devices[id].laboratory = true
	for entry in [[11.5,"PVE-TRAIN-01","PVE-01","Proxmox"],[14.7,"HV-TRAIN-01","HV-01","Hyper-V"],[18.0,"RAID-TRAIN-01","NAS-01","Storage"]]:
		build_rack(Vector3(entry[0],0,-3.5),"LAB")
		var object = item(entry[1],entry[1]+" — cvičný server","server",Vector3(entry[0],1.4,-3.5),Vector3(1.25,0.4,0.95),entry[3])
		object.device_id = entry[2]
		object.laboratory = true
		Geo.text(object.visual,entry[1],Vector3(0,0.03,0.49),32,0.002)
		academy_targets[entry[2]] = object
	# RAID station uses the exact same physical slots of the lesson's model.
	for i in 8:
		var disk = item("TRAIN-RAID:"+str(i),"Cvičný NAS — slot"+str(i),"disk",Vector3(17.55+(i%4)*0.3,1.38-floorf(float(i)/4)*0.23,-2.96),Vector3(0.26,0.18,0.1),"Storage")
		disk.slot = str(i)
		disk.pool = "RAID"
		disk.laboratory = true
		Geo.text(disk.visual,str(i),Vector3(0,0,0.06),26,0.0015)
	for i in 2:
		var slot = "A" if i==0 else "B"
		var disk = item("TRAIN-ZFS:"+slot,"Cvičný PVE — slot"+slot,"disk",Vector3(11.25+i*0.5,1.35,-2.96),Vector3(0.26,0.18,0.1),"Storage")
		disk.slot = slot
		disk.pool = "ZFS"
		disk.laboratory = true
		Geo.text(disk.visual,slot,Vector3(0,0,0.06),26,0.0015)
	build_switch(Vector3(19.1,1.5,-5.8),"TRAIN-")
	var spares = item("TRAIN-SPARES","Laboratorní skříň — náhradní disky","spares",Vector3(10,0.9,-5.5),Vector3(1,1.8,0.65),"Storage")
	spares.laboratory = true
	Geo.text(spares.visual,"SERVIS / LAB",Vector3(0,0.5,0.34),32,0.0025)
	var instructor = item("INSTRUCTOR","Virtuální instruktor — lekce a výsledky","instructor",Vector3(19.7,1.5,-0.3),Vector3(0.8,1.5,0.25),"Trénink")
	Geo.box(instructor.visual,Vector3(0,0.55,0.15),Vector3(0.4,0.3,0.06),Color("5de6d1"),0,0.8)
	Geo.text(instructor.visual,"INSTRUKTOR\n[E] LEKCE",Vector3(0,0,0.14),36,0.0025)
	Geo.text(self,"SÍŤOVÁ LABORATOŘ",Vector3(19.1,2.15,-5.3),32,0.003)
	Geo.text(self,"ZKUŠEBNÍ PRACOVIŠTĚ",Vector3(18,2.4,3.4),40,0.003)

func doorway_occupied() -> bool:
	# Swept leaf volume expanded by the player's capsule, not a broad radius
	# that would incorrectly reject a person standing beside a wall control.
	return absf(player.position.x-9.0)<0.48 and player.position.z>1.7 and player.position.z<5.3 and player.position.y<2.9

func toggle_door() -> bool:
	if door_tween and door_tween.is_running(): return false
	if door_open and doorway_occupied():
		door_feedback = "PRŮCHOD OBSAZENÝ"
		update_door_controls()
		return false
	move_door(not door_open)
	return true

func move_door(opened: bool):
	if door_tween and door_tween.is_running(): door_tween.kill()
	door_open = opened
	door_feedback = ""
	door_tween = create_tween()
	door_tween.tween_property(devices["ACADEMY-DOOR"],"position:z",6.5 if opened else 3.5,0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	update_door_controls()

func update_door_controls():
	for control in door_panels:
		control.object.caption = ("Zavřít" if door_open else "Otevřít")+" dveře — IT Training Academy"
		control.label.text = "DVEŘE\n[E] "+("ZAVŘÍT" if door_open else "OTEVŘÍT")
		control.object.set_status("Warning" if door_feedback!="" else "Healthy")
	door_status.text = door_feedback if door_feedback!="" else "IT TRAINING ACADEMY / "+("OTEVŘENO" if door_open else "ZAVŘENO")

func _physics_process(_delta):
	# Reopen if somebody walks into the opening during a closing animation.
	if not door_open and door_tween and door_tween.is_running() and doorway_occupied(): move_door(true)

func sync_state():
	if game == null or game.sim.state.is_empty(): return
	carried_disk.visible = game.sim.state.world.held!=""
	if carried_disk.visible: carried_label.text = game.sim.state.world.stock[game.sim.state.world.held].serial
	for id in devices:
		var object = devices[id]
		var s = game.training_sim.state if object.laboratory else game.main_sim.state
		match object.kind:
			"server":
				id = object.device_id
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
				object.outline.visible = s.world.identified.get(object.pool+":"+object.slot,false) or player.target==object
			"cable":
				var plugged = s.world.devices[object.slot].cable_connected
				cable_meshes[object.slot].visible = plugged
				object.set_status("Healthy" if plugged and preload("res://scripts/simulation/PhysicalOperations.gd").link_ok(s,object.slot) else "Warning")
			"supply": object.set_status("Healthy" if s.world.devices[object.slot].power_connected else "Offline")
	for port in port_objects:
		var used = false
		var port_state = game.training_sim.state if port.laboratory else game.main_sim.state
		for d in port_state.world.devices.values():
			if d.cable_connected and int(d.port)==int(port.slot): used = true
		port.set_status("Healthy" if used else "Offline")
	var lines = ["PROVOZNÍ DOHLED / ŽIVÁ DATA"]
	var main = game.main_sim.state
	for vm in main.vms.values():
		if vm.get("exists",false): lines.append("%s  %s  /  %s" % [vm.id,vm.name,"BĚŽÍ" if vm.status=="Running" else "VYPNUTO"])
	var states = {"Healthy":"V POŘÁDKU","Degraded":"DEGRADOVANÉ","Failed":"SELHÁNÍ","Recovering":"OBNOVA"}
	lines.append("RAID: %s  %d%%   /   ZFS: %s" % [states.get(main.raid.health,main.raid.health),main.raid.progress,states.get(main.zfs.health,main.zfs.health)])
	lines.append("POOL: %d / %d GB" % [main.storage.used,main.storage.capacity])
	monitoring.text = "\n".join(lines)

func _process(delta):
	if game == null or game.sim.state.is_empty(): return
	screen_time += delta
	if screen_time>=0.5:
		screen_time = 0.0
		visuals.sync(game)
	for fan in fans:
		if game.main_sim.state.hosts[fan.host].online: fan.node.rotate_z(delta*4.5)

func _exit_tree():
	visuals.release()
	Geo.materials.clear()
	Geo.meshes.clear()
	Geo.metal_normal = null
