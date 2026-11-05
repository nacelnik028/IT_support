extends Node3D

const Geo=preload("res://scripts/world/Geometry.gd")
const STATIONS={"terminal":Vector3(10,1.1,10),"gate":Vector3(17,1.1,18),"tower":Vector3(4,1.1,24.7),"tickets":Vector3(12,1.1,10),"info":Vector3(6,1.1,13)}
var world
var gate: StaticBody3D
var prices: Label3D
var last_prices=""

func contains_point(point: Vector3) -> bool:
	var seam=0.15 if world.game!=null and world.game.game_mode.is_english() else -0.15
	return AABB(Vector3(-0.85,-0.4,7-seam),Vector3(21.7,12.5,21.85+seam)).has_point(point)

func contains_player() -> bool:
	return is_instance_valid(world.player) and contains_point(world.player.global_position)

func entrance_position() -> Vector3:
	return Vector3(5,0.02,8.5)

func walkable_point(point: Vector3) -> bool:
	return contains_point(point) and not (point.z>19.75 and point.z<23.25 and (point.x<6.65 or point.x>9.35))

func near(station: String) -> bool:
	if not contains_player() or not STATIONS.has(station): return false
	var point=world.player.global_position; point.y=1.1
	return point.distance_to(STATIONS[station])<2.6

func sign_text(text: String, at: Vector3, size_value: int = 32, scale_value: float = 0.003) -> Label3D:
	var label=Geo.text(self,text,at,size_value,scale_value,Color("ebf5ee"))
	label.rotation.y=PI
	return label

func item(id: String, title: String, station: String, at: Vector3, dimensions: Vector3):
	var object=world.item(id,title,"english",at,dimensions,station)
	object.reparent(self)
	if station in ["tickets","info"]: object.visual.get_child(0).hide()
	return object

func build(owner_world):
	world=owner_world
	# The server/training rooms own the sealed shared north wall.
	Geo.solid(self,Vector3(10,-0.16,18),Vector3(22,0.3,22),Color("88948d"))
	Geo.solid(self,Vector3(-1,5.5,18),Vector3(0.25,11,22),Color("365366"))
	# East corridor enters north of the queue; wall owned only here.
	Geo.solid(self,Vector3(21,5.5,7.5),Vector3(0.25,11,1),Color("365366"))
	Geo.solid(self,Vector3(21,5.5,20),Vector3(0.25,11,18),Color("365366"))
	Geo.solid(self,Vector3(21,7,9.5),Vector3(0.25,8,3),Color("365366"))
	Geo.solid(self,Vector3(10,5.5,29),Vector3(22,11,0.25),Color("597482"))
	Geo.box(self,Vector3(10,11,18),Vector3(22,0.15,22),Color("92abb2"))
	# Seal the pavilion's north span beyond the original server wall height.
	Geo.solid(self,Vector3(10,7.5,7),Vector3(22,7,0.25),Color("365366"))
	for at in [Vector3(4,6,13),Vector3(16,6,14),Vector3(5,7,25),Vector3(17,6,25)]:
		var light=OmniLight3D.new(); light.position=at; light.omni_range=14; light.light_energy=3; light.light_color=Color("e2eddf"); add_child(light)
	var entrance=preload("res://scripts/world/WorldArchitecture.gd").portal(self,Vector3(21,0,9.5),PI/2,3,Color("e9a18b"))
	for face in [-1,1]:
		var sign_node=preload("res://scripts/world/WorldArchitecture.gd").portal_sign(entrance,"04 / ENGLISH IN LONDON" if face>0 else "ROZCESTNÍK AKADEMIE","Angličtina · situace · kvíz · poslech" if face>0 else "Zpět východní chodbou",Color("e9a18b"),3.6)
		sign_node.position=Vector3(0,3.64,face*0.32); sign_node.rotation.y=PI if face<0 else 0.0
	sign_text("ENGLISH IN LONDON\nVýukový pavilon • upravené vzdálenosti, nejde o turistickou mapu",Vector3(10,9.5,28.8),44,0.005)
	# Stylised South Bank, Thames and a wide, level, accessible bridge.
	Geo.box(self,Vector3(10,-0.002,21.5),Vector3(21.7,0.006,3),Color("318b9e"),0.25)
	# The continuous pavilion slab carries the bridge too: no tiny raised collider
	# edge that a CharacterBody without stair stepping can catch at low frame rates.
	Geo.box(self,Vector3(8,0.005,21.5),Vector3(3,0.02,4.2),Color("b1aa95"))
	for z in [19.7,23.3]:
		for span in [[2.5,7],[15.5,11]]:
			Geo.solid(self,Vector3(span[0],0.55,z),Vector3(span[1],1.1,0.1),Color("345565"),0.5)
	for x in [6.45,9.55]:
		Geo.solid(self,Vector3(x,0.55,21.5),Vector3(0.1,1.1,3.6),Color("345565"),0.5)
	for z in [20.3,21.5,22.7]:
		sign_text("↓",Vector3(8,0.055,z),50,0.003).rotation_degrees=Vector3(-90,180,0)
	sign_text("THAMES / TEMŽE",Vector3(13,0.08,21.5),38,0.004).rotation_degrees=Vector3(-90,0,0)
	sign_text("ELIZABETH TOWER\nRovně přes most, pak vlevo  ↓",Vector3(8,2.1,18.8),28,0.0028)
	sign_text("←  ELIZABETH TOWER",Vector3(8,2.1,24),28,0.003)
	for x in [1.5,3.5]:
		Geo.solid(self,Vector3(x,0.45,17),Vector3(1.5,0.15,0.65),Color("997553"))
		Geo.solid(self,Vector3(x,0.85,17.3),Vector3(1.5,0.7,0.12),Color("997553"))
		for dx in [-0.55,0.55]: Geo.box(self,Vector3(x+dx,0.2,17),Vector3(0.1,0.4,0.5),Color("253c4b"))
	build_eye()
	build_tower()
	Geo.solid(self,Vector3(12,0.55,10),Vector3(4.6,1.1,0.75),Color("31586a"))
	Geo.box(self,Vector3(12,2.6,10.2),Vector3(5,0.4,0.2),Color("215044"))
	sign_text("LONDON EYE TICKETS",Vector3(12,2.6,10.07),34,0.003)
	item("LONDON-TICKETS","Prodavač Sam — English in London [E]","tickets",Vector3(12,1.65,10.4),Vector3(0.9,1.15,0.6))
	npc(Vector3(12,0,10.5),Color("cd5f53"))
	prices=sign_text("",Vector3(14.7,1.8,10.2),25,0.0024)
	var terminal=item("LONDON-TERMINAL","Simulovaná platba — přiložit cvičnou kartu [E]","terminal",STATIONS.terminal,Vector3(0.6,0.4,0.45))
	Geo.box(terminal.visual,Vector3(0,0.05,-0.24),Vector3(0.45,0.25,0.03),Color("81d1ba"),0,0.5)
	sign_text("CVIČNÁ KARTA / PLATBA [E]",Vector3(10,1.7,9.8),23,0.002)
	item("LONDON-INFO","Alex / informace — cesta k Elizabeth Tower [E]","info",STATIONS.info,Vector3(0.8,1.6,0.6))
	npc(Vector3(6,0,13),Color("547cba"))
	# A small grounded information plaque beside Alex, clear of the bridge route.
	var plaque=Node3D.new(); plaque.name="AlexInformationSign"; add_child(plaque); plaque.position=Vector3(7.25,0,12.8); plaque.rotation.y=PI
	Geo.bevel(plaque,Vector3(0,1.5,0),Vector3(1.65,0.9,0.12),Color("263e4b"),0.45,0.025)
	Geo.solid(plaque,Vector3(0,0.7,-0.02),Vector3(0.08,1.4,0.08),Color("869b9e"),0.55)
	Geo.solid(plaque,Vector3(0,0.04,0),Vector3(0.6,0.08,0.42),Color("526b76"),0.5)
	Geo.text(plaque,"ALEX / INFORMACE",Vector3(0,1.77,0.07),32,0.003,Color("b5eee0"))
	Geo.text(plaque,"Angličtina: dotaz na cestu\nk Elizabeth Tower",Vector3(0,1.48,0.07),27,0.0031)
	Geo.text(plaque,"[E] Zeptat se na cestu",Vector3(0,1.2,0.07),27,0.0031,Color("b5eee0"))
	var quiz_board=item("LONDON-QUIZ","Otázky na Londýn — B1–B2 [E]","quiz",Vector3(3,1.5,12.5),Vector3(2,1.05,0.16))
	Geo.text(quiz_board.visual,"LONDON QUIZ\n20 otázek · B1–B2\n[E] OTEVŘÍT",Vector3(0,0,-0.1),26,0.004,Color("b5eee0")).rotation.y=PI
	Geo.box(quiz_board.visual,Vector3(0,0.45,-0.09),Vector3(1.8,0.025,0.014),Color("76dfc7"))
	preload("res://scripts/world/WorldArchitecture.gd").board_stand(quiz_board,2)
	var listening_board=item("LONDON-LISTENING","Poslechové procvičování — 12 úloh [E]","listening",Vector3(1,1.5,9.3),Vector3(1.8,1.05,0.16))
	Geo.text(listening_board.visual,"POSLECH\n12 úloh · angličtina\n[E] OTEVŘÍT",Vector3(0,0,-0.1),26,0.004,Color("b5eee0")).rotation.y=PI
	Geo.box(listening_board.visual,Vector3(0,0.45,-0.09),Vector3(1.6,0.025,0.014),Color("76dfc7"))
	preload("res://scripts/world/WorldArchitecture.gd").board_stand(listening_board,1.8)
	item("LONDON-GATE","Vstupní kontrola — předložit konkrétní lístek [E]","gate",STATIONS.gate,Vector3(0.65,1.2,0.55))
	gate=Geo.solid(self,Vector3(18.7,0.8,18),Vector3(2.6,0.15,0.15),Color("d88465")); gate.set_meta("dynamic",true)
	for x in [17.4,20]: Geo.solid(self,Vector3(x,0.55,15.4),Vector3(0.1,1.1,5),Color("345565"))
	Geo.solid(self,Vector3(18.7,0.55,12.9),Vector3(2.6,1.1,0.1),Color("345565"))
	sign_text("ENTRANCE / KONTROLA [E]\nVyhlídková plošina",Vector3(18.5,2.3,18),26,0.0024)
	item("LONDON-TOWER","Elizabeth Tower — ověřit příchod [E]","tower",STATIONS.tower,Vector3(1.5,1.3,0.2))
	sign_text("ELIZABETH TOWER\nBig Ben je velký zvon uvnitř věže.\n[E] POTVRDIT NÁVŠTĚVU",Vector3(4,1.7,24.5),26,0.0023)
	preload("res://scripts/world/AcademyDecor.gd").london(self)

func npc(at: Vector3, coat: Color):
	Geo.cylinder(self,at+Vector3(0,1.2,0),0.23,0.7,coat)
	Geo.cylinder(self,at+Vector3(0,1.6,0),0.095,0.22,Color("ddb296"))
	Geo.cylinder(self,at+Vector3(0,1.82,0),0.18,0.35,Color("ddb296"))
	for dx in [-0.065,0.065]: Geo.box(self,at+Vector3(dx,1.87,-0.17),Vector3(0.035,0.04,0.02),Color("293c51"))
	for dx in [-0.14,0.14]: Geo.box(self,at+Vector3(dx,0.48,0),Vector3(0.19,0.85,0.23),Color("293c51"))
	for dx in [-0.32,0.32]: Geo.box(self,at+Vector3(dx,1.2,0),Vector3(0.16,0.6,0.2),coat)

func beam(a: Vector3, b: Vector3, width: float, color: Color):
	var mesh=Geo.box(self,(a+b)*0.5,Vector3(width,width,a.distance_to(b)),color,0.45)
	mesh.look_at(b,Vector3.RIGHT if absf((b-a).normalized().y)>0.95 else Vector3.UP)

func build_eye():
	var center=Vector3(16,5,14)
	Geo.ring(self,center,3.5,Color("e1e8e4"))
	Geo.ring(self,center+Vector3(0,0,0.25),3.5,Color("a9c6cc"))
	for i in 24:
		var angle=TAU*i/24.0
		var end=center+Vector3(cos(angle),sin(angle),0)*3.35
		beam(center,end,0.035,Color("d1d9d5"))
		Geo.box(self,end+Vector3(0,0,0.12),Vector3(0.48,0.4,0.55),Color("91c6d4"),0.25)
		Geo.box(self,end+Vector3(0,-0.2,0.12),Vector3(0.5,0.07,0.55),Color("eff0e0"))
	for dx in [-2,2]: beam(Vector3(16+dx,0,15.5),center,0.22,Color("ecebd8"))
	sign_text("LONDON EYE / SOUTH BANK",Vector3(16,9.2,14),34,0.0035)

func build_tower():
	var at=Vector3(4,0,27)
	Geo.solid(self,at+Vector3(0,2.65,0),Vector3(2,5.3,2),Color("bca37b"))
	for y in [0.3,1.4,2.6,3.8,5.2,6.5]: Geo.box(self,at+Vector3(0,y,0),Vector3(2.25,0.16,2.25),Color("dcc7a0"))
	Geo.box(self,at+Vector3(0,5.9,0),Vector3(2.2,1.3,2.2),Color("ac976f"))
	for face in 4:
		var clock=Node3D.new(); add_child(clock); clock.position=at+Vector3(0,5.9,0); clock.rotation.y=face*PI/2
		var dial=Geo.cylinder(clock,Vector3(0,0,1.12),0.52,0.04,Color("f1ead4"),0,32); dial.rotation.x=PI/2
		for tick in 12:
			var angle=TAU*tick/12.0
			var hand=Geo.box(clock,Vector3(sin(angle)*0.43,cos(angle)*0.43,1.15),Vector3(0.035,0.08,0.02),Color("263e47")); hand.rotation.z=-angle
		Geo.box(clock,Vector3(0,0.16,1.17),Vector3(0.04,0.32,0.02),Color("263e47"))
		var hand=Geo.box(clock,Vector3(0.13,-0.02,1.17),Vector3(0.28,0.045,0.02),Color("263e47")); hand.rotation.z=-0.2
	for dx in [-0.9,0.9]:
		for dz in [-0.9,0.9]:
			Geo.box(self,at+Vector3(dx,6.65,dz),Vector3(0.18,0.9,0.18),Color("d8c49a"))
	var roof=MeshInstance3D.new(); var mesh=CylinderMesh.new(); mesh.top_radius=0; mesh.bottom_radius=1.55; mesh.height=2; mesh.radial_segments=4; roof.mesh=mesh; roof.position=at+Vector3(0,7.6,0); roof.rotation.y=PI/4; roof.material_override=Geo.material(Color("315365")); add_child(roof)
	Geo.cylinder(self,at+Vector3(0,8.8,0),0.04,0.7,Color("d8c49a"))

func sync():
	if world.game==null: return
	var manager=world.game.english
	var text="CVIČNÉ CENY / PRACTICE PRICES\nStandard: adult £30 / child £20\nFlex: adult £40 / child £25\nBez plavby, bez povinného poplatku\n14:00   15:00   16:00"
	var s=manager.session
	if not s.is_empty(): text+="\nRozpočet "+manager.money(int(s.goal.budget))+"\n"+("Vyprodáno / Sold out: "+s.goal.sold if s.goal.has("sold") else "Všechny časy dostupné")
	if text!=last_prices: prices.text=text; last_prices=text
	var opened=not s.is_empty() and not s.ticket.is_empty() and s.ticket.used
	gate.position.y=2.8 if opened else 0.8
