extends RefCounted

const Geo=preload("res://scripts/world/Geometry.gd")

static func panel(parent: Node3D, at: Vector3, yaw: float, title: String, body: String, accent: Color, width: float = 2.6):
	var face=Node3D.new(); parent.add_child(face); face.position=at; face.rotation.y=yaw
	Geo.bevel(face,Vector3.ZERO,Vector3(width,1.25,0.065),Color("203a46"),0,0.025)
	preload("res://scripts/world/WorldArchitecture.gd").wall_mount(face,width,1.25)
	Geo.box(face,Vector3(-width*0.45,0,0.045),Vector3(0.025,1.05,0.015),accent,0,0.25)
	Geo.text(face,title,Vector3(0,0.3,0.05),32,0.004,accent)
	Geo.text(face,body,Vector3(0,-0.17,0.05),25,0.0033,Color("d2e0dc"))

static func plant(parent: Node3D, at: Vector3):
	Geo.solid(parent,at+Vector3(0,0.28,0),Vector3(0.65,0.56,0.65),Color("80928d"))
	Geo.bevel(parent,at+Vector3(0,0.55,0),Vector3(0.7,0.08,0.7),Color("afbcab"),0,0.03)
	Geo.box(parent,at+Vector3(0,0.6,0),Vector3(0.53,0.04,0.53),Color("3b4b3b"))
	for i in 7:
		var angle=TAU*i/7
		var stalk=Geo.cylinder(parent,at+Vector3(sin(angle)*0.13,1.06,cos(angle)*0.13),0.015,0.95,Color("4f7864"),0,8)
		stalk.rotation=Vector3(0,angle,0.15)
		for h in [0.95,1.25,1.5]:
			var leaf=Geo.bevel(parent,at+Vector3(sin(angle)*0.22,h,cos(angle)*0.22),Vector3(0.17,0.4,0.055),Color("527f69") if i%2 else Color("78a080"),0,0.025)
			leaf.rotation=Vector3(0,angle,0.5 if i%2 else -0.5)

static func technical(world):
	panel(world,Vector3(-8.76,2,4.9),PI/2,"01 / PROVOZNÍ ZÓNA","DIAGNOSTIKA → ZÁSAH → OVĚŘENÍ\nPřed servisem ověř nezávislou zálohu.",Color("86d2e6"),3.3)
	panel(world,Vector3(20.76,2,-0.5),-PI/2,"02 / LABORATOŘ","POZORUJ → OPRAV → OVĚŘ\nVlastní tempo. Bezpečný prostor pro chyby.",Color("efca8b"),3.5)
	# Wall-mounted service equipment stays outside the existing access lanes.
	var cabinet=Geo.bevel(world,Vector3(8.72,1.2,6.25),Vector3(0.16,0.62,0.48),Color("a96558"),0.2,0.025)
	Geo.box(cabinet,Vector3(-0.09,0,0),Vector3(0.015,0.32,0.08),Color("e4daca"))
	for dz in [-0.1,0.1]: Geo.box(cabinet,Vector3(-0.09,0,dz),Vector3(0.015,0.08,0.12),Color("e4daca"))
	for at in [Vector3(-8.72,0.17,4.9),Vector3(20.72,0.17,-0.5)]:
		for dz in [-1.3,1.3]: Geo.box(world,at+Vector3(0,0,dz),Vector3(0.06,0.3,0.06),Color("8da59e"),0.4)
	plant(world,Vector3(20.25,0,6.25))
	# Flush floor inlays add identity without changing floor collision height.
	for x in [-5,-2.3]: Geo.box(world,Vector3(x,0.008,1.1),Vector3(2.1,0.006,0.035),Color("64a7b5"))
	for x in [11.2,14,18]: Geo.box(world,Vector3(x,0.008,0.1 if x!=18 else 3),Vector3(2.1,0.006,0.035),Color("d4b475"))

static func programming(room):
	panel(room,Vector3(-8.78,2,-14),PI/2,"{ }  PYTHON","VSTUP → ZPRACOVÁNÍ → VÝSTUP\nPiš. Spouštěj. Ověřuj.",Color("76dfc7"),3.6)
	panel(room,Vector3(8.78,2,-16),-PI/2,"< >  WEB DEVELOPMENT","HTML / STRUKTURA\nCSS / VZHLED       JS / CHOVÁNÍ",Color("84c6e0"),3.6)
	for x in [-8.84,8.84]:
		for z in [-18.8,-16.8]: Geo.box(room,Vector3(x,2.1,z),Vector3(0.03,2.8,0.025),Color("9bb9ab"),0,0.2)

static func london(room):
	# A shallow riverside skyline is backdrop relief, not a second walkable city.
	for building in [[10,3.2,1.6],[12,4.1,1.4],[14,2.8,1.8],[16.5,4.8,1.8],[19,3.7,1.6]]:
		var x=float(building[0]); var height=float(building[1]); var width=float(building[2])
		Geo.bevel(room,Vector3(x,height*0.5,28.79),Vector3(width,height,0.09),Color("6b8588"),0,0.03)
		Geo.box(room,Vector3(x,height+0.05,28.76),Vector3(width+0.12,0.1,0.14),Color("a9b2a0"))
		for y in range(1,int(height*2)):
			for dx in [-0.35,0.35]: Geo.box(room,Vector3(x+dx,y*0.45,28.72),Vector3(0.22,0.28,0.025),Color("c7c5a8"))
	for z in [19.45,23.55]:
		for x in range(0,21):
			if z<20 and x in [7,8,9]: continue
			Geo.box(room,Vector3(x,0.006,z),Vector3(0.94,0.018,0.28),Color("c1b9a1"))
	# Brick bands and a restrained awning make the ticket desk read as a kiosk.
	for y in [0.18,0.42,0.66,0.9]:
		for i in 9: Geo.bevel(room,Vector3(10.05+i*0.48+(0.12 if y<0.5 else 0),y,9.61),Vector3(0.43,0.2,0.025),Color("9c8070"),0,0.007)
	Geo.box(room,Vector3(12,2.94,10.35),Vector3(5,0.1,1.25),Color("356b5e"))
	for x in [9.6,14.4]: Geo.cylinder(room,Vector3(x,1.5,10.65),0.035,2.9,Color("adc4b4"),0.3,12)
	plant(room,Vector3(1.1,0,11.5))
	plant(room,Vector3(19.6,0,27.9))
	panel(room,Vector3(-0.8,2.5,16),PI/2,"SOUTH BANK","THAMES / TEMŽE\nSleduj značení mostu k Elizabeth Tower.",Color("d7c8a3"),3.3)
