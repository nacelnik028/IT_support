extends SceneTree

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override="user://academy_test_stage1.json"
	var game=preload("res://scripts/core/GameManager.gd").new()
	game.start_mission(0,true)
	assert(not game.complete().ok,"Počáteční stav nesmí splnit misi.")
	assert(game.apply("inspect",{"scope":"Inventory"}).ok)
	assert(not game.apply("prepare",{"vt":false,"mode":"RAID"}).ok)
	assert(game.apply("prepare",{"vt":true,"mode":"HBA","ups":true,"console":true,"iommu":true}).ok)
	assert(game.apply("management",{"hostname":"pve01.lab.example","ip":"192.168.10.10","gateway":"192.168.10.1","dns":"192.168.10.2"}).ok)
	assert(not game.complete().ok,"Změna bez ověření nestačí.")
	assert(game.apply("verify",{}).ok)
	assert(game.complete().ok)
	assert(game.save()==OK)
	print("STAGE 1 PASS: mise 1, chybný vstup, ověření a uložení")
	quit()
