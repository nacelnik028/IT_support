extends Node3D

var shell
var streams := {}
var racks := {}
var effects: Array = []
var doors: Array = []
var played := {}
var step_distance := 0.0
var duck := 1.0
var focused := true

func _notification(what: int):
	if what==MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		focused = false
		if not effects.is_empty(): silence()
	elif what==MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN: focused = true

func _ready():
	for name_value in ["Environment","Effects"]:
		if AudioServer.get_bus_index(name_value)<0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count-1,name_value)
			AudioServer.set_bus_send(AudioServer.bus_count-1,"Master")
	var manifest: Dictionary = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/service_audio.json"))
	for clip in manifest.clips: streams[clip.id] = load(clip.path)
	streams.rack = streams.rack.duplicate()
	streams.rack.loop_mode = AudioStreamWAV.LOOP_FORWARD
	streams.rack.loop_begin = 0
	streams.rack.loop_end = 16000
	# Four shared rack emitters, four reusable one-shot voices, three doors.
	for pair in [["PVE-01",0.0],["HV-01",-3.2],["NAS-01",3.2],["BACKUP-01",6.2]]:
		var source := voice("Environment")
		source.position = Vector3(pair[1],1.4,-3)
		source.stream = streams.rack
		source.max_distance = 14
		source.volume_db = -24
		racks[pair[0]] = source
	for index in 4: effects.append(voice("Effects"))
	for object in [shell.world.devices["ACADEMY-DOOR"],shell.world.programming_room.door,shell.world.network_room.workshop.hinge]:
		var source := voice("Effects")
		source.stream = streams.door
		doors.append({"object":object,"last":object.global_transform,"moving":false,"source":source})
	shell.world.player.ground_moved.connect(moved)
	shell.ui.game.physical_event.connect(physical)
	for model in [shell.ui.game.network_lab.network,shell.ui.game.network_workshop.network]:
		model.physical_event.connect(func(kind: String, _device: String):
			if shell.ui.game.game_mode.is_network_lab(): effect(kind,shell.world.player.global_position))

func voice(bus_name: String) -> AudioStreamPlayer3D:
	var source := AudioStreamPlayer3D.new()
	source.bus = bus_name
	source.max_distance = 16
	source.unit_size = 2
	add_child(source)
	return source

func active() -> bool:
	return focused and shell.mode not in ["menu","pause","introduction"] and (not shell.vr_active or shell.xr_rig.focused)

func effect(kind: String, at: Vector3):
	if not active() or not streams.has(kind): return
	var source: AudioStreamPlayer3D = effects[0]
	for candidate in effects:
		if not candidate.playing:
			source = candidate
			break
	source.stop()
	source.global_position = at
	source.stream = streams[kind]
	source.volume_db = -12
	source.play()
	played[kind] = int(played.get(kind,0))+1

func physical(kind: String, device: String):
	var at: Vector3 = shell.world.devices[device].global_position if shell.world.devices.has(device) else shell.world.player.global_position
	effect(kind,at)

func moved(distance: float):
	if shell.mode!="world" or not active():
		step_distance = 0
		return
	step_distance += distance
	if step_distance>=0.8:
		step_distance = fmod(step_distance,0.8)
		effect("step",shell.world.player.global_position+Vector3(0,0.15,0))

func silence():
	for source in racks.values()+effects: source.stop()
	for entry in doors: entry.source.stop()
	step_distance = 0

func _physics_process(delta):
	var enabled := active()
	duck = move_toward(duck,0.25 if shell.speech.playing else 1.0,delta*3)
	for name_value in ["Environment","Effects"]:
		var level: float = shell.ui.display_settings.environment_volume if name_value=="Environment" else shell.ui.display_settings.effects_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(name_value),linear_to_db(maxf(0.0001,level*duck)))
	for id in racks:
		var source: AudioStreamPlayer3D = racks[id]
		var members: Array = [id]
		if id=="PVE-01": members.append("PVE-02")
		if id=="HV-01": members.append("HV-02")
		var running: bool = enabled and members.any(func(host): return shell.ui.game.main_sim.state.hosts[host].online and shell.ui.game.main_sim.state.world.devices[host].power_connected)
		if running and not source.playing: source.play()
		source.volume_db = move_toward(source.volume_db,-24.0 if running else -80.0,delta*90)
		if not enabled or not running and source.volume_db<=-79: source.stop()
	for entry in doors:
		var current: Transform3D = entry.object.global_transform
		var moving: bool = not current.is_equal_approx(entry.last)
		if enabled and moving and not entry.moving:
			entry.source.global_position = current.origin
			entry.source.volume_db = -18
			entry.source.play()
			played.door = int(played.get("door",0))+1
		if not moving or not enabled: entry.source.stop()
		entry.last = current
		entry.moving = moving
	if not enabled: silence()
