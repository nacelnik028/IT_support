extends Control

var shell
var manager
var page="home"
var station="tickets"
var selected_mode="learn"
var scenario_page=0
var help_text=""
var show_translation=false
var actions: Array=[]
var buttons: Array=[]
var content: VBoxContainer
var last_dispatch=-1000

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme=shell.ui.theme
	draw()

func label_text(text: String, size_value: int = 20, color: Color = Color("e4edf1")):
	var label=shell.ui.label(text,size_value,color)
	content.add_child(label)
	return label

func action(text: String, callback: Callable, primary: bool = false) -> Button:
	var button=shell.ui.button(text,callback,primary)
	button.custom_minimum_size.y=58
	button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	content.add_child(button)
	buttons.append(button)
	return button

func draw():
	for child in get_children(): remove_child(child); child.queue_free()
	buttons.clear(); actions.clear()
	var shade=ColorRect.new(); shade.color=Color("101e2b"); add_child(shade); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin=MarginContainer.new(); add_child(margin); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,100)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,28)
	content=VBoxContainer.new(); content.add_theme_constant_override("separation",10); margin.add_child(content)
	label_text("ENGLISH IN LONDON  /  "+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}.get(selected_mode,"Učím se"),26,Color("77deca"))
	if page=="intro":
		label_text("Vítej v Londýně",28)
		label_text("U přepážky vyber situaci a anglické repliky. Zkontroluj košík, přilož cvičnou kartu u terminálu a ukaž lístek u kontroly. Alex u mostu poradí cestu k věži.\n\nPC: E, myš nebo šipky / Tab a Enter; repliky také 1–4. Esc zavře panel.\nPICO: oba paprsky a trigger, B/Y zavře panel, A/X přemístí panel. Levý stick klik teleportuje při zavřeném panelu.\n\nCvičné ceny, offline hra. Hodnotíme volbu replik a splnění úkolu. Big Ben je zvon v Elizabeth Tower.",22)
		action("Začít / přeskočit seznámení",func():
			manager.progress.intro_seen=true; shell.ui.game.save(); page="home"; draw(),true)
	elif page=="home": draw_home()
	elif page=="progress": draw_progress()
	else: draw_session()
	var spacer=Control.new(); spacer.size_flags_vertical=Control.SIZE_EXPAND_FILL; content.add_child(spacer)
	var footer=HBoxContainer.new(); footer.add_theme_constant_override("separation",14); content.add_child(footer)
	for item in [["Zpět do pavilonu [Esc]",shell.return_to_world],["Situace / restart",func(): page="home"; draw()],["Moje výsledky",func(): page="progress"; draw()]]:
		var b=shell.ui.button(item[0],item[1]); b.custom_minimum_size.y=48; footer.add_child(b); buttons.append(b)
	if shell.ui.game.unsaved:
		var retry=shell.ui.button("NEULOŽENO — zkusit znovu",func(): shell.ui.game.save(); draw()); footer.add_child(retry); buttons.append(retry)
	# All buttons share visible native focus. Link arrows as well as Tab.
	for i in buttons.size():
		buttons[i].focus_neighbor_top=buttons[i].get_path_to(buttons[(i-1+buttons.size())%buttons.size()])
		buttons[i].focus_neighbor_bottom=buttons[i].get_path_to(buttons[(i+1)%buttons.size()])
	call_deferred("focus_first")

func focus_first():
	if is_inside_tree() and not buttons.is_empty() and buttons[0].is_inside_tree(): buttons[0].grab_focus()

func draw_home():
	label_text("Vyber situaci. Nové spuštění zruší současný nákup; uložené výsledky zůstanou.",18)
	var row=HBoxContainer.new(); row.add_theme_constant_override("separation",12); content.add_child(row)
	for key in ["learn","practice","exam"]:
		var b=shell.ui.button(("✓ " if selected_mode==key else "")+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}[key],func(): selected_mode=key; draw())
		b.custom_minimum_size.y=50; row.add_child(b); buttons.append(b)
	label_text("Učím se: překlad a opravy. Procvičování: obměny údajů. Zkouška: bez nápovědy a překladu.",17)
	for i in range(scenario_page*3,mini(scenario_page*3+3,6)):
		var definition=manager.catalog.scenarios[i]
		var result=manager.progress.results.get(definition.id,{})
		action("%d / %s%s" % [i+1,definition.title,"  ✓ %d / 100" % int(result.best) if not result.is_empty() else ""],func():
			manager.cancel()
			if manager.start(definition.id,selected_mode):
				page="dialog"; help_text=""; show_translation=false
				# The directions conversation takes place with the information NPC.
				if not shell.world.english_room.near("info" if definition.id=="LON06" else "tickets"):
					shell.return_to_world(); shell.room_notice.text="Dojdi k Alexovi: INFORMATION u mostu." if definition.id=="LON06" else "Dojdi k Samovi: LONDON EYE TICKETS."
					shell.room_notice.text+=" [E] otevře rozhovor."; shell.notice_time=8
				else: draw())
	action("Další tři situace →" if scenario_page==0 else "← První tři situace",func(): scenario_page=1-scenario_page; draw())
	if not manager.session.is_empty(): action("Pokračovat v aktuální situaci",func(): page="dialog"; draw())

func draw_progress():
	label_text("Uložený postup  /  %d z 6 situací" % manager.progress.results.size(),24)
	var scroll=ScrollContainer.new(); scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL; content.add_child(scroll)
	var lines=VBoxContainer.new(); lines.size_flags_horizontal=Control.SIZE_EXPAND_FILL; scroll.add_child(lines)
	for d in manager.catalog.scenarios:
		var result=manager.progress.results.get(d.id,{})
		lines.add_child(shell.ui.label(d.title+": "+("%d / 100 • dokončeno %d× • nápovědy %d" % [int(result.best),int(result.completed),int(result.hints)] if not result.is_empty() else "zatím nedokončeno"),21))
	lines.add_child(shell.ui.label("Procvičené formulace:\n"+"\n".join(manager.progress.phrases),19))
	for record in manager.progress.attempts.slice(maxi(0,manager.progress.attempts.size()-6)):
		lines.add_child(shell.ui.label("%s / %s: %d bodů, %d nápověd" % [record.id,record.mode,int(record.score),int(record.hints)],18))

func draw_session():
	var s=manager.session
	if s.is_empty(): page="home"; draw_home(); return
	selected_mode=s.mode
	label_text(manager.task(),18)
	if s.completed:
		label_text("✓ Dokončeno — %d / 100" % int(s.result.score),28,Color("77deca"))
		label_text(manager.definition().explanation,21)
		var mistakes=[]
		for error in s.errors: if not error.text in mistakes: mistakes.append(error.text)
		label_text("Chyby: "+("Žádné." if mistakes.is_empty() else "\n".join(mistakes)),19)
		label_text("Užitečné formulace:\n"+"\n".join(s.phrases.slice(0,4)),21)
		return
	label_text("Sam" if s.id!="LON06" else "Alex",16,Color("77deca"))
	label_text(s.npc,25)
	if s.id!="LON06": label_text("Košík: %d adult + %d child • %s • %s   |   Rozpočet %s   |   %s" % [int(s.cart.adult),int(s.cart.child),s.cart.time if s.cart.time!="" else "čas nevybrán",manager.money(manager.total()),manager.money(int(s.goal.budget)-int(s.spent)),"ZAPLACENO" if s.paid else "POTVRZENO" if s.confirmed else "NEPOTVRZENO"],17)
	if show_translation and s.mode!="exam": label_text(s.translation,18,Color("f3d598"))
	if help_text!="" and s.mode!="exam": label_text(help_text,17,Color("f3d598"))
	if s.feedback!="" and s.mode!="exam": label_text(s.feedback,17,Color("f3d598"))
	if not s.ticket.is_empty(): label_text("PENĚŽENKA / %s • %d adult + %d child • %s • zaplaceno %s • %s" % [s.ticket.id,int(s.ticket.adult),int(s.ticket.child),s.ticket.time,manager.money(int(s.ticket.pence)),"POUŽITÝ" if s.ticket.used else "PLATNÝ"],18,Color("77deca"))
	var token=manager.revision
	if s.node=="pay":
		if station=="terminal" and shell.world.english_room.near("terminal"):
			action("Přiložit CVIČNOU KARTU — zaplatit "+manager.money(manager.total()),func(): manager.pay(token); draw(),true)
		else: action("Dojít k platebnímu terminálu",shell.return_to_world,true)
	elif s.node=="gate":
		if station=="gate" and shell.world.english_room.near("gate"):
			action("Předložit vstupenku z peněženky",func(): manager.present_ticket(); draw(),true)
		else: action("Dojít ke kontrole vstupenek",shell.return_to_world,true)
	elif s.node=="walk": action("Jít přes most k Elizabeth Tower",shell.return_to_world,true)
	var options=manager.choices()
	if not shell.world.english_room.near("info" if s.id=="LON06" else "tickets") and not s.node in ["pay","gate","walk"]:
		options=[]
		action("Dojít k NPC: "+("Alex / INFORMATION" if s.id=="LON06" else "Sam / TICKETS"),shell.return_to_world)
	for option in options:
		actions.append(option.id)
		action("%d  %s" % [actions.size(),option.text],func(): choose(option.id,token))
	if s.mode!="exam" and s.node!="pay":
		var row=HBoxContainer.new(); row.add_theme_constant_override("separation",12); content.add_child(row)
		for item in [["Překlad",toggle_translation],["Nápověda",request_hint]]:
			var b=shell.ui.button(item[0],item[1]); row.add_child(b); buttons.append(b)

func toggle_translation():
	show_translation=not show_translation
	if show_translation: manager.hint()
	draw()

func request_hint():
	help_text=manager.hint()
	draw()

func choose(id: String, token: int):
	# A session cannot talk remotely to another NPC after closing the panel.
	if manager.session.is_empty(): return
	if manager.session.id=="LON06" and not shell.world.english_room.near("info"): return
	if manager.session.id!="LON06" and not shell.world.english_room.near("tickets"): return
	if Time.get_ticks_msec()-last_dispatch<220: return
	last_dispatch=Time.get_ticks_msec()
	manager.act(id,token)
	help_text=""; show_translation=false
	draw()

func _unhandled_key_input(event):
	if not is_visible_in_tree() or shell.mode!="english": return
	if not event is InputEventKey or not event.pressed or event.echo: return
	var index=int(event.keycode)-KEY_1
	if index>=0 and index<actions.size():
		choose(actions[index],manager.revision)
		get_viewport().set_input_as_handled()
