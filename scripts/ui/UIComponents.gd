extends RefCounted

const Design = preload("res://scripts/ui/AcademyTheme.gd")

static func selection(ui, caption: String, action: Callable, selected: bool) -> Button:
	var b = ui.button(caption, action)
	b.theme_type_variation = "ActiveNavButton" if selected else "NavButton"
	b.toggle_mode = true
	b.button_pressed = selected
	b.tooltip_text = ("Vybráno · " if selected else "Otevřít · ") + caption
	return b

static func badge(ui, parent: Node, caption: String, color: Color = Design.MUTED):
	var text = ui.label(caption, 12, color)
	text.autowrap_mode = TextServer.AUTOWRAP_OFF
	text.add_theme_stylebox_override("normal", Design.surface(Design.BACKGROUND, color.darkened(0.55), 5, 10))
	text.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(text)
	return text

static func section(ui, parent: Node, caption: String):
	var row = ui.hbox(parent, 10)
	row.add_child(ui.label(caption.to_upper(), 12, Design.MUTED))
	return row

static func console_context(ui, parent: Node):
	var panel = ui.card(parent)
	panel.add_theme_constant_override("separation", 4)
	var row = ui.hbox(panel, 20)
	var platform = ui.vbox(row, 2)
	platform.custom_minimum_size.x = 230 if ui.display_settings.text_scale>1.0 else 180
	platform.add_child(ui.label("PLATFORMA", 11, Design.MUTED))
	platform.add_child(ui.label({"Proxmox":"Proxmox VE", "Hyper-V":"Microsoft Hyper-V", "Storage":"Storage / RAID"}[ui.page], 18))
	var host = ui.vbox(row, 2)
	host.custom_minimum_size.x = 160
	host.add_child(ui.label("HOSTITEL" if ui.page!="Storage" else "ZAŘÍZENÍ", 11, Design.MUTED))
	host.add_child(ui.label("NAS-01" if ui.page=="Storage" else ui.host, 18, Design.ACCENT))
	var target = ui.vbox(row, 2)
	target.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vm = ui.game.sim.get_vm(ui.selected_vm)
	target.add_child(ui.label("CÍL OPERACE / VM", 11, Design.MUTED))
	var caption=ui.label("%s · %s" % [ui.selected_vm, vm.name] if not vm.is_empty() else "Konfigurace hostitele" if ui.page!="Storage" else "Fyzické disky a pole", 17)
	target.add_child(caption)
	ui.register_target("console:vm",caption)
	if not vm.is_empty(): badge(ui, row, "● Běží" if vm.status=="Running" else "○ Vypnuto", Design.SUCCESS if vm.status=="Running" else Design.MUTED)
	ui.register_target("console:context", panel)

static func form_context(ui, action: Dictionary, inputs: Dictionary):
	var label=ui.ui_targets.get("console:vm")
	if not is_instance_valid(label): return
	if inputs.has("vm") and inputs.vm is OptionButton:
		var id=ui.option_value(inputs.vm)
		var vm=ui.game.sim.get_vm(id)
		label.text="%s · %s · %s" % [id,vm.name,"běží" if vm.status=="Running" else "vypnuto"] if not vm.is_empty() else "Žádná kompatibilní VM"
	elif action.panel=="Průvodce VM":
		var vm=ui.game.sim.get_vm(ui.wizard_vm)
		label.text="%s · %s" % [ui.wizard_vm,vm.name] if not vm.is_empty() else "Nový virtuální stroj · průvodce"
	else:
		label.text="Fyzické disky a pole" if ui.page=="Storage" else "Konfigurace hostitele"

static func field_group(key: String) -> String:
	if key in ["id", "name", "hostname", "vm", "target", "host"]: return "Cílový objekt"
	if key in ["cpu", "ram", "ram_mib", "minimum", "maximum", "dynamic"]: return "Výpočetní prostředky"
	if key in ["ip", "gateway", "dns", "bridge", "vlan", "nic", "switch"]: return "Síťové parametry"
	return "Konfigurace"
