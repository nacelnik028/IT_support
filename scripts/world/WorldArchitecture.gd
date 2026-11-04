extends RefCounted

const Geo=preload("res://scripts/world/Geometry.gd")

# Door-local X runs across the opening; Z is the thickness of the partition.
static func portal(parent: Node3D, at: Vector3, yaw: float, width: float, accent: Color, pocket_side: float = 0) -> Node3D:
	var frame=Node3D.new(); frame.name="PortalFrame"; parent.add_child(frame); frame.position=at; frame.rotation.y=yaw
	for side in [-1,1]:
		if side==pocket_side:
			for face in [-1,1]: Geo.solid(frame,Vector3(side*(width*0.5+0.02),1.5,face*0.22),Vector3(0.12,3,0.1),Color("788a94"),0.65)
		else: Geo.solid(frame,Vector3(side*(width*0.5+0.02),1.5,0),Vector3(0.12,3,0.54),Color("788a94"),0.65)
		for face in [-1,1]: Geo.box(frame,Vector3(side*(width*0.5+0.02),1.5,face*0.277),Vector3(0.025,2.8,0.014),accent)
	Geo.solid(frame,Vector3(0,3.05,0),Vector3(width+0.16,0.16,0.54),Color("788a94"),0.65)
	return frame

static func pocket(parent: Node3D, at: Vector3, yaw: float, side: float, travel: float, accent: Color) -> Node3D:
	var frame=portal(parent,at,yaw,3,accent,side)
	var housing=Node3D.new(); housing.name="SlidingDoorPocket"; frame.add_child(housing)
	var span=travel+0.1
	var center=side*(1.5+span*0.5)
	# Two real skins leave a 0.30 m cavity for the 0.216 m decorated leaf.
	for face in [-1,1]:
		Geo.solid(housing,Vector3(center,1.5,face*0.2),Vector3(span,3,0.1),Color("374753"))
		Geo.box(housing,Vector3(center,2.65,face*0.257),Vector3(span-0.2,0.025,0.014),accent)
	Geo.solid(housing,Vector3(side*(1.55+span),1.5,0),Vector3(0.1,3,0.5),Color("374753"))
	Geo.solid(housing,Vector3(center,3.05,0),Vector3(span,0.1,0.5),Color("374753"))
	return housing

static func wall_mount(parent: Node3D, width: float, height: float, back: float = -1.0):
	for x in [-width*0.38,width*0.38]:
		for y in [-height*0.32,height*0.32]:
			Geo.box(parent,Vector3(x,y,back*0.16),Vector3(0.09,0.12,0.3),Color("869b9e"),0.55)

static func board_stand(object, width: float):
	object.set_meta("supported_board",true)
	var panel_height=object.get_children().filter(func(n): return n is CollisionShape3D)[0].shape.size.y
	var support_height=object.position.y-panel_height*0.5+0.02
	for x in [-width*0.32,width*0.32]:
		var foot=Vector3(x,-object.position.y+0.07,0.13)
		var post=Vector3(x,-object.position.y+support_height*0.5,0.1)
		Geo.box(object.visual,foot,Vector3(0.4,0.14,0.6),Color("526b76"),0.5)
		Geo.box(object.visual,post,Vector3(0.07,support_height,0.07),Color("869b9e"),0.65)
		Geo.collision(object,Vector3(0.4,0.14,0.6),foot)
		Geo.collision(object,Vector3(0.07,support_height,0.07),post)
