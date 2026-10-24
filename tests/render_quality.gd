extends SceneTree

const Settings=preload("res://scripts/core/DisplaySettings.gd")
const Saves=preload("res://scripts/progression/SaveManager.gd")
var ui
var checks=0
var failures=0

class IconProbe extends Control:
	var texture: DPITexture
	var sampled_rid: RID
	func _draw():
		draw_texture(texture,Vector2.ZERO)
		sampled_rid=texture.get_scaled_rid()

func _init():
	Saves.path_override="user://academy_test_render_game.json"
	Settings.path_override="user://academy_test_render.cfg"
	call_deferred("run")

func check(value,message):
	checks+=1
	if not value: failures+=1; push_error(message)

func run():
	if DisplayServer.get_name()=="headless":
		print("RENDER QUALITY: requires a graphical renderer; use Godot without --headless")
		quit(1); return
	Settings.new().save_settings()
	ui=load("res://scenes/main_menu/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	ui.apply_display_settings(Vector2i(3840,2160),false)
	await settle()
	check(root.get_texture().get_size()==Vector2(3840,2160),"Skutečný4K framebuffer")
	check(ui.oversampling_with_scale==CanvasItem.OVERSAMPLING_WITH_SCALE_ENABLED,"Ostré vykreslování zapnuté při běžném startu")
	# Compare pixels of actual game text, not merely framebuffer dimensions.
	var heading=find_label(ui,"Tvá první směna\nzačíná tady.")
	await compare_text(heading.get_global_rect(),"menu")
	var rack=find_rack(ui)
	var rack_name=rack.get_global_transform()*Rect2(25,14,100,24)
	await compare_text(rack_name,"rack")
	# Verify the GPU texture used by the real OptionButton icon is re-rasterized.
	var probe=IconProbe.new()
	probe.texture=ui.theme.get_icon("arrow","OptionButton")
	ui.add_child(probe)
	probe.position=Vector2(20,20)
	await settle()
	var native_size=RenderingServer.texture_2d_get(probe.sampled_rid).get_size()
	check(native_size.x>=38 and native_size.y>=38,"16px SVG má při4K skutečnou texturu nejméně38×38, ne roztažených16×16")
	print("4K SVG texture: ",native_size)
	probe.queue_free()
	# A separately loaded system font in the terminal must also be rasterized sharply.
	ui.navigate("Terminál")
	await settle()
	var terminal=find_rich_text(ui)
	await compare_text(terminal.get_global_rect(),"terminal")
	for resolution in [Vector2i(1920,1080),Vector2i(3840,2160)]:
		ui.apply_display_settings(resolution,false)
		await settle()
		check(root.get_texture().get_size()==Vector2(resolution),"Rozlišení se mění i po přepočítání textur")
	ui.queue_free()
	await process_frame
	print("RENDER QUALITY: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)

func compare_text(rect: Rect2,title: String):
	var crop=Rect2i(rect).intersection(Rect2i(Vector2i.ZERO,Vector2i(3840,2160)))
	ui.oversampling_with_scale=CanvasItem.OVERSAMPLING_WITH_SCALE_DISABLED
	await settle()
	var enlarged=root.get_texture().get_image().get_region(crop)
	ui.oversampling_with_scale=CanvasItem.OVERSAMPLING_WITH_SCALE_ENABLED
	await settle()
	var native=root.get_texture().get_image().get_region(crop)
	var old_score=edge_quality(enlarged)
	var new_score=edge_quality(native)
	print("%s edge sharpness: magnified %.3f / native %.3f" % [title,old_score,new_score])
	check(new_score>old_score*1.15,title+": skutečné vykreslení glyphů má ostřejší hrany než zvětšený původní atlas")
	if "--screenshots" in OS.get_cmdline_user_args():
		enlarged.save_png("res://test-output/"+title+"-4k-magnified.png")
		native.save_png("res://test-output/"+title+"-4k-native.png")

# Edge contrast weighted by edge strength: a bilinearly stretched low-res
# glyph spreads contrast over multiple pixels; a native glyph has sharp edges.
func edge_quality(image: Image) -> float:
	var squared=0.0
	var total=0.0
	for y in range(1,image.get_height()):
		for x in range(1,image.get_width()):
			var value=image.get_pixel(x,y).get_luminance()
			var dx=absf(value-image.get_pixel(x-1,y).get_luminance())
			var dy=absf(value-image.get_pixel(x,y-1).get_luminance())
			squared+=dx*dx+dy*dy
			total+=dx+dy
	return squared/maxf(total,0.0001)

func settle():
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

func find_label(node: Node,text: String):
	if node is Label and node.text==text: return node
	for child in node.get_children():
		var found=find_label(child,text)
		if found: return found
	return null

func find_rack(node: Node):
	if node.get_script()==preload("res://scripts/ui/RackView.gd"): return node
	for child in node.get_children():
		var found=find_rack(child)
		if found: return found
	return null

func find_rich_text(node: Node):
	if node is RichTextLabel: return node
	for child in node.get_children():
		var found=find_rich_text(child)
		if found: return found
	return null
