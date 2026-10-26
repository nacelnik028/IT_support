extends RefCounted

const Geo = preload("res://scripts/world/Geometry.gd")
const Display = preload("res://scripts/world/MonitorDisplay.gd")
var world
var screens: Array = []
var environment: Environment
var forward = false
var perforated: ShaderMaterial

func build(scene):
	world = scene
	forward = RenderingServer.get_current_rendering_method()=="forward_plus"
	perforated = ShaderMaterial.new()
	perforated.shader = preload("res://assets/materials/perforated_metal.gdshader")
	lighting()
	architecture()
	corridor()
	for rack in world.racks: rack_details(rack)
	for workstation in world.workstations: workplace(workstation)
	for object in world.devices.values():
		match object.kind:
			"server": server_details(object)
			"disk": disk_details(object)
			"spares": cabinet(object)
			"computer", "monitor": screen(object)
			"door":
				if object.device_id=="ACADEMY-DOOR": door_details(object)
	for id in world.cable_meshes: cable(id)
	instructor()

func lighting():
	for node in world.get_children():
		if node is WorldEnvironment: environment = node.environment
		elif node is DirectionalLight3D:
			node.light_energy = 0.0
			node.shadow_enabled = false
		elif node is OmniLight3D:
			node.light_energy = 1.8
			node.omni_range = 8
			node.light_color = Color("c3ddec") if node.position.x<9 else Color("ffe3ba")
	environment.ambient_light_color = Color("8ca6b9")
	environment.ambient_light_energy = 0.32
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.15
	environment.tonemap_white = 6.0
	environment.ssao_enabled = true
	environment.ssao_radius = 0.65
	environment.ssao_intensity = 1.65
	environment.glow_enabled = true
	environment.glow_intensity = 0.45
	environment.glow_bloom = 0.035
	if forward:
		environment.ssr_enabled = true
		environment.ssr_max_steps = 40
		environment.ssil_enabled = true
		environment.ssil_intensity = 0.7
	for x in [-3.2,0.0,3.2,6.2]:
		spot(Vector3(x,3.6,0.2),Vector3(x,1.2,-3),Color("c1deef"),5.5,true)
	for x in [11.5,14.7,18.0]: spot(Vector3(x,3.5,0),Vector3(x,1.25,-3.5),Color("ffdfb1"),5.0,true)
	for z in [-5,4]:
		var light = OmniLight3D.new()
		light.position = Vector3(-6.7,2.5,z)
		light.light_color = Color("4ca8c1")
		light.light_energy = 1.8
		light.omni_range = 5
		world.add_child(light)
	# Godot4.7 reflection atlases leak GPU textures (#122498). Static interior
	# radiance plus SSR provides the highlights without allocating that atlas.
	var sky = Sky.new()
	var sky_material = ShaderMaterial.new()
	sky_material.shader = preload("res://assets/materials/interior_reflection.gdshader")
	sky.sky_material = sky_material
	sky.radiance_size = Sky.RADIANCE_SIZE_256
	environment.sky = sky
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

func spot(at: Vector3, target: Vector3, color: Color, energy: float, shadows: bool):
	var light = SpotLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = energy
	light.spot_range = 9
	light.spot_angle = 56
	light.spot_attenuation = 1.5
	light.shadow_enabled = shadows
	light.light_size = 0.18
	world.add_child(light)
	light.look_at(target)

func architecture():
	# Fine panel joints and surface finish replace the oversized black grid.
	for node in world.get_children():
		if node is MeshInstance3D and node.mesh is BoxMesh:
			var size = node.mesh.size
			if node.position.y<0.007 and (size.x>10 or size.z>10): node.visible = false
	var floor_material = ShaderMaterial.new()
	floor_material.shader = preload("res://assets/materials/raised_floor.gdshader")
	var floor_mesh = Geo.box(world,Vector3(0,-0.008,0),Vector3(18,0.012,14),Color.WHITE)
	floor_mesh.material_override = floor_material
	var academy_material = floor_material.duplicate()
	academy_material.set_shader_parameter("base_color",Color("70777b"))
	academy_material.set_shader_parameter("metal",0.08)
	Geo.box(world,Vector3(15,-0.008,0),Vector3(12,0.012,14),Color.WHITE).material_override = academy_material
	for x in range(-8,9,2):
		if x < -4: continue # Passage into Programming Academy.
		Geo.bevel(world,Vector3(x,1.9,-6.84),Vector3(1.94,3.4,0.04),Color("52616b"),0.25,0.015)
		Geo.box(world,Vector3(x-0.94,1.9,-6.805),Vector3(0.018,3.2,0.014),Color("111f28"))
	for x in range(10,21,2): Geo.bevel(world,Vector3(x,1.9,-6.84),Vector3(1.94,3.4,0.04),Color("697078"),0.2,0.012)
	for side in [-1,1]:
		for z in [-5.5,-3.5,-1.5,0.5]:
			Geo.bevel(world,Vector3(side*8.84,1.8,z),Vector3(0.04,3.2,1.92),Color("4b5a64"),0.2,0.012)
		var segments = [[0.0,13.7]] if side<0 else [[-2.5,8.8],[6.0,1.8]]
		for segment in segments:
			Geo.box(world,Vector3(side*8.78,0.12,segment[0]),Vector3(0.06,0.2,segment[1]),Color("182630"),0.6)
			Geo.box(world,Vector3(side*8.75,0.27,segment[0]),Vector3(0.025,0.025,segment[1]),Color("3a98ac"),0,1.4)
	for x in [-6.6,-1.6,3.4,8.4,13.4,18.4]:
		Geo.bevel(world,Vector3(x,3.9,0),Vector3(0.14,0.18,13.8),Color("27343d"),0.5,0.018)
	for z in range(-6,7,2):
		Geo.box(world,Vector3(6,3.93,z),Vector3(29.7,0.1,0.035),Color("44505a"),0.5)
	# Route markings stay low and preserve every existing walkable aisle.
	for z in [1.2,2.8,4.4]:
		var arrow = Geo.text(world,"›",Vector3(7.5,0.018,z),96,0.006,Color("d8c28d"))
		arrow.rotation_degrees = Vector3(-90,0,0)
	Geo.bevel(world,Vector3(8.88,3.05,3.5),Vector3(0.2,0.22,3.25),Color("1b2b34"),0.7,0.025)
	for z in [1.97,5.03]:
		Geo.bevel(world,Vector3(9,1.45,z),Vector3(0.3,2.9,0.13),Color("788a94"),0.75,0.025)
		Geo.box(world,Vector3(8.82,1.45,z),Vector3(0.02,2.75,0.025),Color("68cccb"),0,1.5)
	for node in world.get_children():
		if not node is Label3D: continue
		if node.text=="ADMINISTRACE":
			node.position = Vector3(-8.78,2.75,2.4)
			node.rotation.y = PI/2
			Geo.bevel(world,Vector3(-8.82,2.75,2.4),Vector3(0.05,0.34,2.1),Color("142b38"),0.35,0.01)
		elif node.text=="ZKUŠEBNÍ PRACOVIŠTĚ":
			node.position = Vector3(20.78,2.65,3.4)
			node.rotation.y = -PI/2
			Geo.bevel(world,Vector3(20.82,2.65,3.4),Vector3(0.05,0.34,2.65),Color("243a44"),0.35,0.01)
		elif node.text=="SÍŤOVÁ LABORATOŘ":
			Geo.bevel(world,node.position+Vector3(0,0,-0.04),Vector3(2.5,0.24,0.045),Color("1c303b"),0.4,0.01)
			for dx in [-1,1]: Geo.box(world,node.position+Vector3(dx,0.75,-0.06),Vector3(0.012,1.5,0.012),Color("71838d"),0.65)

func corridor():
	# A genuinely recessed corridor creates depth through the glazed wall.
	Geo.solid(world,Vector3(-4.5,-0.12,8.7),Vector3(7,0.24,3.5),Color("343c43"),0.1)
	Geo.box(world,Vector3(-4.5,3.5,8.7),Vector3(7,0.15,3.5),Color("27313a"))
	Geo.box(world,Vector3(-4.5,1.7,10.45),Vector3(7,3.5,0.15),Color("47464a"))
	for x in [-7.8,-1.2]: Geo.box(world,Vector3(x,1.7,8.7),Vector3(0.14,3.5,3.5),Color("293640"))
	for x in range(-8,0):
		for offset in [0.05,0.17,0.29]: Geo.box(world,Vector3(x+offset,1.6,10.34),Vector3(0.045,2.9,0.07),Color("947c65"),0.1)
	Geo.text(world,"NORTHSTAR",Vector3(-4.5,2.05,10.25),86,0.005,Color("d3ecec")).rotation.y = PI
	Geo.text(world,"IT OPERATIONS  /  ACADEMY",Vector3(-4.5,1.6,10.24),32,0.003,Color("9db8c7")).rotation.y = PI
	for x in [-6.5,-2.5]:
		Geo.box(world,Vector3(x,3.3,8.6),Vector3(0.1,0.035,2.7),Color("ffe0b0"),0,2.2)
		var light = OmniLight3D.new()
		light.position = Vector3(x,2.5,9.3)
		light.light_color = Color("ffd2a0")
		light.light_energy = 2.5
		light.omni_range = 5
		world.add_child(light)
	var glass = StandardMaterial3D.new()
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color = Color(0.45,0.7,0.76,0.15)
	glass.metallic = 0.12
	glass.roughness = 0.12
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	var pane = Geo.solid(world,Vector3(-4.5,2.1,6.98),Vector3(6.9,2.35,0.03),Color.WHITE)
	pane.get_child(0).material_override = glass
	for x in [-8.0,-4.5,-1.0]: Geo.bevel(world,Vector3(x,2.1,6.91),Vector3(0.08,2.5,0.12),Color("9fa9ae"),0.7,0.01)
	for y in [0.91,3.3]: Geo.bevel(world,Vector3(-4.5,y,6.91),Vector3(7.1,0.08,0.12),Color("9fa9ae"),0.7,0.01)
	for y in [1.4,1.47]: Geo.box(world,Vector3(-4.5,y,6.89),Vector3(6.8,0.025,0.012),Color("91b4bd"))

func rack_details(rack):
	for x in [-0.71,0.71]:
		Geo.bevel(rack,Vector3(x,1.35,0.66),Vector3(0.1,2.65,0.08),Color("53626c"),0.75,0.014)
		for i in 5: Geo.text(rack,str(5+i*5).pad_zeros(2),Vector3(x,0.5+i*0.4,0.712),18,0.0011,Color("c4d1d6"))
	for y in [0.14,2.67]: Geo.bevel(rack,Vector3(0,y,0.64),Vector3(1.52,0.12,0.11),Color("50606c"),0.7,0.015)
	for x in [-0.57,0.57]:
		for z in [-0.45,0.45]:
			Geo.cylinder(rack,Vector3(x,0.065,z),0.075,0.06,Color("0a1117"),0.3)
	for y in [0.3,1.95,2.15]:
		Geo.box(rack,Vector3(0,y,0.54),Vector3(1.18,0.125,0.022),Color.WHITE).material_override = perforated
	var tag = Geo.bevel(rack,Vector3(0,2.49,0.68),Vector3(0.87,0.2,0.025),Color("0a1923"),0.2,0.01)
	Geo.text(tag,"RACK "+str(rack.get_meta("rack_id","LAB")),Vector3(0,0,0.018),36,0.0026)
	Geo.box(rack,Vector3(0.78,1.35,0.61),Vector3(0.018,2.6,0.025),Color("59bdd4"),0,1.25)
	# Side panel seams, captive fasteners and lower perforated cable access.
	for side in [-1,1]:
		Geo.bevel(rack,Vector3(side*0.79,1.35,-0.05),Vector3(0.025,2.38,1.02),Color("1d2933"),0.6,0.009)
		for y in [0.3,2.35]:
			for z in [-0.45,0.35]:
				var screw = Geo.cylinder(rack,Vector3(side*0.808,y,z),0.012,0.008,Color("81909a"),0.8,8)
				screw.rotation.z = PI/2

func server_details(object):
	var height = 0.9 if object.device_id=="NAS-01" and not object.laboratory else 0.4
	var body = object.visual.get_child(0)
	for child in object.visual.get_children():
		if child is Label3D: child.visible = false
	body.material_override = Geo.material(Color("63717c") if object.device_id.begins_with("PVE") else Color("3b4a56"),0.65)
	for x in [-0.57,0.57]:
		Geo.tube(body,[Vector3(x,-height*0.28,0.5),Vector3(x,-height*0.2,0.565),Vector3(x,height*0.2,0.565),Vector3(x,height*0.28,0.5)],0.015,Color("a5b2b9"),0.8)
	for x in [-0.59,0.59]:
		for y in [-height*0.35,height*0.35]:
			var screw = Geo.cylinder(body,Vector3(x,y,0.482),0.012,0.012,Color("b1c0c8"),0.8,8)
			screw.rotation.x = PI/2
	Geo.bevel(body,Vector3(-0.03,height*0.28,0.499),Vector3(0.91,0.065,0.018),Color("0b1720"),0.2,0.004)
	var title = str(object.name) if object.laboratory else object.device_id+"  /  "+object.console.to_upper()
	Geo.text(body,title,Vector3(-0.03,height*0.28,0.514),30,0.0016,Color("e0ecf1"))
	for i in 4:
		Geo.box(body,Vector3(-0.43+i*0.045,-height*0.26,0.49),Vector3(0.028,0.038,0.014),Color("101c25"),0.6)
	Geo.box(body,Vector3(0.05,-height*0.26,0.492),Vector3(0.18,0.06,0.014),Color.WHITE).material_override = perforated
	var power = Geo.cylinder(body,Vector3(0.48,0.02,0.49),0.028,0.014,Color("a1b3ba"),0.75,20)
	power.rotation.x = PI/2
	Geo.text(body,"⏻",Vector3(0.48,0.02,0.503),24,0.001,Color("223746"))
	Geo.ring(body,Vector3(0.36,0.02,0.5),0.076,Color("899fa9"))

func disk_details(object):
	var body = object.visual.get_child(0)
	body.material_override = Geo.material(Color("4a5b67"),0.6)
	object.indicator.position = Vector3(0.103,0.015,0.09)
	for child in object.visual.get_children():
		if child!=body and child!=object.indicator and child is MeshInstance3D: child.reparent(body)
	Geo.bevel(body,Vector3(0,0,0.056),Vector3(0.234,0.16,0.02),Color("152832"),0.5,0.007)
	Geo.bevel(body,Vector3(0,-0.043,0.074),Vector3(0.19,0.033,0.032),Color("b6c2c6"),0.75,0.005)
	Geo.box(body,Vector3(0,0.036,0.069),Vector3(0.12,0.038,0.008),Color.WHITE).material_override = perforated
	for x in [-0.103,0.103]:
		var screw = Geo.cylinder(body,Vector3(x,0.058,0.07),0.007,0.005,Color("a7b9c5"),0.8,8)
		screw.rotation.x = PI/2

func cable(id: String):
	var host = world.devices[id]
	var at = host.position
	var points = [at+Vector3(0.81,0,0.65),at+Vector3(0.94,-0.12,0.73),at+Vector3(0.98,0.32,0.55),Vector3(at.x+0.96,2.95,-3.4),Vector3(at.x+0.7,3.38,-3.5)]
	var mesh = Geo.tube(world,points,0.017,Color("3e9bb6") if id.begins_with("PVE") else Color("d49d53"))
	mesh.set_meta("dynamic",true)
	world.cable_meshes[id].queue_free()
	world.cable_meshes[id] = mesh
	Geo.tube(world,[at+Vector3(-0.83,0,0.6),at+Vector3(-0.96,-0.18,0.64),Vector3(at.x-0.97,0.2,-3.5),Vector3(at.x-0.9,0.18,-4.4)],0.018,Color("18232d"))

func workplace(info):
	var at: Vector3 = info.at
	Geo.bevel(world,at+Vector3(0,0.79,0),Vector3(2.04,0.12,1.12),Color("8999a1"),0.15,0.025)
	Geo.bevel(world,at+Vector3(0,0.86,0.25),Vector3(0.69,0.025,0.25),Color("101d28"),0.25,0.007)
	for row in 5:
		for column in 15:
			Geo.bevel(world,at+Vector3(-0.292+column*0.041,0.878,0.155+row*0.041),Vector3(0.035,0.012,0.032),Color("667a86") if row==0 else Color("c7d2d7"),0.1,0.003)
	Geo.bevel(world,at+Vector3(0,0.882,0.355),Vector3(0.22,0.012,0.025),Color("c7d2d7"),0.1,0.003)
	Geo.bevel(world,at+Vector3(0.57,0.854,0.25),Vector3(0.33,0.009,0.34),Color("1b3040"),0.1,0.008)
	Geo.bevel(world,at+Vector3(0.55,0.885,0.23),Vector3(0.075,0.05,0.13),Color("7b919d"),0.2,0.022)
	Geo.box(world,at+Vector3(0.55,0.913,0.22),Vector3(0.006,0.003,0.026),Color("54d1ce"),0,1)
	Geo.tube(world,[at+Vector3(0,0.88,0.15),at+Vector3(0,0.9,-0.05),at+Vector3(0.07,0.85,-0.4)],0.006,Color("132332"))
	# Ergonomic seat shell and arm rests around the existing chair collider.
	Geo.bevel(world,at+Vector3(0,0.51,1.1),Vector3(0.58,0.14,0.54),Color("28404c"),0.1,0.055)
	var back = Geo.bevel(world,at+Vector3(0,0.9,1.37),Vector3(0.57,0.73,0.13),Color("2b424d"),0.1,0.055)
	back.rotation.x = -0.09
	for side in [-1,1]:
		Geo.tube(world,[at+Vector3(side*0.23,0.5,1.26),at+Vector3(side*0.33,0.69,1.27),at+Vector3(side*0.33,0.7,0.94)],0.018,Color("637c87"),0.65)
		Geo.bevel(world,at+Vector3(side*0.33,0.72,1.1),Vector3(0.075,0.045,0.31),Color("142630"),0,0.02)
	for i in 5:
		var angle = TAU*i/5
		var end = at+Vector3(cos(angle)*0.31,0.08,1.1+sin(angle)*0.31)
		Geo.tube(world,[at+Vector3(0,0.18,1.1),end],0.027,Color("6a818c"),0.7)
		Geo.cylinder(world,end,0.045,0.065,Color("111d27"),0.1).rotation.z = PI/2
	var tower = Geo.bevel(world,at+Vector3(0.64,0.38,-0.08),Vector3(0.25,0.63,0.48),Color("1b2a34"),0.5,0.02)
	Geo.box(tower,Vector3(-0.09,0,0.245),Vector3(0.015,0.48,0.012),Color("68d5cd"),0,1)
	Geo.text(world,info.id,at+Vector3(0.6,0.86,0.46),24,0.0016)

func cabinet(object):
	for x in [-0.47,0.47]: Geo.bevel(object.visual,Vector3(x,0,0.34),Vector3(0.045,1.74,0.04),Color("a1b0b7"),0.7,0.008)
	for y in [-0.6,-0.25,0.1]:
		Geo.bevel(object.visual,Vector3(0,y,0.337),Vector3(0.87,0.29,0.025),Color("445963"),0.5,0.01)
		Geo.bevel(object.visual,Vector3(0,y,0.37),Vector3(0.19,0.025,0.03),Color("9aadb6"),0.75,0.006)
	Geo.text(object.visual,"SAS  /  SATA",Vector3(0,-0.78,0.36),22,0.002)

func door_details(object):
	var body = object.visual.get_child(0)
	body.material_override = Geo.material(Color("71808b"),0.6)
	for side in [-1,1]:
		Geo.bevel(body,Vector3(side*0.085,-0.05,0),Vector3(0.025,2.4,2.55),Color("354b59"),0.5,0.009)
		Geo.box(body,Vector3(side*0.103,0,1.23),Vector3(0.012,2.3,0.025),Color("76d3cf"),0,1.3)
		for z in [-0.5,0.5]: Geo.box(body,Vector3(side*0.108,0.35,z),Vector3(0.012,1.05,0.04),Color("708e9b"),0.6)

func screen(object):
	for child in object.visual.get_children():
		if child is Label3D: child.visible = false
	var viewport = SubViewport.new()
	viewport.size = Vector2i(1600,440) if object.kind=="monitor" else Vector2i(1024,600)
	viewport.disable_3d = true
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	world.add_child(viewport)
	var content = Display.new()
	content.size = Vector2(viewport.size)
	content.application = object.console
	content.laboratory = object.laboratory
	content.overview = object.kind=="monitor"
	viewport.add_child(content)
	var mesh = QuadMesh.new()
	mesh.size = Vector2(4.95,1.35) if content.overview else Vector2(1.1,0.6)
	var surface = MeshInstance3D.new()
	surface.mesh = mesh
	surface.position.z = 0.088 if content.overview else 0.065
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = viewport.get_texture()
	material.albedo_color = Color("c4d9e3")
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	surface.material_override = material
	object.visual.add_child(surface)
	if content.overview: world.monitoring.visible = false
	screens.append({"viewport":viewport,"control":content,"surface":surface})

func instructor():
	var object = world.devices["INSTRUCTOR"]
	Geo.bevel(object.visual,Vector3(0,-0.68,0),Vector3(0.86,0.16,0.6),Color("253d49"),0.6,0.025)
	Geo.box(object.visual,Vector3(0,-0.59,0),Vector3(0.65,0.025,0.4),Color("5cd7d0"),0,2)
	Geo.text(object.visual,"NORTHSTAR\nVIRTUÁLNÍ INSTRUKTOR",Vector3(0,-0.38,0.2),24,0.0016)
	for x in [-0.34,0.34]: Geo.box(object.visual,Vector3(x,0.1,0.15),Vector3(0.022,1.2,0.025),Color("47adb9"),0,1.4)

func sync(game):
	for entry in screens:
		entry.control.game = game
		entry.control.queue_redraw()
		entry.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func release():
	# Break ViewportTexture references before their render targets leave the tree.
	for entry in screens:
		if is_instance_valid(entry.surface): entry.surface.material_override.albedo_texture = null
		if is_instance_valid(entry.viewport): entry.viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	screens.clear()
