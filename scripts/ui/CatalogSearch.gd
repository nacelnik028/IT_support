extends RefCounted

static func draw(ui, parent: Node, key: String, status: bool = false):
	var row=ui.hbox(parent)
	var input=LineEdit.new()
	input.placeholder_text="Hledat podle názvu, oblasti nebo popisu…"
	input.text=ui.search_queries.get(key,"")
	input.custom_minimum_size.y=38
	input.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	row.add_child(input)
	ui.register_target("search:"+key,input)
	input.text_changed.connect(func(value): ui.search_queries[key]=value; ui.call_deferred("draw_ui"))
	if status:
		var picker=OptionButton.new()
		for title in ["Všechny stavy","Nedokončené","Dokončené"]: picker.add_item(title)
		picker.select(ui.search_status.get(key,0))
		row.add_child(picker)
		picker.item_selected.connect(func(i): ui.search_status[key]=i; ui.draw_ui())

static func matches(ui, key: String, value, complete: bool = false) -> bool:
	var query=ui.search_queries.get(key,"").strip_edges().to_lower()
	var state=ui.search_status.get(key,0)
	return (query=="" or query in str(value).to_lower()) and (state==0 or (state==2)==complete)
