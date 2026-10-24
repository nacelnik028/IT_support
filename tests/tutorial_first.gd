extends SceneTree

const Game=preload("res://scripts/core/GameManager.gd")
var ui
var failed=0

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override="user://academy_test_first_tutorial.json"
	call_deferred("run")

func check(value,message):
	if not value: failed+=1; push_error(message)

func run():
	ui=load("res://scenes/main_menu/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	ui.game.start_mission(3,false)
	ui.game.sim.state.vms["100"].vlan=31
	ui.game.save()
	ui.begin_lesson(1002,"learn",false)
	await process_frame
	await process_frame
	check(ui.game.tutorial.session.step==0,"Začátek skutečné lekce")
	check(ui.ui_targets.has("rack:PVE-01"),"Zvýrazňovaný rack existuje")
	ui.ui_targets["rack:PVE-01"].server_selected.emit("PVE-01")
	await process_frame
	check(ui.game.tutorial.session.step==1,"Kliknutí na rack postoupilo")
	var tree=ui.ui_targets["tree:PVE-01"]
	tree.get_root().get_first_child().select(0)
	tree.item_selected.emit()
	await process_frame
	await process_frame
	check(ui.game.tutorial.session.step==2,"Výběr uzlu postoupil")
	ui.ui_targets["wizard:create_vm"].pressed.emit()
	await process_frame
	check(ui.game.tutorial.session.step==3,"Průvodce skutečně otevřen")
	await submit("vm_identity",{"id":"101","name":"WEB01"})
	check(ui.game.tutorial.session.step==4 and ui.game.sim.state.vms["101"].name=="WEB01","Identita uložena do stavu")
	var resumed=Game.new()
	check(resumed.session_kind=="lesson" and resumed.tutorial.session.step==4 and resumed.sim.state.vms["101"].name=="WEB01","Načtení kroku i konfigurace")
	await submit("vm_media",{"vm":"101","iso":"debian.iso"})
	await submit("vm_resources",{"vm":"101","cpu":2,"ram_mib":2048})
	check(ui.game.tutorial.session.step==5 and ui.game.sim.state.vms["101"].ram==2,"Kliknutí s chybnou RAM nepostoupí")
	await submit("vm_resources",{"vm":"101","cpu":2,"ram_mib":4096})
	check(ui.game.tutorial.session.step==6 and ui.game.sim.state.vms["101"].ram==4,"Skutečná RAM4096MiB ověřena")
	await submit("vm_disk",{"vm":"101","size":32,"storage":"local-lvm"})
	await submit("vm_network",{"vm":"101","bridge":"vmbr0","vlan":20,"ip":"192.168.20.101"})
	check(not ui.game.complete().ok,"Bez startu a ověření se nedokončí")
	await submit("vm_install",{"vm":"101"})
	ui.tab="VM / CT"
	ui.draw_ui()
	await process_frame
	await submit("power",{"vm":"101","power":"Start"})
	ui.tab="Ověření"
	ui.draw_ui()
	await process_frame
	await submit("verify",{})
	check(ui.game.tutorial.session.step==9,"Všech9 kroků splněno podle stavu")
	check(ui.game.complete().ok,"Lekce dokončena")
	check(ui.game.education.lessons["1002"].status=="Dokončeno","Vedená lekce označena správně")
	ui.game.resume_campaign()
	check(ui.game.current.id==4 and ui.game.sim.state.vms["100"].vlan==31,"Kampaň i rozpracovaná konfigurace zůstaly zachované")
	ui.begin_lesson(1002,"exam",false)
	check(not ui.game.tutorial.guided(),"Zkouška bez vedení")
	ui.game.lesson_hint()
	check(ui.game.hints_used==0,"Zkouška neposkytuje přímé nápovědy")
	await create_timer(0.2).timeout
	ui.queue_free()
	await process_frame
	print("FIRST TUTORIAL: %d failures" % failed)
	quit(0 if failed==0 else 1)

func submit(id: String,params: Dictionary):
	check(ui.form_controls.has(id),"Dostupný skutečný formulář "+id)
	if not ui.form_controls.has(id): return
	var controls=ui.form_controls[id]
	for key in params:
		var input=controls[key]
		if input is SpinBox: input.value=float(params[key])
		elif input is OptionButton:
			for i in input.item_count:
				if input.get_item_text(i)==str(params[key]): input.select(i)
		elif input is CheckButton: input.button_pressed=bool(params[key])
		else: input.text=str(params[key])
	ui.form_buttons[id].pressed.emit()
	await process_frame
	await process_frame
