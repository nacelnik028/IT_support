extends PanelContainer

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

func _ready():
	name="ProgrammingCodeEditor"
	position=Vector2(20,18); size=Vector2(1560,820)
	add_theme_stylebox_override("panel",shell.ui.box(Color("101c27"),Color("365968"),8))
	var margin=MarginContainer.new(); add_child(margin)
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,14)
	var root=VBoxContainer.new(); margin.add_child(root)
	var top=HBoxContainer.new(); root.add_child(top)
	var heading=label("PROGRAMMING ACADEMY",24)
	heading.autowrap_mode=TextServer.AUTOWRAP_OFF
	top.add_child(heading)
	mode_picker=OptionButton.new()
	for caption in ["Učím se","Procvičování","Zkouška"]: mode_picker.add_item(caption)
	top.add_child(mode_picker)
	mode_picker.item_selected.connect(func(_i):
		if not manager.current.is_empty(): launch(manager.current.id,manager.is_lesson))
	top.add_child(button("Moje znalosti",show_dashboard))
	top.add_child(button("Podporovaný rozsah",show_limits))
	top.add_child(button("Další úloha",next_generated))
	top.add_child(button("Zpět do učebny [Esc]",shell.return_to_world))
	var body=HBoxContainer.new(); root.add_child(body); body.size_flags_vertical=Control.SIZE_EXPAND_FILL
	var sidebar=VBoxContainer.new(); body.add_child(sidebar); sidebar.custom_minimum_size.x=330
	category_picker=OptionButton.new()
	for caption in ["Všechny oblasti","Python","HTML","CSS","JavaScript","Celý webový vývoj"]: category_picker.add_item(caption)
	sidebar.add_child(category_picker)
	category_picker.item_selected.connect(func(i): selected_category=["all","python","html","css","javascript","web"][i]; populate())
	var tabs=HBoxContainer.new(); sidebar.add_child(tabs)
	for item in [["Lekce","lessons"],["Úlohy","missions"],["Opravy","debugging"]]:
		tabs.add_child(button(item[0],func(): task_kind=item[1]; populate()))
	sidebar.add_child(button("Generovat sérii",show_generator))
	list_scroll=ScrollContainer.new(); sidebar.add_child(list_scroll); list_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	task_list=VBoxContainer.new(); list_scroll.add_child(task_list); task_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	var main=VBoxContainer.new(); main.size_flags_horizontal=Control.SIZE_EXPAND_FILL; body.add_child(main)
	details=label("Vyber lekci nebo praktický úkol.",20); main.add_child(details)
	lesson_text=RichTextLabel.new(); lesson_text.custom_minimum_size.y=150; lesson_text.size_flags_vertical=Control.SIZE_EXPAND_FILL; main.add_child(lesson_text)
	instruction=label("",17); main.add_child(instruction)
	var actions=HBoxContainer.new(); main.add_child(actions)
	file_picker=OptionButton.new(); actions.add_child(file_picker)
	file_picker.item_selected.connect(func(i): manager.edit(file_name,editor.text); switch_file(file_picker.get_item_text(i)))
	actions.add_child(button("Spustit",run_code))
	actions.add_child(button("Otestovat",test_code))
	actions.add_child(button("Resetovat",reset_code))
	hint_button=button("Nápověda",func(): console.text=manager.hint()); actions.add_child(hint_button)
	example_button=button("Ukázka",show_example); actions.add_child(example_button)
	actions.add_child(button("A−",func(): zoom(-2)))
	actions.add_child(button("A+",func(): zoom(2)))
	actions.add_child(button("Odsadit",func(): editor.insert_text_at_caret("    "); editor.grab_focus()))
	var split=HSplitContainer.new(); main.add_child(split); split.custom_minimum_size.y=290; split.size_flags_vertical=Control.SIZE_EXPAND_FILL
	editor=CodeEdit.new(); split.add_child(editor); editor.size_flags_horizontal=Control.SIZE_EXPAND_FILL; editor.custom_minimum_size.x=560
	editor.add_theme_stylebox_override("normal",shell.ui.box(Color("0a121a"),Color("253e4e"),4))
	editor.gutters_draw_line_numbers=true; editor.indent_use_spaces=true; editor.indent_size=4; editor.indent_automatic=true
	editor.auto_brace_completion_enabled=true
	var font=SystemFont.new(); font.font_names=PackedStringArray(["Consolas","DejaVu Sans Mono","monospace"]); editor.add_theme_font_override("font",font)
	editor.add_theme_font_size_override("font_size",int(manager.progress.settings.get("font_size",22)))
	editor.text_changed.connect(func():
		if not changing: manager.edit(file_name,editor.text); update_instruction())
	preview=preload("res://scripts/programming/WebPreviewController.gd").new(); split.add_child(preview); preview.custom_minimum_size.x=440; preview.hide()
	var bottom=HBoxContainer.new(); main.add_child(bottom)
	input_console=TextEdit.new(); input_console.custom_minimum_size=Vector2(220,106); input_console.placeholder_text="Virtuální input()\nJeden vstup na řádek"; bottom.add_child(input_console)
	console=TextEdit.new(); console.editable=false; console.custom_minimum_size.y=106; console.size_flags_horizontal=Control.SIZE_EXPAND_FILL; bottom.add_child(console)
	console.add_theme_stylebox_override("read_only",shell.ui.box(Color("0a121a"),Color("253e4e"),4))
	input_console.add_theme_stylebox_override("normal",shell.ui.box(Color("0a121a"),Color("253e4e"),4))
	console.add_theme_font_size_override("font_size",18)
	populate(); show_dashboard()

func label(text: String, font_size: int) -> Label:
	var node=Label.new(); node.text=text; node.add_theme_font_size_override("font_size",font_size); node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; return node

func button(text: String, action: Callable) -> Button:
	var node=Button.new(); node.text=text; node.pressed.connect(action); return node

func populate():
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
		node.alignment=HORIZONTAL_ALIGNMENT_LEFT; node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; node.custom_minimum_size=Vector2(305,54); task_list.add_child(node)

func launch(id: String, lesson: bool):
	if not manager.start(id,["learn","practice","exam"][mode_picker.selected],lesson): return
	load_current()

func load_current():
	file_picker.clear()
	for filename in manager.files: file_picker.add_item(filename)
	switch_file(file_picker.get_item_text(0))
	var task=manager.current
	details.text=task.id+" / "+task.title
	lesson_text.text=task.description+"\n\nVýukové cíle: "+", ".join(task.objectives)
	if task.category=="python" and not task.tests[0].get("globals",{}).is_empty(): lesson_text.text+="\n\nData mise (již existující proměnné): "+JSON.stringify(task.tests[0].globals)
	if manager.mode=="learn": lesson_text.text+="\n\nAda: "+task.explanation+"\nČasté chyby: "+task.errors
	hint_button.disabled=manager.mode=="exam"; example_button.disabled=manager.mode!="learn"
	console.text="Napiš vlastní řešení a spusť ho. Testy používají více vstupů."
	input_console.text="\n".join(task.tests[0].get("inputs",[])) if task.category=="python" else ""
	preview.visible=task.category!="python"
	if not manager.queue.is_empty(): details.text+=" · Série %d/%d" % [manager.position+1,manager.queue.size()]
	update_instruction()

func switch_file(filename: String):
	file_name=filename; changing=true; editor.text=manager.files.get(filename,""); editor.clear_undo_history(); changing=false
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
	manager.files=manager.current.starter.duplicate(true); switch_file(file_name); manager.step=0; manager.last_run={}; console.text="Obnoveno počáteční zadání."; update_instruction()

func show_example():
	if manager.current.is_empty() or manager.mode!="learn": return
	lesson_text.text=manager.current.explanation+"\n\nUkázka:\n"+str(manager.current.example.get(file_name,""))+"\n\nSamostatný úkol: "+manager.current.description+"\nČasté chyby: "+manager.current.errors

func zoom(change: int):
	var value=clampi(int(manager.progress.settings.get("font_size",22))+change,16,36)
	manager.progress.settings.font_size=value; editor.add_theme_font_size_override("font_size",value)
	if manager.persist.is_valid(): manager.persist.call()

func show_dashboard(): lesson_text.text=manager.dashboard()
func show_limits(): lesson_text.text=FileAccess.get_file_as_string("res://data/programming/LIMITS.txt")
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
