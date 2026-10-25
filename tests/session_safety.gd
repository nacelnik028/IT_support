extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
var checks=0
var failures=0

func check(ok, message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func fresh():
	check(Saves.save_game({},true)==OK,"Čistý izolovaný save")
	return Game.new()

func _init():
	Saves.path_override="user://academy_test_session_safety.json"
	var game=fresh()
	game.start_mission(3,true)
	game.sim.state.vms["100"].vlan=39
	game.enter_training()
	game.start_random("Sítě","Začátečník",3,true,91)
	for operation in game.current.reference: game.apply(operation[0],operation[1])
	check(game.complete().ok and game.next_random(),"První úloha vyhodnocena, druhá otevřená")
	game.apply("inspect",{"scope":"Network"})
	var batch=game.education.random.duplicate(true)
	var campaign=game.suspended_campaign.duplicate(true)
	check(game.restart_current(),"Restart aktuální náhodné úlohy")
	check(game.session_kind=="random" and game.current.id==20001,"Restart zachoval režim a ID")
	for key in ["queue","position","results","hints_allowed","area","difficulty"]:
		check(game.education.random[key]==batch[key],"Restart zachoval "+key)
	check(game.suspended_campaign==campaign,"Restart zachoval odloženou kampaň")
	check(game.sim.state.journal.is_empty() and game.undo_states.is_empty() and not game.finished and game.hints_used==0,"Restart vyčistil jen aktuální scénář")
	var before=JSON.stringify({"session":game.snapshot(),"education":game.education,"campaign":game.suspended_campaign,"progress":game.progress,"undo":game.undo_states})
	var disk=FileAccess.get_file_as_string(Saves.save_path())
	for index in [-1,game.missions.size(),20000]:
		check(not game.start_mission(index),"Odmítnutí neplatného indexu")
		check(before==JSON.stringify({"session":game.snapshot(),"education":game.education,"campaign":game.suspended_campaign,"progress":game.progress,"undo":game.undo_states}),"Odmítnutí nemění paměť")
		check(disk==FileAccess.get_file_as_string(Saves.save_path()),"Odmítnutí nemění soubor")
	check(not game.restore_session({"id":20000,"kind":"campaign"}),"Neplatná obnova odmítnuta před změnami")
	check(game.session_kind=="random" and game.current.id==20001,"Odmítnutá obnova zachovala relaci")
	var random_session=game.snapshot()
	game.resume_campaign()
	game.sim.state.vms["100"].vlan=42
	game.enter_training()
	check(game.restore_session(random_session),"Přímá obnova relace také odkládá aktuální stav")
	game.resume_campaign()
	check(game.sim.state.vms["100"].vlan==42,"Přímá obnova neztratila změny kampaně")
	# All lesson modes: cache switches within the room, discard on actual exit.
	for mode in ["learn","practice","exam"]:
		for restart in [false,true]:
			game=fresh()
			game.start_mission(3,true)
			game.sim.state.vms["100"].vlan=39
			game.enter_training()
			check(game.start_random("Sítě","Začátečník",2,true,91),"Sestavení série")
			game.sim.state.vms["100"].dns="192.168.20.55"
			check(game.start_lesson(1002,mode,false),"Série → lekce "+mode)
			game.apply("vm_identity",{"id":"101","name":"DRAFT01"})
			check(game.resume_random(),"Lekce → uložená série ve stejné místnosti")
			check(game.sim.state.vms["100"].dns=="192.168.20.55","Série uchovala svou konfiguraci")
			check(game.start_lesson(1002,mode),"Série → uložená lekce")
			check(game.sim.state.vms["101"].name=="DRAFT01","Lekce uchovala konfiguraci")
			check(game.undo_states.is_empty(),"Obnovená lekce nemá undo z jiné relace")
			check(game.resume_random(),"Lekce → uložená série")
			if restart: game=Game.new()
			game.resume_campaign()
			check(game.sim.state.vms["100"].vlan==39,"Návrat/restart zachoval nejnovější změny kampaně")
			check(game.education.sessions.is_empty() and not game.education.random.has("session"),"Odchod zrušil dočasné relace")
			game.enter_training()
			check(not game.resume_random(),"Opuštěná série se sama neobnoví")
			check(game.start_lesson(1002,mode) and game.sim.state.vms.get("101",{}).get("name","")!="DRAFT01","Návrat spustí novou lekci bez předchozího konceptu")
			game.resume_campaign()
			var state=game.sim.state.duplicate(true)
			check(game.undo_states.is_empty() and not game.undo() and game.sim.state==state,"Cizí undo nevloží lekci do kampaně")
			game.resume_campaign()
			check(game.sim.state==state,"Opakovaný návrat kampaň nerestartuje")
	game=fresh()
	game.start_mission(3,true)
	game.apply("inspect",{"scope":"Network"})
	check(not game.undo_states.is_empty(),"Undo vzniká uvnitř tréninku")
	game.start_mission(4,true)
	check(game.undo_states.is_empty() and not game.undo(),"Jiná mise nemá předchozí undo")
	game.apply("inspect",{"scope":"Storage"})
	check(game.undo(),"Undo aktuálního tréninku funguje")
	game.apply("inspect",{"scope":"Storage"})
	game.set_campaign_mode(false)
	check(game.undo_states.is_empty() and not game.undo(),"Přepnutí režimu čistí undo")
	game=Game.new()
	check(game.undo_states.is_empty(),"Restart aplikace neobnovuje undo")
	var sim=game.Simulator.new()
	sim.reset({})
	var network=sim.state.network.duplicate(true)
	var vms=sim.state.vms.duplicate(true)
	var result=sim.act("switch",{"name":"vmbr0","type":"Private","adapter":"Ethernet2","management":true})
	check(not result.ok,"Hyper-V nesmí vytvořit switch vmbr0 přes Proxmox bridge")
	check(sim.state.network==network and sim.state.vms==vms,"Kolize zachovala síť i VM; změnil se jen chybový deník")
	check(sim.act("switch",{"name":"vSwitch-LAN","type":"Internal","adapter":"Ethernet2","management":true}).ok,"Úprava vlastního Hyper-V switche funguje")
	print("SESSION SAFETY: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
