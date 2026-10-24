extends Control

signal server_selected(server: String)
var state: Dictionary = {}
var hovered = -1
var tick = 0.0
var names_list = ["PVE-01","PVE-02","HV-01","HV-02","NAS-01","BACKUP-01"]
var boxes: Array[Rect2] = []
var compact = false

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(520,340)
	resized.connect(queue_redraw)
	mouse_exited.connect(func(): hovered = -1; queue_redraw())

func _process(delta):
	tick += delta
	if int(tick*3) != int((tick-delta)*3): queue_redraw()

func _gui_input(event):
	if event is InputEventMouseMotion:
		hovered = -1
		for i in boxes.size():
			if boxes[i].has_point(event.position): hovered = i
		queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and hovered >= 0:
		server_selected.emit(names_list[hovered])

func _draw():
	var font = ThemeDB.fallback_font
	var columns = 3
	var gap = 18.0
	var w = (size.x - gap*2) / 3.0
	var h = minf(220.0,(size.y-34)/2.0)
	boxes.clear()
	for i in range(0, int(size.x), 24): draw_line(Vector2(i,0),Vector2(i,size.y),Color(0.1,0.3,0.4,0.08))
	for y in range(0, int(size.y), 24): draw_line(Vector2(0,y),Vector2(size.x,y),Color(0.1,0.3,0.4,0.08))
	for i in names_list.size():
		var x = (i % columns) * (w+gap)
		var y = (i / columns) * (h+18)
		var box = Rect2(x,y,w,h)
		boxes.append(box)
		var color = Color("3ddbc6") if i < 2 else (Color("609cff") if i < 4 else Color("aa99ff"))
		var online = state.get("hosts",{}).get(names_list[i],{}).get("online",true)
		var warning = (i == 4 and state.get("raid",{}).get("health","Healthy") != "Healthy")
		var led = Color("48df9b") if online else Color("ff6178")
		if warning: led = Color("ffb65c")
		draw_style_box(style(Color("101e30") if hovered != i else Color("192f45"),color if hovered == i else Color("263a50")),box)
		draw_rect(Rect2(x+12,y+14,3,h-28),color)
		draw_string(font,Vector2(x+25,y+32),names_list[i],HORIZONTAL_ALIGNMENT_LEFT,w-30,17,Color("e0eaf6"))
		draw_string(font,Vector2(x+25,y+52),"PROXMOX VE" if i < 2 else ("HYPER-V" if i < 4 else ("SHARED STORAGE" if i == 4 else "BACKUP SERVER")),HORIZONTAL_ALIGNMENT_LEFT,w-30,10,color)
		var units = 4 if h > 170 else 3
		for unit in units:
			var uy = y+68+unit*23
			draw_style_box(style(Color("091320"),Color("25394c")),Rect2(x+25,uy,w-40,18))
			for stripe in 5: draw_line(Vector2(x+36+stripe*5,uy+5),Vector2(x+36+stripe*5,uy+13),Color("2e475b"),1)
			draw_circle(Vector2(x+w-29,uy+9),2.4,led if sin(tick*3+i+unit)>-0.8 else led.darkened(0.65))
		draw_string(font,Vector2(x+25,y+h-15),"●  DEGRADED" if warning else ("●  ONLINE" if online else "●  OFFLINE"),HORIZONTAL_ALIGNMENT_LEFT,w-30,10,led)

func style(bg: Color,border: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	return s
