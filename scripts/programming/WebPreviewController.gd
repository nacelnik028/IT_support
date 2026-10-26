extends ScrollContainer

const Document=preload("res://scripts/programming/WebDocument.gd")
var document
var content: VBoxContainer
var controls={}
var fields={}
var groups={}
var feedback: Label

func clear_preview():
	for child in get_children(): remove_child(child); child.queue_free()
	document=null; controls={}; fields={}; groups={}
	var empty=Label.new()
	empty.text="NÁHLED STRÁNKY\n\nSpusť svůj kód tlačítkem Spustit.\nPotom zde vyzkoušej odkazy, tlačítka a formuláře."
	empty.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; empty.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	empty.add_theme_color_override("font_color",preload("res://scripts/ui/AcademyTheme.gd").MUTED)
	add_child(empty)

func render_files(files: Dictionary):
	document=Document.new()
	var result=document.load_files(files)
	render_document()
	if not result.ok: feedback.text=result.error

func render_document():
	for child in get_children(): remove_child(child); child.queue_free()
	controls={}; fields={}; groups={}
	content=VBoxContainer.new(); content.size_flags_horizontal=Control.SIZE_EXPAND_FILL; add_child(content)
	feedback=Label.new(); feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; feedback.add_theme_color_override("font_color",Color("ffd27c")); content.add_child(feedback)
	var note=Label.new(); note.text="Živý výukový náhled · lokální dokument"; note.add_theme_font_size_override("font_size",15); content.add_child(note)
	for child in document.nodes[0].children: render_node(child,content)

func css_number(text, fallback: float = 0.0) -> float:
	var value=str(text).strip_edges().trim_suffix("px")
	return clampf(float(value),0,800) if value.is_valid_float() else fallback

func color_value(value, fallback: Color) -> Color:
	return Color.from_string(str(value),fallback)

func box_style(style: Dictionary) -> StyleBoxFlat:
	var box=StyleBoxFlat.new()
	box.bg_color=color_value(style.get("background-color",style.get("background","transparent")),Color.TRANSPARENT)
	var border=str(style.get("border","")); var parts=border.split(" ",false)
	if parts.size()>=3:
		box.set_border_width_all(int(css_number(parts[0],1))); box.border_color=color_value(parts[-1],Color.GRAY)
	box.set_corner_radius_all(int(css_number(style.get("border-radius","0"))))
	var padding=str(style.get("padding","0")).split(" ",false)
	var top=css_number(padding[0]) if not padding.is_empty() else 0.0
	var right=css_number(padding[1]) if padding.size()>1 else top
	var bottom=css_number(padding[2]) if padding.size()>2 else top
	var left=css_number(padding[3]) if padding.size()>3 else right
	box.content_margin_top=top; box.content_margin_right=right; box.content_margin_bottom=bottom; box.content_margin_left=left
	return box

func render_node(id: int, parent: Control):
	var node=document.nodes[id]; var tag=str(node.tag); var attrs=node.attrs; var style=node.style
	if tag in ["head","style","script","meta","link","title"] or attrs.has("hidden") or style.get("display","")=="none": return
	if tag=="#text":
		if node.text.strip_edges()!="":
			var text=make_text(node.text.strip_edges(),style,18); parent.add_child(text); controls[id]=text
		return
	var outer=MarginContainer.new(); outer.size_flags_horizontal=Control.SIZE_EXPAND_FILL; parent.add_child(outer); controls[id]=outer
	outer.tooltip_text=attrs.get("title","")
	var margin_parts=str(style.get("margin","2")).split(" ",false)
	var margin=int(css_number(margin_parts[0],2)) if not margin_parts.is_empty() else 2
	for side in ["left","right","top","bottom"]: outer.add_theme_constant_override("margin_"+side,margin)
	var panel=PanelContainer.new(); outer.add_child(panel)
	var visual_style=style.duplicate()
	if tag=="body" and not visual_style.has("background-color") and not visual_style.has("background"): visual_style["background-color"]="white"
	panel.add_theme_stylebox_override("panel",box_style(visual_style))
	var child_container: Container
	if style.get("display","")=="flex" and style.get("flex-direction","")!="column": child_container=HBoxContainer.new()
	elif style.get("display","")=="grid":
		var grid=GridContainer.new(); var columns=str(style.get("grid-template-columns","1fr 1fr"))
		grid.columns=clampi(int(columns.get_slice("(",1).get_slice(",",0)),1,4) if columns.begins_with("repeat(") else clampi(columns.split(" ",false).size(),1,4)
		child_container=grid
	else: child_container=VBoxContainer.new()
	child_container.add_theme_constant_override("separation",int(css_number(style.get("gap","4"),4)))
	panel.add_child(child_container)
	if style.has("width"): outer.custom_minimum_size.x=minf(400,css_number(style.width,100))
	if tag in ["h1","h2","h3","h4","h5","h6","p","strong","em","mark","span","pre","code","label","caption","li","th","td"]:
		var text=document.text_content(id)
		if tag=="li":
			var prefix="• "
			if document.nodes[node.parent].tag=="ol":
				var siblings=document.nodes[node.parent].children.filter(func(child): return document.nodes[child].tag=="li")
				prefix=str(siblings.find(id)+1)+". "
			text=prefix+text
		var font_size=30 if tag=="h1" else 24 if tag=="h2" else 21 if tag=="h3" else 18
		var label=make_text(text,style,font_size)
		if tag=="mark": label.add_theme_color_override("font_color",Color("7a4700")); panel.add_theme_stylebox_override("panel",box_style({"background-color":"#fff19a"}))
		if tag in ["strong","th"]: label.add_theme_font_size_override("font_size",20)
		if tag=="label" and attrs.has("for"):
			label.mouse_filter=Control.MOUSE_FILTER_STOP
			label.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed:
					var targets=document.query("#"+attrs.for)
					if not targets.is_empty() and fields.has(targets[0]): fields[targets[0]].grab_focus())
		if tag in ["p","li","strong","em","mark","span","h1","h2"] and node.children.any(func(child): return document.nodes[child].tag in ["strong","em","mark","code","span","br"]):
			var rich=RichTextLabel.new(); rich.bbcode_enabled=true; rich.fit_content=true; rich.scroll_active=false
			rich.add_theme_font_size_override("normal_font_size",int(css_number(style.get("font-size",font_size),font_size)))
			rich.add_theme_color_override("default_color",color_value(style.get("color","#20313d"),Color("20313d")))
			rich.text=inline_markup(id); child_container.add_child(rich); label.queue_free()
		else: child_container.add_child(label)
		# Form labels may wrap their associated input.
		if tag=="label":
			for child in node.children:
				if document.nodes[child].tag in ["input","textarea","select"]: render_node(child,child_container)
		return
	if tag=="a":
		var link=LinkButton.new(); link.text=document.text_content(id); child_container.add_child(link)
		link.pressed.connect(func():
			var href=str(attrs.get("href",""))
			if href.begins_with("#"):
				var targets=document.query(href)
				if not targets.is_empty() and controls.has(targets[0]): ensure_control_visible(controls[targets[0]])
			else: feedback.text="Externí odkaz: "+href+" · Náhled neotevírá síť ani jiné aplikace.")
		return
	if tag=="img":
		if attrs.get("src","")=="server.svg":
			var image=TextureRect.new(); image.texture=preload("res://assets/icons/academy.svg"); image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; image.custom_minimum_size=Vector2(100,100); child_container.add_child(image)
		else: child_container.add_child(make_text("[Obrázek: "+str(attrs.get("alt","chybí alt"))+"]",style,18))
		return
	if tag=="input":
		var type=str(attrs.get("type","text"))
		if type=="hidden": outer.hide(); return
		if type in ["checkbox","radio"]:
			var box=CheckBox.new(); box.text=str(attrs.get("value","")); box.button_pressed=attrs.has("checked"); box.disabled=attrs.has("disabled"); child_container.add_child(box); fields[id]=box
			if type=="radio":
				var group_name=str(attrs.get("name","default"))
				if not groups.has(group_name): groups[group_name]=ButtonGroup.new()
				box.button_group=groups[group_name]
		else:
			var field=LineEdit.new(); field.text=str(attrs.get("value","")); field.placeholder_text=str(attrs.get("placeholder","")); field.editable=not attrs.has("disabled"); field.secret=type=="password"; child_container.add_child(field); fields[id]=field
		return
	if tag=="textarea":
		var field=TextEdit.new(); field.text=document.text_content(id); field.custom_minimum_size.y=90; field.editable=not attrs.has("disabled"); child_container.add_child(field); fields[id]=field; return
	if tag=="select":
		var field=OptionButton.new()
		for option in node.children:
			if document.nodes[option].tag=="option": field.add_item(document.text_content(option))
		child_container.add_child(field); fields[id]=field; return
	if tag=="button":
		var button=Button.new(); button.text=document.text_content(id); button.disabled=attrs.has("disabled"); child_container.add_child(button)
		button.pressed.connect(func():
			if document.click(id): render_document()
			elif attrs.get("type","submit")=="submit": validate_form())
		return
	if tag=="hr": child_container.add_child(HSeparator.new()); return
	if tag=="br": child_container.add_child(Control.new()); return
	if tag=="tr":
		panel.remove_child(child_container); child_container.queue_free(); child_container=HBoxContainer.new(); panel.add_child(child_container)
	for child in node.children: render_node(child,child_container)

func make_text(text: String, style: Dictionary, font_size: int) -> Label:
	var label=Label.new(); label.text=text; label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color",color_value(style.get("color","#20313d"),Color("20313d")))
	label.add_theme_font_size_override("font_size",int(css_number(style.get("font-size",font_size),font_size)))
	return label

func inline_markup(id: int) -> String:
	var node=document.nodes[id]; var text=str(node.text).replace("[","[lb]")
	for child in node.children: text+=inline_markup(child)
	match node.tag:
		"strong","th": return "[b]"+text+"[/b]"
		"em": return "[i]"+text+"[/i]"
		"mark": return "[bgcolor=#fff19a][color=#332600]"+text+"[/color][/bgcolor]"
		"code": return "[code]"+text+"[/code]"
		"br": return "\n"
	return text

func validate_form():
	var errors=[]
	for id in fields:
		var attrs=document.nodes[id].attrs; var field=fields[id]
		if attrs.has("disabled"): continue
		if field is CheckBox and attrs.has("required") and not field.button_pressed: errors.append("Potvrď povinnou volbu.")
		if field is LineEdit or field is TextEdit:
			var value=field.text
			if attrs.has("required") and value.strip_edges()=="": errors.append("Vyplň povinné pole "+str(attrs.get("id","")))
			if attrs.get("type","")=="email" and value!="" and (not "@" in value or not "." in value.get_slice("@",1)): errors.append("Oprav e-mailovou adresu.")
			if attrs.get("type","")=="number" and value!="" and not value.is_valid_float(): errors.append("Zadej číslo.")
	feedback.text="Formulář je platný. Lokální simulace jej nikam neodesílá." if errors.is_empty() else "\n".join(errors)
