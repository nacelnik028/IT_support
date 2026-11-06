extends RefCounted

const Geo=preload("res://scripts/world/Geometry.gd")

# Door-local X runs across the opening; Z is the thickness of the partition.
static func portal(parent: Node3D, at: Vector3, yaw: float, width: float, accent: Color, pocket_side: float = 0) -> Node3D:
	var frame=Node3D.new(); frame.name="PortalFrame"; parent.add_child(frame); frame.position=at; frame.rotation.y=yaw
	for side in [-1,1]:
		if side==pocket_side:
			for face in [-1,1]: Geo.solid(frame,Vector3(side*(width*0.5+0.02),1.5,face*0.22),Vector3(0.12,3,0.1),Color("788a94"),0.65)
		else: Geo.solid(frame,Vector3(side*(width*0.5+0.02),1.5,0),Vector3(0.12,3,0.54),Color("788a94"),0.65)
		for face in [-1,1]: Geo.box(frame,Vector3(side*(width*0.5+0.02),1.5,face*0.277),Vector3(0.06,2.8,0.014),accent,0,0.55)
	Geo.solid(frame,Vector3(0,3.05,0),Vector3(width+0.16,0.16,0.54),Color("788a94"),0.65)
	frame.set_meta("academy_portal",true)
	# Stepped wall collars sit outside the original clear opening and pocket.
	# The same construction is finished on both sides of every partition.
	for face in [-1,1]:
		for side in [-1,1]:
			var x=side*(width*0.5+0.115)
			Geo.bevel(frame,Vector3(x,1.5,face*0.245),Vector3(0.31,3,0.1),Color("243a46"),0.45,0.015)
			Geo.bevel(frame,Vector3(x,1.5,face*0.325),Vector3(0.27,3,0.08),Color("8d9ca0"),0.65,0.018)
			Geo.bevel(frame,Vector3(x,0.19,face*0.38),Vector3(0.27,0.38,0.035),Color("374f5c"),0.55,0.012)
			Geo.box(frame,Vector3(x,2.61,face*0.37),Vector3(0.13,0.38,0.014),accent)
			for y in [0.5,2.85]:
				var bolt=Geo.cylinder(frame,Vector3(x,y,face*0.373),0.023,0.014,Color("253b46"),0.7,8); bolt.rotation.x=PI/2
		Geo.bevel(frame,Vector3(0,3.16,face*0.25),Vector3(width+0.54,0.28,0.1),Color("243a46"),0.45,0.018)
		Geo.bevel(frame,Vector3(0,3.16,face*0.325),Vector3(width+0.46,0.22,0.08),Color("8d9ca0"),0.65,0.018)
		Geo.box(frame,Vector3(0,3.16,face*0.373),Vector3(width-0.3,0.055,0.014),Color("374f5c"),0.5)
	return frame

static func portal_sign(parent: Node3D, title: String, subtitle: String, accent: Color, width: float = 3.5) -> Node3D:
	var sign_node=Node3D.new(); sign_node.name="PortalDirectory"; parent.add_child(sign_node)
	# Mount the existing board below ceiling fins, with its lower edge over the
	# lintel. Letters stay in the sightline of a player arriving at an angle.
	Geo.bevel(sign_node,Vector3(0,-0.16,0.05),Vector3(width,0.46,0.09),Color("213e4b"),0.15,0.02)
	Geo.box(sign_node,Vector3(0,0.05,0.105),Vector3(width-0.12,0.035,0.016),accent,0,0.55)
	# Physical letter height is readable while approaching, not just close up.
	var heading=Geo.text(sign_node,title,Vector3(0,-0.11,0.105),40,0.005,accent)
	var sign_font=heading.font if heading.font!=null else ThemeDB.fallback_font
	var font_width=sign_font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,heading.font_size).x
	heading.pixel_size=minf(heading.pixel_size,(width-0.22)/maxf(1,font_width))
	Geo.text(sign_node,subtitle,Vector3(0,-0.30,0.105),26,0.0036,Color("e6efeb"))
	return sign_node

static func sliding_leaf(parent: Node3D, width: float, accent: Color, number: String, title: String):
	for face in [-1,1]:
		var surface_node=Node3D.new(); parent.add_child(surface_node); surface_node.rotation.y=PI if face<0 else 0.0
		Geo.bevel(surface_node,Vector3(0,0,0.088),Vector3(width-0.16,2.62,0.026),Color("354b59"),0.5,0.01)
		Geo.bevel(surface_node,Vector3(0,0.24,0.107),Vector3(width-0.36,1.66,0.012),Color("263e4b"),0.4,0.005)
		for y in [-1.13,1.12]: Geo.box(surface_node,Vector3(0,y,0.109),Vector3(width-0.3,0.06,0.014),Color("a2afb0"),0.7)
		Geo.box(surface_node,Vector3(0,0.87,0.118),Vector3(width-0.45,0.035,0.008),accent)
		Geo.text(surface_node,number,Vector3(0,0.49,0.125),40,0.0026,accent)
		Geo.text(surface_node,title,Vector3(0,0.12,0.125),29,0.0025)
		Geo.text(surface_node,"Ovladač vedle průchodu",Vector3(0,-0.26,0.125),22,0.0023,Color("b5c8cf"))
		for x in [-width*0.38,width*0.38]:
			Geo.bevel(surface_node,Vector3(x,-0.86,0.11),Vector3(0.2,0.22,0.015),Color("71808b"),0.65,0.006)

static func control_surround(parent: Node3D, accent: Color):
	Geo.bevel(parent,Vector3(0,0,-0.035),Vector3(0.39,0.56,0.045),Color("8d9ca0"),0.65,0.014)
	Geo.box(parent,Vector3(0,-0.245,-0.006),Vector3(0.29,0.04,0.012),accent,0,0.6)

static func pocket(parent: Node3D, at: Vector3, yaw: float, side: float, travel: float, accent: Color) -> Node3D:
	var frame=portal(parent,at,yaw,3,accent,side)
	var housing=Node3D.new(); housing.name="SlidingDoorPocket"; frame.add_child(housing)
	var span=travel+0.1
	var center=side*(1.5+span*0.5)
	# Two real skins leave a 0.30 m cavity for the 0.216 m decorated leaf.
	for face in [-1,1]:
		Geo.solid(housing,Vector3(center,1.5,face*0.2),Vector3(span,3,0.1),Color("374753"))
		Geo.box(housing,Vector3(center,2.65,face*0.257),Vector3(span-0.2,0.025,0.014),accent)
		# Service cover, end seam and overhead drive enclosure never enter the cavity.
		Geo.bevel(housing,Vector3(center,1.53,face*0.28),Vector3(span-0.24,2.12,0.05),Color("425966"),0.4,0.015)
		Geo.bevel(housing,Vector3(center,3.18,face*0.27),Vector3(span,0.26,0.11),Color("8d9ca0"),0.65,0.018)
		for x in [center-span*0.5+0.2,center+span*0.5-0.2]:
			for y in [0.56,2.5]:
				var bolt=Geo.cylinder(housing,Vector3(x,y,face*0.315),0.022,0.014,Color("a2afb0"),0.7,8); bolt.rotation.x=PI/2
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
