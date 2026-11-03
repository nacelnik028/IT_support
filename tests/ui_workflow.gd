extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Settings=preload("res://scripts/core/DisplaySettings.gd")
var shell
var checks=0
var failures=0
var suffix=""
var baseline=false
var save_path=""

func _init():
	preload("res://scripts/xr/VRSettings.gd").path_override="user://academy_test_ui_workflow_"+str(OS.get_process_id())+"_vr.cfg"
	baseline="--baseline" in OS.get_cmdline_user_args()
	var tag=str(OS.get_process_id())
	save_path="user://ui_workflow_"+tag+".json"
	Saves.path_override=save_path
	Settings.path_override="user://ui_workflow_"+tag+".cfg"
	Saves.save_game({},true)
	var settings=Settings.new(); settings.resolution=Vector2i(1280,720); settings.vsync=false; settings.quality="Úsporná"; settings.introduction_seen=true; settings.save_settings()
	call_deferred("run")

func check(ok: bool, message: String):
	checks+=1
	if not ok: failures+=1; push_error(message+" / "+suffix)

func settle():
	for frame in 8: await process_frame

func visible(control: Control) -> bool:
	if not is_instance_valid(control) or not control.is_visible_in_tree(): return false
	var rect=control.get_global_rect()
	if not rect.has_area() or not root.get_visible_rect().encloses(rect): return false
	var ancestor=control.get_parent()
	while ancestor is Control:
		if ancestor.clip_contents and not ancestor.get_global_rect().encloses(rect): return false
		ancestor=ancestor.get_parent()
	return true

func click(control: Control):
	check(visible(control),"Action is fully visible: "+control.text)
	if not visible(control): return
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var at=control.get_global_rect().get_center()
	var motion=InputEventMouseMotion.new(); motion.position=at; root.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down
		root.push_input(event,true); await process_frame
	await settle()

func type_character(control: Control, character: String):
	control.grab_focus()
	var event=InputEventKey.new(); event.pressed=true; event.unicode=character.unicode_at(0); event.keycode=event.unicode
	root.push_input(event,true); await settle()

func capture(screen: String):
	if DisplayServer.get_name()=="headless" or "--screenshots" not in OS.get_cmdline_user_args(): return
	await settle()
	if "--manual-capture" in OS.get_cmdline_user_args(): RenderingServer.force_draw()
	else: await RenderingServer.frame_post_draw
	var directory="res://test-output/ux-"+("before" if baseline else "after")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	root.get_texture().get_image().save_png(directory+"/"+screen+"-"+suffix+".png")

func reveal(control: Control):
	for ancestor in shell.ui.get_scroll_ancestors(control):
		ancestor.ensure_control_visible(control)
		ancestor.scroll_vertical+=4
	await settle()

func check_credit():
	var credit=shell.ui.find_child("AuthorCredit",true,false)
	check(visible(credit) and credit.text=="Vytvořil: Vít Kellner a Codex","Exact author credit visible in main menu")
	if not is_instance_valid(credit): return
	check(credit.get_line_count()==1 and credit.size.x>=credit.get_minimum_size().x,"Credit fits on one line")
	check(credit.mouse_filter==Control.MOUSE_FILTER_IGNORE and credit.focus_mode==Control.FOCUS_NONE,"Credit cannot capture pointer or keyboard focus")
	for button in shell.ui.root_box.find_children("*","Button",true,false):
		check(not credit.get_global_rect().intersects(button.get_global_rect()),"Credit does not cover menu action: "+button.text)
	var inset=(root.get_visible_rect().end-credit.get_global_rect().end)/shell.ui.scale
	check(inset.distance_to(Vector2(24,24))<1.0,"Credit follows bottom/right menu margins")

func credit_visible() -> bool:
	var credit=shell.ui.find_child("AuthorCredit",true,false)
	return is_instance_valid(credit) and credit.is_visible_in_tree()

func run():
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await settle()
	var ui=shell.ui; var game=ui.game
	if not baseline:
		var syntax=preload("res://scripts/programming/PythonRuntime.gd").new().run("print('ok')\n\tprint('bad')")
		check(not syntax.ok and syntax.line==2,"Lexer error carries exact line metadata")
	if not baseline:
		check(ProjectSettings.get_setting("application/config/name")=="IT Support Simulator: Training academy","Renamed application")
		var directory_key="application/config/custom_user_dir_name."+OS.get_name().to_lower()
		if not ProjectSettings.has_setting(directory_key): directory_key="application/config/custom_user_dir_name"
		check(OS.get_user_data_dir().replace("\\","/").ends_with(ProjectSettings.get_setting(directory_key)),"Rename retains supported platform save location")
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for text_scale in [1.0,1.3]:
			suffix=str(resolution.x)+"-"+str(roundi(text_scale*100))
			shell.enter_world("Hlavní serverovna"); game.start_mission(3,false)
			ui.apply_display_settings(resolution,false); ui.save_preference("text_scale",text_scale)
			ui.page="menu"; ui.draw_ui(); shell.set_mode("menu"); await settle()
			if not baseline:
				for button in ui.root_box.find_children("*","Button",true,false): check(visible(button),"Every desktop menu choice is reachable")
				for target in ["primary","vr","programming","training","tickets","settings","quit"]:
					check(visible(ui.ui_targets["menu:"+target]),"Main scene menu action visible without scrolling: "+target)
				check_credit()
			await capture("menu")
			if not baseline:
				# Exercise the real menu input paths, then its normal save/return action.
				ui.ui_targets["menu:primary"].grab_focus()
				check(ui.ui_targets["menu:primary"].find_next_valid_focus() is Button,"Tab navigation skips the author credit")
				for down in [true,false]:
					var event=InputEventKey.new(); event.keycode=KEY_ENTER
					event.pressed=down; Input.parse_input_event(event)
					await settle()
				await settle()
				check(shell.mode=="world" and game.game_mode.is_hub(),"Keyboard menu entry opens hub")
				check(not credit_visible(),"Credit hidden during gameplay")
				shell.pause_menu(); await settle()
				check(not credit_visible(),"Credit hidden in pause")
				var back: Button
				for button in shell.overlay.find_children("*","Button",true,false):
					if button.text=="Uložit a hlavní menu": back=button
				await reveal(back)
				await click(back)
				check(shell.mode=="menu","Pause return opens main menu")
				check_credit()
			var campaign=game.sim.state.duplicate(true); var mission_id=game.current.id
			if baseline: shell.enter_world("Programming Academy")
			else: await click(ui.ui_targets["menu:programming"])
			check(game.game_mode.is_programming() and shell.mode=="world","Programming entry uses room transition")
			check(game.programming.current.is_empty(),"Entry does not start a task")
			if not baseline:
				check(shell.room_notice.size.x<=480 and shell.room_notice.size.y<=70,"Room notice is compact")
				check(not shell.room_notice.get_global_rect().intersects(shell.context_plate.get_global_rect()),"Notice does not cover interaction")
			await capture("room-notice")
			shell._process(4.1)
			if not baseline:
				check(not shell.room_notice.visible,"Ordinary notification expires")
				Saves.path_override="user://missing-room-workflow-"+str(OS.get_process_id())+"/save.json"; game.save()
				shell.update_time=1; shell._process(4.1)
				check("NEJSOU ULOŽENÉ" in shell.status_label.text,"Critical warning remains in idle classroom HUD")
				Saves.path_override=save_path; game.save()
			shell.open_programming("python"); await settle()
			var code=shell.code_editor
			if not baseline: check(ui.find_child("AuthorCredit",true,false)==null,"Credit absent from programming panels")
			code.mode_picker.select(1); code.launch("PY01",false)
			code.editor.text="print('výstup před chybou')\nprint(unknown_name)"; code.manager.edit("main.py",code.editor.text)
			code.input_console.text="vlastní vstup"
			await settle()
			await click(code.run_button)
			if not baseline:
				check(code.manager.last_result.is_empty(),"Run does not grade the task")
				check("výstup před chybou" in code.console.text and code.output_tabs.current_tab==1,"Output and error are separate")
				check(code.errors_list.get_child_count()==1,"Single diagnostic without overlapping panels")
			await capture("editor-errors")
			if not baseline:
				await click(code.errors_list.get_child(0))
				check(code.file_name=="main.py" and code.editor.get_caret_line()==1,"Click error navigates to exact source line")
				check(code.editor.get_line_background_color(1).a>0,"Error source line highlighted")
				check(code.input_console.text=="vlastní vstup","Error navigation preserves inputs")
			code.editor.text="print('Ahoj, světe!')"; code.manager.edit("main.py",code.editor.text)
			await click(code.run_button); await capture("editor-output")
			await click(code.test_button)
			if not baseline:
				check(code.manager.last_result.ok and code.output_tabs.current_tab==2,"Verify invokes existing evaluator")
				check("této verze" in code.verification_state.text,"Verification version identified")
			await capture("editor-results")
			if not baseline:
				Saves.path_override="user://missing-code-workflow-"+str(OS.get_process_id())+"/save.json"
				await click(code.test_button)
				check(game.unsaved and code.save_row.visible,"Programming save failure remains outside output tabs")
				shell._process(10.0)
				check(code.save_row.visible,"Critical save warning does not expire")
				await capture("editor-save-failure")
				Saves.path_override=save_path
				await click(code.save_row.get_child(1))
				check(not game.unsaved and not code.save_row.get_child(1).visible and code.save_state.text.begins_with("Uloženo"),"Programming retry uses existing save path")
			if not baseline:
				var best=code.manager.progress.results.PY01.best
				await type_character(code.editor," ")
				check("Předchozí" in code.verification_state.text and code.manager.progress.results.PY01.best==best,"Editing invalidates presentation, preserves best result")
				# Each matrix cell deliberately starts fresh. Persisted unfinished code is
				# covered by work_persistence's real restore/fresh/delete dialog.
				code.manager.start("WEB21","practice",false); code.load_current()
				var html=code.editor; html.set_caret_line(0); html.set_caret_column(0)
				html.insert_text_at_caret("<!-- koncept -->\n"); code.manager.edit("index.html",html.text)
				html.select(0,1,0,5); var selected=html.get_selected_text(); var caret=html.get_caret_column()
				code.switch_file("style.css"); code.editor.insert_text_at_caret("p { color: red; }\n"); code.manager.edit("style.css",code.editor.text)
				code.switch_file("index.html")
				check(code.editor==html and html.get_selected_text()==selected and html.get_caret_column()==caret,"File switching keeps native selection and caret")
				html.deselect(); html.undo(); check(not "koncept" in html.text,"Undo survives file switching")
				html.redo(); check("koncept" in html.text,"Redo survives file switching")
				code.clear_diagnostics(); code.add_diagnostic("Známá poloha","index.html",2); code.switch_file("style.css"); code.output_tabs.current_tab=1; await settle()
				await click(code.errors_list.get_child(0))
				check(code.file_name=="index.html" and code.editor.get_caret_line()==1,"Known diagnostic opens correct file and line")
				code.add_diagnostic("Chyba bez polohy","",0)
				check(code.errors_list.get_child(-1) is Label,"Unknown error location is not a false link")
			shell.enter_world("Hlavní serverovna"); await settle()
			check(game.current.id==mission_id and game.session_kind=="campaign","Returning restores campaign identity")
			check(game.sim.state.vms==campaign.vms and game.sim.state.hosts==campaign.hosts,"Returning preserves campaign infrastructure")
			if not baseline: check("programovací" in shell.room_notice.text,"Exit names correct classroom")
			shell.update_time=1; shell._process(0.01); await capture("hud")
			shell.open_app("Proxmox"); ui.open_action("management"); await settle()
			var field=ui.form_controls.management.ip
			field.text="špatná IP"; field.text_changed.emit(field.text)
			var state=game.sim.state.duplicate(true)
			if not baseline: check("Rozepsané" in ui.form_states.management.text,"Typing marks draft without save")
			await click(ui.form_buttons.management)
			check(game.sim.state==state,"Format error leaves infrastructure and penalties unchanged")
			check(ui.form_controls.management.ip.text=="špatná IP" and ui.ui_targets["error:management:ip"].visible,"Invalid field remains open with specific explanation")
			await capture("form-validation")
			field=ui.form_controls.management.ip; field.text="192.168.10.11"; field.text_changed.emit(field.text)
			if not baseline:
				Saves.path_override="user://missing-ui-workflow-"+str(OS.get_process_id())+"/save.json"
				await click(ui.form_buttons.management)
				check(game.unsaved and "ale neuloženo" in ui.form_states.management.text,"Model success does not claim disk save")
				await capture("form-save-failure")
				Saves.path_override=save_path
				game.save(); await settle()
				check(not game.unsaved and "Použito a uloženo" in ui.form_states.management.text,"Successful retry updates correct form")
				ui.host="PVE-02"; ui.draw_ui(); await settle()
				check(not "Použito a uloženo" in ui.form_states.management.text,"Status does not leak to another host")
				ui.host="PVE-01"; ui.draw_ui()
			ui.open_action("create_vm"); await settle()
			var number=ui.form_controls.create_vm.cpu
			number.get_line_edit().grab_focus(); await settle()
			number.get_line_edit().text="7.5"; number.get_line_edit().caret_column=1
			ui.capture_form_drafts()
			ui.draw_ui()
			await settle()
			check(ui.form_controls.create_vm.cpu.get_line_edit().text=="7.5","Rebuild preserves uncommitted numeric draft: "+ui.form_controls.create_vm.cpu.get_line_edit().text)
			await capture("form-long")
			ui.open_settings(); await settle(); await capture("settings")
			ui.close_settings(); shell.enter_world("Trénink"); shell.open_app("Trénink"); await settle(); await capture("lessons")
			if not baseline: check(ui.find_child("AuthorCredit",true,false)==null,"Credit absent from training panels")
	print("UI WORKFLOW: %d checks, %d failures" % [checks,failures])
	shell.queue_free(); await process_frame
	quit(1 if failures else 0)
