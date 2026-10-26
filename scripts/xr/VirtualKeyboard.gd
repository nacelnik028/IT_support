extends PanelContainer

var viewport: SubViewport
var target: Control
var shifted = false
var rows: VBoxContainer

func _ready():
	custom_minimum_size = Vector2(1260,248)
	rows = VBoxContainer.new()
	add_child(rows)
	draw_keys()
	hide()

func draw_keys():
	for c in rows.get_children(): rows.remove_child(c); c.queue_free()
	for letters in ["1234567890-_=+", "qwertyuiop[]{}", "asdfghjkl;:'\"", "zxcvbnm,./\\@", "ěščřžýáíéůú()", "<>#*%!?&|:"]:
		var row = HBoxContainer.new()
		rows.add_child(row)
		for letter in letters:
			var value = letter.to_upper() if shifted else letter
			add_key(row,value,func(): type_text(value))
	var commands = HBoxContainer.new()
	rows.add_child(commands)
	add_key(commands,"Shift",func(): shifted = not shifted; draw_keys())
	add_key(commands,"Mezera",func(): type_text(" "))
	add_key(commands,"← Smazat",func(): send_key(KEY_BACKSPACE))
	add_key(commands,"Enter",func(): send_key(KEY_ENTER))
	add_key(commands,"Tab",func(): send_key(KEY_TAB))
	add_key(commands,"4 mezery",func(): type_text("    "))
	add_key(commands,"Zavřít",dismiss)

func dismiss():
	if is_instance_valid(target): target.release_focus()
	hide()

func add_key(row, caption: String, action: Callable):
	var key = Button.new()
	key.text = caption
	key.custom_minimum_size = Vector2(60,36)
	key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Clicking the keyboard must retain the text field's caret and selection.
	key.focus_mode = Control.FOCUS_NONE
	key.pressed.connect(action)
	row.add_child(key)

func track_focus():
	var focus = viewport.gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		target = focus
		show()
	elif focus != null and focus != target:
		target = null
		hide()
	if not is_instance_valid(target) or not target.is_visible_in_tree(): hide()

func type_text(value: String):
	if not is_instance_valid(target): return
	target.grab_focus()
	if target is LineEdit:
		if target.has_selection(): target.delete_text(target.get_selection_from_column(),target.get_selection_to_column())
		target.insert_text_at_caret(value)
		target.text_changed.emit(target.text)
	elif target is TextEdit: target.insert_text_at_caret(value)

func send_key(code: Key):
	if not is_instance_valid(target): return
	target.grab_focus()
	for pressed in [true,false]:
		var event = InputEventKey.new()
		event.keycode = code
		event.pressed = pressed
		viewport.push_input(event,true)
