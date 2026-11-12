extends RefCounted

# Shared London/support reply widgets: native focus, wrapping and both XR rays.
static func reply(ui, parent: Node, text: String, callback: Callable, primary := false, height := 58) -> Button:
	var button = ui.button(text,callback,primary)
	button.custom_minimum_size.y = height
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(button)
	return button
