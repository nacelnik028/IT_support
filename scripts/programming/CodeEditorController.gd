extends PanelContainer

const Design=preload("res://scripts/ui/AcademyTheme.gd")

var manager
var shell
var editor: CodeEdit
var console: TextEdit
var input_console: TextEdit
var lesson_text: RichTextLabel
var task_list: VBoxContainer
var file_picker: OptionButton
var mode_picker: OptionButton
var category_picker: OptionButton
var file_name="main.py"
var changing=false
var buffer_key=""
var preview: Control
var hint_button: Button
var example_button: Button
var details: Label
var selected_category="all"
var task_kind="lessons"
var list_scroll: ScrollContainer
var instruction: Label
var workspace_split: VSplitContainer
var input_toggle: CheckButton
var input_box: VBoxContainer
var verification_details: CheckButton
var code_split: HSplitContainer
var buffers: Dictionary={}
var navigation: Dictionary={}
var run_button: Button
var test_button: Button
var reset_button: Button
var next_button: Button
var summary: Label
var brief_text=""
var save_row: HBoxContainer
var save_state: Label
var output_tabs: TabContainer
var errors_panel: VBoxContainer
var errors_list: VBoxContainer
var verification: TextEdit
var verification_state: Label
var verified_files: Dictionary={}
var diagnostic_files: Dictionary={}
var results_button: Button
var results_enlarged=false
var regular_split=0
var layout_extent=Vector2.ZERO
var sidebar: VBoxContainer
var sidebar_button: Button
var sidebar_collapsed=false

func _notification(what):
	if what==NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		for window in find_children("*","Window",true,false): window.hide()


func _exit_tree():
	capture_editor_state()
	if not manager.current.is_empty() and manager.draft_dirty: shell.ui.game.save()
	# Inactive file buffers retain native undo/caret state outside the split.
	for control in buffers.values():
		if is_instance_valid(control) and control.get_parent()==null: control.queue_free()

func _ready():
	name="ProgrammingCodeEditor"
	position=Vector2(20,18); size=Vector2(1560,864)
	var surface_style=Design.surface(Design.BACKGROUND,Design.BORDER,12,18)
	surface_style.content_margin_top=6; surface_style.content_margin_bottom=6
	add_theme_stylebox_override("panel",surface_style)
	var margin=MarginContainer.new(); add_child(margin)
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,8)
	var root=VBoxContainer.new(); root.add_theme_constant_override("separation",6); margin.add_child(root)
	var top=HBoxContainer.new(); root.add_child(top)
	var heading=label("NORTHSTAR  /  PROGRAMOVACÍ UČEBNA",20)
	heading.autowrap_mode=TextServer.AUTOWRAP_OFF
	top.add_child(heading)
	top.add_child(button("Zpět do učebny  [Esc]",shell.return_to_world))
	var tools_row=HFlowContainer.new(); root.add_child(tools_row)
	sidebar_button=button("Sbalit seznam lekcí a úloh",toggle_sidebar); tools_row.add_child(sidebar_button)
	sidebar_button.toggle_mode=true
	sidebar_button.tooltip_text="Skryje pouze výběr úloh. Aktuální zadání, režim, kód i výsledky zůstanou otevřené."
	mode_picker=OptionButton.new()
	for caption in ["Učím se","Procvičování","Zkouška"]: mode_picker.add_item(caption)
	tools_row.add_child(mode_picker)
	mode_picker.item_selected.connect(change_mode)
	tools_row.add_child(button("Celé zadání",show_brief))
	tools_row.add_child(button("Moje znalosti",func(): shell.open_app("Moje znalosti")))
	tools_row.add_child(button("Výsledky programování",show_dashboard))
	tools_row.add_child(button("Rozepsaná práce",show_drafts))
	tools_row.add_child(button("Podporovaný rozsah",show_limits))
	next_button=button("Další úloha →",next_generated); tools_row.add_child(next_button)
	var study_tools=tools_row.get_children().filter(func(n): return n is Button and n.text in ["Moje znalosti","Výsledky programování","Rozepsaná práce","Podporovaný rozsah"])
	tool_menu(tools_row,"Studium a postup",study_tools)
	save_row=HBoxContainer.new(); root.add_child(save_row)
	save_state=label("",14); save_state.add_theme_color_override("font_color",Design.GOLD); save_row.add_child(save_state)
	save_row.add_child(button("Zkusit uložit znovu",func(): shell.ui.game.save()))
	shell.ui.game.persistence_changed.connect(refresh_save_state)
	refresh_save_state()
	var body=HBoxContainer.new(); root.add_child(body); body.size_flags_vertical=Control.SIZE_EXPAND_FILL
	sidebar=VBoxContainer.new(); body.add_child(sidebar); sidebar.custom_minimum_size.x=290
	category_picker=OptionButton.new()
	for caption in ["Všechny oblasti","Python","HTML","CSS","JavaScript","Celý webový vývoj"]: category_picker.add_item(caption)
	sidebar.add_child(category_picker)
	category_picker.item_selected.connect(func(i): selected_category=["all","python","html","css","javascript","web"][i]; populate())
	var tabs=HBoxContainer.new(); sidebar.add_child(tabs)
	for item in [["Lekce","lessons"],["Úlohy","missions"],["Opravy","debugging"]]:
		var nav=button(item[0],func(): task_kind=item[1]; populate()); tabs.add_child(nav); navigation[item[1]]=nav
	sidebar.add_child(button("Generovat sérii",show_generator))
	list_scroll=ScrollContainer.new(); sidebar.add_child(list_scroll); list_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	task_list=VBoxContainer.new(); list_scroll.add_child(task_list); task_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	summary=label("",14); summary.add_theme_color_override("font_color",Design.MUTED); sidebar.add_child(summary)
	var main=VBoxContainer.new(); main.size_flags_horizontal=Control.SIZE_EXPAND_FILL; body.add_child(main)
	details=label("Vyber lekci nebo praktický úkol.",18); details.max_lines_visible=1; details.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS; main.add_child(details)
	lesson_text=RichTextLabel.new(); lesson_text.custom_minimum_size.y=33; lesson_text.add_theme_font_size_override("normal_font_size",roundi(17*shell.ui.display_settings.text_scale)); main.add_child(lesson_text)
	instruction=label("",17); sidebar.add_child(instruction)
	var actions=HFlowContainer.new(); main.add_child(actions)
	file_picker=OptionButton.new(); actions.add_child(file_picker)
	file_picker.item_selected.connect(func(i): manager.edit(file_name,editor.text); switch_file(file_picker.get_item_text(i)))
	run_button=button("Spustit kód",run_code); actions.add_child(run_button)
	test_button=button("Ověřit řešení",test_code,true); actions.add_child(test_button)
	run_button.tooltip_text="Provede program s tvými vstupy nebo obnoví webový náhled. Neověřuje splnění úlohy."
	test_button.tooltip_text="Zkontroluje požadavky zadání všemi existujícími testy a pokusí se uložit výsledek. Samotné spuštění úlohu nesplní."
	reset_button=button("Resetovat",reset_code); actions.add_child(reset_button)
	hint_button=button("Nápověda",func(): console.text=manager.hint(); output_tabs.current_tab=0); actions.add_child(hint_button)
	hint_button.theme_type_variation="InstructorButton"
	example_button=button("Ukázka",show_example); actions.add_child(example_button)
	actions.add_child(button("A−",func(): zoom(-2)))
	actions.add_child(button("A+",func(): zoom(2)))
	actions.add_child(button("Odsadit",func(): editor.insert_text_at_caret("    "); editor.grab_focus()))
	var code_tools=actions.get_children().filter(func(n): return n is Button and n.text in ["Resetovat","Ukázka","A−","A+","Odsadit"])
	tool_menu(actions,"Nástroje kódu",code_tools)
	workspace_split=VSplitContainer.new(); workspace_split.size_flags_vertical=Control.SIZE_EXPAND_FILL; workspace_split.split_offset=0; workspace_split.add_theme_icon_override("grabber",preload("res://scripts/ui/VectorIcons.gd").icon("split")); main.add_child(workspace_split)
	workspace_split.add_theme_constant_override("separation",18); workspace_split.add_theme_constant_override("minimum_grab_thickness",18)
	workspace_split.add_theme_constant_override("autohide",0)
	var split_style=StyleBoxFlat.new(); split_style.bg_color=Color("233c48"); split_style.border_color=Color("497782"); split_style.set_border_width_all(1); split_style.set_corner_radius_all(3)
	workspace_split.add_theme_stylebox_override("split_bar_background",split_style)
	workspace_split.tooltip_text="Táhni pro změnu poměru editoru a výsledků. Obě části zachovají místo na čtení."
	code_split=HSplitContainer.new(); workspace_split.add_child(code_split); code_split.custom_minimum_size.y=120; code_split.size_flags_vertical=Control.SIZE_EXPAND_FILL
	editor=create_editor("main.py"); buffers["main.py"]=editor; code_split.add_child(editor)
	preview=preload("res://scripts/programming/WebPreviewController.gd").new(); code_split.add_child(preview); preview.custom_minimum_size.x=300; preview.hide()
	var bottom=VBoxContainer.new(); workspace_split.add_child(bottom); bottom.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var results_toolbar=HBoxContainer.new(); bottom.add_child(results_toolbar)
	input_toggle=CheckButton.new(); input_toggle.text="Vstupy pro input()"; results_toolbar.add_child(input_toggle)
	results_button=button("Zvětšit výsledky",toggle_results); results_toolbar.add_child(results_button)
	var output_row=HBoxContainer.new(); output_row.size_flags_vertical=Control.SIZE_EXPAND_FILL; bottom.add_child(output_row)
	input_box=VBoxContainer.new(); input_box.custom_minimum_size.x=200; output_row.add_child(input_box); input_box.hide()
	input_box.add_child(label("Jeden vstup na řádek",14))
	input_toggle.toggled.connect(input_box.set_visible)
	input_console=TextEdit.new(); input_console.size_flags_vertical=Control.SIZE_EXPAND_FILL; input_console.custom_minimum_size=Vector2(200,64); input_console.placeholder_text="Vstupy pro input()"; input_box.add_child(input_console)
	output_tabs=TabContainer.new(); output_row.add_child(output_tabs)
	output_tabs.size_flags_horizontal=Control.SIZE_EXPAND_FILL; output_tabs.size_flags_vertical=Control.SIZE_EXPAND_FILL; output_tabs.custom_minimum_size.y=150
	console=TextEdit.new(); console.name="Výstup"; console.editable=false; output_tabs.add_child(console)
	errors_panel=VBoxContainer.new(); errors_panel.name="Chyby"; output_tabs.add_child(errors_panel)
	var error_scroll=ScrollContainer.new(); error_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL; errors_panel.add_child(error_scroll)
	errors_list=VBoxContainer.new(); errors_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL; error_scroll.add_child(errors_list)
	var results=VBoxContainer.new(); results.name="Ověření"; output_tabs.add_child(results)
	var verification_header=HBoxContainer.new(); results.add_child(verification_header)
	verification_state=label("Dosud neověřeno.",14); verification_state.size_flags_horizontal=Control.SIZE_EXPAND_FILL; verification_state.max_lines_visible=1; verification_state.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS; verification_header.add_child(verification_state)
	verification_details=CheckButton.new(); verification_details.text="Podrobnosti testů"; verification_header.add_child(verification_details)
	verification=TextEdit.new(); verification.editable=false; verification.size_flags_vertical=Control.SIZE_EXPAND_FILL; results.add_child(verification); verification.hide(); verification_details.toggled.connect(verification.set_visible)
	for output in [console,verification]:
		output.add_theme_font_override("font",editor.get_theme_font("font"))
		output.add_theme_stylebox_override("read_only",shell.ui.box(Color("0a121a"),Color("253e4e"),4))
		output.add_theme_font_size_override("font_size",roundi(18*shell.ui.display_settings.text_scale))
		output.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
		output.add_theme_color_override("font_readonly_color",Design.TEXT)
	input_console.add_theme_stylebox_override("normal",shell.ui.box(Color("0a121a"),Color("253e4e"),4))
	input_console.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
	populate()
	if manager.current.is_empty(): show_dashboard()
	else: load_current()
	fit_workspace()

func _process(_delta):
	fit_workspace()

func toggle_sidebar():
	sidebar_collapsed=not sidebar_collapsed
	sidebar.visible=not sidebar_collapsed
	sidebar_button.text="Zobrazit lekce a úlohy" if sidebar_collapsed else "Sbalit seznam lekcí a úloh"
	sidebar_button.set_pressed_no_signal(sidebar_collapsed)

func fit_workspace():
	if not is_instance_valid(workspace_split): return
	# Large desktop windows gain working area while keeping comfortable text.
	# VR reserves y=900..1200 for the keyboard in the real 1600x1200 viewport.
	var ratio=get_viewport().get_visible_rect().size.y/900.0
	var factor=1.0 if shell.vr_active else 1.0/sqrt(maxf(1,ratio))
	var extent=Vector2(1600,900)/factor-Vector2(40,36)
	if extent!=layout_extent:
		layout_extent=extent; scale=Vector2.ONE*factor; position=Vector2(20,18); size=extent
		if results_enlarged: call_deferred("enlarge_results")
	# Containers can grow during initial tab/minimum-size negotiation. Reclaim
	# the available bounds after that negotiation, including on first opening.
	if size!=extent: size=extent
	# Six rows leave five complete rows even at a fractional scroll position.
	for output in [console,verification]:
		output.custom_minimum_size.y=output.get_line_height()*6+output.get_theme_stylebox("read_only").get_minimum_size().y+4
	code_split.custom_minimum_size.y=editor.get_line_height()*5+editor.get_theme_stylebox("normal").get_minimum_size().y+4

func toggle_results():
	results_enlarged=not results_enlarged
	if results_enlarged:
		regular_split=workspace_split.split_offset; enlarge_results()
	else:
		code_split.show(); workspace_split.split_offset=regular_split
	results_button.text="Běžné rozložení" if results_enlarged else "Zvětšit výsledky"

func enlarge_results():
	code_split.hide()

func label(text: String, font_size: int) -> Label:
	return shell.ui.label(text,font_size,Design.TEXT)

func button(text: String, action: Callable, primary: bool = false) -> Button:
	return shell.ui.button(text,action,primary)

func tool_menu(parent: Control, title: String, controls: Array):
	var popup=PopupPanel.new(); popup.theme=shell.ui.theme; popup.name=title.replace(" ",""); add_child(popup)
	var entries=VBoxContainer.new(); popup.add_child(entries)
	for control in controls:
		control.reparent(entries)
		var callbacks=control.pressed.get_connections()
		for connection in callbacks: control.pressed.disconnect(connection.callable)
		# Close the popup before opening a sibling dialog, so its focus teardown
		# cannot hide or steal the first click from the newly opened window.
		control.pressed.connect(func():
			popup.hide()
			for connection in callbacks: connection.callable.call_deferred())
	var trigger=button(title,func():
		popup.content_scale_factor=shell.ui.scale.x
		popup.popup_centered(Vector2i(Vector2(420,entries.get_combined_minimum_size().y+24)*shell.ui.scale)))
	parent.add_child(trigger)

func show_brief():
	var dialog=AcceptDialog.new(); dialog.theme=shell.ui.theme; dialog.title="Celé zadání"; dialog.ok_button_text="Zavřít"
	var text=RichTextLabel.new(); text.text=brief_text if brief_text!="" else lesson_text.text; text.custom_minimum_size=Vector2(680,340); text.add_theme_font_size_override("normal_font_size",roundi(18*shell.ui.display_settings.text_scale)); dialog.add_child(text)
	dialog.confirmed.connect(dialog.queue_free); dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); dialog.content_scale_factor=shell.ui.scale.x; dialog.popup_centered(Vector2i(Vector2(740,440)*shell.ui.scale))

func create_editor(filename: String) -> CodeEdit:
	var control=CodeEdit.new(); control.size_flags_horizontal=Control.SIZE_EXPAND_FILL; control.custom_minimum_size.x=380
	control.gutters_draw_line_numbers=true; control.indent_use_spaces=true; control.indent_size=4; control.indent_automatic=true; control.auto_brace_completion_enabled=true
	control.highlight_current_line=true
	var font=SystemFont.new(); font.font_names=PackedStringArray(["Consolas","DejaVu Sans Mono","monospace"]); control.add_theme_font_override("font",font)
	control.add_theme_font_size_override("font_size",int(manager.progress.settings.get("font_size",22)))
	control.text_changed.connect(func():
		if not changing and control==editor and file_name==filename: manager.edit(filename,control.text); update_instruction(); refresh_verification(); clear_error_marks(control))
	control.caret_changed.connect(capture_editor_state)
	control.get_v_scroll_bar().value_changed.connect(func(_value): capture_editor_state())
	return control

func capture_editor_state():
	if changing or manager.current.is_empty() or buffer_key!=manager.drafts.key(manager.draft_record()): return
	var changed_view=false
	for filename in buffers:
		var control=buffers[filename]
		if not is_instance_valid(control) or not manager.files.has(filename): continue
		var view={"line":control.get_caret_line(),"column":control.get_caret_column(),"scroll":int(control.get_v_scroll())}
		if control.has_selection():
			view.merge({"from_line":control.get_selection_from_line(),"from_column":control.get_selection_from_column(),"to_line":control.get_selection_to_line(),"to_column":control.get_selection_to_column()})
		if manager.views.get(filename,{})!=view: manager.views[filename]=view; changed_view=true
	if manager.active_file!=file_name and manager.files.has(file_name): manager.active_file=file_name; changed_view=true
	if changed_view: manager.mark_draft()

func restore_editor_state():
	var view=manager.views.get(file_name,{})
	if view.is_empty(): return
	var line=clampi(int(view.get("line",0)),0,editor.get_line_count()-1)
	editor.set_caret_line(line); editor.set_caret_column(clampi(int(view.get("column",0)),0,editor.get_line(line).length()))
	if view.has("from_line"):
		var first=clampi(int(view.from_line),0,editor.get_line_count()-1)
		var last=clampi(int(view.to_line),first,editor.get_line_count()-1)
		editor.select(first,clampi(int(view.from_column),0,editor.get_line(first).length()),last,clampi(int(view.to_column),0,editor.get_line(last).length()))
	editor.set_v_scroll(float(view.get("scroll",0)))

func clear_buffers():
	for control in buffers.values():
		if control.get_parent()!=null: control.get_parent().remove_child(control)
		control.queue_free()
	buffers.clear(); editor=null

func populate():
	for key in navigation: navigation[key].theme_type_variation="ActiveNavButton" if key==task_kind else "NavButton"
	next_button.disabled=manager.queue.is_empty()
	for control in [run_button,test_button,reset_button,hint_button,example_button]: control.disabled=manager.current.is_empty()
	if not manager.current.is_empty(): hint_button.disabled=manager.mode=="exam"; example_button.disabled=manager.mode!="learn"
	summary.text="%d / 28 lekcí  ·  %d XP" % [manager.progress.lessons.size(),int(manager.progress.xp)]
	for child in task_list.get_children(): task_list.remove_child(child); child.queue_free()
	for item in manager.catalog.get(task_kind,[]):
		var category=item.category
		if task_kind=="lessons" and selected_category in ["css","javascript"]:
			for task in manager.catalog.missions:
				if task.id==item.mission: category=task.category; break
		if selected_category!="all" and selected_category!=category and not (selected_category=="html" and category=="web") and not (selected_category=="web" and category!="python"): continue
		var text=item.id+" · "+item.title
		if manager.progress.lessons.has(item.id) or manager.progress.results.get(item.id,{}).get("passed",false): text="✓ "+text
		var node=button(text,func(): launch(item.mission if task_kind=="lessons" else item.id,task_kind=="lessons"))
		node.theme_type_variation="ActiveNavButton" if manager.current.get("id","")==item.get("mission",item.id) else "NavButton"
		node.alignment=HORIZONTAL_ALIGNMENT_LEFT; node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; node.custom_minimum_size=Vector2(270,54); task_list.add_child(node)

func launch(id: String, lesson: bool):
	capture_editor_state()
	var key=manager.drafts.key({"id":id,"mode":["learn","practice","exam"][mode_picker.selected],"lesson":lesson,"series":{},"position":0})
	if manager.progress.drafts.has(key) and not manager.progress.results.get(id,{}).get("passed",false):
		show_drafts(key)
		return
	if not manager.start(id,["learn","practice","exam"][mode_picker.selected],lesson): return
	load_current()

func load_current():
	changing=true
	buffer_key=manager.drafts.key(manager.draft_record())
	reset_feedback()
	clear_buffers()
	file_picker.clear()
	for filename in manager.files: file_picker.add_item(filename)
	mode_picker.select(["learn","practice","exam"].find(manager.mode))
	switch_file(manager.active_file if manager.files.has(manager.active_file) else file_picker.get_item_text(0))
	var task=manager.current
	details.text=task.id+" / "+task.title
	lesson_text.text=task.description
	if task.category=="python" and not task.tests[0].get("globals",{}).is_empty(): lesson_text.text+="\n\nData mise (již existující proměnné): "+JSON.stringify(task.tests[0].globals)
	if manager.mode=="learn": lesson_text.text+="\n\nAda: "+task.explanation+"\nČasté chyby: "+task.errors
	brief_text=lesson_text.text
	lesson_text.text=task.description.split("\n")[0]
	lesson_text.tooltip_text="Celé zadání a podmínky otevře tlačítko Celé zadání."
	details.tooltip_text=details.text
	hint_button.disabled=manager.mode=="exam"; example_button.disabled=manager.mode!="learn"
	console.text="Napiš vlastní řešení a spusť ho. Testy používají více vstupů."
	input_console.text="\n".join(task.tests[0].get("inputs",[])) if task.category=="python" else ""
	input_toggle.visible=task.category=="python"; input_toggle.button_pressed=not input_console.text.is_empty(); input_box.visible=input_toggle.button_pressed
	preview.visible=task.category!="python"
	preview.clear_preview()
	if not manager.queue.is_empty(): details.text+=" · Série %d/%d" % [manager.position+1,manager.queue.size()]
	update_instruction()
	populate()

func switch_file(filename: String):
	capture_editor_state()
	changing=true
	if is_instance_valid(editor) and editor.get_parent()==code_split: code_split.remove_child(editor)
	file_name=filename
	var restore_view=not buffers.has(filename)
	if restore_view: buffers[filename]=create_editor(filename)
	editor=buffers[filename]; code_split.add_child(editor); code_split.move_child(editor,0)
	if editor.text!=manager.files.get(filename,""): editor.text=manager.files.get(filename,""); editor.clear_undo_history()
	for i in file_picker.item_count:
		if file_picker.get_item_text(i)==filename: file_picker.select(i)
	manager.active_file=filename
	if restore_view: restore_editor_state()
	changing=false
	var syntax=CodeHighlighter.new(); syntax.number_color=Color("e5ba72"); syntax.symbol_color=Color("89d4dc"); syntax.function_color=Color("81dcb5")
	for keyword in (["print","input","if","elif","else","for","while","def","return","import","try","except","with","as","in","and","or","not","True","False","None","break","continue"] if filename.ends_with("py") else ["html","head","body","div","p","h1","function","document","const","let","return"]): syntax.add_keyword_color(keyword,Color("c9a4ef"))
	syntax.add_color_region('"','"',Color("b4d99b")); syntax.add_color_region("'","'",Color("b4d99b"))
	if filename.ends_with("py"): syntax.add_color_region("#","",Color("829ba6"),true)
	editor.syntax_highlighter=syntax

func update_instruction():
	if manager.current.is_empty(): instruction.text=""; return
	var steps=["1/4 · Napiš nebo uprav kód v editoru.","2/4 · Klikni Spustit kód a zkontroluj konzoli nebo náhled.","3/4 · Změň kód a znovu ho spusť; pozoruj rozdíl.","4/4 · Splň zadání a klikni Ověřit řešení."]
	instruction.text=steps[mini(manager.step,3)] if manager.mode=="learn" and manager.is_lesson else "Zkouška bez nápovědy" if manager.mode=="exam" else "Vyřeš zadání vlastním postupem a ověř ho testy."

func run_code():
	manager.edit(file_name,editor.text)
	var inputs=Array(input_console.text.split("\n")) if input_console.text!="" else []
	var result=manager.run_program(inputs)
	console.text=result.get("output","")
	clear_diagnostics()
	if not result.ok:
		add_diagnostic(result.get("error","Chyba bez přesné polohy."),"main.py" if not manager.current.is_empty() and manager.current.category=="python" else "",int(result.get("line",0)))
	output_tabs.current_tab=0 if result.ok else 1
	if not manager.current.is_empty() and manager.current.category!="python": preview.render_files(manager.files)
	update_instruction()

func test_code():
	manager.edit(file_name,editor.text)
	var result=manager.test_program()
	verified_files=manager.files.duplicate(true)
	verification.text=result.text+"\nXP: "+str(result.get("xp",0))
	clear_diagnostics()
	for diagnostic in result.get("diagnostics",[]): add_diagnostic(diagnostic.text,diagnostic.get("file",""),int(diagnostic.get("line",0)))
	refresh_verification(); output_tabs.current_tab=2; populate()

func reset_code():
	if manager.current.is_empty(): return
	reset_feedback(); manager.files=manager.current.starter.duplicate(true); clear_buffers(); switch_file(file_name); manager.step=0; manager.last_run={}; manager.edited_after_run=false; console.text="Obnoveno počáteční zadání."; preview.clear_preview(); update_instruction()
	manager.mark_draft(); shell.ui.game.save()

func refresh_save_state():
	save_row.visible=true
	save_state.text=shell.ui.game.persistence_caption()
	for child in save_row.get_children():
		if child is Button: child.visible=shell.ui.game.unsaved

func show_drafts(only_key: String = ""):
	capture_editor_state()
	var dialog=AcceptDialog.new(); dialog.title="Rozepsaná práce / výslovná obnova"; dialog.ok_button_text="Zavřít"
	var scroll=ScrollContainer.new(); scroll.follow_focus=true; scroll.custom_minimum_size=Vector2(680,300); dialog.add_child(scroll)
	var list=VBoxContainer.new(); list.size_flags_horizontal=Control.SIZE_EXPAND_FILL; scroll.add_child(list)
	list.add_child(label("Obnova nespouští kód ani testy. Undo/redo patří jen živému editoru. Začít znovu nahradí pouze tento koncept počátečním zadáním.",16))
	var records=manager.progress.drafts.duplicate(true)
	records.merge(manager.pending_drafts,true)
	if records.is_empty(): list.add_child(label("Žádná uložená rozepsaná práce.",18))
	for key in records.keys():
		if only_key!="" and key!=only_key: continue
		var record=records[key]
		if manager.pending_drafts.has(key): list.add_child(label("NEULOŽENO / koncept překračuje limit. Obnov ho a zkrať, nebo jej výslovně smaž.",16))
		list.add_child(label(record.id+" / "+record.mode+(" / lekce" if record.lesson else " / úloha")+" · "+Time.get_datetime_string_from_unix_time(int(record.updated)),18))
		list.add_child(button("Obnovit rozepsanou práci",func():
			if manager.restore_draft(key): dialog.hide(); load_current(); editor.grab_focus(); restore_editor_state(); dialog.queue_free()
			else: console.text="Koncept nelze obnovit: změněný obsah, neplatná varianta nebo neuložená aktuální práce."))
		list.add_child(button("Začít znovu / nahradit tento koncept",func():
			if manager.restore_draft(key): manager.views={}; load_current(); reset_code(); dialog.queue_free()))
		list.add_child(button("Smazat koncept / výsledky zůstanou",func(): manager.delete_draft(key); dialog.queue_free()))
	dialog.confirmed.connect(dialog.queue_free); dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); dialog.content_scale_factor=shell.ui.scale.x; dialog.popup_centered(Vector2i(Vector2(740,460)*shell.ui.scale))

func refresh_verification():
	if verified_files.is_empty():
		verification_state.text="Dosud neověřeno. Spuštění kódu úlohu nesplní."
		verification_state.add_theme_color_override("font_color",Design.MUTED)
		return
	var stale=manager.files!=verified_files
	var result=manager.last_result
	var tests=result.get("checks",[])
	var passed=tests.filter(func(item): return item.ok).size()
	var state="OVĚŘENÍ JE ZASTARALÉ" if stale else "SPLNĚNO" if result.get("ok",false) else "NESPLNĚNO"
	verification_state.text="%s · %d/%d testů · skóre %d/100" % [state,passed,tests.size(),int(result.get("score",0))]
	verification_state.tooltip_text="Předchozí ověření neplatí. Ověř řešení znovu." if stale else "Ověření této verze. "+str(result.get("summary",""))
	verification_state.add_theme_color_override("font_color",Design.GOLD if stale else Design.SUCCESS if manager.last_result.get("ok",false) else Design.ERROR)

func clear_error_marks(control: CodeEdit):
	for line in control.get_line_count(): control.set_line_background_color(line,Color.TRANSPARENT)

func clear_diagnostics():
	diagnostic_files=manager.files.duplicate(true)
	for child in errors_list.get_children(): errors_list.remove_child(child); child.queue_free()
	for control in buffers.values(): clear_error_marks(control)

func reset_feedback():
	verification_details.button_pressed=false
	verified_files.clear(); verification.text=""; refresh_verification(); clear_diagnostics(); output_tabs.current_tab=0

func add_diagnostic(text: String, filename: String, line: int):
	var valid=manager.files.has(filename) and line>0 and line<=str(manager.files[filename]).split("\n").size()
	if valid:
		var link=button("%s:%d / %s" % [filename,line,text],func(): jump_to_error(filename,line))
		link.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; link.alignment=HORIZONTAL_ALIGNMENT_LEFT; errors_list.add_child(link)
	else: errors_list.add_child(label(text+"\nPřesná poloha není dostupná.",15))

func jump_to_error(filename: String, line: int):
	if manager.files!=diagnostic_files:
		errors_list.add_child(label("Kód se změnil. Spusť ho nebo ověř znovu pro aktuální polohu chyby.",15)); return
	if not manager.files.has(filename): return
	switch_file(filename)
	var index=line-1
	if index<0 or index>=editor.get_line_count(): return
	editor.deselect(); editor.set_caret_line(index); editor.set_caret_column(0)
	editor.set_line_background_color(index,Color("56303a")); editor.center_viewport_to_caret(); editor.grab_focus()

func show_example():
	if manager.current.is_empty() or manager.mode!="learn": return
	var saved_brief=brief_text
	brief_text=manager.current.explanation+"\n\nUkázka:\n"+str(manager.current.example.get(file_name,""))+"\n\nSamostatný úkol: "+manager.current.description+"\nČasté chyby: "+manager.current.errors
	show_brief(); brief_text=saved_brief

func zoom(change: int):
	var value=clampi(int(manager.progress.settings.get("font_size",22))+change,16,36)
	manager.progress.settings.font_size=value
	for control in buffers.values(): control.add_theme_font_size_override("font_size",value)
	if manager.persist.is_valid(): manager.persist.call()

func show_dashboard():
	if manager.current.is_empty(): lesson_text.text=manager.dashboard()
	else:
		var saved_brief=brief_text; brief_text=manager.dashboard(); show_brief(); brief_text=saved_brief
func show_limits():
	var saved_brief=brief_text; brief_text=preload("res://scripts/core/ContentReader.gd").text("res://data/programming/LIMITS.txt"); show_brief(); brief_text=saved_brief
func change_mode(index: int):
	mode_picker.select(index)
	if manager.current.is_empty(): return
	if manager.current.id.begins_with("GEN-"):
		var task=manager.current.duplicate(true); manager.cancel(false); manager.current=task; manager.files=task.starter.duplicate(true)
		manager.mode=["learn","practice","exam"][index]; manager.series_mode=manager.mode; load_current()
	else: launch(manager.current.id,manager.is_lesson)

func focus_station(category: String):
	if category in ["python","web"]:
		selected_category=category; category_picker.select(1 if category=="python" else 5)
		if not manager.current.is_empty() and (manager.current.category=="python")!=(category=="python"):
			manager.cancel(); reset_feedback(); clear_buffers(); editor=create_editor("main.py"); buffers["main.py"]=editor; code_split.add_child(editor); code_split.move_child(editor,0)
			preview.hide(); file_picker.clear(); details.text="Vyber lekci · "+("Python Lab" if category=="python" else "Web Development Lab"); instruction.text=""; show_dashboard()
		populate()
	elif category=="exam":
		mode_picker.select(2)
		if not manager.current.is_empty(): change_mode(2)
		populate()
	elif manager.current.is_empty(): show_dashboard()
func show_generator():
	var dialog=AcceptDialog.new(); dialog.title="Generátor procvičování"; dialog.size=Vector2i(580,360); dialog.ok_button_text="Spustit sérii"
	var box=VBoxContainer.new(); dialog.add_child(box)
	var category=OptionButton.new()
	for text in ["Python","HTML","CSS","JavaScript","Smíšený trénink"]: category.add_item(text)
	box.add_child(category)
	var difficulty=OptionButton.new()
	for text in ["Začátečník","Pokročilý","Zkouška"]: difficulty.add_item(text)
	box.add_child(difficulty)
	box.add_child(label("Počet úloh (1–20)",20))
	var count=SpinBox.new(); count.min_value=1; count.max_value=20; count.value=5; box.add_child(count)
	dialog.confirmed.connect(func():
		if manager.generate_series(["python","html","css","javascript","mixed"][category.selected],["beginner","advanced","exam"][difficulty.selected],int(count.value),int(Time.get_ticks_msec())):
			mode_picker.select(2 if manager.mode=="exam" else 1); load_current()
		else: console.text="Tuto sérii se nepodařilo připravit. Zkus jinou oblast."
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); dialog.popup_centered()

func next_generated():
	if manager.next_generated(): load_current()
	elif manager.queue.is_empty(): console.text="Nejprve spusť generátor procvičování."
	elif manager.position+1>=manager.queue.size(): console.text="Série dokončena.\n"+manager.dashboard()
	else: console.text="Nejprve úspěšně otestuj aktuální úlohu."
