extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Comfort=preload("res://scripts/xr/VRSettings.gd")
var shell
var checks=0
var failures=0

func _init():
	var tag=str(OS.get_process_id())
	Saves.path_override="user://academy_test_hub_"+tag+".json"
	Settings.path_override="user://academy_test_hub_"+tag+".cfg"
	Comfort.path_override="user://academy_test_hub_"+tag+"_vr.cfg"
	Saves.save_game({},true)
	call_deferred("run")

func check(ok: bool, title: String):
	checks+=1
	if not ok: failures+=1; push_error(title)

func frames(n: int = 5):
	for i in n: await process_frame

func walk(point: Vector3):
	var p=shell.world.player
	shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	for i in 700:
		if shell.mode=="pause": shell.return_to_world(); Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		var offset=point-p.position; offset.y=0
		if offset.length()<0.13: break
		p.rotation.y=atan2(-offset.x,-offset.z)
		Input.action_press("walk_forward",minf(1,offset.length()*3)); Input.action_press("walk_fast")
		await physics_frame
	Input.action_release("walk_forward"); Input.action_release("walk_fast")
	await frames()
	check(Vector2(p.position.x-point.x,p.position.z-point.z).length()<0.4,"Fyzická trasa "+str(point)+" skutečně "+str(p.position))

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	var g=shell.ui.game; var p=shell.world.player
	g.english.progress.intro_seen=true
	# Trigger the actual main menu action on a new save.
	shell.ui.ui_targets["menu:primary"].pressed.emit()
	await frames()
	check(g.game_mode.is_hub() and not g.game_mode.is_education() and not g.active,"Nová hra začíná v neutrálním hubu bez úlohy")
	check(p.position.distance_to(shell.world.hub.SPAWN)<0.1,"Volný nástupní bod PC")
	shell.enter_world("Hlavní serverovna"); g.start_mission(6)
	g.sim.state.hosts["PVE-01"].hostname="hub-preserved"
	var original=g.snapshot().duplicate(true)
	shell.enter_world("Rozcestník akademie")
	check(g.suspended_campaign==original and not g.main_available(),"Hub odkládá skutečnou infrastrukturu a blokuje kampaňové akce")
	check(not g.start_mission(0) and g.suspended_campaign==original,"V hubu nelze restartovat kampaň")
	await walk(Vector3(-6,0.02,-10)); await walk(Vector3(-6,0.02,-5.5))
	check(g.game_mode.current==0 and g.current.id==7 and g.sim.state.hosts["PVE-01"].hostname=="hub-preserved","Chůze do serverovny obnoví ticket a stav")
	await walk(Vector3(-6,0.02,-10)); await walk(Vector3(16,0.02,-10)); await walk(Vector3(16,0.02,-5.5))
	check(g.game_mode.is_training(),"Přímá chůze hub → IT trénink")
	for mode in ["learn","practice","exam"]:
		check(g.start_lesson(1002,mode,false),"IT relace "+mode)
		await walk(Vector3(16,0.02,-10))
		check(g.game_mode.is_hub() and not g.active and g.education.sessions.is_empty(),"Odchod zruší "+mode)
		await walk(Vector3(16,0.02,-5.5))
	check(g.start_random("RAID","Vše",2,true,42),"Náhodná série")
	await walk(Vector3(16,0.02,-10))
	check(g.game_mode.is_hub() and not g.education.random.has("session"),"Série neunikne do hubu")
	await walk(Vector3(-7,0.02,-10)); await walk(Vector3(-7,0.02,-12)); await walk(Vector3(-11,0.02,-12))
	check(g.game_mode.is_programming(),"Přímá chůze hub → programování")
	g.programming.start("WEB28","practice"); g.programming.edit("index.html","<h1>Hub draft</h1>"); shell.open_programming("web")
	await walk(Vector3(-7,0.02,-12))
	check(g.game_mode.is_hub() and g.programming.current.is_empty() and shell.mode=="world","Editor a náhled zrušeny při odchodu")
	await walk(Vector3(19,0.02,-12)); await walk(Vector3(19,0.02,-11.5)); await walk(Vector3(23,0.02,-11.5)); await walk(Vector3(23,0.02,9.5)); await walk(Vector3(19,0.02,9.5))
	check(g.game_mode.is_english(),"Přímá označená chodba hub → Londýn")
	g.english.start("LON01","practice",0); shell.open_english()
	await walk(Vector3(23,0.02,9.5))
	check(g.game_mode.is_hub() and g.english.session.is_empty() and shell.mode=="world","Londýn opouští dočasný nákup a UI")
	await walk(Vector3(23,0.02,-11.5)); await walk(Vector3(19,0.02,-11.5))
	shell.enter_world("Hlavní serverovna")
	check(g.current.id==original.id and g.sim.state.hosts["PVE-01"].hostname=="hub-preserved","Všechny oblasti zachovaly odloženou kampaň")
	shell.enter_world("Rozcestník akademie"); check(g.save()==OK,"Save v hubu")
	var restored=preload("res://scripts/core/GameManager.gd").new()
	check(restored.current.id==7 and restored.sim.state.hosts["PVE-01"].hostname=="hub-preserved","Restart obnoví odloženou kampaň")
	var rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; p.add_child(rig); await frames()
	check(rig.can_teleport(Vector3(5,0,-11)),"Hub je skutečně v teleportovatelných mezích")
	check(rig.can_teleport(Vector3(23,0,0)),"Chodba je teleportovatelná")
	check(not rig.can_teleport(Vector3(26,0,-12)) and not rig.can_teleport(Vector3(4,5,-11)),"Žádné cíle mimo podlahu / nad stropem")
	check(not rig.can_teleport(Vector3(14,0,21.5)),"Řeka zůstává zakázaným cílem")
	shell.enter_world("Hlavní serverovna"); p.position=Vector3(-7,0.02,0)
	rig.left.global_transform=Transform3D(Basis().looking_at(Vector3(-1,-0.2,0)),Vector3(-7,1.4,0))
	rig.update_teleport()
	check(not rig.teleport_valid,"Skutečný teleportovací oblouk zastaví zavřené programovací dveře")
	shell.world.programming_room.toggle_door(); await create_timer(0.5).timeout
	rig.update_teleport()
	check(rig.teleport_valid and rig.teleport_point.x< -9,"Otevřené dveře zpřístupní skutečný teleportovací oblouk")
	check(Saves.rules().valid(Saves.load_game()),"Skutečný validovaný save")
	shell.queue_free(); await frames(); restored=null
	print("ACADEMY HUB: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
