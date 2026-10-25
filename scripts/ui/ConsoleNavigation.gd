extends RefCounted

const STEPS = ["vm_identity","vm_media","vm_resources","vm_disk","vm_network","vm_install"]
const TITLES = ["Identita","ISO","CPU / RAM","Disk","Síť","Shrnutí / instalace"]

static func draw(ui):
	var actions = []
	var options = ["Přehled"]
	var relevant = []
	for a in ui.game.actions:
		if a.get("console","Proxmox") != ui.page: continue
		if ui.world_enabled and a.id.begins_with("physical_"): continue
		actions.append(a)
		if not a.panel in options: options.append(a.panel)
		if a.id in ui.game.current.get("available_actions",[]): relevant.append(a.id)
	if not relevant.is_empty() and not (ui.game.session_kind == "lesson" and ui.game.tutorial.session.mode == "exam"): options.insert(1,"Podle ticketu")
	if not ui.tab in options: ui.tab = "Podle ticketu" if "Podle ticketu" in options else "Přehled"
	var row = ui.hbox(ui.center,14)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var navigation = ui.vbox(row,8)
	navigation.custom_minimum_size.x = 280
	navigation.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	if ui.page in ["Proxmox","Hyper-V"]: ui.draw_tree(navigation)
	else: navigation.add_child(ui.label("NAS-01  /  ÚLOŽIŠTĚ",15,ui.CYAN))
	ui.Components.section(ui,navigation,"Pracovní oblasti")
	var sections = ui.scroll(navigation)
	sections.add_theme_constant_override("separation",4)
	ui.register_target("console:sections",sections)
	for section in options:
		var b = ui.Components.selection(ui,section,func(): ui.tab = section; ui.active_action = ""; ui.notice = ""; ui.draw_ui(),ui.tab == section)
		b.custom_minimum_size.y = 32
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		sections.add_child(b)
		ui.register_target("section:"+section,b)
	var detail = ui.vbox(row,10)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ui.Components.console_context(ui,detail)
	ui.Components.section(ui,detail,ui.tab)
	if ui.tab == "Přehled":
		ui.draw_state(ui.scroll(detail))
		return
	if ui.tab == "Průvodce VM":
		draw_wizard(ui,detail,actions)
		return
	var available = []
	var operations = HFlowContainer.new()
	operations.add_theme_constant_override("h_separation",6)
	operations.add_theme_constant_override("v_separation",6)
	detail.add_child(operations)
	for a in actions:
		if a.panel == ui.tab or (ui.tab == "Podle ticketu" and a.id in relevant): available.append(a)
	if available.is_empty(): return
	if not ui.active_action in available.map(func(a): return a.id): ui.active_action = available[0].id
	for a in available:
		var b = ui.Components.selection(ui,a.label,func(): ui.active_action = a.id; ui.notice = ""; ui.draw_ui(),ui.active_action == a.id)
		b.custom_minimum_size.y = 32
		b.add_theme_font_size_override("font_size",roundi(14*ui.display_settings.text_scale))
		operations.add_child(b)
		ui.register_target("operation:"+a.id,b)
	var contents = ui.scroll(detail)
	contents.get_parent().name = "OperationScroll"
	for a in available:
		if a.id == ui.active_action: ui.draw_form(contents,a,detail)

static func draw_wizard(ui, parent: Node, actions: Array):
	var header = HFlowContainer.new()
	header.add_theme_constant_override("h_separation",6)
	header.add_theme_constant_override("v_separation",6)
	parent.add_child(header)
	for i in STEPS.size():
		var b = ui.Components.selection(ui,("✓ " if i<ui.wizard_step else str(i+1)+". ")+TITLES[i],func(): ui.wizard_step = i; ui.draw_ui(),i == ui.wizard_step)
		b.disabled = i > ui.wizard_unlocked
		b.custom_minimum_size.y = 34
		b.add_theme_font_size_override("font_size",roundi(13*ui.display_settings.text_scale))
		header.add_child(b)
		ui.register_target("wizard:step:"+str(i),b)
	var contents = ui.scroll(parent)
	contents.get_parent().name = "OperationScroll"
	if ui.wizard_step == 5:
		var vm = ui.game.sim.get_vm(ui.wizard_vm)
		contents.add_child(ui.label("%s / %s\nISO: %s · %s vCPU · %s MiB RAM\nDisk: %s GB na %s\n%s · VLAN %s · %s" % [ui.wizard_vm,vm.get("name","—"),vm.get("iso","—"),vm.get("cpu",0),vm.get("ram_mib",0),vm.get("disk",0),vm.get("storage","—"),vm.get("bridge","—"),vm.get("vlan",0),vm.get("ip","—")],16,ui.CYAN))
	for a in actions:
		if a.id == STEPS[ui.wizard_step]:
			ui.active_action = a.id
			ui.draw_form(contents,a,parent)
			ui.form_buttons[a.id].text = "Uložit a Další →" if ui.wizard_step < 5 else "Dokončit instalaci OS"
	var footer = ui.hbox(parent)
	var back = ui.button("← Zpět",func(): ui.wizard_step -= 1; ui.draw_ui())
	back.disabled = ui.wizard_step == 0
	footer.add_child(back)
	ui.register_target("wizard:back",back)
	footer.add_child(ui.button("Zavřít průvodce",func(): ui.tab = "VM / CT"; ui.active_action = "power"; ui.draw_ui()))
	if ui.wizard_step == 5:
		footer.add_child(ui.button("Spustit VM",func(): ui.perform("power",{"vm":ui.wizard_vm,"power":"Start"})))
		footer.add_child(ui.button("Ověřit službu",func(): ui.perform("verify",{})))
		ui.register_target("action:power",footer.get_child(2))
		ui.register_target("action:verify",footer.get_child(3))
