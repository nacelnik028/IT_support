extends RefCounted

const VERSION=1
const MAX_DRAFTS=128
const MAX_FILE_BYTES=131072
const MAX_TOTAL_BYTES=2097152
var catalog=JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/programming/catalog.json"))
var generated={}
var digest=""

func content_version() -> String:
	if digest=="": digest=JSON.stringify(catalog).sha256_text()
	return digest

static func key(record: Dictionary) -> String:
	# JSON reload represents numbers as floats. Keys must remain identical to
	# those created by the live generator's integer seed/count/position.
	var recipe=record.series
	var variant=[] if recipe.is_empty() else [recipe.category,recipe.difficulty,int(recipe.count),int(recipe.seed)]
	return JSON.stringify([VERSION,record.id,record.mode,record.lesson,variant,int(record.position)]).sha256_text()

func task(record: Dictionary) -> Dictionary:
	if not record.series.is_empty():
		var recipe=record.series
		if recipe.keys().size()!=4 or not recipe.get("category") in ["python","html","css","javascript","mixed"] or not recipe.get("difficulty") in ["beginner","advanced","exam"]: return {}
		if not number(recipe.get("seed"),0) or not number(recipe.get("count"),1,20) or not number(record.position,0,int(recipe.count)-1): return {}
		if record.mode!=("exam" if recipe.difficulty=="exam" else "practice") or record.lesson: return {}
		var fingerprint=JSON.stringify(recipe)
		if not generated.has(fingerprint):
			if generated.size()>32: generated.clear()
			generated[fingerprint]=preload("res://scripts/programming/PracticeGenerator.gd").new().generate(catalog,recipe.category,recipe.difficulty,int(recipe.count),int(recipe.seed))
		var queue=generated[fingerprint]
		if queue.size()!=int(recipe.count): return {}
		return queue[int(record.position)] if queue[int(record.position)].id==record.id else {}
	if record.position!=0: return {}
	for item in catalog.missions+catalog.debugging:
		if item.id==record.id: return item
	return {}

static func number(value, low: int, high: int = 9007199254740991) -> bool:
	return typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(value) and value==floor(value) and value>=low and value<=high

func valid_record(record) -> bool:
	if not record is Dictionary: return false
	for field in ["id","content","mode","active"]:
		if not record.get(field) is String: return false
	if record.get("version")!=VERSION or record.content!=content_version() or not record.mode in ["learn","practice","exam"]: return false
	if not record.get("lesson") is bool or not record.get("series") is Dictionary or not record.get("files") is Dictionary or not record.get("views") is Dictionary: return false
	if not number(record.get("position"),0,19) or not number(record.get("hints"),0,10000) or not number(record.get("step"),0,3) or not number(record.get("updated"),0): return false
	if record.mode=="exam" and int(record.hints)>0: return false
	var definition=task(record)
	if definition.is_empty() or record.files.size()!=definition.starter.size() or not record.files.has(record.active): return false
	for filename in record.files:
		if not filename in ["main.py","index.html","style.css","script.js"] or not definition.starter.has(filename): return false
		if not record.files[filename] is String or record.files[filename].to_utf8_buffer().size()>MAX_FILE_BYTES: return false
	for filename in record.views:
		if not record.files.has(filename) or not record.views[filename] is Dictionary: return false
		var view=record.views[filename]
		if view.keys().size()>7: return false
		for field in view:
			if not field in ["line","column","from_line","from_column","to_line","to_column","scroll"] or not number(view[field],0,1000000): return false
	return true

func valid(records) -> bool:
	if not records is Dictionary or records.size()>MAX_DRAFTS or JSON.stringify(records).to_utf8_buffer().size()>MAX_TOTAL_BYTES: return false
	for id in records:
		if not valid_record(records[id]) or id!=key(records[id]): return false
	return true
