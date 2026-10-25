extends SceneTree

var ui
var failures=0

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override="user://academy_test_ui.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://academy_test_ui_smoke.cfg"
	call_deferred("run")

func check(ok, message):
	if not ok: failures+=1; push_error(message)

func run():
	if "--small" in OS.get_cmdline_user_args(): root.size=Vector2i(1280,720)
	ui=load("res://scenes/main_menu/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	var shots="--screenshots" in OS.get_cmdline_user_args()
	if shots:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test-output"))
		await capture("menu")
	ui.game.start_mission(0,true)
	for page in ["Serverovna","Tickety","Proxmox","Hyper-V","Storage","Síť","Terminál","Akademie","Statistiky"]:
		ui.navigate(page)
		await process_frame
		await process_frame
		check(ui.center.size.x>350,"Příliš úzký obsah: "+page)
		if shots: await capture(page)
	var solutions=JSON.parse_string(FileAccess.get_file_as_string("res://tests/solutions.json"))
	for i in ui.game.missions.size():
		ui.game.start_mission(i,true)
		for step in solutions[i]:
			var chosen={}
			var preferred=ui.game.current.category
			if step[1].has("vm"):
				var vm=ui.game.sim.get_vm(str(step[1].vm))
				if not vm.is_empty(): preferred=ui.Context.platform(ui.game.sim.state,vm); ui.host=vm.host
			for a in ui.game.actions:
				if a.id==step[0]:
					chosen=a
					if a.get("console","Proxmox")==preferred: break
			check(not chosen.is_empty(),"Chybí UI akce "+step[0])
			if chosen.is_empty(): continue
			ui.page=chosen.get("console","Proxmox")
			ui.tab=chosen.panel
			ui.notice=""
			ui.draw_ui()
			await process_frame
			ui.open_action(step[0])
			await process_frame
			var inputs=ui.form_controls[step[0]]
			for key in step[1]:
				if not inputs.has(key): continue
				var input=inputs[key]
				var value=step[1][key]
				if input is CheckButton: input.button_pressed=bool(value)
				elif input is OptionButton:
					for index in input.item_count:
						if ui.option_value(input,index)==str(value): input.select(index)
				elif input is SpinBox: input.value=float(value)
				elif input.has_meta("selection"): input.set_meta("selection",value)
				else: input.text=str(value)
			ui.form_buttons[step[0]].pressed.emit()
			if chosen.get("danger",false):
				for node in ui.get_children():
					if node is ConfirmationDialog:
						node.confirmed.emit()
			await process_frame
			check(not ui.bad_notice,"UI mise %d, %s: %s" % [i+1,step[0],ui.notice])
			check(not ui.game.unsaved,"Uložení UI mise %d, %s: %s" % [i+1,step[0],ui.game.save_message])
		for goal in ui.game.goals(): check(goal.passed,"UI mise %d: %s" % [i+1,goal.label])
		check(ui.game.complete().ok,"UI dokončení mise %d" % (i+1))
		ui.show_review()
		await process_frame
		var correct_text=ui.game.current.review.options[int(ui.game.current.review.correct)]
		var answer=find_button(ui,correct_text)
		check(answer!=null,"UI otázka má odpověď")
		if answer: answer.pressed.emit()
		await process_frame
		check(ui.game.sim.state.get("review_answered",false),"Odpověď na kontextovou otázku uložena")
		for dialog in ui.get_children():
			if dialog is AcceptDialog and not dialog.is_queued_for_deletion(): dialog.confirmed.emit()
		await process_frame
		print("UI MISSION %02d PASS" % (i+1))
	await create_timer(0.2).timeout
	ui.queue_free()
	await process_frame
	print("UI SMOKE: %d missions through form signals; %d failures" % [ui.game.missions.size() if is_instance_valid(ui) else solutions.size(),failures])
	quit(0 if failures==0 else 1)

func find_button(node: Node, text: String):
	if node is Button and node.text==text: return node
	for child in node.get_children():
		var found=find_button(child,text)
		if found: return found
	return null

func capture(title):
	await process_frame
	await process_frame
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-output/"+("small-" if "--small" in OS.get_cmdline_user_args() else "")+title+".png")
