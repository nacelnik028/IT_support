extends RefCounted

static func record(ui, scope: String, action: String) -> Dictionary:
	var parts=scope.split("|")
	if parts.size()!=4 or not ui.game.active or ui.game.introduction_active: return {}
	return {"version":1,"session":ui.game.attempt_id,"page":parts[0],"host":parts[1],"vm":parts[2],"action":action,"values":{}}

static func capture(ui, scope: String, action: String, edits: Dictionary):
	var item=record(ui,scope,action)
	if item.is_empty(): return
	item["values"]=edits.duplicate(true)
	var archive=ui.game.work
	var key=archive.form_key(item)
	if edits.is_empty():
		if archive.data.forms.has(key): archive.data.forms.erase(key); ui.game.mark_work_dirty()
		return
	if archive.data.forms.get(key,{})==item: return
	archive.data.forms[key]=item
	ui.game.mark_work_dirty()

static func restore(ui, scope: String, action: String) -> Dictionary:
	var item=record(ui,scope,action)
	if item.is_empty(): return {}
	var archive=ui.game.work
	var saved=archive.data.forms.get(archive.form_key(item),{})
	if saved.is_empty(): return {}
	if not archive.form_valid(saved): ui.notice="Koncept formuláře má neplatnou strukturu a nebyl použit."; return {}
	if item.vm!="" and action in ui.Forms.EDIT_VM:
		var target=ui.game.sim.get_vm(item.vm)
		if target.is_empty() or target.get("host","")!=item.host:
			ui.notice="Koncept odmítnut: původní VM nebo hostitel již neexistuje. Model se nezměnil."
			return {}
	return saved["values"].duplicate(true)

static func erase(ui, scope: String, action: String):
	var item=record(ui,scope,action)
	if not item.is_empty(): ui.game.work.data.forms.erase(ui.game.work.form_key(item))
