extends SceneTree

var ui
var failures=0
var actions_run=0

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override="user://academy_test_training_ui.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://academy_test_training_ui.cfg"
	call_deferred("run")

func check(ok,message):
	if not ok: failures+=1; push_error(message)

func run():
	if "--small" in OS.get_cmdline_user_args(): root.size=Vector2i(1280,720)
	ui=load("res://scenes/main_menu/Main.tscn").instantiate(); root.add_child(ui)
	await process_frame
	ui.navigate("Trénink")
	await process_frame
	for view in ["lessons","random","profile","glossary"]:
		ui.training_view=view; ui.draw_ui()
		await process_frame
		await capture("training-"+view)
	var solutions=JSON.parse_string(FileAccess.get_file_as_string("res://tests/lesson_solutions.json"))
	var modes=["learn"] if not "--all-modes" in OS.get_cmdline_user_args() else ["learn","practice","exam"]
	for mode in modes:
		for definition in ui.game.tutorial.lessons:
			var id=int(definition.id)
			ui.begin_lesson(id,mode,false)
			await process_frame
			for operation in solutions[str(id)]:
				if operation is Dictionary:
					var event=operation.event
					if event.type=="server_selected":
						ui.navigate("Serverovna"); await process_frame
						ui.ui_targets["rack:"+event.host].server_selected.emit(event.host)
					elif event.type=="node_selected":
						var tree=ui.ui_targets["tree:"+event.host]
						var node=tree.get_root().get_first_child()
						while node and not node.get_text(0).begins_with(event.host): node=node.get_next()
						if node: node.select(0); tree.item_selected.emit()
					else: ui.ui_targets["wizard:create_vm"].pressed.emit()
					await process_frame
					await process_frame
					continue
				var action={}
				var page=definition.category
				for tutorial_step in definition.steps:
					if tutorial_step.get("event",{}).get("action","")==operation[0]: page=tutorial_step.page; break
				for item in ui.game.actions:
					if item.id==operation[0] and item.get("console","Proxmox")==page: action=item; break
				check(not action.is_empty(),"Existující konzole a akce: "+operation[0])
				if action.is_empty(): continue
				if operation[1].has("vm"):
					var vm=ui.game.sim.get_vm(str(operation[1].vm))
					if not vm.is_empty(): ui.host=vm.host
				ui.page=page; ui.tab=action.panel; ui.notice=""; ui.selected_vm=""; ui.draw_ui()
				await process_frame
				await process_frame
				if mode=="exam": check(not is_instance_valid(ui.tutorial_overlay),"Zkouška nesmí zvýrazňovat")
				ui.open_action(operation[0])
				await process_frame
				var inputs=ui.form_controls[operation[0]]
				for key in operation[1]:
					var input=inputs.get(key)
					if input==null: continue
					var value=operation[1][key]
					if input is SpinBox: input.value=float(value)
					elif input is CheckButton: input.button_pressed=bool(value)
					elif input is OptionButton:
						for index in input.item_count:
							if ui.option_value(input,index)==str(value): input.select(index)
					elif input.has_meta("selection"): input.set_meta("selection",value)
					else: input.text=str(value)
				if id==1002 and operation[0]=="vm_resources": await capture("guided-vm-"+mode)
				ui.form_buttons[operation[0]].pressed.emit()
				if action.get("danger",false):
					for dialog in ui.get_children():
						if dialog is ConfirmationDialog and not dialog.is_queued_for_deletion(): dialog.confirmed.emit()
				await process_frame
				check(not ui.bad_notice,"UI lekce%d %s %s: %s" % [id,mode,operation[0],ui.notice])
				actions_run+=1
			check(ui.game.complete().ok,"UI dokončení lekce%d %s krok%s" % [id,mode,ui.game.tutorial.session.step])
			print("TRAINING UI %d %s PASS" % [id,mode])
	await create_timer(0.2).timeout
	ui.queue_free(); await process_frame
	print("TRAINING UI: %d actions, %d failures" % [actions_run,failures])
	quit(0 if failures==0 else 1)

func capture(title):
	if not "--screenshots" in OS.get_cmdline_user_args() or DisplayServer.get_name()=="headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/"+title+".png")
