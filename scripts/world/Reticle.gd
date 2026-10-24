extends Control

var focused = false

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _draw():
	var at = size*0.5
	var color = Color("65e2d4") if focused else Color(0.8,0.9,0.96,0.8)
	draw_circle(at,2.2,color)
	if focused:
		draw_arc(at,13,0,TAU,40,Color(0.3,0.85,0.78,0.7),1.5,true)
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		draw_line(at+direction*7,at+direction*11,color,1,true)

func set_focus(value: bool):
	if focused==value: return
	focused = value
	queue_redraw()
