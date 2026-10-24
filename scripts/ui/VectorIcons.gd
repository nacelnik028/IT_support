extends RefCounted

# Keep the SVG source: DPITexture rasterizes a separate, sharp texture for
# each display scale instead of magnifying the default theme's tiny bitmaps.
static var cache: Dictionary={}

static func icon(kind: String,disabled=false) -> DPITexture:
	var key=kind+str(disabled)
	if cache.has(key): return cache[key]
	var ink="#64748b" if disabled else "#dce8f5"
	var accent="#64748b" if disabled else "#3ddbc6"
	var body=""
	var size=Vector2i(16,16)
	match kind:
		"down": body='<path d="m4 6 4 4 4-4"/>'
		"up": body='<path d="m4 10 4-4 4 4"/>'
		"right": body='<path d="m6 4 4 4-4 4"/>'
		"left": body='<path d="m10 4-4 4 4 4"/>'
		"updown":
			size=Vector2i(16,24)
			body='<path d="m4 8 4-4 4 4m-8 8 4 4 4-4"/>'
		"checked","unchecked","indeterminate":
			body='<rect x="1.5" y="1.5" width="13" height="13" rx="3" fill="#102135"/>'
			if kind=="checked": body+='<path d="m4.5 8 2.3 2.5 4.7-5" stroke="%s"/>' % accent
			if kind=="indeterminate": body+='<path d="M4.5 8h7" stroke="%s"/>' % accent
		"radio_checked","radio_unchecked":
			body='<circle cx="8" cy="8" r="6.5" fill="#102135"/>'
			if kind=="radio_checked": body+='<circle cx="8" cy="8" r="3" fill="%s" stroke="none"/>' % accent
		"on","off","on_mirrored","off_mirrored":
			size=Vector2i(36,20)
			var active=kind.begins_with("on")
			var right=active!=kind.ends_with("mirrored")
			body='<rect x="1" y="1" width="34" height="18" rx="9" fill="%s" stroke="%s"/><circle cx="%d" cy="10" r="6" fill="%s" stroke="none"/>' % ["#194d4a" if active else "#0a1727",accent if active else "#52667e",26 if right else 10,accent if active else ink]
		"search": body='<circle cx="6.5" cy="6.5" r="4.5"/><path d="m10 10 4 4"/>'
		"close": body='<path d="m4 4 8 8m0-8-8 8"/>'
	var svg='<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d"><g fill="none" stroke="%s" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">%s</g></svg>' % [size.x,size.y,size.x,size.y,ink,body]
	var texture=DPITexture.create_from_string(svg)
	texture.fix_alpha_border=true
	cache[key]=texture
	return texture

static func apply(theme: Theme):
	theme.set_icon("arrow","OptionButton",icon("down"))
	for state in ["","_hover","_pressed","_disabled"]:
		for direction in ["up","down"]:
			theme.set_icon(direction+state,"SpinBox",icon(direction,state=="_disabled"))
	theme.set_icon("updown","SpinBox",icon("updown"))
	for type in ["CheckBox","Tree","PopupMenu"]:
		for name in ["checked","unchecked","radio_checked","radio_unchecked","indeterminate"]:
			for state in ["","_disabled"]: theme.set_icon(name+state,type,icon(name,state!=""))
	for name in ["checked","unchecked"]:
		for state in ["","_disabled"]:
			for mirror in ["","_mirrored"]:
				theme.set_icon(name+state+mirror,"CheckButton",icon(("on" if name=="checked" else "off")+mirror,state!=""))
	for pair in [["arrow","down"],["arrow_collapsed","right"],["arrow_collapsed_mirrored","left"],["select_arrow","right"],["updown","updown"]]:
		theme.set_icon(pair[0],"Tree",icon(pair[1]))
	theme.set_icon("submenu","PopupMenu",icon("right"))
	theme.set_icon("submenu_mirrored","PopupMenu",icon("left"))
	theme.set_icon("search","PopupMenu",icon("search"))
	theme.set_icon("close","Window",icon("close"))
	theme.set_icon("close_pressed","Window",icon("close"))
