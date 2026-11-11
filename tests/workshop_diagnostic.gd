extends "res://tests/network_workshop.gd"

func run():
	if "--model-only" in OS.get_cmdline_user_args():
		model_checks()
		print("WORKSHOP MODEL: %d checks, %d failures" % [checks,failures])
		quit(1 if failures else 0)
		return
	capture_directory = "res://docs/ui-review/2026-11-11-network-workshop/after/"
	shell = load("res://scenes/world/Game.tscn").instantiate()
	root.add_child(shell)
	await frames()
	shell.ui.save_preference("introduction_seen",true)
	shell.enter_world("Počítačové sítě")
	shell.world.player.position = Vector3(5.7,0.02,-30.2)
	await ui_all_tickets()
	shell.queue_free()
	await frames()
	print("WORKSHOP UI DIAGNOSTIC: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
