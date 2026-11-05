extends RefCounted

# A small physics-checked route graph is built only when a destination is chosen.
# It uses the same capsule clearance as walking, never crosses the river or walls.
const TARGETS={"tickets":["Sam / TICKETS",Vector3(12,0.02,8.8)],"info":["Alex / INFORMATION",Vector3(6,0.02,11.4)],"terminal":["Platební terminál",Vector3(10,0.02,8.7)],"gate":["Kontrola vstupenek",Vector3(16,0.02,18)],"tower":["Elizabeth Tower",Vector3(4,0.02,24)]}
var shell
var target=""
var run_id=-1
var route: Array[Vector3]=[]
var marker: Label3D
var arrived=false

func clear():
	target=""; route.clear(); arrived=false
	if is_instance_valid(marker): marker.queue_free()
	marker=null

func start(destination: String):
	clear()
	var manager=shell.ui.game.english
	if manager.session.is_empty() or manager.session.completed or manager.session.get("exam_ended",false) or not TARGETS.has(destination) or not shell.ui.game.game_mode.is_english(): return
	target=destination; run_id=manager.session.run_id
	var grid=AStarGrid2D.new(); grid.region=Rect2i(0,0,43,43); grid.cell_size=Vector2(0.5,0.5); grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER; grid.update()
	var shape=CapsuleShape3D.new(); shape.radius=0.36; shape.height=1.8
	var query=PhysicsShapeQueryParameters3D.new(); query.shape=shape; query.exclude=[shell.world.player.get_rid()]
	var space=shell.world.get_world_3d().direct_space_state
	for x in 43:
		for z in 43:
			var point=Vector3(x*0.5,0.04,7.5+z*0.5)
			query.transform=Transform3D(Basis(),point+Vector3(0,0.9,0))
			grid.set_point_solid(Vector2i(x,z),not shell.world.english_room.walkable_point(point) or not space.intersect_shape(query,1).is_empty())
	var from=cell(shell.world.player.global_position); var to=cell(TARGETS[target][1])
	# A player can stand between grid cells next to a counter. Find the nearest
	# clear start cell, with a capsule sweep proving the short joining segment.
	if grid.is_point_solid(from):
		var nearest=from; var distance=INF
		for x in range(maxi(0,from.x-3),mini(43,from.x+4)):
			for z in range(maxi(0,from.y-3),mini(43,from.y+4)):
				var c=Vector2i(x,z); var p=Vector3(x*0.5,0.04,7.5+z*0.5)
				query.transform=Transform3D(Basis(),shell.world.player.global_position+Vector3(0,0.92,0)); query.motion=p-shell.world.player.global_position; query.motion.y=0
				if not grid.is_point_solid(c) and p.distance_to(shell.world.player.global_position)<distance and space.cast_motion(query)[0]>=0.999:
					nearest=c; distance=p.distance_to(shell.world.player.global_position)
		from=nearest
	if not grid.is_point_solid(from) and not grid.is_point_solid(to):
		for c in grid.get_id_path(from,to): route.append(Vector3(c.x*0.5,0.04,7.5+c.y*0.5))
	if route.is_empty(): clear(); shell.return_to_world(); shell.room_notice.text="Cesta není dostupná. Vyjdi do volné uličky a zvol cíl znovu."; shell.notice_time=6; return
	marker=Label3D.new(); marker.text="▼"; marker.font_size=64; marker.pixel_size=0.003; marker.modulate=Color("9bbfff"); marker.billboard=BaseMaterial3D.BILLBOARD_ENABLED; shell.world.add_child(marker)
	shell.return_to_world(); update()

func cell(point: Vector3) -> Vector2i:
	return Vector2i(clampi(roundi(point.x*2),0,42),clampi(roundi((point.z-7.5)*2),0,42))

func update():
	if target=="": return
	var manager=shell.ui.game.english
	if not shell.ui.game.game_mode.is_english() or manager.session.is_empty() or manager.session.get("run_id",-1)!=run_id or manager.session.completed or manager.session.get("exam_ended",false): clear(); return
	var player=shell.world.player
	var destination=TARGETS[target][1]
	var offset=destination-player.global_position; offset.y=0
	if arrived and offset.length()>=0.8: clear(); return
	if offset.length()<0.8:
		arrived=true; route.clear()
		if is_instance_valid(marker): marker.queue_free(); marker=null
		shell.direction.text="%s · %s interakce" % [TARGETS[target][0],"trigger" if shell.vr_active else OS.get_keycode_string(shell.ui.display_settings.bindings.interact)]
		shell.instruction.text="CÍL NA DOSAH\nPokračuj ve stejné situaci u pracoviště."
		return
	if shell.mode=="world" and not route.is_empty() and route.all(func(point): return point.distance_to(player.global_position)>1.25):
		start(target); return
	while route.size()>1 and player.global_position.distance_to(route[0])<0.55: route.pop_front()
	var waypoint=route[0] if not route.is_empty() else destination
	if is_instance_valid(marker): marker.global_position=route[mini(3,route.size()-1)]+Vector3(0,0.45,0); marker.visible=shell.mode=="world"
	var distance=player.global_position.distance_to(waypoint)
	for i in range(1,route.size()): distance+=route[i-1].distance_to(route[i])
	var local=player.global_basis.inverse()*(waypoint-player.global_position)
	var angle=atan2(local.x,-local.z)
	var arrow="↑" if absf(angle)<0.35 else "↓" if absf(angle)>2.4 else "→" if angle>0 else "←"
	shell.direction.text="%s %s · %.1f m po cestě" % [arrow,TARGETS[target][0],distance]
	shell.instruction.text="CESTA K CÍLI\nSleduj modrou značku dalšího bodu.\n"+manager.current_step()

func interacted(station: String):
	if station==target: clear()
