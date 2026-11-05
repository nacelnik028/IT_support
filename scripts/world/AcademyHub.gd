extends Node3D

const Geo=preload("res://scripts/world/Geometry.gd")
const SPAWN=Vector3(4,0.02,-11)
const HALL=AABB(Vector3(-9,-0.4,-16),Vector3(30,4.5,9))
const PASSAGE=AABB(Vector3(21,-0.4,-16),Vector3(4,4.5,27.5))
var world

static func floor_point(p: Vector3) -> bool:
	return HALL.has_point(p) or PASSAGE.has_point(p)

func contains_player() -> bool:
	if not is_instance_valid(world.player): return false
	var p=world.player.global_position
	var seam=0.16 if world.game!=null and world.game.game_mode.is_hub() else -0.16
	return (p.x>=-9 and p.x<=21 and p.z>=-16 and p.z< -7+seam) or (p.x>21-seam and p.x<25 and p.z>=-16 and p.z<=11.5)

func sign_at(words: String, at: Vector3, yaw: float, accent: Color, width: float = 4.0):
	var face=Node3D.new(); add_child(face); face.position=at; face.rotation.y=yaw
	Geo.box(face,Vector3.ZERO,Vector3(width,0.85,0.07),Color("173442"))
	Geo.box(face,Vector3(0,0.38,0.05),Vector3(width,0.035,0.015),accent,0,0.4)
	Geo.text(face,words,Vector3(0,0,0.055),32,0.005,accent)

func portal(at: Vector3, yaw: float, title: String, subtitle: String, accent: Color):
	preload("res://scripts/world/WorldArchitecture.gd").portal(self,at,yaw,3,accent)
	for face in [-1,1]:
		var sign_node=preload("res://scripts/world/WorldArchitecture.gd").portal_sign(self,title if face>0 else "ROZCESTNÍK AKADEMIE",subtitle if face>0 else title+" · návrat",accent,4.4)
		sign_node.position=at+Vector3(0,3.64,face*0.32).rotated(Vector3.UP,yaw); sign_node.rotation.y=yaw+(PI if face<0 else 0.0)

func build(owner_world):
	world=owner_world; name="AcademyHub"
	Geo.solid(self,Vector3(6,-0.16,-11.5),Vector3(30,0.3,9),Color("53656b"))
	Geo.solid(self,Vector3(23,-0.16,-2.25),Vector3(4,0.3,27.5),Color("53656b"))
	Geo.box(self,Vector3(6,4,-11.5),Vector3(30,0.15,9),Color("283f4a"))
	Geo.box(self,Vector3(23,4,-2.25),Vector3(4,0.15,27.5),Color("283f4a"))
	Geo.solid(self,Vector3(8,2,-16),Vector3(34,4,0.25),Color("455e69"))
	# Shared west/south walls are owned by the existing rooms. The short west
	# return is outside the classroom; no second coplanar wall is introduced.
	Geo.solid(self,Vector3(-9,2,-15.75),Vector3(0.25,4,0.5),Color("455e69"))
	Geo.solid(self,Vector3(25,2,-2.25),Vector3(0.25,4,27.5),Color("455e69"))
	Geo.solid(self,Vector3(23,2,11.5),Vector3(4,4,0.25),Color("455e69"))
	# This partition has a real 3 m opening to the corridor at z=-11.5.
	for z in [-14.5,-8.5]:
		Geo.solid(self,Vector3(21,2,z),Vector3(0.25,4,3),Color("455e69"))
	Geo.solid(self,Vector3(21,3.5,-11.5),Vector3(0.25,1,3),Color("455e69"))
	portal(Vector3(-6,0,-7),PI,"01 / SERVEROVNA","Pracovní směna · incidenty · kampaň",Color("8acfe9"))
	portal(Vector3(16,0,-7),PI,"02 / IT TRÉNINK","21 lekcí · cvičná infrastruktura",Color("efca8b"))
	portal(Vector3(-9,0,-12),PI/2,"03 / PROGRAMOVÁNÍ","Python · HTML / CSS / JavaScript",Color("76dfc7"))
	portal(Vector3(21,0,-11.5),-PI/2,"04 / ENGLISH IN LONDON","B1–B2 · situace a otázky na Londýn",Color("e9a18b"))
	var directory=Geo.box(self,Vector3(4,2.1,-15.8),Vector3(13,2.4,0.1),Color("153440"))
	preload("res://scripts/world/WorldArchitecture.gd").wall_mount(directory,13,2.4)
	Geo.text(self,"TRAINING ACADEMY / ROZCESTNÍK",Vector3(4,2.8,-15.73),52,0.007,Color("b5eee0"))
	Geo.text(self,"01  Serverovna  ↓ vlevo       02  IT trénink  ↓ vpravo\n03  Programování  ←       04  English in London  →\n\nVyber si cestu. Úlohu zahájíš až u pracoviště.",Vector3(4,1.9,-15.72),34,0.006)
	for x in [-5,5,16]:
		Geo.box(self,Vector3(x,3.85,-11.5),Vector3(3,0.08,0.5),Color("e1e9d7"),0,0.6)
		var light=OmniLight3D.new(); light.position=Vector3(x,3,-11.5); light.light_energy=2; light.omni_range=9; add_child(light)
	for z in [-10,-2,6]:
		Geo.box(self,Vector3(23,3.8,z),Vector3(2.5,0.06,0.4),Color("e1e9d7"),0,0.6)
		var light=OmniLight3D.new(); light.position=Vector3(23,3,z); light.light_energy=1.6; light.omni_range=7; add_child(light)
		Geo.text(self,"04 / LONDÝN  ↓",Vector3(23,0.018,z+1),28,0.003,Color("e9a18b")).rotation_degrees=Vector3(-90,180,0)
	sign_at("04 / LONDON  →\nZpět do hubu po stejné chodbě",Vector3(23,2.3,11.3),PI,Color("e9a18b"),3.5)
	for x in [0,10]:
		Geo.solid(self,Vector3(x,0.45,-14.8),Vector3(2.6,0.14,0.65),Color("263e48"))
		Geo.bevel(self,Vector3(x,0.52,-14.8),Vector3(2.64,0.18,0.68),Color("b2946f"),0,0.06)
		Geo.bevel(self,Vector3(x,0.96,-15.05),Vector3(2.64,0.68,0.16),Color("7c998b"),0,0.06)
		for dx in [-1,1]: Geo.box(self,Vector3(x+dx,0.22,-14.8),Vector3(0.1,0.44,0.5),Color("263e48"))
	decorate()

func decorate():
	# Warm details stay at the perimeter. The central turning space, spawn,
	# controller reach and all four physical routes remain free of colliders.
	for x in [-7.5,-6.9,-6.3,-5.7,13.4,14.0,14.6,15.2,15.8,16.4,17.0,17.6,18.2,18.8]:
		Geo.bevel(self,Vector3(x,1.9,-15.79),Vector3(0.16,3.35,0.12),Color("a58c6a"),0,0.02)
	Geo.box(self,Vector3(6,0.14,-15.7),Vector3(29.6,0.22,0.06),Color("223d46"))
	for span in [[-8.25,1.1],[5,18.6],[19.25,3.1]]:
		Geo.box(self,Vector3(span[0],0.14,-7.35),Vector3(span[1],0.22,0.06),Color("223d46"))
	Geo.box(self,Vector3(4,0.001,-13),Vector3(13,0.012,3),Color("697d74"))
	for x in [-2.55,10.55]: Geo.box(self,Vector3(x,0.009,-13),Vector3(0.025,0.004,2.9),Color("b9baa0"))
	for x in [-7.7,19.3]: plant(Vector3(x,0,-14.4))
	plant(Vector3(12,0,-14.8))
	# Simple ceiling fins add depth without new lights, textures or shaders.
	for x in [-7,0,7,14,20]: Geo.bevel(self,Vector3(x,3.78,-11.5),Vector3(0.14,0.26,8.6),Color("58717a"),0,0.02)
	for route in [[Vector3(-6,0.012,-9),Vector3(0.09,0.01,3.7),Color("8acfe9")],[Vector3(16,0.012,-9),Vector3(0.09,0.01,3.7),Color("efca8b")],[Vector3(-7.7,0.012,-12),Vector3(2.1,0.01,0.09),Color("76dfc7")],[Vector3(19.7,0.012,-11.5),Vector3(2.1,0.01,0.09),Color("e9a18b")]]:
		Geo.box(self,route[0],route[1],route[2],0,0.25)
	# The long inner wall has a calm identity panel, not another course screen.
	var wall=Node3D.new(); add_child(wall); wall.position=Vector3(3,2,-7.2); wall.rotation.y=PI
	Geo.bevel(wall,Vector3.ZERO,Vector3(7,1.6,0.1),Color("263f49"),0,0.04)
	preload("res://scripts/world/WorldArchitecture.gd").wall_mount(wall,7,1.6)
	Geo.box(wall,Vector3(-3.2,0,0.065),Vector3(0.04,1.25,0.02),Color("96d3be"),0,0.3)
	Geo.text(wall,"PROSTOR PRO TVŮJ DALŠÍ KROK",Vector3(0,0.28,0.07),38,0.005,Color("c5e6d9"))
	Geo.text(wall,"Vyber si směr. Uč se vlastním tempem.",Vector3(0,-0.22,0.07),30,0.0045,Color("d3ddd5"))
	# Repeated wall accents help identify the return corridor without a maze.
	for z in [-10,-3,4]:
		Geo.bevel(self,Vector3(24.8,1.65,z),Vector3(0.07,1.4,1.8),Color("2a4550"),0,0.025)
		Geo.box(self,Vector3(24.74,1.65,z),Vector3(0.015,0.04,1.5),Color("d4a287"),0,0.3)

func plant(at: Vector3):
	preload("res://scripts/world/AcademyDecor.gd").plant(self,at)
