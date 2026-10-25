extends RefCounted

var views = {}
var rendered = ""
var pending = 0
var expected: Control

static func key(ui) -> String:
	return "%d|%s|%s|%s|%s|%s|%d" % [ui.game.session_revision,ui.page,ui.host,ui.selected_vm,ui.tab,ui.active_action,ui.wizard_step]

func capture(ui):
	if not is_instance_valid(ui.root_box) or rendered == "": return
	var state = {"scroll":[]}
	for node in ui.root_box.find_children("*","ScrollContainer",true,false): state.scroll.append(node.scroll_vertical)
	var focused = ui.get_viewport().gui_get_focus_owner()
	for target in ui.ui_targets:
		var c = ui.ui_targets[target]
		if focused == c or (c is SpinBox and focused == c.get_line_edit()):
			state.focus = target
			if focused is LineEdit:
				state.caret = focused.caret_column
				state.selection = [focused.get_selection_from_column(),focused.get_selection_to_column()] if focused.has_selection() else [0,0]
	views[rendered] = state

func restore(ui):
	rendered = key(ui)
	expected = ui.root_box
	pending = 2

func process(ui):
	if pending <= 0: return
	pending -= 1
	if pending > 0 or not is_instance_valid(expected) or expected != ui.root_box: return
	var state = views.get(rendered,{})
	var scrolls=ui.root_box.find_children("*","ScrollContainer",true,false)
	for i in mini(scrolls.size(),state.get("scroll",[]).size()): scrolls[i].scroll_vertical=state.scroll[i]
	var control = ui.ui_targets.get(state.get("focus",""))
	if is_instance_valid(control):
		if control is SpinBox: control = control.get_line_edit()
		control.grab_focus()
		if control is LineEdit:
			control.caret_column = state.get("caret",0)
			var selection = state.get("selection",[0,0])
			if selection[0] != selection[1]: control.select(selection[0],selection[1])
