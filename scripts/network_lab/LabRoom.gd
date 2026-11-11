extends Node3D

const Geo = preload("res://scripts/world/Geometry.gd")
const Architecture = preload("res://scripts/world/WorldArchitecture.gd")
const Network = preload("res://scripts/network_lab/LabNetwork.gd")
const ACCENT = Color("43dad0")
const STEEL = Color("3e5562")
const WALL = Color("acbec0")
const DARK = Color("172e3a")
const BOUNDS = AABB(Vector3(-3,-0.4,-41),Vector3(14,4.5,25))
const SPAWN = Vector3(4,0.02,-17.2)
const PORTAL_X = 4.0

var world
var targets := {}
var labels := {}
var cables: Node3D
var board_ports := {}
var board_links := {}
var flow: Label3D
var handover: Label3D
var cell_lamps: Array[MeshInstance3D]
var handset: Node3D
var sim_tokens: Array[MeshInstance3D]
var cable_signature := ""
var workshop

func contains_player() -> bool:
	if not is_instance_valid(world.player): return false
	var p: Vector3 = world.player.global_position
	var edge := -15.84 if world.game!=null and world.game.game_mode.is_network_lab() else -16.16
	return p.z<edge and p.x>-3 and p.x<11 and p.z>-41 and p.y>-0.4 and p.y<4.1

func lab_sign(parent: Node3D, words: String, at: Vector3, yaw: float = 0.0, scale_value: float = 0.0035) -> Label3D:
	var label := Geo.text(parent,words,at,34,scale_value,Color("e4f8f5"))
	label.rotation.y = yaw
	return label

func item(id: String, caption: String, at: Vector3, dimensions: Vector3, yaw: float = 0.0):
	var object = world.item("NET-"+id,caption,"network_lab",at,dimensions,id)
	object.reparent(self)
	object.rotation.y = yaw
	targets[id] = object
	return object

func build(owner_world):
	world = owner_world
	name = "NetworkLab"
	Geo.solid(self,Vector3(4,-0.16,-22.5),Vector3(14,0.3,13),Color("455762"))
	Geo.box(self,Vector3(4,3.95,-22.5),Vector3(14,0.14,13),Color("668087"))
	for x in [-3,11]:
		Geo.solid(self,Vector3(x,2,-22.5),Vector3(0.24,4,13),WALL)
		Geo.box(self,Vector3(x+(-0.15 if x>4 else 0.15),0.28,-22.5),Vector3(0.06,0.45,12.8),STEEL)
	# The shared partition has a real 2.4 m opening at x=8.
	Geo.solid(self,Vector3(1.9,2,-29),Vector3(9.8,4,0.24),WALL)
	Geo.solid(self,Vector3(10.1,2,-29),Vector3(1.8,4,0.24),WALL)
	Geo.solid(self,Vector3(8,3.5,-29),Vector3(2.4,1,0.24),WALL)
	for x in [2.35,5.65]:
		Geo.box(self,Vector3(x,0.004,-22.5),Vector3(0.045,0.009,12.65),ACCENT,0,0.25)
	for x in range(-2,11,2):
		Geo.box(self,Vector3(x,0.001,-22.5),Vector3(0.012,0.004,12.8),Color("304653"))
	for z in [-18,-20,-22,-24,-26,-28]:
		Geo.box(self,Vector3(4,0.001,z),Vector3(13.8,0.004,0.012),Color("304653"))
	for at in [Vector3(0.15,3.3,-20.8),Vector3(-0.5,3.3,-24.4),Vector3(8.5,3.3,-22.5),Vector3(4,3.3,-27.1)]:
		Geo.box(self,at+Vector3.UP*0.54,Vector3(2.2,0.06,0.44),Color("c3f4ef"),0,0.8)
		var light := OmniLight3D.new()
		light.position = at
		light.light_color = Color("e1f7fa")
		light.light_energy = 2.4
		light.omni_range = 7
		add_child(light)
	build_entry()
	build_rack()
	build_clients()
	build_terminal()
	build_demo()
	cables = Node3D.new()
	cables.name = "PatchCables"
	cables.set_meta("dynamic",true)
	add_child(cables)
	workshop = preload("res://scripts/network_lab/WorkshopRoom.gd").new()
	add_child(workshop)
	workshop.build(self)

func build_entry():
	var plan = item("plan","Plán učebny a volba ročníku",Vector3(7.23,1.72,-18.05),Vector3(2.3,1.04,0.13),-PI/2)
	lab_sign(plan.visual,"05 / SÍŤOVÁ UČEBNA\nServisní rack · Diagnostika\nTréninková dílna → vzadu vpravo\nRočník 1 / 2 · Výuka / Praxe / Zkouška",Vector3(0,0.08,0.082),0.0,0.0024)
	Architecture.board_stand(plan,2.3)
	for year in [1,2]:
		var control = item("year"+str(year),"%d. ročník" % year,Vector3(7.12,1.19,-18.6+(year-1)*1.11),Vector3(1.0,0.23,0.10),-PI/2)
		lab_sign(control.visual,"%d. ROČNÍK" % year,Vector3(0,0,0.066),0.0,0.0027)
	Geo.box(self,Vector3(-0.4,2.42,-16.2),Vector3(2.9,0.4,0.08),DARK)
	lab_sign(self,"SERVISNÍ RACK  →",Vector3(-0.4,2.42,-16.25),PI,0.0032)
	Geo.box(self,Vector3(4,3,-20),Vector3(5.8,0.9,0.12),DARK)
	for x in [1.7,6.3]: Geo.box(self,Vector3(x,3.68,-20),Vector3(0.06,0.5,0.06),STEEL,0.6)
	lab_sign(self,"05 / SÍŤOVÁ UČEBNA\n← Servisní rack    Diagnostika ↑\nTréninková dílna ↗",Vector3(4,3.0,-19.92),0,0.004)

func build_rack():
	var rack := Node3D.new()
	rack.position = Vector3(0.18,0,-21.0)
	rack.rotation.y = PI/2
	add_child(rack)
	for x in [-1.04,1.04]:
		Geo.solid(rack,Vector3(x,1.36,0),Vector3(0.1,2.72,1.1),STEEL,0.55)
		for y in range(3,26):
			Geo.box(rack,Vector3(x,0.1*y,0.56),Vector3(0.035,0.022,0.016),Color("9aabaf"),0.5)
	for y in [0.12,2.63]:
		Geo.solid(rack,Vector3(0,y,0),Vector3(2.17,0.15,1.14),DARK,0.6)
	Geo.solid(rack,Vector3(0,1.38,-0.56),Vector3(2.16,2.6,0.07),DARK,0.6)
	lab_sign(rack,"SERVISNÍ RACK / 05",Vector3(0,2.42,0.57),0.0,0.004)
	for row in [["patch","PATCH PANEL",2.01],["switch","SWITCH / ACCESS",1.51],["router","ROUTER / BRÁNA",0.97]]:
		var object = item(row[0],row[1],rack.to_global(Vector3(0,row[2],0.47)),Vector3(1.93,0.34,0.17),PI/2)
		lab_sign(object.visual,row[1],Vector3(0,0.11,0.10),0.0,0.00235)
		if row[0]=="router":
			lab_sign(object.visual,"192.168.10.1 · DHCP · resolver .2",Vector3(0,-0.06,0.10),0.0,0.002)
	for port in range(1,9):
		var x := (float(port)-4.5)*0.225
		Geo.box(rack,Vector3(x,1.96,0.57),Vector3(0.113,0.085,0.025),Color("091821"))
		lab_sign(rack,"%02d" % port,Vector3(x,1.87,0.59),0.0,0.0016)
		var target = item(str(port),"Switch · port %02d" % port,rack.to_global(Vector3(x,1.47,0.65)),Vector3(0.195,0.155,0.13),PI/2)
		Geo.box(target.visual,Vector3(0,0,0.071),Vector3(0.102,0.066,0.012),Color("0c161b"))
		for pin in range(-2,3):
			Geo.box(target.visual,Vector3(pin*0.016,0.02,0.08),Vector3(0.007,0.009,0.005),Color("ddbe76"),0.5)
		labels[str(port)] = lab_sign(target.visual,"",Vector3(0,-0.112,0.082),0.0,0.00155)

func table(at: Vector3, size_value: Vector2):
	Geo.solid(self,at+Vector3(0,0.84,0),Vector3(size_value.x,0.10,size_value.y),Color("556b76"),0.44)
	for dx in [-1,1]:
		for dz in [-1,1]:
			Geo.solid(self,at+Vector3(dx*(size_value.x/2-0.12),0.42,dz*(size_value.y/2-0.12)),Vector3(0.09,0.84,0.09),STEEL,0.6)

func build_clients():
	table(Vector3(-1.1,0,-24.05),Vector2(1.55,6.05))
	for row in [["pc04","PC 04",-22.2],["pc02","PC 02",-24.05],["printer","TISKÁRNA",-25.94]]:
		var z: float = row[2]
		var port = item(row[0],row[1]+" · konektor",Vector3(-0.25,1.15,z),Vector3(0.31,0.22,0.14),PI/2)
		Geo.box(port.visual,Vector3(0,0.02,0.075),Vector3(0.14,0.08,0.02),Color("0b1c29"))
		labels[row[0]] = lab_sign(port.visual,"",Vector3(0,-0.21,0.082),0.0,0.0021)
		if row[0]=="printer":
			Geo.bevel(self,Vector3(-1.25,1.09,z),Vector3(0.65,0.4,0.73),Color("b2c5c8"))
			Geo.box(self,Vector3(-1.26,1.3,z),Vector3(0.34,0.04,0.54),STEEL)
			Geo.box(self,Vector3(-0.91,1.16,z),Vector3(0.025,0.047,0.46),DARK)
		else:
			Geo.bevel(self,Vector3(-1.22,1.39,z),Vector3(0.13,0.68,1.02),DARK,0.4)
			Geo.box(self,Vector3(-1.14,1.39,z),Vector3(0.023,0.54,0.9),Color("294e5c"),0,0.22)
			Geo.box(self,Vector3(-1.20,0.99,z),Vector3(0.11,0.19,0.18),STEEL,0.5)
			Geo.box(self,Vector3(-0.76,0.92,z),Vector3(0.24,0.04,0.61),DARK)
			labels["screen_"+row[0]] = lab_sign(self,row[1],Vector3(-1.122,1.39,z),PI/2,0.0022)
		lab_sign(self,row[1],Vector3(-0.16,1.42,z),PI/2,0.003)

func build_terminal():
	var wall_board := Geo.box(self,Vector3(4,2.35,-28.72),Vector3(6.25,2.4,0.16),DARK)
	Architecture.wall_mount(wall_board,6.25,2.4)
	Geo.box(self,Vector3(4,3.28,-28.61),Vector3(5.84,0.026,0.04),ACCENT,0,0.7)
	lab_sign(self,"SÍŤOVÁ TOPOLOGIE / ŽIVÝ STAV",Vector3(4,3.12,-28.58),0.0,0.0048)
	var rows := ["pc04","pc02","printer","router","resolver"]
	for index in rows.size():
		var device: String = rows[index]
		var y := 2.82-index*0.25
		var nameplate := Geo.box(self,Vector3(2.01,y,-28.57),Vector3(1.70,0.20,0.021),Color("284b5b"))
		lab_sign(nameplate,Network.NAMES[device],Vector3(0,0,0.022),0.0,0.00325)
		board_ports[device] = lab_sign(self,"",Vector3(3.6,y,-28.53),0.0,0.00285)
		var start := Vector3(4.37,y,-28.54)
		var end := Vector3(5.68,2.32,-28.54)
		var beam := Geo.box(self,(start+end)*0.5,Vector3(start.distance_to(end),0.018,0.022),ACCENT,0,0.6)
		beam.rotation.z = atan2(end.y-start.y,end.x-start.x)
		beam.set_meta("dynamic",true)
		board_links[device] = beam
	var icon := Geo.bevel(self,Vector3(6.19,2.32,-28.53),Vector3(1.08,0.65,0.10),Color("305464"))
	lab_sign(icon,"SWITCH",Vector3(0,0.09,0.06),0.0,0.0036)
	lab_sign(icon,"VLAN 10 / 20",Vector3(0,-0.11,0.06),0.0,0.00245)
	flow = lab_sign(self,"",Vector3(4,1.55,-28.58),0.0,0.00285)
	var terminal = item("terminal","Terminál · úlohy, konfigurace a analyzátor",Vector3(4,1.42,-26.65),Vector3(2.0,0.61,0.18))
	Architecture.board_stand(terminal,2.0)
	lab_sign(terminal.visual,"TERMINÁL / 05\nÚlohy · měření · zachycený provoz",Vector3(0,0,0.11),0.0,0.0028)

func build_demo():
	table(Vector3(9.1,0,-21.0),Vector2(1.7,3.95))
	for row in [["splitter","SPLITTER",Vector3(8.89,1.07,-19.65)],["dsl","DSL MODEM",Vector3(8.89,1.07,-20.7)],["ap","PŘÍSTUPOVÝ BOD",Vector3(8.89,1.07,-22.18)]]:
		var device = item(row[0],row[1],row[2],Vector3(0.65,0.32,0.44),-PI/2)
		lab_sign(device.visual,row[1],Vector3(0,0.03,0.232),0.0,0.0021)
		if row[0]=="ap":
			for side in [-0.26,0.26]: Geo.box(device.visual,Vector3(side,0.22,0),Vector3(0.055,0.41,0.055),DARK)
	Geo.tube(self,[Vector3(9.7,0.91,-19.4),Vector3(9.2,0.94,-19.65),Vector3(9.35,0.91,-20.15),Vector3(9.11,0.99,-20.7)],0.019,ACCENT)
	Geo.tube(self,[Vector3(9.12,0.97,-19.64),Vector3(9.5,0.92,-19.24),Vector3(9.59,0.98,-19.27)],0.017,Color("e8b987"))
	Geo.bevel(self,Vector3(9.66,1.02,-19.24),Vector3(0.26,0.20,0.32),STEEL)
	Geo.bevel(self,Vector3(9.67,1.145,-19.24),Vector3(0.22,0.07,0.30),Color("d5c4a1"))
	lab_sign(self,"VEDENÍ → SPLITTER\nDSL MODEM / TELEFON\nWLAN · Ucebna",Vector3(10.84,1.97,-20.8),-PI/2,0.0038)
	table(Vector3(9.1,0,-25.7),Vector2(1.7,4.25))
	var model := Node3D.new()
	model.position = Vector3(9.0,0.9,-25.7)
	model.rotation.y = -PI/2
	add_child(model)
	for x in [-0.8,0.8]:
		Geo.cylinder(model,Vector3(x,0.035,0),0.63,0.07,Color("416676"))
		var lamp := Geo.ring(model,Vector3(x,0.085,0),0.57,ACCENT)
		lamp.set_meta("dynamic",true)
		cell_lamps.append(lamp)
		Geo.cylinder(model,Vector3(x,0.33,-0.08),0.07,0.55,STEEL)
		Geo.box(model,Vector3(x,0.61,-0.08),Vector3(0.22,0.12,0.1),Color("cbe4df"))
		lab_sign(model,"BTS A" if x<0 else "BTS B",Vector3(x,0.77,-0.08),0.0,0.0025)
	Geo.tube(model,[Vector3(-0.8,0.1,-0.32),Vector3(0,0.1,-0.68),Vector3(0.8,0.1,-0.32)],0.019,Color("b4dfe1"))
	lab_sign(model,"BSC  →  MSC",Vector3(0,0.29,-0.62),0.0,0.00235)
	handset = Node3D.new()
	model.add_child(handset)
	handset.set_meta("dynamic",true)
	Geo.bevel(handset,Vector3.ZERO,Vector3(0.18,0.08,0.28),Color("f8c479"))
	Geo.box(handset,Vector3(0,0.045,0),Vector3(0.14,0.013,0.21),Color("d0f9ee"),0,0.45)
	handover = lab_sign(model,"",Vector3(0,1.1,-0.44),0.0,0.0027)
	var mobile = item("gsm","Mobilní panel · hovor a identity",Vector3(8.21,1.53,-25.7),Vector3(1.45,0.26,0.13),-PI/2)
	lab_sign(mobile.visual,"GSM / HOVOR A IDENTITY",Vector3(0,0,0.08),0.0,0.0027)
	for phone in [0,1]:
		var body = item("sim_a" if phone==0 else "sim_b","Telefon A · fyzická SIM" if phone==0 else "Telefon B · fyzická SIM",
			Vector3(8.18,1.12,-26.95+2.5*phone),Vector3(0.38,0.35,0.14),-PI/2)
		Geo.box(body.visual,Vector3(0,0.028,0.078),Vector3(0.29,0.20,0.018),Color("2b6270"))
		lab_sign(body.visual,"A" if phone==0 else "B",Vector3(0,0.04,0.09),0.0,0.003)
		var token := Geo.box(body.visual,Vector3(0,-0.11,0.084),Vector3(0.1,0.062,0.025),Color("f8cc79"),0.4)
		token.set_meta("dynamic",true)
		sim_tokens.append(token)
		labels[body.console] = lab_sign(body.visual,"",Vector3(0,-0.237,0.08),0.0,0.002)

func sync():
	if world.game==null: return
	workshop.sync(world.game.network_workshop.model())
	var lab = world.game.network_lab
	var model = lab.current_network()
	var active: bool = world.game.game_mode.is_network_lab()
	var guides: Array = lab.guide_targets() if active else []
	for key in targets:
		targets[key].set_guided(key in guides or (active and model.cable==key))
	for device in Network.CLIENTS:
		var has_link: bool = model.link(device)
		targets[device].set_status("Healthy" if has_link else "Offline")
		labels[device].text = "VYBRÁNO" if model.cable==device else "LINK" if has_link else "BEZ LINKY"
		if labels.has("screen_"+device):
			labels["screen_"+device].text = Network.NAMES[device]+"\n"+("Bez linky" if not has_link else "VLAN %d / %s" % [model.segment(device),str(model.lease.get("ip","DHCP nepřiděleno")) if device=="pc04" else Network.IPS[device]])
	for port in range(1,9):
		var key := str(port)
		var occupied: String = model.occupant(port)
		var status := "VADNÝ" if port==8 else "VOLNÝ" if occupied=="" else "LINK"
		targets[key].set_status("Failed" if port==8 else "Offline" if occupied=="" else "Healthy")
		labels[key].text = "%02d\n%s" % [port,status]
	var observed_path: Array = lab.display_path()
	for device in board_ports:
		var linked: bool = model.link(device)
		board_ports[device].text = "SW %02d · VLAN %d" % [model.ports[device],model.segment(device)] if linked else "BEZ LINKY"
		board_ports[device].modulate = Color("e4f8f5") if linked else Color("f0bb87")
		board_links[device].visible = linked
		board_links[device].material_override = Geo.material(ACCENT,0,0.8) if device in observed_path else Geo.material(Color("527885"))
	var path: PackedStringArray = []
	for node in observed_path: path.append(Network.NAMES.get(node,"SWITCH"))
	flow.text = (("VYBRANÝ RÁMEC  /  " if lab.view=="capture" and lab.selected_capture>=0 else "POSLEDNÍ RÁMEC  /  ")+path[0]+" → SWITCH  /  "+(" · ".join(path.slice(2)) if path.size()==3 else "%d výstupů" % (path.size()-2))) if path.size()>=2 else "Switch čeká na první rámec"
	for phone in [0,1]:
		sim_tokens[phone].visible = model.sim_slot==phone
		labels["sim_a" if phone==0 else "sim_b"].text = "SIM VLOŽENA" if model.sim_slot==phone else "BEZ SIM"
	for index in [0,1]:
		cell_lamps[index].material_override = Geo.material(ACCENT,0,0.8) if model.cell==index and model.call_step>=0 else Geo.material(Color("526c79"))
	var destination := Vector3(-0.63 if model.cell==0 else 0.63,0.18,0.25)
	if model.call_step==1: destination.x = 0.0
	handset.position = handset.position.lerp(destination,0.58)
	handover.text = ["HOVOR / BTS A","MĚŘENÍ SOUSEDNÍ BUŇKY","PŘEDÁNO / BTS B"][model.call_step] if model.call_step>=0 else "GSM / PŘEDÁNÍ HOVORU"
	var signature := str(model.ports)
	if signature==cable_signature: return
	cable_signature = signature
	for child in cables.get_children():
		cables.remove_child(child)
		child.queue_free()
	for index in Network.CLIENTS.size():
		var id: String = Network.CLIENTS[index]
		if not model.link(id): continue
		var start: Vector3 = targets[id].position+Vector3(0.075,-0.03,0)
		var end: Vector3 = targets[str(model.ports[id])].position+Vector3(0.083,0,0)
		var height := 0.78-index*0.09
		Geo.tube(cables,[start,start+Vector3(0.08,-0.26,0),Vector3(-0.56,height,start.z),Vector3(-0.61,height,end.z),end],
			0.018,[ACCENT,Color("e2b571"),Color("96afd9")][index])
