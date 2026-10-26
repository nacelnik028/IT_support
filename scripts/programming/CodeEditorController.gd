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
var preview: Control
var hint_button: Button
var example_button: Button
var details: Label
var selected_category="all"
var task_kind="lessons"
var list_scroll: ScrollContainer
var instruction: Label
var code_split: HSplitContainer
var buffers: Dictionary={}
var navigation: Dictionary={}
var run_button: Button
var test_button: Button
var reset_button: Button
var next_button: Button
var summary: Label
var brief_text=""

func _exit_tree():
	# Inactive file buffers retain native undo/caret state outside the split.
	for control in buffers.values():
		if is_instance_valid(control) and control.get_parent()==null: control.queue_free()

func _ready():
	name="ProgrammingCodeEditor"
	position=Vector2(20,18); size=Vector2(1560,820)
	add_theme_stylebox_override("panel",Design.surface(Design.BACKGROUND,Design.BORDER,12,18))
	var margin=MarginContainer.new(); add_child(margin)
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,14)
	var root=VBoxContainer.new(); margin.add_child(root)
	var top=HBoxContainer.new(); root.add_child(top)
	var heading=label("NORTHSTAR  /  PROGRAMMING ACADEMY",22)
	heading.autowrap_mode=TextServer.AUTOWRAP_OFF
	top.add_child(heading)
	top.add_child(button("Zpět do učebny  [Esc]",shell.return_to_world))
	var tools_row=HFlowContainer.new(); root.add_child(tools_row)
	mode_picker=OptionButton.new()
	for caption in ["Učím se","Procvičování","Zkouška"]: mode_picker.add_item(caption)
	tools_row.add_child(mode_picker)
	mode_picker.item_selected.connect(change_mode)
	tools_row.add_child(button("Zadání",func(): lesson_text.text=brief_text))
	tools_row.add_child(button("Moje znalosti",show_dashboard))
	tools_row.add_child(button("Podporovaný rozsah",show_limits))
	next_button=button("Další úloha →",next_generated); tools_row.add_child(next_button)
	var body=HBoxContainer.new(); root.add_child(body); body.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var sidebar=VBoxContainer.new(); body.add_child(sidebar); sidebar.custom_minimum_size.x=330
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
	details=label("Vyber lekci nebo praktický úkol.",20); main.add_child(details)
	lesson_text=RichTextLabel.new(); lesson_text.custom_minimum_size.y=136; main.add_child(lesson_text)
	instruction=label("",17); main.add_child(instruction)
	var actions=HFlowContainer.new(); main.add_child(actions)
	file_picker=OptionButton.new(); actions.add_child(file_picker)
	file_picker.item_selected.connect(func(i): manager.edit(file_name,editor.text); switch_file(file_picker.get_item_text(i)))
	run_button=button("▶ Spustit",run_code); actions.add_child(run_button)
	test_button=button("✓ Otestovat",test_code,true); actions.add_child(test_button)
	reset_button=button("Resetovat",reset_code); actions.add_child(reset_button)
	hint_button=button("Nápověda",func(): console.text=manager.hint()); actions.add_child(hint_button)
	hint_button.theme_type_variation="InstructorButton"
	example_button=button("Ukázka",show_example); actions.add_child(example_button)
	actions.add_child(button("A−",func(): zoom(-2)))
	actions.add_child(button("A+",func(): zoom(2)))
	actions.add_child(button("Odsadit",func(): editor.insert_text_at_caret("    "); editor.grab_focus()))
	code_split=HSplitContainer.new(); main.add_child(code_split); code_split.custom_minimum_size.y=280; code_split.size_flags_vertical=Control.SIZE_EXPAND_FILL
	editor=create_editor("main.py"); buffers["main.py"]=editor; code_split.add_child(editor)
	preview=preload("res://scripts/programming/WebPreviewController.gd").new(); code_split.add_child(preview); preview.custom_minimum_size.x=400; preview.hide()
	var bottom=HBoxContainer.new(); main.add_child(bottom)
	input_console=TextEdit.new(); input_console.custom_minimum_size=Vector2(220,106); input_console.placeholder_text="Virtuální input()\nJeden vstup na řádek"; bottom.add_child(input_console)
	console=TextEdit.new(); console.editable=false; console.custom_minimum_size.y=106; console.size_flags_horizontal=Control.SIZE_EXPAND_FILL; bottom.add_child(console)
	console.add_theme_stylebox_override("read_only",shell.ui.box(Color("0a121a"),Color("253e4e"),4))
	input_console.add_theme_stylebox_override("normal",shell.ui.box(Color("0a121a"),Color("253e4e"),4))
	console.add_theme_font_size_override("font_size",18)
	console.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
	input_console.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
	console.add_theme_color_override("font_readonly_color",Design.TEXT)
	populate(); show_dashboard()

func label(text: String, font_size: int) -> Label:
	return shell.ui.label(text,font_size,Design.TEXT)

func button(text: String, action: Callable, primary: bool = false) -> Button:
	return shell.ui.button(text,action,primary)

func create_editor(filename: String) -> CodeEdit:
	var control=CodeEdit.new(); control.size_flags_horizontal=Control.SIZE_EXPAND_FILL; control.custom_minimum_size.x=520
	control.gutters_draw_line_numbers=true; control.indent_use_spaces=true; control.indent_size=4; control.indent_automatic=true; control.auto_brace_completion_enabled=true
	control.highlight_current_line=true
	var font=SystemFont.new(); font.font_names=PackedStringArray(["Consolas","DejaVu Sans Mono","monospace"]); control.add_theme_font_override("font",font)
	control.add_theme_font_size_override("font_size",int(manager.progress.settings.get("font_size",22)))
	control.text_changed.connect(func():
		if not changing and control==editor and file_name==filename: manager.edit(filename,control.text); update_instruction())
	return control

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
		node.alignment=HORIZONTAL_ALIGNMENT_LEFT; node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; node.custom_minimum_size=Vector2(305,54); task_list.add_child(node)

func launch(id: String, lesson: bool):
	if not manager.start(id,["learn","practice","exam"][mode_picker.selected],lesson): return
	load_current()

func load_current():
	clear_buffers()
	file_picker.clear()
	for filename in manager.files: file_picker.add_item(filename)
	switch_file(file_picker.get_item_text(0))
	var task=manager.current
	details.text=task.id+" / "+task.title
	lesson_text.text=task.description
	if task.category=="python" and not task.tests[0].get("globals",{}).is_empty(): lesson_text.text+="\n\nData mise (již existující proměnné): "+JSON.stringify(task.tests[0].globals)
	if manager.mode=="learn": lesson_text.text+="\n\nAda: "+task.explanation+"\nČasté chyby: "+task.errors
	brief_text=lesson_text.text
	hint_button.disabled=manager.mode=="exam"; example_button.disabled=manager.mode!="learn"
	console.text="Napiš vlastní řešení a spusť ho. Testy používají více vstupů."
	input_console.text="\n".join(task.tests[0].get("inputs",[])) if task.category=="python" else ""
	preview.visible=task.category!="python"
	preview.clear_preview()
	if not manager.queue.is_empty(): details.text+=" · Série %d/%d" % [manager.position+1,manager.queue.size()]
	update_instruction()
	populate()

func switch_file(filename: String):
	changing=true
	if is_instance_valid(editor) and editor.get_parent()==code_split: code_split.remove_child(editor)
	file_name=filename
	if not buffers.has(filename): buffers[filename]=create_editor(filename)
	editor=buffers[filename]; code_split.add_child(editor); code_split.move_child(editor,0)
	if editor.text!=manager.files.get(filename,""): editor.text=manager.files.get(filename,""); editor.clear_undo_history()
	for i in file_picker.item_count:
		if file_picker.get_item_text(i)==filename: file_picker.select(i)
	changing=false
	var syntax=CodeHighlighter.new(); syntax.number_color=Color("e5ba72"); syntax.symbol_color=Color("89d4dc"); syntax.function_color=Color("81dcb5")
	for keyword in (["print","input","if","elif","else","for","while","def","return","import","try","except","with","as","in","and","or","not","True","False","None","break","continue"] if filename.ends_with("py") else ["html","head","body","div","p","h1","function","document","const","let","return"]): syntax.add_keyword_color(keyword,Color("c9a4ef"))
	syntax.add_color_region('"','"',Color("b4d99b")); syntax.add_color_region("'","'",Color("b4d99b"))
	if filename.ends_with("py"): syntax.add_color_region("#","",Color("829ba6"),true)
	editor.syntax_highlighter=syntax

func update_instruction():
	if manager.current.is_empty(): instruction.text=""; return
	var steps=["1/4 · Napiš nebo uprav kód v editoru.","2/4 · Klikni Spustit a zkontroluj konzoli nebo náhled.","3/4 · Změň kód a znovu ho spusť; pozoruj rozdíl.","4/4 · Splň zadání a klikni Otestovat."]
	instruction.text=steps[mini(manager.step,3)] if manager.mode=="learn" and manager.is_lesson else "Zkouška bez nápovědy" if manager.mode=="exam" else "Vyřeš zadání vlastním postupem a ověř ho testy."

func run_code():
	manager.edit(file_name,editor.text)
	var inputs=Array(input_console.text.split("\n")) if input_console.text!="" else []
	var result=manager.run_program(inputs)
	console.text=result.get("output","") if result.ok else ("Řádek %d: " % result.line if result.has("line") else "")+result.get("error","Chyba")
	if not manager.current.is_empty() and manager.current.category!="python": preview.render_files(manager.files)
	update_instruction()

func test_code():
	manager.edit(file_name,editor.text)
	var result=manager.test_program(); console.text=result.text+"\nXP: "+str(result.get("xp",0)); populate()

func reset_code():
	if manager.current.is_empty(): return
	manager.files=manager.current.starter.duplicate(true); clear_buffers(); switch_file(file_name); manager.step=0; manager.last_run={}; manager.edited_after_run=false; console.text="Obnoveno počáteční zadání."; preview.clear_preview(); update_instruction()

func show_example():
	if manager.current.is_empty() or manager.mode!="learn": return
	lesson_text.text=manager.current.explanation+"\n\nUkázka:\n"+str(manager.current.example.get(file_name,""))+"\n\nSamostatný úkol: "+manager.current.description+"\nČasté chyby: "+manager.current.errors

func zoom(change: int):
	var value=clampi(int(manager.progress.settings.get("font_size",22))+change,16,36)
	manager.progress.settings.font_size=value
	for control in buffers.values(): control.add_theme_font_size_override("font_size",value)
	if manager.persist.is_valid(): manager.persist.call()

func show_dashboard(): lesson_text.text=manager.dashboard()
func show_limits(): lesson_text.text=FileAccess.get_file_as_string("res://data/programming/LIMITS.txt")
func change_mode(index: int):
	if manager.current.is_empty(): return
	if manager.current.id.begins_with("GEN-"):
		var task=manager.current.duplicate(true); manager.cancel(false); manager.current=task; manager.files=task.starter.duplicate(true)
		manager.mode=["learn","practice","exam"][index]; manager.series_mode=manager.mode; load_current()
	else: launch(manager.current.id,manager.is_lesson)

func focus_station(category: String):
	if category in ["python","web"]:
		selected_category=category; category_picker.select(1 if category=="python" else 5)
		if not manager.current.is_empty() and (manager.current.category=="python")!=(category=="python"):
			manager.cancel(); clear_buffers(); editor=create_editor("main.py"); buffers["main.py"]=editor; code_split.add_child(editor); code_split.move_child(editor,0)
			preview.hide(); file_picker.clear(); details.text="Vyber lekci · "+("Python Lab" if category=="python" else "Web Development Lab"); instruction.text=""; show_dashboard()
		populate()
	elif category=="exam":
		mode_picker.select(2)
		if not manager.current.is_empty(): change_mode(2)
		populate()
	else: show_dashboard()
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
