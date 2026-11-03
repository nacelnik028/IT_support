extends RefCounted

var data={"version":1,"forms":{},"lessons":{}}

static func form_key(record: Dictionary) -> String:
	return JSON.stringify([record.session,record.page,record.host,record.vm,record.action,1]).sha256_text()

static func form_valid(record) -> bool:
	if not record is Dictionary or record.get("version")!=1 or not record.get("values") is Dictionary or record.values.size()>40: return false
	for key in ["session","page","host","vm","action"]:
		if not record.get(key) is String or record[key].length()>160: return false
	if record.session=="" or not record.host in ["PVE-01","PVE-02","HV-01","HV-02","NAS-01","BACKUP-01"]: return false
	if not record.page in ["Proxmox","Hyper-V","Storage","Síť","Terminál"]: return false
	var fields=[]
	if record.action=="_terminal": fields=["command"]
	else:
		for action in JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/actions.json")):
			if action.id==record.action:
				for field in action.fields: fields.append(field.key)
	if fields.is_empty(): return false
	for field in record.values:
		if not field in fields or field=="vm": return false
		var value=record.values[field]
		if value is String:
			if value.length()>8192: return false
		elif value is Dictionary:
			if value.keys().size()!=2 or not value.get("text") is String or value.text.length()>128 or not typeof(value.get("value")) in [TYPE_INT,TYPE_FLOAT] or not is_finite(value.value): return false
		elif value is Array:
			if value.size()>32: return false
			for id in value:
				if not id is String or id.length()>80: return false
		elif not typeof(value) in [TYPE_BOOL,TYPE_INT,TYPE_FLOAT]: return false
	return true

static func valid(value, validator) -> bool:
	if not value is Dictionary or value.get("version",1)!=1 or not value.get("forms",{}) is Dictionary or not value.get("lessons",{}) is Dictionary: return false
	if value.get("forms",{}).size()>64 or value.get("lessons",{}).size()>63 or JSON.stringify(value).to_utf8_buffer().size()>4194304: return false
	for key in value.get("forms",{}):
		if not form_valid(value.forms[key]) or key!=form_key(value.forms[key]): return false
	for key in value.get("lessons",{}):
		var record=value.lessons[key]
		if not record is Dictionary or not validator.session(record.get("snapshot",{}),"lesson") or record.get("snapshot",{}).is_empty(): return false
		if record.get("content")!=JSON.stringify(validator.lesson_by_id(int(record.snapshot.id))).sha256_text(): return false
		if key!=str(int(record.snapshot.id))+":"+record.snapshot.tutorial.mode or record.snapshot.finished: return false
	return true
