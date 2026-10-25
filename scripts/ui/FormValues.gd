extends RefCounted

const Context = preload("res://scripts/simulation/OperationContext.gd")
const EDIT_VM = ["pve_resources","memory","network","vm_options","integration","vm_media","vm_resources","vm_disk","vm_network"]

static func option_value(picker: OptionButton, index: int = -1) -> String:
	if index < 0: index = picker.selected
	if index < 0: return ""
	var data = picker.get_item_metadata(index)
	return str(data) if data != null else picker.get_item_text(index)

static func value(ui, action: Dictionary, field: Dictionary):
	var fallback = field.get("default","")
	var path = field.get("path","")
	if path != "":
		if ui.selected_vm != "" and path.begins_with("vms."):
			var parts = path.split("."); parts[1] = ui.selected_vm; path = ".".join(parts)
		return ui.Eval.read_path(ui.game.sim.state,path,fallback)
	if field.key == "vm":
		if action.id.begins_with("vm_") and action.panel == "Průvodce VM": return ui.wizard_vm
		return ui.selected_vm if ui.selected_vm != "" else fallback
	if action.id in EDIT_VM:
		var id = ui.selected_vm
		if action.panel == "Průvodce VM": id = ui.wizard_vm
		if id == "":
			for f in action.fields:
				if f.key == "vm": id = str(f.get("default",""))
		var vm = ui.game.sim.get_vm(id)
		var key = str(field.key)
		if action.id == "vm_disk" and key == "size": key = "disk"
		if key == "ram_mib" and not vm.is_empty(): return float(vm.ram)*1024.0
		if vm.has(key): return vm[key]
	return fallback

static func choices(ui, action: Dictionary, field: Dictionary) -> Array:
	if field.key == "vm":
		var ids = []
		var platform = Context.required(action.id)
		if platform == "" and ui.page in ["Proxmox","Hyper-V"] and action.id != "promote": platform = ui.page
		for id in ui.game.sim.state.vms:
			var vm = ui.game.sim.get_vm(id)
			if not vm.is_empty() and (platform == "" or Context.platform(ui.game.sim.state,vm) == platform): ids.append(id)
		return ids
	var result = field.options.duplicate()
	if field.key == "bridge":
		for id in ui.game.sim.state.network.switches:
			if not id in result: result.append(id)
	return result

static func display(ui, field: Dictionary, raw) -> String:
	if field.key == "vm":
		var vm = ui.game.sim.get_vm(str(raw))
		return "%s · %s · %s" % [raw,vm.get("name",""),vm.get("host","")]
	return {"Off":"Vypnuto","Running":"Běží","Healthy":"V pořádku","Start":"Spustit","Shutdown":"Korektně vypnout","TurnOff":"Vynutit vypnutí","ShutDown":"Korektně vypnout"}.get(str(raw),str(raw))

static func validate(ui, action: Dictionary, inputs: Dictionary) -> String:
	for field in action.fields:
		var input = inputs[field.key]
		if input is OptionButton and input.selected < 0: return "%s: vyber existující kompatibilní objekt." % field.label
		if input is LineEdit:
			var value = input.text.strip_edges()
			if field.key in ["ip","gateway","dns"] and not ui.game.sim.valid_ip(value): return "%s: zadej IPv4 adresu, například 192.168.20.10." % field.label
			if field.key in ["name","hostname","id","serial","path"] and value == "": return "%s: doplň hodnotu." % field.label
			if field.key == "id" and (not value.is_valid_int() or int(value) < 100 or int(value) > 9999): return "%s: zadej celé číslo 100–9999." % field.label
		if input is SpinBox:
			var text = input.get_line_edit().text.strip_edges().trim_suffix(input.suffix).strip_edges()
			if not text.is_valid_float() or not is_finite(float(text)): return "%s: zadej platné číslo." % field.label
	return ""
