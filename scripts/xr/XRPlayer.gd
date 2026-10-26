extends XROrigin3D

const Geo = preload("res://scripts/world/Geometry.gd")
var shell
var settings = preload("res://scripts/xr/VRSettings.gd").new()
var monitor
var active = false
var snap_ready = true
var teleporting = false
var teleport_valid = false
var teleport_point = Vector3.ZERO
var turn_cooldown = 0.0
var scroll_cooldown = 0.0
var hold_hand: Node3D
var marker: MeshInstance3D
var wrist: Label3D
var beams = {}
var spare_objects = []
var grip_nodes = {}
var focused = true
var signals_connected = false
var previous_physics_ticks = 60
var teleport_line: MeshInstance3D
@onready var head: XRCamera3D = $Head
@onready var left: XRController3D = $LeftHand
@onready var right: XRController3D = $RightHand

func _ready():
	settings.load_settings()
	monitor = preload("res://scripts/xr/VRMonitor.gd").new()
	shell.world.add_child(monitor)
	for hand in [left,right]:
		var grip = XRController3D.new()
		grip.tracker = hand.tracker
		grip.pose = "grip"
		add_child(grip)
		grip_nodes[hand] = grip
		Geo.box(grip,Vector3.ZERO,Vector3(0.065,0.10,0.12),Color("5fe4ce"))
		var beam = Geo.box(hand,Vector3(0,0,-0.6),Vector3(0.003,0.003,1.2),Color("5fe4ce"),0,1)
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		beams[hand] = beam
		hand.button_pressed.connect(func(action): pressed(hand,action))
		hand.button_released.connect(func(action): released(hand,action))
	marker = Geo.box(shell.world,Vector3.ZERO,Vector3(0.5,0.012,0.5),Color("5fe4ce"),0,1)
	marker.hide()
	teleport_line=MeshInstance3D.new()
	teleport_line.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shell.world.add_child(teleport_line)
	wrist = Geo.text(grip_nodes[left],"",Vector3(0,0.17,-0.15),26,0.0009)
	wrist.no_depth_test = false
	wrist.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	build_physical_targets()
	calibrate_height()

func activate(render_xr: bool = true):
	active = true
	show()
	shell.world.player.camera.current = false
	head.current = true
	get_viewport().use_xr = render_xr
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	previous_physics_ticks=Engine.physics_ticks_per_second
	Engine.physics_ticks_per_second = 72
	var interface = XRServer.find_interface("OpenXR")
	if interface != null and interface.is_initialized() and not signals_connected:
		signals_connected=true
		interface.session_focussed.connect(func(): focused=true)
		interface.session_visible.connect(lose_focus)
		interface.session_stopping.connect(lose_focus)
		interface.session_loss_pending.connect(lose_focus)
		interface.session_begun.connect(configure_refresh)
		configure_refresh()
	shell.ui_layer.reparent(monitor.viewport)
	shell.ui.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	shell.ui.size=Vector2(1600,900)
	shell.ui.scale = Vector2.ONE
	mode_changed()

func deactivate():
	active=false
	hide()
	monitor.hide()
	monitor.click(false)
	shell.ui_layer.reparent(shell)
	shell.ui.sync_display_layout()
	get_viewport().use_xr=false
	shell.world.player.camera.current=true
	Engine.physics_ticks_per_second=previous_physics_ticks
	shell.world.carried_disk.reparent(shell.world.player.camera)
	shell.world.carried_disk.position=Vector3(0.32,-0.3,-0.65)
	for object in spare_objects: object.collision_layer=0; object.hide()

func configure_refresh():
	var interface = XRServer.find_interface("OpenXR")
	if interface == null or not interface.is_initialized(): return
	for rate in interface.get_available_display_refresh_rates():
		if absf(float(rate)-72.0)<0.1: interface.display_refresh_rate=72.0; break
	if interface.is_foveation_supported(): interface.foveation_level=1; interface.foveation_dynamic=true

func lose_focus():
	if not active: return
	focused = false
	teleporting = false
	teleport_line.hide()
	monitor.click(false)
	if shell.mode == "world": shell.pause_menu()

func calibrate_height():
	position.y = maxf(0.0,1.68-head.position.y) if settings.seated else 0.0

func mode_changed():
	if not active: return
	shell.world.player.set_enabled(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	monitor.visible = shell.mode != "world"
	if monitor.visible:
		monitor.place_in_front(head)
		monitor.viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		monitor.click(false)
		monitor.viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func ray_hit(hand: Node3D, distance: float = 3.2) -> Dictionary:
	var query = PhysicsRayQueryParameters3D.create(hand.global_position,hand.global_position-hand.global_basis.z*distance,5,[shell.world.player.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query)

func allowed(object) -> bool:
	if not is_instance_valid(object): return false
	if object.has_meta("laboratory"): return object.get_meta("laboratory") == shell.ui.game.game_mode.is_training()
	if "laboratory" in object: return object.kind == "door" or object.laboratory == shell.ui.game.game_mode.is_training()
	return false

func pressed(hand: XRController3D, action: String):
	if not active or not focused or not hand.get_has_tracking_data(): return
	if action in ["menu_button","by_button"]:
		if shell.mode == "world": shell.pause_menu()
		else: shell.return_to_world()
		return
	if action == "ax_button":
		if shell.mode == "world": shell.show_tasks()
		else: monitor.place_in_front(head)
		return
	if shell.mode != "world":
		if action == "trigger_click":
			var pixel = monitor.pixel_at(hand.global_position,-hand.global_basis.z)
			monitor.point(pixel)
			if pixel.x >= 0: monitor.click(true)
		return
	if action == "primary_click" and hand == left:
		teleporting = true
		return
	if action == "trigger_click":
		var hit = ray_hit(hand)
		if not hit.is_empty(): interact_target(hit.collider,false,hand)
	elif action == "grip_click":
		var hit = ray_hit(grip_nodes[hand],0.65)
		if not hit.is_empty(): interact_target(hit.collider,true,hand)
		if shell.ui.game.sim.state.world.held != "": attach_disk(hand)

func released(_hand: XRController3D, action: String):
	if action == "trigger_click": monitor.click(false)
	if action == "primary_click" and _hand == left:
		if teleporting and teleport_valid: teleport_to(teleport_point)
		teleporting = false
		marker.hide()
		teleport_line.hide()
	if action == "grip_click" and hold_hand==grip_nodes[_hand]:
		var hit=ray_hit(hold_hand,0.65)
		if not hit.is_empty() and allowed(hit.collider) and "kind" in hit.collider:
			if hit.collider.kind=="spares": shell.ui.game.apply("physical_return_spare",{})
			elif hit.collider.kind=="disk": shell.interact(hit.collider)
		shell.world.carried_disk.reparent(self)
		shell.world.carried_disk.position=Vector3(0.32,1.0,-0.4)
		hold_hand = null

func interact_target(object, grip: bool, hand: XRController3D):
	shell.ui.game.reconcile_room()
	if not allowed(object): return
	if object.has_meta("spare"):
		if grip:
			var result = shell.ui.game.apply("physical_spare",{"spare":object.get_meta("spare")})
			if result.ok: attach_disk(hand)
			else: shell.message=result.text; shell.show_spares()
		return
	if object.has_meta("power"):
		var device = object.get_meta("power")
		var online = shell.ui.game.sim.state.hosts[device].online
		shell.message = shell.ui.game.apply("physical_power",{"device":device,"operation":"Shutdown" if online else "Start"}).text
		wrist.text=shell.message
		return
	if not "kind" in object: return
	if grip and object.kind == "cable":
		shell.pending_cable=object.slot
		wrist.text="Konektor %s → port SW-CORE / trigger" % object.slot
		return
	# Disk removal/insertion retains serial, backup and confirmation checks.
	shell.interact(object)

func attach_disk(hand):
	hold_hand = grip_nodes[hand]
	var disk = shell.world.carried_disk
	disk.reparent(hold_hand)
	disk.position = Vector3(0,0,-0.14)
	disk.rotation = Vector3.ZERO

func build_physical_targets():
	for object in shell.world.devices.values():
		if object.kind == "server":
			var power = StaticBody3D.new()
			power.collision_layer=4
			power.collision_mask=0
			power.set_meta("power",object.device_id)
			power.set_meta("laboratory",object.laboratory)
			object.add_child(power)
			power.position=Vector3(-0.33,0.10,0.49)
			Geo.collision(power,Vector3(0.09,0.09,0.06))
			Geo.box(power,Vector3.ZERO,Vector3(0.07,0.07,0.04),Color("5fe4ce"),0,0.5)
	var stock = shell.ui.game.main_sim.state.world.stock
	for laboratory in [false,true]:
		var cabinet = shell.world.devices.get("TRAIN-SPARES" if laboratory else "SPARES")
		if cabinet == null: continue
		var index = 0
		for id in stock:
			var item = StaticBody3D.new()
			item.collision_layer=4
			item.collision_mask=0
			item.set_meta("spare",id)
			item.set_meta("laboratory",laboratory)
			cabinet.add_child(item)
			item.position=Vector3(-0.3+(index%3)*0.29,-0.5+floori(index/3.0)*0.29,0.44)
			Geo.collision(item,Vector3(0.23,0.20,0.18))
			Geo.box(item,Vector3.ZERO,Vector3(0.22,0.08,0.18),Color("bac8ce"),0.5)
			Geo.text(item,id,Vector3(0,0.05,0.10),20,0.0006)
			spare_objects.append(item)
			index+=1

func can_teleport(point: Vector3) -> bool:
	if point.y < -0.05 or point.y > 0.15 or point.x < -8.4 or point.x > 20.4 or absf(point.z)>6.4: return false
	var shape = CapsuleShape3D.new()
	shape.radius=0.31
	shape.height=1.8
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape=shape
	query.transform=Transform3D(Basis(),point+Vector3(0,0.94,0))
	query.collision_mask=1
	query.exclude=[shell.world.player.get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(query,1).is_empty()

func teleport_to(point: Vector3) -> bool:
	if not can_teleport(point): return false
	shell.world.player.global_position=point+Vector3(0,0.02,0)
	position.x=-head.position.x
	position.z=-head.position.z
	shell.world.player.velocity=Vector3.ZERO
	shell.ui.game.reconcile_room()
	shell.store_pose()
	return true

func update_teleport():
	teleport_valid=false
	var points=PackedVector3Array()
	var start=left.global_position
	points.append(start)
	var velocity=-left.global_basis.z*5.5+Vector3.UP*1.2
	for segment in 30:
		var time=(segment+1)*0.055
		var next=left.global_position+velocity*time+Vector3.DOWN*4.9*time*time
		var query=PhysicsRayQueryParameters3D.create(start,next,1,[shell.world.player.get_rid()])
		var hit=get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			points.append(hit.position)
			teleport_point=hit.position
			teleport_valid=hit.normal.y>0.9 and can_teleport(teleport_point)
			break
		start=next
		points.append(next)
	marker.visible=teleport_valid
	if teleport_valid: marker.global_position=teleport_point+Vector3.UP*0.02
	var line=ImmediateMesh.new()
	var material=StandardMaterial3D.new()
	material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color=Color("5fe4ce") if teleport_valid else Color("f5a567")
	line.surface_begin(Mesh.PRIMITIVE_LINE_STRIP,material)
	for point in points: line.surface_add_vertex(point)
	line.surface_end()
	teleport_line.mesh=line
	teleport_line.show()

func snap_turn(axis: float):
	if absf(axis)<0.3: snap_ready=true
	if absf(axis)<0.7 or not snap_ready: return
	snap_ready=false
	var before=head.global_position
	shell.world.player.rotate_y(deg_to_rad(-settings.snap_degrees*signf(axis)))
	var difference=before-head.global_position
	position+=shell.world.player.global_basis.inverse()*Vector3(difference.x,0,difference.z)

func _physics_process(delta):
	if not active: return
	var p=shell.world.player
	for hand in [left,right]:
		beams[hand].visible=hand.get_has_tracking_data()
		grip_nodes[hand].visible=hand.get_has_tracking_data()
	var head_tracker=XRServer.get_tracker("head")
	if not focused or head_tracker==null or not head_tracker.has_pose("default"): return
	if not head_tracker.get_pose("default").has_tracking_data:
		lose_focus()
		return
	var stick=right.get_vector2("primary")
	# Room-scale walking also reconciles training boundaries while a monitor is open.
	var offset=head.global_position-p.global_position
	p.velocity=Vector3(offset.x,0,offset.z)/maxf(delta,0.001)
	var previous=p.global_position
	p.move_and_slide()
	position-=p.global_basis.inverse()*(p.global_position-previous)
	shell.ui.game.reconcile_room()
	if shell.mode == "world":
		snap_turn(stick.x)
		var move=left.get_vector2("primary")
		var forward=-head.global_basis.z
		forward.y=0
		forward=forward.normalized()
		var direction=(forward*move.y+head.global_basis.x*move.x)
		direction.y=0
		p.velocity=direction.limit_length()*settings.speed if settings.locomotion=="smooth" else Vector3.ZERO
		p.velocity.y=-0.5
		p.move_and_slide()
		if teleporting: update_teleport()
		var hit=ray_hit(right)
		p.update_focus(hit.collider if not hit.is_empty() and hit.collider.has_method("set_focus") else null)
		wrist.text=shell.status_label.text+"\n"+shell.instruction.text+"\nB/Y: menu  A/X: mise\nLevý stick klik: teleport"
	else:
		var pixel=monitor.pixel_at(right.global_position,-right.global_basis.z) if right.get_has_tracking_data() else Vector2(-1,-1)
		if pixel.x<0 and left.get_has_tracking_data(): pixel=monitor.pixel_at(left.global_position,-left.global_basis.z)
		monitor.point(pixel)
		scroll_cooldown-=delta
		if absf(stick.y)>0.5 and scroll_cooldown<=0:
			monitor.scroll(stick.y)
			scroll_cooldown=0.12
	for object in spare_objects:
		var sim=shell.ui.game.training_sim if object.get_meta("laboratory") else shell.ui.game.main_sim
		object.visible=sim.state.world.stock[object.get_meta("spare")].available
		object.collision_layer=4 if object.visible else 0
	shell.ui.game.reconcile_room()
