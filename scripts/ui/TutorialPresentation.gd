extends RefCounted

# Only presentation changes here. Opening a step never emits a completion event
# or fills in a configuration value; the existing validator owns progression.
static func descriptor(ui, action_id: String, target_page: String) -> Dictionary:
	for action in ui.game.actions:
		if action.id==action_id and action.get("console","Proxmox")==target_page: return action
	return {}

static func route(ui, change_page: bool = false):
	if ui.game.session_kind!="lesson" or not ui.game.tutorial.guided(): return
	var step=ui.game.tutorial.current_step()
	if step.is_empty(): return
	var target_page=step.get("page",ui.game.current.category)
	if not change_page and ui.page!=target_page: return
	ui.context_open=false
	ui.page=target_page
	ui.tab=step.get("tab","")
	var key=ui.game.tutorial.target(ui.game.sim.state).split(":")
	var action=descriptor(ui,key[1],target_page) if key.size()>1 and key[0] in ["field","action"] else {}
	var target_host=step.get("event",{}).get("host",ui.game.current.server)
	var target_vm=""
	if not action.is_empty():
		for field in action.fields:
			if field.key=="vm": target_vm=str(field.get("default",""))
		# A restore's checks refer to its destination, not its source selector.
		if not action.id in ["restore","promote","import"]:
			for goal in step.get("checks",[]):
				var parts=str(goal.path).split(".")
				if parts.size()>1 and parts[0]=="vms" and not ui.game.sim.get_vm(parts[1]).is_empty(): target_vm=parts[1]; break
		ui.active_action=action.id
		if ui.tab!="Průvodce VM": ui.tab=action.panel
	if ui.tab=="Průvodce VM":
		var index=ui.Console.STEPS.find(ui.active_action)
		ui.wizard_step=index if index>=0 else 5
		ui.wizard_unlocked=maxi(ui.wizard_unlocked,ui.wizard_step)
		# The final tutorial step switches its target between installation,
		# Start and Verify while all three controls belong to the summary page.
		for goal in step.get("checks",[]):
			var parts=str(goal.path).split(".")
			if parts.size()>1 and parts[0]=="vms": ui.wizard_vm=parts[1]; break
		if target_vm!="": target_vm=ui.wizard_vm
	var vm=ui.game.sim.get_vm(target_vm)
	if not vm.is_empty() and ui.Context.platform(ui.game.sim.state,vm)==target_page: target_host=vm.host
	if target_page in ["Proxmox","Hyper-V"] and ui.game.sim.state.hosts.get(target_host,{}).get("kind","")!=target_page:
		target_host="PVE-01" if target_page=="Proxmox" else "HV-01"
	ui.host=target_host
	ui.selected_vm=target_vm if not vm.is_empty() and ui.Context.platform(ui.game.sim.state,vm)==target_page else ""
	ui.game.tutorial.session.page=ui.page
	ui.game.tutorial.session.tab=ui.tab

static func target_key(ui) -> String:
	if ui.context_open: return "tutorial:recover"
	var key=ui.game.tutorial.target(ui.game.sim.state)
	var step=ui.game.tutorial.current_step()
	var target_page=step.get("page",ui.game.current.category)
	if ui.page!=target_page: return "nav:"+target_page
	if ui.ui_targets.has(key): return key
	var parts=key.split(":")
	if parts.size()>1 and parts[0] in ["field","action"]:
		var operation="operation:"+parts[1]
		if ui.ui_targets.has(operation): return operation
		var action=descriptor(ui,parts[1],target_page)
		var section="section:"+action.get("panel",step.get("tab",""))
		if ui.ui_targets.has(section): return section
	return "tutorial:recover"

static func draw(ui, parent: Node):
	if ui.game.session_kind!="lesson" or ui.game.tutorial.session.get("mode","")!="learn": return
	var t=ui.game.tutorial
	var panel=ui.card(parent)
	panel.get_parent().add_theme_stylebox_override("panel",ui.box(Color("2b2923"),ui.Design.GOLD))
	panel.add_theme_constant_override("separation",4)
	var row=ui.hbox(panel,12)
	var text=ui.vbox(row,3)
	text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	var step=t.current_step()
	if step.is_empty():
		text.add_child(ui.label("Všechny kroky ověřeny — předej lekci.",14,ui.CYAN))
		row.add_child(ui.button("Vyhodnotit lekci",ui.close_ticket,true))
		return
	text.add_child(ui.label("INSTRUKTOR · %d / %d · %s" % [int(t.session.step)+1,t.lesson.steps.size(),step.title],14,ui.Design.GOLD))
	var instruction=ui.label(t.last_feedback if t.last_feedback!="" else step.text,13,ui.ORANGE if t.last_feedback!="" else ui.WHITE)
	instruction.max_lines_visible=2
	instruction.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	instruction.tooltip_text=instruction.text
	text.add_child(instruction)
	ui.register_target("tutorial:instruction",instruction)
	var recover=ui.button("Zobrazit krok",ui.recover_tutorial_target)
	recover.theme_type_variation="InstructorButton"
	row.add_child(recover)
	ui.register_target("tutorial:recover",recover)
