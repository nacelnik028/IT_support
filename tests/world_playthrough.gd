extends SceneTree

var shell
var failures = 0
var checks = 0
var shots = false

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_world_playthrough.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_world_playthrough.cfg"
	call_deferred("run")

func check(value, message):
	checks += 1
	if not value: failures += 1; push_error(message)

func button(prefix: String):
	var found = find_button(shell.overlay,prefix)
	check(found != null,"Viditelné tlačítko: "+prefix)
	if found: found.pressed.emit()

func find_button(node, prefix):
	if node is Button and node.text.begins_with(prefix): return node
	for child in node.get_children():
		var found = find_button(child,prefix)
		if found: return found
	return null

func fill_identity(serial: String):
	for node in descendants(shell.overlay):
		if node is LineEdit: node.text = serial
		if node is CheckButton: node.button_pressed = true

func descendants(node) -> Array:
	var result = []
	for child in node.get_children(): result.append(child); result.append_array(descendants(child))
	return result

func use(id: String, at: Vector3, aim_offset: Vector3 = Vector3.ZERO):
	shell.return_to_world()
	var p = shell.world.player
	p.position = at
	p.rotation = Vector3.ZERO
	p.camera.rotation = Vector3.ZERO
	p.camera.look_at(shell.world.devices[id].global_position+aim_offset)
	for i in 3: await physics_frame
	p.poll_target()
	check(p.target == shell.world.devices[id],"Raycast před E: "+id)
	var key = InputEventKey.new()
	key.physical_keycode = KEY_E
	key.keycode = KEY_E
	key.pressed = true
	root.push_input(key,true)
	await process_frame

func capture(name: String):
	if not shots: return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("res://test-output/"+name+".png")==OK,"GPU snímek "+name)

func run():
	shots = "--screenshots" in OS.get_cmdline_user_args() and DisplayServer.get_name()!="headless"
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	shell.ui.game.start_mission(52,true)
	shell.enter_world()
	await use("NAS-01",Vector3(3.65,0.02,-0.85),Vector3(0.48,0.32,0.48))
	check(shell.ui.game.sim.state.world.inspected.get("NAS-01",false),"E validuje fyzickou kontrolu NAS")
	await use("RAID:2",Vector3(3.35,0.02,-0.8))
	fill_identity("DC-002")
	button("Rozsvítit identifikační LED")
	check(shell.ui.game.sim.state.world.identified.get("RAID:2",false),"Identifikace přes skutečný formulář")
	fill_identity("DC-002")
	button("Vytáhnout vybraný disk")
	var dialog
	for node in shell.overlay.get_children():
		if node is ConfirmationDialog: dialog = node
	check(dialog != null and dialog.visible,"Potvrzení fyzického zásahu")
	if dialog: dialog.confirmed.emit()
	await process_frame
	check(shell.ui.game.sim.state.disks["2"].health=="Missing","Potvrzené tlačítko skutečně vytáhlo disk")
	shell.world.sync_state()
	check(not shell.world.devices["RAID:2"].visual.get_child(0).visible,"Model zobrazuje prázdný slot")
	await capture("world-disk-removed")
	await use("SPARES",Vector3(-7.6,0.02,-0.3))
	button("SP-SAS-2000")
	check(shell.ui.game.sim.state.world.held=="SPARE-2T","Disk lze vyzvednout ze skutečné 3D skříně")
	await use("RAID:2",Vector3(3.35,0.02,-0.8))
	fill_identity("")
	button("Vložit nesený náhradní disk")
	check(shell.ui.game.sim.state.disks["2"].serial=="SP-SAS-2000","Vložený disk má skutečný nový serial")
	check(shell.ui.game.sim.state.raid.rebuilding,"Vložení přes 3D UI spustilo rebuild")
	button("Sledovat obnovu")
	check(shell.ui.game.sim.state.raid.progress==50,"Rebuild50% ve formuláři")
	button("Sledovat obnovu")
	button("Ověřit konečný stav")
	check(shell.ui.game.sim.state.verified.raid,"Fyzická servisní cesta obnovila zdravé pole")
	shell.show_tasks()
	button("Předat vyřešený ticket")
	check(shell.ui.game.finished and not shell.ui.game.unsaved,"Nová mise dokončena a uložená přes skutečné ovládání")
	# Choose an actual switch port after carrying the actual host connector.
	shell.ui.game.start_mission(54,true)
	shell.enter_world()
	await use("NIC:HV-01",Vector3(-2.39,0.02,-0.7))
	button("Uchopit konektor")
	check(shell.pending_cable=="HV-01" and shell.mode=="world","Uchopení kabelu vrátí hráče do prostoru")
	await use("PORT:3",Vector3(-6.87,0.02,-3.5))
	check(shell.ui.game.sim.state.world.devices["HV-01"].port==3 and shell.pending_cable=="","E ve správném fyzickém portu přepojí server")
	check(preload("res://scripts/simulation/NetworkSimulator.gd").probe(shell.ui.game.sim.state,"200").app,"Opravený kabel obnovil skutečnou službu")
	shell.open_app("Storage")
	for action in shell.ui.form_controls:
		check(not action.begins_with("physical_"),"Fyzický zásah se provádí u3D zařízení")
	# The two rooms and console must remain readable at small and UHD sizes.
	shell.ui.begin_lesson(1002,"learn",false)
	shell.world.player.position = Vector3(15,0.02,5.5)
	shell.update_guidance()
	await capture("world-academy")
	shell.open_app("Proxmox")
	await capture("world-console")
	if shots:
		shell.ui.apply_display_settings(Vector2i(3840,2160),false)
		shell.return_to_world()
		await process_frame
		await process_frame
		check(shell.chrome.scale.x>2.0,"HUD a fyzické formuláře mají skutečné4K měřítko")
		shell.show_disk(shell.world.devices["TRAIN-RAID:2"])
		await capture("world-service-4k")
		shell.ui.apply_display_settings(Vector2i(1280,720),false)
	# Block selection through the rear wall (interaction never ignores geometry).
	shell.return_to_world()
	var p = shell.world.player
	p.position = Vector3(0,0.02,-6.5)
	p.rotation = Vector3.ZERO
	p.camera.rotation = Vector3.ZERO
	for i in 3: await physics_frame
	p.poll_target()
	check(p.target==null,"Stěna blokuje paprsek a interakci")
	check(shell.world.batched_instances>300,"Opakovaná statická geometrie se dávkuje")
	shell.ui.page = "menu"
	shell.ui.draw_ui()
	find_button(shell.ui,"Kampaň a přehled").pressed.emit()
	check(not shell.ui.game.training and shell.ui.page=="Tickety","Kampaň po volném tréninku znovu zapne odemykání a XP")
	shell.ui.page = "menu"
	shell.ui.draw_ui()
	find_button(shell.ui,"15 praktických").pressed.emit()
	check(shell.ui.game.training and shell.ui.mission_filter=="3D praxe","Přímý vstup do15 otevřených3D úkolů")
	if DisplayServer.get_name()!="headless": print("GPU METRICS: draw calls %d, visible objects %d; batched %d" % [Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),shell.world.batched_instances])
	shell.queue_free()
	await process_frame
	print("WORLD PLAYTHROUGH: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
