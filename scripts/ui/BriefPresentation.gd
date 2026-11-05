extends RefCounted

# Only presentation changes: the complete source text remains in a native,
# focusable disclosure in every mode. No catalog or technical parameter is edited.
static func draw(ui, parent, body: String, title: String = "Celé zadání / podrobnosti"):
	var first=body.find(". ")
	var preview=body.substr(0,first+1) if first>=0 else body
	if preview==body or body.length()<180:
		parent.add_child(ui.label(body,15)); return
	parent.add_child(ui.label(preview,15))
	var full=ui.label(body,15); full.name="CompleteBrief"; full.visible=false
	var toggle=ui.button(title,func(): full.visible=not full.visible)
	toggle.tooltip_text="Úplný původní text včetně všech parametrů."
	parent.add_child(toggle); parent.add_child(full)
