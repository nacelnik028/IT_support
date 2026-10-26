extends Node3D

const Geo=preload("res://scripts/world/Geometry.gd")
var world
var objects: Array = []
var door
var door_open=false
var dashboard: Label3D
var door_tween: Tween
var door_panels: Array=[]
var door_notice: Label3D
var last_dashboard=""

func build(owner_world):
	world=owner_world
	name="ProgrammingAcademy"
	Geo.solid(self,Vector3(0,-0.16,-14),Vector3(18,0.3,14),Color("344953"))
	Geo.solid(self,Vector3(0,2,-21),Vector3(18,4,0.25),Color("263b4c"))
	for x in [-9,9]: Geo.solid(self,Vector3(x,2,-14),Vector3(0.25,4,14),Color("304a58"))
	Geo.box(self,Vector3(0,4,-14),Vector3(18,0.15,14),Color("1b2835"))
	Geo.text(self,"PROGRAMMING ACADEMY",Vector3(0,3.35,-20.8),64,0.0045,Color("76e8cd"))
	Geo.text(self,"A / PYTHON LAB                 B / WEB DEVELOPMENT                 C / EXAMINATION",Vector3(0,2.95,-20.8),30,0.003)
	for x in [-6,0,6]:
		for z in [-11,-17]:
			Geo.box(self,Vector3(x,3.8,z),Vector3(3,0.05,0.35),Color("a0e8ee"),0,0.8)
			var light=OmniLight3D.new(); light.position=Vector3(x,3,z); light.omni_range=7; light.light_energy=2.5; light.light_color=Color("b2e7ff"); add_child(light)
	for station in [[-5,-17,"PYTHON-PC","Python Lab — editor","python"],[0,-17,"WEB-PC","Web Development Lab — editor a náhled","web"],[5,-17,"PROGRAM-EXAM","Examination Zone — praktická zkouška","exam"],[-5,-12,"PYTHON-PC-2","Python Lab — druhé pracoviště","python"],[0,-12,"WEB-PC-2","Web Development Lab — druhé pracoviště","web"]]:
		var at=Vector3(station[0],0,station[1])
		Geo.solid(self,at+Vector3(0,0.78,0),Vector3(2.3,0.12,1.1),Color("6b8490"),0.3)
		for dx in [-0.95,0.95]: Geo.solid(self,at+Vector3(dx,0.38,0),Vector3(0.08,0.7,0.8),Color("172936"),0.7)
		var pc=add_item(station[2],station[3],at+Vector3(0,1.42,-0.25),Vector3(1.6,0.9,0.12),station[4])
		Geo.box(pc.visual,Vector3(0,0,0.07),Vector3(1.48,0.78,0.02),Color("073a45"),0,0.5)
		Geo.text(pc.visual,station[4].to_upper()+"\n[E] OTEVŘÍT EDITOR",Vector3(0,0,0.09),32,0.002)
		Geo.box(self,at+Vector3(0,0.86,0.23),Vector3(0.85,0.04,0.3),Color("192c38"))
		for key in 12: Geo.box(self,at+Vector3(-0.38+key*0.068,0.888,0.23),Vector3(0.04,0.008,0.2),Color("76b9c0"))
	var board=add_item("PROGRAM-DASHBOARD","Moje programátorské znalosti — studijní tabule",Vector3(5,2,-20.65),Vector3(4.8,1.7,0.15),"dashboard")
	dashboard=Geo.text(board.visual,"Moje programátorské znalosti\n[E] LEKCE A VÝSLEDKY",Vector3(0,0,0.09),28,0.0023)
	var teacher=add_item("PROGRAM-INSTRUCTOR","Instruktor Ada — lekce a nápověda",Vector3(-5,1.6,-20),Vector3(1.5,2,0.15),"dashboard")
	Geo.box(teacher.visual,Vector3(0,0.45,0.12),Vector3(0.55,0.55,0.06),Color("64edcf"),0,1)
	Geo.text(teacher.visual,"ADA / INSTRUKTOR\nVítej! Vyber si lekci.\n[E] STUDIUM",Vector3(0,-0.35,0.12),27,0.002)
	add_item("PROGRAM-TERMINAL","Terminál výběru lekcí",Vector3(4,1.4,-9),Vector3(1,1,0.15),"dashboard")
	door=world.item("PROGRAM-DOOR","Dveře — Programming Academy","program_door",Vector3(-6.5,1.4,-7),Vector3(2.9,2.8,0.15))
	for z in [-6.65,-7.35]:
		var button=world.item("PROGRAM-DOOR-"+str(z),"Otevřít / zavřít Programming Academy [E]","program_door",Vector3(-4.65,1.35,z),Vector3(0.35,0.5,0.12))
		var label=Geo.text(button.visual,"[E]\nDVEŘE",Vector3(0,0,0.08),24,0.0015)
		if z<-7: label.rotation.y=PI
		door_panels.append({"object":button,"label":label})
	Geo.text(world,"PROGRAMMING ACADEMY",Vector3(-6.5,3.25,-6.8),34,0.0028,Color("76e8cd"))
	Geo.text(self,"ZPĚT / SERVEROVNA",Vector3(-6.5,3.25,-7.25),32,0.0028).rotation.y=PI
	preload("res://scripts/programming/AcademyVisuals.gd").new().build(self)

func add_item(id: String, title: String, at: Vector3, size_value: Vector3, category: String):
	var object=world.item(id,title,"programming",at,size_value,category)
	objects.append(object)
	return object

func contains_player() -> bool:
	if not is_instance_valid(world.player): return false
	var point=world.player.global_position
	var seam=0.15 if world.game!=null and world.game.game_mode.is_programming() else -0.15
	return AABB(Vector3(-8.9,-0.4,-20.9),Vector3(17.8,4.5,13.9+seam)).has_point(point)

func toggle_door() -> bool:
	if door_tween and door_tween.is_running(): return false
	if door_open and absf(world.player.position.z+7)<0.62 and absf(world.player.position.x+6.5)<1.8 and world.player.position.y<2.9:
		door_notice.text="PRŮCHOD OBSAZENÝ / USTUP OD DVEŘÍ"; return false
	door_open=not door_open
	door_tween=create_tween(); door_tween.tween_property(door,"position:x",-9.6 if door_open else -6.5,0.35)
	door_notice.text="PROGRAMMING ACADEMY / "+("OTEVŘENO" if door_open else "[E] OTEVŘÍT")
	for panel in door_panels:
		panel.label.text="[E]\n"+("ZAVŘÍT" if door_open else "OTEVŘÍT")
		panel.object.caption=("Zavřít" if door_open else "Otevřít")+" dveře — Programming Academy [E]"
	return true

func sync():
	if world.game==null: return
	var manager=world.game.programming
	var py=manager.progress.lessons.keys().filter(func(id): return id.begins_with("PYL")).size()
	var web=manager.progress.lessons.size()-py
	var passed=manager.progress.results.values().filter(func(result): return result.passed).size()
	var text="MOJE PROGRAMÁTORSKÉ ZNALOSTI\n\nPYTHON  %d / 15 lekcí     WEB  %d / 13 lekcí\nÚspěšné úlohy  %d / 60     XP  %d\n\n[E] OTEVŘÍT PŘEHLED A DOPORUČENÍ" % [py,web,passed,int(manager.progress.xp)]
	if text!=last_dashboard: dashboard.text=text; last_dashboard=text
	for object in objects: object.set_guided(world.game.game_mode.is_programming() and world.game.programming.mode=="learn" and not world.game.programming.current.is_empty() and object.console==("python" if world.game.programming.current.category=="python" else "web"))
