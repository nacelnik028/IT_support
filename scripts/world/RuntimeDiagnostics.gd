extends Label

var elapsed=0.0

func _ready():
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	position=Vector2(590,18)
	size=Vector2(440,170)
	add_theme_font_size_override("font_size",16)
	hide()
	set_process(false)

func toggle():
	visible=not visible
	set_process(visible)
	if visible: refresh()

func _process(delta):
	elapsed+=delta
	if elapsed<0.5: return
	elapsed=0.0
	refresh()

func refresh():
	var fps=Engine.get_frames_per_second()
	text="DIAGNOSTIKA / %s\n%d FPS · interval %.2f ms (1/FPS)\nViewport %s\nDraw calls %d · objekty %d\nVideo paměť %.1f MiB (engine)\nCPU/GPU časy: neměřeny" % [RenderingServer.get_current_rendering_method(),fps,1000.0/maxi(fps,1),str(get_viewport().get_visible_rect().size),int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0]
