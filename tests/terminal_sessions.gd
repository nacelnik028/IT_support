extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Game=preload("res://scripts/core/GameManager.gd")
const Terminal=preload("res://scripts/simulation/TerminalParser.gd")
var ui
var checks=0
var failures=0
var saves=0

func _init():
	var suffix="_gpu" if DisplayServer.get_name()!="headless" else ""
	Saves.path_override="user://academy_test_terminal_sessions"+suffix+".json"
	Settings.path_override="user://academy_test_terminal_sessions"+suffix+".cfg"
	Saves.save_game({},true)
	Settings.new().save_settings()
	call_deferred("run")

func check(ok, message: String):
	checks+=1
	if not ok: failures+=1; push_error(message)

func frames():
	for i in 3: await process_frame

func command(line: String, host: String="PVE-01") -> String:
	ui.terminal_host=host
	ui.navigate("Terminál")
	await frames()
	var input=ui.form_controls._terminal.command
	input.text=line
	input.text_submitted.emit(line)
	await frames()
	return ui.terminal_history

func same(a, b) -> bool:
	return JSON.parse_string(JSON.stringify(a))==JSON.parse_string(JSON.stringify(b))

func run():
	ui=load("res://scenes/main_menu/Main.tscn").instantiate()
	root.add_child(ui)
	await frames()
	var game=ui.game
	if "--verify-packaged" in OS.get_cmdline_user_args():
		check(FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://tests/terminal_sessions.gd"),"Test běží nad daty samostatného EXE bez zdrojového projektu")
	game.persistence_changed.connect(func(): saves+=1)
	game.start_mission(3,true)
	game.sim.state.hosts["PVE-01"].repo="HOST-ONE"
	game.sim.state.hosts["PVE-01"].updated=false
	game.sim.state.hosts["PVE-02"].repo="HOST-TWO"
	game.sim.state.hosts["PVE-02"].updated=true
	var text=await command("pveversion -v","PVE-02")
	check("Repo: HOST-TWO / updated: true" in text,"PVE-02 vypíše vlastní repozitář a aktualizace")
	text=await command("pveversion -v","PVE-01")
	check(text.ends_with("Repo: HOST-ONE / updated: false\n"),"PVE-01 si zachová vlastní diagnostiku")
	game.sim.state.hosts["HV-01"].vmms=false
	game.sim.state.hosts["HV-02"].vmms=true
	text=await command("Get-VMHost","HV-02")
	check(text.ends_with("VMMS true\n"),"Get-VMHost čte VMMS z HV-02")
	text=await command("Get-Service vmms","HV-02")
	check(text.ends_with("vmms Running\n"),"Diagnostické příkazy se shodují na stavu HV-02")
	text=await command("Get-VMHost","HV-01")
	check(text.ends_with("VMMS false\n"),"Get-VMHost čte VMMS z HV-01")
	check(game.undo_states.is_empty(),"Diagnostika nevytváří undo")
	for host in ["PVE-99","HV-99"]:
		check("Neznámý cílový hostitel" in Terminal.execute(game.sim,"ip route",host),"Neplatný hostitel je odmítnut bez pádu: "+host)
	game.start_mission(3,true)
	var previous_saves=saves
	await command("qm shutdown 100")
	check(game.sim.state.vms["100"].status=="Off" and game.undo_states.size()==1,"PVE vypnutí přes skutečné UI vytvoří jeden zásah")
	check(saves==previous_saves+1,"Měnící příkaz se ukládá právě jednou")
	check(Game.new().sim.state.vms["100"].status=="Off","Terminál uloží skutečně změněný stav")
	await command("qm list")
	check(game.undo_states.size()==1,"Dotaz nepřekryje poslední zásah")
	check(game.undo() and game.sim.state.vms["100"].status=="Running","Undo vrátí vypnutí z terminálu")
	await command("qm shutdown 100")
	await command("qm start 100")
	check(game.undo_states.size()==2 and game.sim.state.vms["100"].status=="Running","PVE start i vypnutí mají samostatné undo")
	check(game.undo() and game.sim.state.vms["100"].status=="Off","Undo vrátí poslední start")
	game.start_mission(3,true)
	await command("Stop-VM -Name 'FS01'","HV-01")
	await command("Start-VM -VMName FS01","HV-01")
	check(game.undo_states.size()==2 and game.sim.state.vms["200"].status=="Running","Hyper-V start i vypnutí mají samostatné undo")
	check(game.undo() and game.sim.state.vms["200"].status=="Off","Undo vrátí Hyper-V start")
	var before=game.sim.state.vms.duplicate(true)
	var undo_count=game.undo_states.size()
	for line in ["qm start 200","qm start 100; qm shutdown 200","qm nonsense 100","qm start"]:
		await command(line)
		check(game.sim.state.vms==before and game.undo_states.size()==undo_count,"Odmítnutý vstup parseru nemění VM ani historii: "+line)
	await command("Start-VM -Name APP01","HV-01")
	check(game.sim.state.vms==before and game.undo_states.size()==undo_count,"Nesprávný hostitel ani VM nepřejde na jinou platformu")
	game.start_mission(3,false)
	await command("qm shutdown 100")
	check(game.undo_states.is_empty() and game.sim.state.vms["100"].status=="Off","Běžná kampaň zachová pravidlo bez undo")
	game.start_mission(3,true)
	game.sim.state.vms["100"].vlan=39
	game.save()
	game.enter_training()
	var suspended=game.suspended_campaign.duplicate(true)
	var solutions_path="res://tests/lesson_solutions.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--lesson-solutions="): solutions_path=argument.trim_prefix("--lesson-solutions=")
	var solutions=JSON.parse_string(FileAccess.get_file_as_string(solutions_path))
	for mode in ["learn","practice","exam"]:
		check(game.start_lesson(1010,mode,false),"Spuštění skutečné lekce Dynamic Memory: "+mode)
		for operation in solutions["1010"]:
			if operation is Dictionary:
				game.notify_event(operation.event)
			elif operation[0]=="power":
				var vm=game.sim.get_vm(str(operation[1].vm))
				var step=int(game.tutorial.session.step)
				var history=game.undo_states.size()
				var line=("Start-VM" if operation[1].power=="Start" else "Stop-VM")+" -Name "+vm.name
				await command(line,vm.host)
				check(vm.status==("Running" if operation[1].power=="Start" else "Off"),"Terminál provede výukový zásah: "+mode)
				check(game.undo_states.size()==history+(0 if mode=="exam" else 1),"Historie respektuje režim lekce: "+mode)
				if mode=="learn": check(int(game.tutorial.session.step)==step+1,"Terminál potvrdí skutečnou událost výukového kroku")
			else:
				check(game.apply(operation[0],operation[1]).ok,"Příprava lekce: "+str(operation[0]))
		check(game.complete().ok and not game.unsaved,"Lekce je dokončitelná po terminálových příkazech: "+mode)
		check(same(game.suspended_campaign,suspended),"Výuka nezmění odloženou kampaň: "+mode)
		game.start_lesson(1010,mode,false)
		game.sim.state.vms["200"].locked=true
		var mistakes=game.tutorial.session.mistakes.size()
		var errors=int(game.sim.state.errors)
		var topic=game.current.topic
		var topic_errors=int(game.progress.mistakes.get(topic,0))
		await command("Start-VM -Name FS01","HV-01")
		check(int(game.sim.state.errors)==errors+1 and game.tutorial.session.mistakes.size()==mistakes+1,"Odborně chybný příkaz se hodnotí v lekci: "+mode)
		check(int(game.progress.mistakes.get(topic,0))==topic_errors+1,"Chyba terminálu ovlivní doporučení tématu: "+mode)
	game.resume_campaign()
	check(game.sim.state.vms["100"].vlan==39 and game.sim.state.vms["100"].status=="Running","Návrat obnoví celou původní kampaň")
	var inside=[true]
	game.room_probe=func(): return inside[0]
	game.enter_training()
	game.start_lesson(1010,"learn",false)
	inside[0]=false
	text=game.execute_terminal("Stop-VM -Name FS01","HV-01")
	check("není aktivní" in text and game.session_kind=="campaign" and not game.game_mode.is_training(),"Odchod místností odmítne opožděný příkaz a obnoví MAIN")
	check(game.sim.state.vms["200"].status=="Running" and game.sim.state.vms["100"].vlan==39,"Opožděný příkaz nezmění obnovenou produkci")
	game.room_probe=Callable()
	game.start_mission(3,true)
	var original=FileAccess.get_file_as_string(Saves.save_path())
	var temp=ProjectSettings.globalize_path(Saves.save_path()+".tmp")
	check(DirAccess.make_dir_absolute(temp)==OK,"Příprava skutečného selhání zápisu v testovací cestě")
	await command("qm shutdown 100")
	check(game.unsaved and game.save_message!="" and game.sim.state.vms["100"].status=="Off","Terminál zachová změnu v paměti a ohlásí selhání zápisu")
	check(FileAccess.get_file_as_string(Saves.save_path())==original,"Terminál při chybě nepoškodí poslední save")
	check(DirAccess.remove_absolute(temp)==OK and game.save()==OK,"Opakované uložení terminálové změny uspěje")
	check(Game.new().sim.state.vms["100"].status=="Off","Opakovaný zápis obnoví poslední skutečný stav")
	game.active=false
	before=game.sim.state.duplicate(true)
	check("není aktivní" in game.execute_terminal("qm start 100","PVE-01") and game.sim.state==before,"Bez aktivní relace se terminálový zásah neprovede")
	ui.queue_free()
	await frames()
	await create_timer(0.15).timeout
	print("TERMINAL SESSIONS: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
