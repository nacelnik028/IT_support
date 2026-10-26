extends RefCounted

# One palette and one state system for the application, dialogs and 3D HUD.
const BACKGROUND = Color("101519")
const PANEL = Color("1a232b")
const RAISED = Color("25313b")
const BORDER = Color("3b4b58")
const TEXT = Color("eef4f6")
const MUTED = Color("acbbc7")
const ACCENT = Color("4de0cb")
const GOLD = Color("efc47d")
const ERROR = Color("ff9ca8")
const SUCCESS = Color("8ce2b3")
static var semibold: SystemFont

static func heading_font() -> SystemFont:
	if semibold == null:
		semibold = SystemFont.new()
		semibold.font_names = PackedStringArray(["Segoe UI", "Noto Sans", "DejaVu Sans"])
		semibold.font_weight = 600
	return semibold

static func surface(bg: Color = PANEL, border: Color = BORDER, radius: int = 8, padding: int = 16) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func build(text_scale: float) -> Theme:
	var t = Theme.new()
	var font = SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI", "Noto Sans", "DejaVu Sans"])
	t.default_font = font
	t.default_font_size = roundi(16 * text_scale)
	for type in ["Label", "Button", "OptionButton", "CheckButton", "CheckBox", "LineEdit", "Tree", "PopupMenu"]:
		t.set_color("font_color", type, TEXT)
		t.set_color("font_disabled_color", type, Color("8595a2"))
		t.set_color("font_hover_color", type, TEXT)
		t.set_color("font_focus_color", type, TEXT)
		t.set_color("font_pressed_color", type, TEXT)
	for type in ["Button", "OptionButton"]:
		t.set_font("font", type, heading_font())
		t.set_stylebox("normal", type, surface(RAISED, BORDER))
		t.set_stylebox("hover", type, surface(Color("31434e"), ACCENT))
		t.set_stylebox("pressed", type, surface(Color("214b48"), ACCENT))
		t.set_stylebox("disabled", type, surface(Color("1a2229"), Color("2f3a44")))
		t.set_stylebox("focus", type, focus_ring(ACCENT))
	t.set_type_variation("PrimaryButton", "Button")
	for state in ["normal", "hover", "pressed"]:
		t.set_stylebox(state, "PrimaryButton", surface({"normal": ACCENT,"hover": Color("8bf2e2"),"pressed": Color("34b9a7")}[state], ACCENT))
		t.set_color("font_" + ("color" if state=="normal" else state+"_color"), "PrimaryButton", Color("082c2a"))
	t.set_color("font_focus_color", "PrimaryButton", Color("082c2a"))
	t.set_type_variation("NavButton", "Button")
	t.set_type_variation("ActiveNavButton", "Button")
	t.set_stylebox("normal", "NavButton", surface(Color("171f26"), Color("293640"), 6, 12))
	var selected = surface(Color("233d40"), Color("406361"), 6, 12)
	selected.border_width_left = 3
	selected.border_color = ACCENT
	t.set_stylebox("normal", "ActiveNavButton", selected)
	t.set_stylebox("pressed", "ActiveNavButton", selected)
	t.set_color("font_color", "ActiveNavButton", ACCENT)
	t.set_type_variation("InstructorButton", "Button")
	t.set_stylebox("normal", "InstructorButton", surface(Color("393126"), Color("8a7047")))
	t.set_color("font_color", "InstructorButton", GOLD)
	t.set_stylebox("focus", "InstructorButton", focus_ring(GOLD))
	t.set_stylebox("normal", "LineEdit", surface(Color("10191f"), Color("4a5d6b"), 6, 12))
	t.set_stylebox("focus", "LineEdit", focus_ring(ACCENT))
	t.set_stylebox("read_only", "LineEdit", surface(Color("192128"), Color("303e48"), 6, 12))
	t.set_color("font_placeholder_color", "LineEdit", MUTED)
	t.set_color("caret_color", "LineEdit", ACCENT)
	t.set_color("selection_color", "LineEdit", Color("2b635e"))
	for type in ["TextEdit","CodeEdit"]:
		t.set_stylebox("normal",type,surface(Color("10191f"),BORDER,6,12))
		t.set_stylebox("read_only",type,surface(Color("121c24"),BORDER,6,12))
		t.set_stylebox("focus",type,focus_ring(ACCENT))
		t.set_color("font_color",type,TEXT)
		t.set_color("font_readonly_color",type,TEXT)
		t.set_color("font_placeholder_color",type,MUTED)
		t.set_color("caret_color",type,ACCENT)
		t.set_color("selection_color",type,Color("2b635e"))
		t.set_color("line_number_color",type,MUTED)
		t.set_color("current_line_color",type,Color("192d38"))
	t.set_color("default_color","RichTextLabel",TEXT)
	t.set_stylebox("panel", "Tree", surface(Color("111a21"), Color("2e3d48"), 6, 8))
	for state in ["selected", "selected_focus"]: t.set_stylebox(state, "Tree", surface(Color("27514e"), ACCENT, 4, 4))
	t.set_stylebox("hovered", "Tree", surface(Color("24343f"), Color("405560"), 4, 4))
	t.set_color("font_selected_color", "Tree", TEXT)
	t.set_color("guide_color", "Tree", BORDER)
	t.set_constant("v_separation", "Tree", 9)
	t.set_constant("h_separation", "Tree", 6)
	t.set_stylebox("panel", "PopupMenu", surface(RAISED, BORDER))
	t.set_stylebox("hover", "PopupMenu", surface(Color("31504e"), ACCENT, 4))
	t.set_stylebox("panel", "AcceptDialog", surface(PANEL, BORDER, 12))
	for type in ["HScrollBar", "VScrollBar"]:
		t.set_stylebox("scroll", type, surface(Color("11191f"), Color("11191f"), 4, 4))
		t.set_stylebox("grabber", type, surface(Color("536774"), Color("536774"), 4, 4))
		t.set_stylebox("grabber_highlight", type, surface(MUTED, MUTED, 4, 4))
		t.set_stylebox("grabber_pressed", type, surface(ACCENT, ACCENT, 4, 4))
	t.set_stylebox("background", "ProgressBar", surface(Color("10191f"), Color.TRANSPARENT, 4))
	t.set_stylebox("fill", "ProgressBar", surface(ACCENT, Color.TRANSPARENT, 4))
	preload("res://scripts/ui/VectorIcons.gd").apply(t)
	return t

static func focus_ring(color: Color) -> StyleBoxFlat:
	var style = surface(Color.TRANSPARENT, color, 6, 12)
	style.set_border_width_all(2)
	return style
