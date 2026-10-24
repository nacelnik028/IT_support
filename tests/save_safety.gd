extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
var checks=0
var failures=0

func check(ok, message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func write_raw(text: String):
	var file=FileAccess.open(Saves.save_path(),FileAccess.WRITE)
	file.store_string(text)
	file.close()

func invalid_fixture(data):
	var raw=JSON.stringify(data)
	write_raw(raw)
	var game=Game.new()
	check(not game.active and game.load_warning!="","Vadný save nezpůsobí chybu při startu a má upozornění")
	game.start_mission(3)
	check(game.unsaved and game.last_save_error!=OK,"Vadný save je chráněný před automatickým přepsáním")
	check(FileAccess.get_file_as_string(Saves.save_path())==raw,"Vadný soubor zůstal beze změny")

func _init():
	Saves.path_override="user://academy_test_save_safety.json"
	check(Saves.save_game({},true)==OK,"Čistý izolovaný save")
	var game=Game.new()
	game.start_mission(3,true)
	var original=FileAccess.get_file_as_string(Saves.save_path())
	# A directory at the temporary filename forces a real filesystem error.
	var temp=ProjectSettings.globalize_path(Saves.save_path()+".tmp")
	check(DirAccess.make_dir_absolute(temp)==OK,"Připravená chyba zápisu v izolované cestě")
	var result=game.apply("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true})
	check(result.ok and not result.saved and result.save_error!=OK,"Úspěch zásahu je oddělený od selhání zápisu")
	check(game.unsaved and game.save_message!="" and game.sim.state.vms["100"].vlan==20,"Neuložená změna zůstala v paměti")
	check(FileAccess.get_file_as_string(Saves.save_path())==original,"Při chybě zůstal poslední platný soubor")
	check(game.undo() and game.unsaved,"Selhání ukládání undo je viditelné")
	game.apply("network",{"vm":"100","bridge":"vmbr0","vlan":20,"ip":"192.168.20.100","prefix":24,"gateway":"192.168.20.1","dns":"192.168.20.10","firewall":true})
	game.apply("inspect",{"scope":"Events"})
	game.apply("verify",{})
	result=game.complete()
	check(result.ok and not result.saved and game.finished,"Ticket dokončen v paměti, uložení se neslibuje")
	check(DirAccess.remove_absolute(temp)==OK,"Odstraněna pouze testovací překážka zápisu")
	check(game.save()==OK and not game.unsaved and game.save_message=="","Opakovaný zápis úspěšný")
	var loaded=Game.new()
	check(loaded.finished and loaded.sim.state.vms["100"].vlan==20,"Opakovaný zápis uchoval poslední skutečný stav")
	check(FileAccess.file_exists(Saves.save_path()+".last-good.bak"),"Předchozí platný postup má zálohu pro selhání nahrazení")
	for fixture in [
		{"schema":2,"progress":{"scores":null}},
		{"schema":2,"progress":[]},
		{"schema":"2"},
		{"schema":2,"progress":{"scores":{"nonsense":90}}},
		{"schema":2,"progress":{"scores":{"1":101}}},
		{"schema":2,"progress":{"last_mission":999}},
		{"schema":2,"progress":{"xp":-1}},
		{"schema":2,"education":{"attempts":[{}]}},
		{"schema":2,"education":{"sessions":[]}},
		{"schema":2,"education":{"random":{"queue":[],"position":0,"results":[],"hints_allowed":true}}},
		{"schema":2,"session":{"id":20000,"kind":"campaign"}},
		{"schema":2,"session":{"id":1.5}},
		{"schema":2,"session":{"id":1,"kind":"other"}},
		{"schema":2,"session":{"id":1002,"kind":"lesson","tutorial":{"lesson_id":1002,"mode":"learn","step":0}}},
		{"schema":2,"session":{"id":1,"state":{"vms":null}}},
		{"schema":2,"session":{"id":1,"state":{"hosts":{}}}},
		{"schema":2,"session":{"id":1,"state":{"vms":{"100":{"ram":"bad"}}}}},
		{"schema":2,"session":{"id":1,"state":{"network":{"switches":{"vmbr0":{}}}}}},
		{"schema":2,"suspended_campaign":{"id":1002,"kind":"lesson"}}
	]: invalid_fixture(fixture)
	write_raw("invalid JSON")
	check(Saves.load_game().is_empty() and Saves.last_message!="","Neplatný JSON hlášen")
	var invalid_raw=FileAccess.get_file_as_string(Saves.save_path())
	game=Game.new()
	game.start_mission(0)
	check(game.save(true)==OK,"Výslovná obnova po vytvoření zálohy")
	var found_backup=false
	var directory=DirAccess.open("user://")
	for filename in directory.get_files():
		if filename.begins_with("academy_test_save_safety.json.invalid-") and FileAccess.get_file_as_string("user://"+filename)==invalid_raw: found_backup=true
	check(found_backup,"Záloha obsahuje přesné původní poškozené bajty")
	check(not game.unsaved and game.load_warning=="","Upozornění mizí až po úspěšném zápisu")
	# Migration keeps exact schema1 bytes, including a newly created VM.
	game.start_mission(3)
	var vm=game.sim.state.vms["100"].duplicate(true)
	vm.id="301"; vm.identity="301"
	for key in ["ram_mib","virtio_drivers","disk_bus"]: vm.erase(key)
	game.sim.state.vms["301"]=vm
	var legacy={"schema":1,"progress":{"xp":987,"scores":{"1.0":91},"last_mission":4},"session":game.snapshot()}
	legacy.session.erase("kind")
	write_raw(JSON.stringify(legacy))
	var legacy_raw=FileAccess.get_file_as_string(Saves.save_path())
	var backup=ProjectSettings.globalize_path(Saves.save_path()+".v1.bak")
	if FileAccess.file_exists(backup): DirAccess.remove_absolute(backup)
	game=Game.new()
	check(game.active and game.progress.xp==987 and game.progress.scores["1"]==91 and game.sim.state.vms.has("301"),"Schema1 obnoví XP, skóre i dříve vytvořenou VM")
	check(game.save()==OK and FileAccess.get_file_as_string(backup)==legacy_raw,"Migrace vytvořila přesnou v1 zálohu")
	# Every catalog starting state and every solution must remain saveable.
	Saves.save_game({})
	game=Game.new()
	var solutions=JSON.parse_string(FileAccess.get_file_as_string("res://tests/solutions.json"))
	for i in game.missions.size():
		game.start_mission(i,true)
		check(not game.unsaved,"Uložení výchozí mise %d" % (i+1))
		for operation in solutions[i]:
			result=game.apply(operation[0],operation[1])
			check(result.ok and result.saved,"Uložení mise %d po %s: %s" % [i+1,operation[0],game.save_message])
	game.start_random("Sítě","Začátečník",2,true,91)
	var payload=Saves.load_game()
	for position in [-1,2,0.5]:
		var bad=payload.duplicate(true)
		bad.education.random.position=position
		check(not Saves.rules().valid(bad),"Neplatná pozice série odmítnuta")
	var bad=payload.duplicate(true)
	bad.education.random.session.id=20001
	check(not Saves.rules().valid(bad),"Nesoulad ID série a pozice odmítnut")
	bad=payload.duplicate(true)
	bad.education={}
	check(not Saves.rules().valid(bad),"Aktivní série bez fronty odmítnuta")
	game.start_lesson(1002,"learn",false)
	payload=Saves.load_game()
	bad=payload.duplicate(true)
	bad.session.tutorial.step=999
	check(not Saves.rules().valid(bad),"Krok lekce mimo rozsah odmítnut")
	# Earlier schema2 versions used both numeric and decimal lesson keys.
	var legacy_lesson=payload.education.sessions["1002:learn"].duplicate(true)
	payload.education.sessions={"1002.0":legacy_lesson}
	payload.education.lessons={"1002.0":{"status":"Rozpracováno","best":0}}
	write_raw(JSON.stringify(payload))
	game=Game.new()
	check(game.active and game.education.sessions.has("1002:learn") and game.education.lessons.has("1002"),"Staré desetinné klíče lekcí jsou přijaty a normalizovány")
	check(game.save()==OK,"Normalizované schema2 lze znovu uložit")
	print("SAVE SAFETY: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
