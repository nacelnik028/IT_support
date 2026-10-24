extends Control

var target: Control
var local_rect=Rect2()
var time=0.0

func _ready():
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index=80

func _process(delta):
	time+=delta
	queue_redraw()

func _draw():
	if not is_instance_valid(target) or not target.is_visible_in_tree(): return
	var rect=target.get_global_rect()
	if local_rect.has_area(): rect=target.get_global_transform()*local_rect
	var ancestor=target.get_parent()
	while ancestor is Control:
		if ancestor is ScrollContainer: rect=rect.intersection(ancestor.get_global_rect())
		ancestor=ancestor.get_parent()
	if not rect.has_area(): return
	rect=get_global_transform().affine_inverse()*rect
	var color=Color(0.25,1.0,0.84,0.65+sin(time*4.0)*0.25)
	draw_rect(rect.grow(3),color,false,3)
	var point=Vector2(rect.position.x+minf(rect.size.x*0.5,120),rect.position.y-5)
	draw_colored_polygon(PackedVector2Array([point,point+Vector2(-9,-13),point+Vector2(9,-13)]),color)
	draw_line(point+Vector2(0,-13),point+Vector2(0,-28),color,3)
