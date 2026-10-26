extends RefCounted

const Geo=preload("res://scripts/world/Geometry.gd")
const Design=preload("res://scripts/ui/AcademyTheme.gd")
const PYTHON=Color("4de0cb")
const WEB=Color("80bdf4")
const EXAM=Color("efc47d")
var room
var world

func build(academy):
	room=academy; world=room.world
	# Replace coarse decorative surfaces; the room's physical shell stays shared.
	for node in room.get_children():
		if node is MeshInstance3D and node.mesh is BoxMesh and node.position.y<0.92 and node.position.y>0.84: node.hide()
		if node is Label3D: node.hide()
	var floor_mesh=Geo.box(room,Vector3(0,-0.008,-14),Vector3(17.8,0.012,13.8),Color.WHITE)
	var floor_material=ShaderMaterial.new(); floor_material.shader=preload("res://assets/materials/raised_floor.gdshader")
	floor_material.set_shader_parameter("base_color",Color("424f58")); floor_material.set_shader_parameter("metal",0.08); floor_mesh.material_override=floor_material
	for x in range(-8,9,2): Geo.bevel(room,Vector3(x,2,-20.84),Vector3(1.94,3.4,0.045),Color("53616c"),0.2,0.012)
	for x in [-8.84,8.84]:
		for z in [-9.2,-11.4,-13.6,-15.8,-18,-20]: Geo.bevel(room,Vector3(x,1.9,z),Vector3(0.05,3.4,2.14),Color("44535f"),0.2,0.012)
		Geo.box(room,Vector3(x,0.12,-14),Vector3(0.06,0.2,13.6),Color("15232d"),0.5)
		Geo.box(room,Vector3(x,0.27,-14),Vector3(0.02,0.025,13.6),PYTHON,0,0.7)
	for x in [-5,0,5]: Geo.box(room,Vector3(x,3.89,-14),Vector3(0.16,0.18,13.7),Color("283942"),0.5)
	for z in [-9,-12.8,-16.5,-19.8]: Geo.bevel(room,Vector3(0,3.92,z),Vector3(17.6,0.1,0.18),Color("43525b"),0.3,0.01)
	for zone in [[-5,PYTHON],[0,WEB],[5,EXAM]]:
		Geo.box(room,Vector3(zone[0],0.004,-16.8),Vector3(3.5,0.005,4.6),Color("2e414c"))
		for z in [-14.5,-19.1]: Geo.box(room,Vector3(zone[0],0.009,z),Vector3(3.5,0.005,0.035),zone[1],0,0.3)
	for station in [[-5,-17,"PYTHON-PC",PYTHON],[0,-17,"WEB-PC",WEB],[5,-17,"PROGRAM-EXAM",EXAM],[-5,-12,"PYTHON-PC-2",PYTHON],[0,-12,"WEB-PC-2",WEB]]: workstation(station)
	for at in [Vector3(-8.1,0,-19.8),Vector3(8.1,0,-9.3)]: plant(at)
	Geo.solid(room,Vector3(7.5,0.5,-12),Vector3(1.1,0.16,2.6),Color("435c6a"))
	for z in [-13,-11]: Geo.cylinder(room,Vector3(7.5,0.23,z),0.1,0.46,Color("536b78"),0.7)
	study_wall(); entrance()

func workstation(station: Array):
	var at=Vector3(station[0],0,station[1]); var accent: Color=station[3]
	Geo.bevel(room,at+Vector3(0,0.8,0),Vector3(2.34,0.12,1.14),Color("8c9ba3"),0.15,0.025)
	Geo.box(room,at+Vector3(0,0.7,-0.45),Vector3(1.9,0.08,0.06),Color("25313b"),0.7)
	Geo.box(room,at+Vector3(0,0.875,0.36),Vector3(1.6,0.008,0.025),accent,0,0.7)
	Geo.bevel(room,at+Vector3(0,0.9,-0.25),Vector3(0.45,0.06,0.28),Color("24343f"),0.7,0.02)
	Geo.box(room,at+Vector3(0,1.07,-0.28),Vector3(0.09,0.35,0.08),Color("4c606c"),0.8)
	var pc=world.devices[station[2]]
	for child in pc.visual.get_children():
		if child is Label3D: child.hide()
	Geo.box(pc.visual,Vector3(0,0.32,0.082),Vector3(1.45,0.025,0.005),accent,0,0.9)
	var title="PYTHON LAB" if pc.console=="python" else "WEB DEVELOPMENT" if pc.console=="web" else "ZKOUŠKA"
	Geo.text(pc.visual,title+"\n\n"+("print(\"Ahoj, světe!\")" if pc.console=="python" else "<h1>Tvůj první web</h1>" if pc.console=="web" else "Vlastní řešení bez nápovědy")+"\n\n[E] OTEVŘÍT",Vector3(0,0,0.09),24,0.0017,accent)
	Geo.bevel(room,at+Vector3(0,0.89,0.22),Vector3(0.77,0.035,0.26),Color("172630"),0.25,0.008)
	for row in 4:
		for key in 13: Geo.box(room,at+Vector3(-0.35+key*0.055,0.913,0.135+row*0.052),Vector3(0.043,0.009,0.034),Color("afc2cc") if row>0 else accent)
	Geo.bevel(room,at+Vector3(0.67,0.87,0.22),Vector3(0.4,0.01,0.32),Color("31434d"),0,0.008)
	Geo.bevel(room,at+Vector3(0.67,0.9,0.2),Vector3(0.08,0.05,0.14),Color("a3b5c0"),0.2,0.02)
	Geo.tube(room,[at+Vector3(0,0.9,0.11),at+Vector3(0,0.87,-0.05),at+Vector3(0.05,0.85,-0.4)],0.005,Color("20313e"))
	Geo.bevel(room,at+Vector3(-0.84,0.89,0.18),Vector3(0.25,0.025,0.32),Color("c5bca4"),0,0.008)
	chair(at+Vector3(0,0,1.28),accent)

func chair(at: Vector3, accent: Color):
	Geo.solid(room,at+Vector3(0,0.48,0),Vector3(0.6,0.12,0.57),Color("263d49"))
	Geo.bevel(room,at+Vector3(0,0.51,0),Vector3(0.62,0.14,0.6),Color("435c6a"),0.1,0.05)
	Geo.solid(room,at+Vector3(0,0.9,0.26),Vector3(0.58,0.7,0.11),Color("263d49"))
	Geo.bevel(room,at+Vector3(0,0.93,0.27),Vector3(0.6,0.75,0.13),Color("435c6a"),0.1,0.04)
	Geo.box(room,at+Vector3(0,1.18,0.34),Vector3(0.24,0.025,0.006),accent)
	Geo.cylinder(room,at+Vector3(0,0.23,0),0.045,0.46,Color("8395a0"),0.8)
	for yaw in 5:
		var arm=Node3D.new(); arm.position=at+Vector3(0,0.08,0); arm.rotation.y=yaw*TAU/5; room.add_child(arm)
		Geo.box(arm,Vector3(0,0,0.17),Vector3(0.05,0.04,0.36),Color("586e7d"),0.65)
		Geo.cylinder(arm,Vector3(0,-0.02,0.32),0.035,0.05,Color("192832"))

func study_wall():
	Geo.text(room,"NORTHSTAR  /  ACADEMY 03",Vector3(0,3.48,-20.73),32,0.003,Design.MUTED)
	Geo.text(room,"PROGRAMMING ACADEMY",Vector3(0,3.13,-20.73),56,0.0035,PYTHON)
	var board=world.devices["PROGRAM-DASHBOARD"]; board.position=Vector3(4,1.9,-20.6)
	room.dashboard.font_size=27; room.dashboard.pixel_size=0.002; room.dashboard.width=2300; room.dashboard.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	var teacher=world.devices["PROGRAM-INSTRUCTOR"]
	for child in teacher.visual.get_children():
		if child is Label3D: child.hide()
	Geo.ring(teacher.visual,Vector3(0,0.47,0.15),0.26,PYTHON).rotation.x=0
	Geo.text(teacher.visual,"{  }",Vector3(0,0.47,0.19),64,0.0024,PYTHON)
	Geo.text(teacher.visual,"ADA / PRŮVODCE\nVysvětlím, ukážu, pomohu.\n[E] VYBRAT LEKCI",Vector3(0,-0.3,0.16),24,0.0017)
	var terminal=world.devices["PROGRAM-TERMINAL"]
	Geo.solid(room,terminal.position+Vector3(0,-0.85,-0.04),Vector3(0.4,0.9,0.35),Color("354b58"),0.4)
	Geo.text(terminal.visual,"ZAČNI TADY\nLekce · úlohy · výsledky\n[E] STUDIUM",Vector3(0,0,0.09),25,0.0017,PYTHON)
	for zone in [[-5,"A / PYTHON",PYTHON],[0,"B / TVORBA WEBU",WEB],[5,"C / ZKOUŠKA",EXAM]]:
		Geo.bevel(room,Vector3(zone[0],2.5,-19.65),Vector3(2.6,0.4,0.07),Color("21333f"),0.3,0.015)
		Geo.text(room,zone[1],Vector3(zone[0],2.5,-19.6),27,0.0022,zone[2])

func plant(at: Vector3):
	Geo.cylinder(room,at+Vector3(0,0.3,0),0.27,0.6,Color("879397"),0.1)
	for angle in [0,1.2,2.4,3.6,4.8]:
		var leaf=Geo.box(room,at+Vector3(sin(angle)*0.12,0.96,cos(angle)*0.12),Vector3(0.1,0.9,0.24),Color("477c6b")); leaf.rotation=Vector3(0,angle,0.15)

func entrance():
	for z in [4.2,2.8,1.4,0,-1.4,-2.8,-4.2,-5.6,-8.1,-9.4]:
		Geo.text(world,"›",Vector3(-6.5,0.014,z),64,0.004,PYTHON).rotation_degrees=Vector3(-90,90,0)
	Geo.box(world,Vector3(-7.3,0.012,-0.6),Vector3(0.025,0.005,10.8),PYTHON,0,0.2)
	Geo.text(world,"03  /  PROGRAMMING ACADEMY  ↑",Vector3(-6.5,0.016,4.4),30,0.003,PYTHON).rotation_degrees=Vector3(-90,0,0)
	for side in [-1,1]:
		var face=Node3D.new(); face.position.z=side*0.085; face.rotation.y=0.0 if side>0 else PI; room.door.visual.add_child(face)
		Geo.box(face,Vector3.ZERO,Vector3(2.55,2.5,0.015),Color("263e4b"),0.6)
		Geo.box(face,Vector3(0,0.7,0.013),Vector3(2.5,0.025,0.01),PYTHON,0,0.9)
		Geo.text(face,"03\nPROGRAMMING\nACADEMY\n\n[E] OTEVŘÍT",Vector3(0,0.08,0.027),38,0.0025,PYTHON)
	for x in [-8.04,-4.96]:
		Geo.bevel(world,Vector3(x,1.45,-7),Vector3(0.13,2.9,0.31),Color("6d818d"),0.7,0.018)
		Geo.box(world,Vector3(x,1.45,-6.82),Vector3(0.025,2.75,0.015),PYTHON,0,0.8)
	room.door_notice=Geo.text(world,"PROGRAMMING ACADEMY / [E] OTEVŘÍT",Vector3(-6.5,3.48,-6.8),28,0.0027,PYTHON)
	# The inside control must face the inside, including its text plane.
	room.door_panels[1].label.position.z=-0.08
