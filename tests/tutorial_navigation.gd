extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var ui
var checks=0
var failures=0

func _init():
	var suffix="_gpu" if DisplayServer.get_name()!="headless" else ""
	Saves.path_override="user://academy_test_tutorial_navigation"+suffix+".json"
	Settings.path_override="user://academy_test_tutorial_navigation"+suffix+".cfg"
	Saves.save_game({},true); Settings.new().save_settings()
	call_deferred("run")

func check(ok,message):
	checks+=1
	if not ok: failures+=1; push_error(message)

func frames():
	for i in 4: await process_frame
	# process_frame precedes Control sorting. GPU hit testing must use a layout
	# that has actually finished drawing, especially after resolution changes.
	if DisplayServer.get_name()!="headless": await RenderingServer.frame_post_draw

func visible(control: Control) -> bool:
	if not is_instance_valid(control) or not control.is_visible_in_tree(): return false
	var rect=control.get_global_rect()
	if not rect.has_area() or not root.get_visible_rect().encloses(rect): return false
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor.clip_contents and not ancestor.get_global_rect().encloses(rect): return false
		ancestor=ancestor.get_parent()
	return true

func pointer(at: Vector2):
	# These positions are already in the scene Window's viewport coordinates.
	# Dispatch there so native confirmation focus / window resizing cannot send
	# a click to another OS window; normal Control hit testing still handles it.
	var motion=InputEventMouseMotion.new(); motion.position=at; root.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; event.position=at
		root.push_input(event,true)
		await process_frame
	await frames()

func submit(action: String, params: Dictionary) -> bool:
	# Recovery and normal navigation use only visible controls, never open_action
	# or assignments to page/tab/active_action as in the older UI adapter.
	if not ui.ui_targets.has("action:"+action):
		var recover=ui.ui_targets.get("tutorial:recover")
		check(recover!=null,"Je dostupný návrat ke kroku "+action)
		if recover==null: return false
		await click(recover)
	check(ui.ui_targets.has("action:"+action),"Tutoriál otevřel skutečné ovládání "+action)
	if not ui.ui_targets.has("action:"+action):
		print("MISSED RECOVERY ",{"action":action,"page":ui.page,"tab":ui.tab,"step":ui.game.tutorial.session.step,"target":ui.game.tutorial.target(ui.game.sim.state),"hover":str(root.gui_get_hovered_control())})
		await capture("missed-recovery-"+action)
		return false
	if ui.form_controls.has(action):
		var inputs=ui.form_controls[action]
		if inputs.has("vm") and params.has("vm") and ui.option_value(inputs.vm)!=str(params.vm):
			for i in inputs.vm.item_count:
				if ui.option_value(inputs.vm,i)==str(params.vm):
					inputs.vm.select(i); inputs.vm.item_selected.emit(i); break
			await frames(); inputs=ui.form_controls[action]
		for key in params:
			if not inputs.has(key): continue
			var input=inputs[key]
			var value=params[key]
			if input is SpinBox: input.value=float(value)
			elif input is LineEdit: input.text=str(value)
			elif input is CheckButton: input.button_pressed=bool(value)
			elif input is OptionButton:
				var found=false
				for i in input.item_count:
					if ui.option_value(input,i)==str(value): input.select(i); found=true; break
				check(found,"Nabídka obsahuje cílový objekt / "+action+" / "+key)
			elif input.has_meta("selection"): input.set_meta("selection",value.duplicate())
	var journal_size=ui.game.sim.state.journal.size()
	await click(ui.ui_targets["action:"+action])
	for node in ui.get_children():
		if node is ConfirmationDialog and node.visible:
			# Native child windows do not receive desktop pointer events headless.
			# Activate their real OK button; console controls above use raw input.
			node.get_ok_button().pressed.emit()
	await frames()
	check(ui.game.sim.state.journal.size()>journal_size,"Tlačítko skutečně provedlo zásah / "+action)
	if ui.game.sim.state.journal.size()==journal_size:
		print("MISSED ACTION ",action," ",{"page":ui.page,"tab":ui.tab,"step":ui.game.tutorial.session.step,"mouse":root.get_mouse_position(),"button":ui.ui_targets["action:"+action].get_global_rect(),"reveal_frames":ui.tutorial_reveal_frames,"hover":str(root.gui_get_hovered_control())})
		await capture("missed-"+action)
	check(not ui.bad_notice,"Zásah přes viditelný formulář: "+action+" / "+ui.notice)
	return not ui.bad_notice and ui.game.sim.state.journal.size()>journal_size

func tree_click(host: String, keyboard: bool = false):
	var tree=ui.ui_targets["tree:"+host]
	var item=tree.get_root().get_first_child()
	while item!=null and item.get_metadata(0).host!=host: item=item.get_next()
	check(item!=null,"Hostitel je ve stromu")
	if item==null: return
	if keyboard:
		tree.grab_focus()
		var key=InputEventKey.new(); key.keycode=KEY_ENTER; key.pressed=true
		root.push_input(key,true); key.pressed=false; root.push_input(key,true)
		await frames()
	else: await pointer(tree.get_global_transform()*tree.get_item_area_rect(item,0).get_center())

func dismiss_messages():
	for node in ui.get_children():
		if node is AcceptDialog:
			node.hide(); node.confirmed.emit()
	await frames()

func click(control: Control):
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor is ScrollContainer:
			var content=ancestor.get_child(0)
			var rect=content.get_global_transform().affine_inverse()*control.get_global_rect()
			ancestor.scroll_vertical=maxi(0,roundi(rect.end.y-ancestor.size.y+8))
		ancestor=ancestor.get_parent()
	await frames()
	check(visible(control),"Ovládací prvek je dosažitelný: "+str(control.name))
	if visible(control): await pointer(control.get_global_rect().get_center())

func find_button(node: Node,caption: String):
	if node is Button and node.text==caption: return node
	for child in node.get_children():
		var result=find_button(child,caption)
		if result: return result
	return null

func run():
	ui=load("res://scenes/main_menu/Main.tscn").instantiate(); root.add_child(ui)
	await frames()
	ui.apply_display_settings(Vector2i(1280,720),false)
	ui.game.start_mission(3,false); ui.game.sim.state.vms["100"].vlan=31; ui.game.save()
	ui.game.enter_training(); ui.begin_lesson(1002,"learn",false)
	ui.ui_targets["rack:PVE-01"].server_selected.emit("PVE-01")
	await frames()
	var tree=ui.ui_targets["tree:PVE-01"]
	var item=tree.get_root().get_first_child()
	check(tree.get_selected()==item,"Hostitel je předvybraný")
	var at=tree.get_global_transform()*tree.get_item_area_rect(item,0).get_center()
	await pointer(at)
	check(ui.game.tutorial.session.step==2,"Skutečný klik na předvybraný hostitel potvrdí krok")
	# Continue the reproduction even if the old selection callback did not fire.
	if ui.game.tutorial.session.step==1: ui.game.notify_event({"type":"node_selected","host":"PVE-01"})
	await click(ui.ui_targets["wizard:create_vm"])
	await click(ui.ui_targets["context:toggle"])
	var recover=find_button(ui,"Zobrazit potřebný panel")
	check(recover!=null and visible(recover),"Instruktor má v kontextovém panelu viditelné ovládání")
	if recover!=null and visible(recover): await click(recover)
	else: ui.recover_tutorial_target()
	await frames()
	check(not ui.context_open and ui.form_controls.has("vm_identity"),"Obnovení kroku zavře kontext a otevře správný formulář")
	check(ui.ui_targets.has("tutorial:instruction") and visible(ui.ui_targets["tutorial:instruction"]),"Instrukce jsou viditelné současně s formulářem")
	await capture("recovered-identity-720")
	for resolution in [Vector2i(1920,1080),Vector2i(3840,2160)]:
		ui.apply_display_settings(resolution,false); await frames()
		check(visible(ui.ui_targets["tutorial:instruction"]) and visible(ui.form_controls.vm_identity.name),"Instrukce a formulář jsou vedle sebe v "+str(resolution))
		await capture("identity-"+str(resolution.x))
	ui.apply_display_settings(Vector2i(1280,720),false); await frames()
	if not ui.form_controls.has("vm_identity"): await dispose(); return
	await submit("vm_identity",{"id":"101","name":"WEB01"})
	await submit("vm_media",{"vm":"101","iso":"debian.iso"})
	var revision=ui.game.sim.state.revision
	ui.form_controls.vm_resources.ram_mib.value=6144
	await click(ui.ui_targets["section:Hostitel"])
	check(is_instance_valid(ui.tutorial_overlay) and ui.tutorial_overlay.target==ui.ui_targets["section:Průvodce VM"],"Jiná sekce zvýrazní konkrétní cestu zpět")
	var sections=ui.ui_targets["section:Hostitel"].get_parent().get_parent()
	sections.scroll_vertical=0; ui.draw_ui(); await frames()
	check(visible(ui.ui_targets["section:Průvodce VM"]),"Obnova posuvu neschová zvýrazněnou sekci")
	await frames()
	sections=ui.ui_targets["section:Hostitel"].get_parent().get_parent()
	sections.scroll_vertical=0; await frames()
	check(sections.scroll_vertical==0,"Po zobrazení cíle může hráč dál volně posouvat sekce")
	if "--navigation-only" in OS.get_cmdline_user_args():
		await dispose(); return
	await click(ui.ui_targets["tutorial:recover"])
	check(ui.form_controls.vm_resources.ram_mib.value==6144 and ui.game.sim.state.revision==revision,"Návrat zachová koncept a sám nezmění konfiguraci")
	await submit("vm_resources",{"vm":"101","cpu":2,"ram_mib":2048})
	check(ui.game.tutorial.session.step==5 and ui.wizard_step==2,"Nesprávná RAM ponechá stejný skutečný krok")
	check(ui.ui_targets["tutorial:instruction"].text==ui.game.tutorial.last_feedback,"Chyba kroku je vidět u konfigurace")
	await submit("vm_resources",{"vm":"101","cpu":2,"ram_mib":4096})
	await submit("vm_disk",{"vm":"101","size":32,"storage":"local-lvm"})
	await submit("vm_network",{"vm":"101","bridge":"vmbr0","vlan":20,"ip":"192.168.20.101"})
	await submit("vm_install",{"vm":"101"})
	ui.begin_lesson(1001,"learn",false); ui.begin_lesson(1002,"learn",true)
	await frames()
	check(ui.wizard_step==5 and ui.ui_targets.has("action:power"),"Obnovení posledního kroku otevře shrnutí se startem VM")
	await click(ui.ui_targets["context:toggle"])
	await click(ui.ui_targets["tutorial:recover"])
	check(ui.wizard_step==5 and ui.wizard_vm=="101","Návrat z instruktora zachová správnou VM a souhrn")
	await submit("power",{"vm":"101","power":"Start"})
	check(is_instance_valid(ui.tutorial_overlay) and ui.tutorial_overlay.target==ui.ui_targets["action:verify"],"Shrnutí zvýrazní navazující ověření")
	await capture("summary-720")
	await submit("verify",{})
	await click(find_button(ui,"Vyhodnotit lekci"))
	check(ui.game.finished,"Celou první VM lekci lze předat bez testovací navigační zkratky")
	await dismiss_messages()
	# Replaying every other guided lesson catches switches of section, operation,
	# VM target, and console. The data remains the original reference solution.
	var solutions_path="res://tests/lesson_solutions.json"
	if not FileAccess.file_exists(solutions_path): solutions_path=get_script().resource_path.get_base_dir().path_join("lesson_solutions.json")
	var solutions=JSON.parse_string(FileAccess.get_file_as_string(solutions_path))
	for lesson in ui.game.tutorial.lessons:
		if int(lesson.id)==1002: continue
		ui.begin_lesson(int(lesson.id),"learn",false); await frames()
		for operation in solutions[str(int(lesson.id))]:
			if operation is Dictionary:
				var event=operation.event
				if event.type=="server_selected": ui.ui_targets["rack:"+event.host].server_selected.emit(event.host); await frames()
				elif event.type=="node_selected": await tree_click(event.host,int(lesson.id)==1007)
				elif event.type=="action_opened": await click(ui.ui_targets["wizard:create_vm"])
			else:
				if not await submit(operation[0],operation[1]): await dispose(); return
		check(ui.game.tutorial.session.step==lesson.steps.size(),"Přirozená navigace ověřila všechny kroky lekce "+str(lesson.id))
		await click(ui.ui_targets["context:toggle"])
		await click(find_button(ui,"Vyhodnotit lekci"))
		check(ui.game.finished,"Předání lekce "+str(lesson.id))
		await dismiss_messages()
		print("GUIDED NAVIGATION %d PASS" % int(lesson.id))
	for mode in ["practice","exam"]:
		ui.begin_lesson(1002,mode,false); await frames()
		var previous=[ui.page,ui.tab,ui.selected_vm]
		ui.recover_tutorial_target(); await frames()
		check([ui.page,ui.tab,ui.selected_vm]==previous and not ui.ui_targets.has("tutorial:instruction") and not is_instance_valid(ui.tutorial_overlay),"Vedení se neaktivuje mimo Učím se / "+mode)
	ui.return_to_campaign(); await frames()
	check(ui.game.current.id==4 and ui.game.sim.state.vms["100"].vlan==31,"Oprava výuky zachovává odloženou kampaň")
	await dispose()

func capture(title: String):
	if DisplayServer.get_name()=="headless" or not "--screenshots" in OS.get_cmdline_user_args(): return
	await frames(); await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/tutorial-"+title+".png")

func dispose():
	ui.queue_free(); await frames(); OS.delay_msec(120)
	print("TUTORIAL NAVIGATION: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
