extends SceneTree

const Generator=preload("res://scripts/training/PracticeGenerator.gd")
const Game=preload("res://scripts/core/GameManager.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
var failures=0
var count=0

func check(ok,message):
	count+=1
	if not ok: failures+=1; push_error(message)

func _init():
	Saves.path_override="user://academy_test_training_features.json"
	var generator=Generator.new()
	var fingerprints={}
	for seed_value in range(1,21):
		var area=["Vše","Proxmox","Hyper-V","RAID","Sítě","Zálohy","Diagnostika"][seed_value%7]
		var batch=generator.generate(area,"Vše",5,seed_value)
		check(batch.size()==5,"Generátor vytvořil počet úloh pro "+area)
		for scenario in batch:
			check(generator.validate(scenario,scenario.reference),"Vygenerovaná úloha je skutečně řešitelná")
			fingerprints[JSON.stringify(scenario.initial_state)+JSON.stringify(scenario.objectives)]=true
	check(fingerprints.size()>20,"Parametrizace mění konfigurace a příčiny, nejen názvy")
	var deterministic_a=generator.generate("Proxmox","Začátečník",3,7331)
	var deterministic_b=generator.generate("Proxmox","Začátečník",3,7331)
	check(deterministic_a==deterministic_b,"Seed dává opakovatelnou a testovatelnou sérii")
	for area in ["Vše","Proxmox","Hyper-V","RAID","Sítě","Zálohy","Diagnostika"]:
		for difficulty in ["Začátečník","Pokročilý","Administrátor","Expert"]:
			var selected=generator.generate(area,difficulty,1,775)
			check(selected.size()==1,"Řešitelná kombinace filtru: "+area+" / "+difficulty)
			if not selected.is_empty(): check(selected[0].difficulty==difficulty,"Obtížnost odpovídá výběru")
	var game=Game.new()
	game.start_mission(3,false)
	game.sim.state.vms["100"].vlan=39
	check(game.start_random("RAID","Vše",2,false,91),"Spuštění náhodného procvičování")
	for operation in game.current.reference: check(game.apply(operation[0],operation[1]).ok,"Náhodná úloha operace")
	check(game.complete().ok,"Náhodná úloha vyhodnocena")
	check(game.education.random.results.size()==1,"Výsledek série uložen")
	check(game.next_random(),"Další úloha série")
	game.save()
	var loaded=Game.new()
	check(loaded.session_kind=="random" and loaded.education.random.position==1,"Načtení rozpracované série")
	loaded.resume_campaign()
	check(loaded.current.id==4 and loaded.sim.state.vms["100"].vlan==39,"Generátor neztratil kampaň")
	# Build an old schema1 fixture without altering any player's save.
	var original={"schema":1,"progress":{"xp":987,"scores":{"1.0":91,"2":88},"mistakes":{"VLAN":3},"achievements":["Bezpečné ruce"],"last_mission":4},"session":{"id":4,"state":loaded.sim.state.duplicate(true),"hints":2,"training":false,"finished":false}}
	var fixture=FileAccess.open(Saves.save_path(),FileAccess.WRITE)
	fixture.store_string(JSON.stringify(original)); fixture.close()
	var migrated=Game.new()
	check(migrated.progress.xp==987 and migrated.progress.scores["1"]==91 and migrated.progress.scores["2"]==88,"Migrace zachovala XP a normalizovala staré klíče skóre")
	check(migrated.progress.mistakes.VLAN==3 and migrated.hints_used==2,"Migrace zachovala chyby a nápovědy")
	check(migrated.sim.state.vms["100"].vlan==39 and migrated.unlocked(2),"Migrace zachovala infrastrukturu a odemčení")
	check(migrated.start_lesson(1002,"learn",false),"Původní save lze rozšířit lekcí")
	check(Saves.load_game().schema==2,"Nová data mají schema2")
	check(FileAccess.file_exists(Saves.save_path()+".v1.bak"),"Původní save je zálohován před migrací")
	migrated.notify_event({"type":"server_selected","host":"PVE-01"})
	var resumed=Game.new()
	check(resumed.tutorial.session.step==1,"Výukový krok po restartu zachován")
	resumed.resume_campaign()
	check(resumed.sim.state.vms["100"].vlan==39 and resumed.hints_used==2,"Návrat k původní kampani zachovává i nápovědy")
	var profile=resumed.Profile.summarize(resumed)
	check(profile.domains.size()==6,"Šest znalostních oblastí")
	check(resumed.Profile.recommendations(resumed,["Sítě"]).size()==3,"Doporučené lekce existují")
	var networking_recommended=false
	for lesson in resumed.Profile.recommendations(resumed,["Sítě"]):
		if int(lesson.id) in [1003,1006,1008]: networking_recommended=true
	check(networking_recommended,"Skutečné chyby VLAN doporučí lekci sítí")
	print("TRAINING FEATURES: %d checks, %d failures, %d distinct configurations" % [count,failures,fingerprints.size()])
	quit(0 if failures==0 else 1)
