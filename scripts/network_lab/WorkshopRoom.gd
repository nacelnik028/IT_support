extends Node3D

const Geo = preload("res://scripts/world/Geometry.gd")
const Arch = preload("res://scripts/world/WorldArchitecture.gd")
const AMBER = Color("f3c476")
const DARK = Color("24343e")
var room
var world
var targets := {}
var labels := {}
var cables: Node3D
var signature := ""
var hinge: Node3D
var door: AnimatableBody3D
var opened := false
var angle := 0.0
var in_workshop := false
var tester_visual: Node3D
var tester_display: Label3D

func item(id: String, title: String, at: Vector3, size_value: Vector3, yaw := 0.0):
	var object = world.item("WORK-"+id,title,"network_lab",at,size_value,"work:"+id)
	object.reparent(self)
	object.rotation.y = yaw
	targets[id] = object
	room.targets["work:"+id] = object
	return object

func sign_at(words: String, at: Vector3, yaw := 0.0, pixel := 0.003):
	return room.lab_sign(self,words,at,yaw,pixel)

func table(at: Vector3, size_value: Vector2):
	Geo.solid(self,at+Vector3(0,0.85,0),Vector3(size_value.x,0.12,size_value.y),DARK,0.4)
	for x in [-1,1]:
		for z in [-1,1]:
			Geo.solid(self,at+Vector3(x*(size_value.x/2-0.13),0.42,z*(size_value.y/2-0.13)),Vector3(0.1,0.84,0.1),Color("839498"),0.5)

func build(owner_room):
	room = owner_room
	world = room.world
	name = "NetworkWorkshop"
	Geo.solid(self,Vector3(4,-0.16,-35),Vector3(14,0.3,12),Color("34434d"))
	Geo.box(self,Vector3(4,3.95,-35),Vector3(14,0.14,12),Color("51636a"))
	for x in [-3,11]: Geo.solid(self,Vector3(x,2,-35),Vector3(0.24,4,12),Color("778d94"))
	Geo.solid(self,Vector3(4,2,-41),Vector3(14,4,0.24),Color("778d94"))
	for z in [-31,-33,-35,-37,-39]:
		Geo.box(self,Vector3(4,0.002,z),Vector3(13.8,0.006,0.024),Color("68716b"))
	for at in [Vector3(1,3.45,-32.5),Vector3(7,3.45,-32.5),Vector3(1,3.45,-38),Vector3(7,3.45,-38)]:
		Geo.box(self,at+Vector3(0,0.38,0),Vector3(2.6,0.06,0.35),Color("f4eed9"),0,0.7)
		var lamp := OmniLight3D.new()
		lamp.position = at
		lamp.light_energy = 2.3
		lamp.omni_range = 7
		add_child(lamp)
	Arch.portal(self,Vector3(8,0,-29),0,2.4,AMBER)
	for face in [-1,1]:
		var title := "TRÉNINKOVÁ DÍLNA" if face>0 else "SÍŤOVÁ UČEBNA"
		var panel = Arch.portal_sign(self,title,"05 / servisní tickety" if face>0 else "05 / návrat k lekci",AMBER,3.1)
		panel.position = Vector3(8,3.64,-29+face*0.34)
		panel.rotation.y = 0.0 if face>0 else PI
		var control = item("door_"+str(face),"Dveře dílny · otevřít / zavřít",Vector3(9.78,1.35,-29+face*0.38),Vector3(0.28,0.4,0.1),0.0 if face>0 else PI)
		Arch.control_surround(control.visual,AMBER)
		room.lab_sign(control.visual,"DVEŘE",Vector3(0,0,0.065),0,0.0018)
	hinge = Node3D.new()
	hinge.set_meta("dynamic",true)
	# Mount the pivot behind the stepped jamb: a thick leaf rotating at the
	# partition centre intersected its own frame throughout most of the sweep.
	hinge.position = Vector3(9.16,0,-29.43)
	add_child(hinge)
	door = AnimatableBody3D.new()
	door.sync_to_physics = false
	hinge.add_child(door)
	door.position = Vector3(-1.16,1.44,0)
	Geo.collision(door,Vector3(2.28,2.88,0.27))
	Geo.box(door,Vector3.ZERO,Vector3(2.28,2.88,0.16),DARK)
	Arch.sliding_leaf(door,2.28,AMBER,"05","DÍLNA / UČEBNA")
	table(Vector3(5.7,0,-31.5),Vector2(2.5,1.0))
	var desk = item("desk","Servisní stůl · výběr ticketu a historie",Vector3(5.7,1.38,-31.6),Vector3(1.95,0.75,0.13))
	room.lab_sign(desk.visual,"SERVISNÍ STŮL / 05\nTickety A–H · volný trénink · výsledky",Vector3(0,0,0.08),0,0.0026)
	Arch.board_stand(desk,1.95)
	item("tester","Tester trasy · vzít / vrátit",Vector3(6.6,1.0,-31.3),Vector3(0.3,0.22,0.25)).visual.hide()
	tester_visual = Node3D.new()
	tester_visual.set_meta("dynamic",true)
	add_child(tester_visual)
	Geo.box(tester_visual,Vector3.ZERO,Vector3(0.22,0.3,0.07),AMBER)
	Geo.box(tester_visual,Vector3(0,0.035,0.04),Vector3(0.2,0.22,0.015),Color("07151c"))
	tester_display = room.lab_sign(tester_visual,"TESTER TRASY",Vector3(0,0.04,0.052),0,0.00065)
	tester_display.font_size = 32
	tester_display.width = 290
	tester_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sign_at("TESTER TRASY\nVezmi · konektor · port · změř",Vector3(6.6,1.3,-31.25),0,0.0018)
	build_rack()
	for row in [["pc04","PC 04",-33.4],["pc02","PC 02 / KONTROLA",-35.6],["printer","TISKÁRNA",-37.8]]:
		table(Vector3(-1.1,0,row[2]),Vector2(1.6,1.65))
		var client = item(row[0],row[1]+" · konektor",Vector3(-0.22,1.2,row[2]),Vector3(0.28,0.23,0.12),PI/2)
		Geo.box(client.visual,Vector3(0,0,0.072),Vector3(0.13,0.08,0.02),Color("07151c"))
		var screen = item("screen_"+row[0],row[1]+" · diagnostika",Vector3(-1.12,1.38,row[2]),Vector3(1.03,0.64,0.12),PI/2)
		labels[row[0]] = room.lab_sign(screen.visual,"",Vector3(0,0,0.08),0,0.0021)
		Geo.box(self,Vector3(-1.1,1.02,row[2]),Vector3(0.16,0.22,0.3),Color("97a6aa"))
		var socket = item("socket_"+row[0],row[1]+" · zásuvka",Vector3(-2.81,1.2,row[2]),Vector3(0.6,0.34,0.12),PI/2)
		room.lab_sign(socket.visual,"Z / "+row[0].to_upper(),Vector3(0,0,0.08),0,0.0018)
		Geo.tube(self,[Vector3(-0.3,1.17,row[2]),Vector3(-0.6,0.7,row[2]),Vector3(-2.7,0.7,row[2]),Vector3(-2.7,1.2,row[2])],0.017,Color("43dad0"))
		var patch: Vector3 = targets["patch_"+row[0]].position
		Geo.tube(self,[Vector3(-2.7,1.2,row[2]),Vector3(-2.65,0.62,row[2]),Vector3(-2.65,0.62,patch.z),Vector3(-0.6,0.62,patch.z),Vector3(-0.6,2.02,patch.z)],0.014,Color("a5bac0"))
		if row[0]=="printer":
			Geo.solid(self,Vector3(-1.12,1.05,row[2]),Vector3(0.65,0.32,0.72),Color("bdc8c6"))
			Geo.box(self,Vector3(-0.8,1.2,row[2]),Vector3(0.04,0.06,0.45),DARK)
	var diagnostics = item("diagnostics","Diagnostický pult · měření a analyzátor",Vector3(4.7,1.48,-39),Vector3(2.2,0.8,0.16))
	Arch.board_stand(diagnostics,2.2)
	room.lab_sign(diagnostics.visual,"DIAGNOSTIKA / 05\nZdroj · cíl · výsledek měření",Vector3(0,0,0.1),0,0.0027)
	sign_at("SÍŤOVÁ TRÉNINKOVÁ DÍLNA\nSamostatná pracovní síť / offline model",Vector3(4,3.15,-40.8),0,0.0043)
	var ap = item("ap","Cvičný AP · poloha a pokrytí",Vector3(10.4,2.2,-35),Vector3(0.8,0.7,0.28),-PI/2)
	room.lab_sign(ap.visual,"AP / DÍLNA",Vector3(0,0,0.16),0,0.002)
	for point in [["near","W1 / U AP",-34.6],["far","W2 / ZADNÍ ČÁST",-39.6]]:
		var sensor = item(point[0],point[1]+" · měření Wi-Fi",Vector3(8.7,1.25,point[2]),Vector3(1.05,0.38,0.12),-PI/2)
		room.lab_sign(sensor.visual,point[1],Vector3(0,0,0.08),0,0.0021)
		Arch.board_stand(sensor,1.05)
	Geo.box(self,Vector3(-2.69,0.68,-35),Vector3(0.13,0.18,11.3),Color("87969a"))
	cables = Node3D.new()
	cables.set_meta("dynamic",true)
	add_child(cables)

func toggle():
	opened = not opened

func _physics_process(delta):
	if not is_instance_valid(world.player) or world.game==null: return
	var p: Vector3 = world.player.global_position
	if p.z< -29.2: in_workshop = true
	elif p.z> -28.8: in_workshop = false
	var session = world.game.workshop()
	if session.tester.held and (not in_workshop or not world.game.game_mode.is_network_lab()): session.tester.put_back()
	if session.tester.held:
		var controller = session.tester.hand.get_ref() if session.tester.hand!=null else null
		if is_instance_valid(controller) and not controller.get_has_tracking_data():
			session.tester.release_hand()
			controller = null
		var anchor: Node3D = world.player.camera
		var owner_shell = world.get_parent()
		if "vr_active" in owner_shell and owner_shell.vr_active and is_instance_valid(owner_shell.xr_rig) and owner_shell.xr_rig.active: anchor = owner_shell.xr_rig.head
		if is_instance_valid(controller): anchor = controller
		tester_visual.global_transform = anchor.global_transform
		tester_visual.position += tester_visual.basis*(Vector3(0,0,-0.14) if is_instance_valid(controller) else Vector3(-0.26,-0.18,-0.5))
	else:
		tester_visual.transform = Transform3D(Basis.IDENTITY,Vector3(6.6,1.04,-31.3))
	tester_display.text = session.tester.screen(session.network) if session.tester.held else "TESTER TRASY\nVezmi u servisního stolu"
	var desired := -PI/2 if opened else 0.0
	# A closing leaf waits while the player occupies any part of its sweep.
	if not opened and p.x>6.4 and p.x<9.65 and p.z> -32.1 and p.z< -28.5: return
	angle = move_toward(angle,desired,delta*1.5)
	hinge.rotation.y = angle

func sync(model):
	targets.ap.position = model.AP_POSITIONS[model.ap_position]
	var active: bool = room.workshop.in_workshop and world.game.game_mode.is_network_lab()
	for key in targets: targets[key].set_guided(active and key in model.last_path)
	for id in ["pc04","pc02","printer"]:
		labels[id].text = model.device_status(id)
		targets[id].set_status("Healthy" if model.link(id) else "Offline")
		targets[id].set_guided(model.cable==id)
	for port in range(1,9):
		var id := str(port)
		var occupied: String = model.occupant(port)
		labels[id].text = "%02d\n%s" % [port,"×" if port in model.bad_ports else "L%d" % model.vlans[port] if occupied!="" else "—"]
		targets[id].set_status("Failed" if port in model.bad_ports else "Healthy" if occupied!="" else "Offline")
	var current := str(model.ports)+str(model.last_path)
	if signature==current: return
	signature = current
	for child in cables.get_children():
		cables.remove_child(child)
		child.queue_free()
	for id in ["pc04","pc02","printer"]:
		if model.ports[id]==0: continue
		var a: Vector3 = targets["patch_"+id].position+Vector3(0.1,0,0)
		var b: Vector3 = targets[str(model.ports[id])].position+Vector3(0.1,0,0)
		Geo.tube(cables,[a,a+Vector3(0.13,0,0),b+Vector3(0.13,0,0),b],0.014,Color("43dad0") if id in model.last_path else AMBER)

func build_rack():
	for x in [-0.8,1.25]: Geo.solid(self,Vector3(0,1.4,-31.8+x),Vector3(1.05,2.8,0.1),DARK)
	for y in [0.12,2.73]: Geo.solid(self,Vector3(0,y,-31.58),Vector3(1.1,0.13,2.17),DARK)
	for row in [["patch","PATCH / ZÁSUVKY",2.05],["switch","SWITCH / VLAN",1.52],["router","BRÁNA / DHCP",0.92]]:
		var object = item(row[0],row[1],Vector3(0.48,row[2],-31.58),Vector3(1.93,0.33,0.16),PI/2)
		room.lab_sign(object.visual,row[1],Vector3(0,0.1,0.1),0,0.0023)
	for port in range(1,9):
		var target = item(str(port),"Dílna · switch port %02d" % port,Vector3(0.63,1.47,-31.58-(port-4.5)*0.225),Vector3(0.195,0.15,0.13),PI/2)
		Geo.box(target.visual,Vector3(0,0,0.075),Vector3(0.10,0.06,0.018),Color("08151b"))
		labels[str(port)] = room.lab_sign(target.visual,"%02d" % port,Vector3(0,-0.17,0.082),0,0.0015)
	for index in 3:
		var id: String = ["pc04","pc02","printer"][index]
		var patch = item("patch_"+id,"Patch / "+id.to_upper(),Vector3(0.64,2.02,-31.2-index*0.4),Vector3(0.3,0.2,0.13),PI/2)
		room.lab_sign(patch.visual,id.to_upper(),Vector3(0,-0.14,0.08),0,0.0016)
