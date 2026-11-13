extends "res://scripts/programming/CodeEditorController.gd"

var service

func _ready():
	super._ready()
	for item in find_children("*","Label",true,false):
		if item.text=="NORTHSTAR  /  PROGRAMOVACÍ UČEBNA": item.text = "SERVISNÍ MISE / PYTHON"
	for item in find_children("*","Button",true,false):
		if item.text in ["Studium a postup","Sbalit seznam lekcí a úloh","Zpět do učebny  [Esc]"]: item.hide()
		if item.text=="Resetovat": item.text = "Obnovit počáteční kód"
	sidebar.hide()
	instruction.reparent(save_row)
	instruction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_button.hide()
	mode_picker.disabled = true
	mode_picker.tooltip_text = "Režim patří celé servisní misi; vybírá se při novém pokusu u servisního stolu."
	var toolbar := run_button.get_parent()
	toolbar.add_child(button("Aktualizovat virtuální data",func():
		capture_editor_state()
		service.refresh_input()
		brief_text = manager.current.description+"\n\nVirtuální vstup:\n"+JSON.stringify({"current":service.input.records,"initial":service.records(service.session.before)},"  ")
		update_instruction()
		refresh_verification()))
	toolbar.add_child(button("Zpět k incidentu",func():
		capture_editor_state()
		shell.ui.game.save()
		shell.open_network_workshop("ticket")))
	brief_text = manager.current.description+"\n\nVirtuální vstup:\n"+JSON.stringify({"current":service.input.records,"initial":service.records(service.session.before)},"  ")
	update_instruction()

func update_instruction():
	super.update_instruction()
	if service!=null and not service.input.is_empty():
		instruction.text = ("Aktuální virtuální data incidentu" if service.analysis_input_current() else "! Data zastaralá / aktualizuj vstup")+" · "+session_mode()

func session_mode() -> String:
	return service.session.MODES[service.session.mode]

func refresh_verification():
	super.refresh_verification()
	if service!=null and not service.analysis_input_current():
		verification_state.text = "! Analýza zastaralá po změně incidentu"

