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
var shown_session_id=""
var recommendation={}
var task_details=false
var show_assessment=false

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
	shell.speech.stop_speech()
	if page=="listening" and not manager.listening.session.is_empty(): selected_mode=manager.listening.session.mode
	elif page=="quiz" and not manager.quiz.session.is_empty(): selected_mode=manager.quiz.session.mode
	elif page=="dialog" and not manager.session.is_empty():
		selected_mode=manager.session.mode
		if shown_session_id!=manager.session.id:
			shown_session_id=manager.session.id; help_text=""; show_translation=false; show_assessment=false
	for child in get_children(): remove_child(child); child.queue_free()
	buttons.clear(); actions.clear()
	var shade=ColorRect.new(); shade.color=Color("101e2b"); add_child(shade); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin=MarginContainer.new(); add_child(margin); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,100)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,28)
	var layout=VBoxContainer.new(); margin.add_child(layout)
	var active_dialog=page=="dialog" and not manager.session.is_empty()
	var heading=shell.ui.label("ENGLISH IN LONDON  /  "+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}.get(selected_mode,"Učím se"),20,Color("77deca")); layout.add_child(heading)
	if active_dialog:
		layout.add_child(shell.ui.label(manager.definition().title,24))
		if manager.session.completed or show_assessment or manager.session.get("exam_ended",false):
			var state="✓ SPLNĚNO" if manager.session.completed else "○ NESPLNĚNO — zkouška ukončena" if manager.session.get("exam_ended",false) else "○ NESPLNĚNO — pokus pokračuje"
			layout.add_child(shell.ui.label(state+" · %d / 100" % manager.attempt_score(),23))
			if not manager.session.completed and not manager.session.get("exam_ended",false): layout.add_child(shell.ui.label("Průběžné skóre · výsledek ještě není uložený.",16))
		else: layout.add_child(shell.ui.label("Aktuální krok: "+manager.current_step(),17))
	content=VBoxContainer.new(); content.size_flags_horizontal=Control.SIZE_EXPAND_FILL; content.add_theme_constant_override("separation",10)
	if active_dialog and not (manager.session.completed or show_assessment or manager.session.get("exam_ended",false)):
		content.size_flags_vertical=Control.SIZE_EXPAND_FILL; layout.add_child(content)
	else:
		var scroll=ScrollContainer.new(); scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL; scroll.follow_focus=true; layout.add_child(scroll); scroll.add_child(content)
	if page=="intro":
		label_text("Vítej v Londýně",28)
		label_text("U přepážky vyber situaci a anglické repliky. Zkontroluj košík, přilož cvičnou kartu u terminálu a ukaž lístek u kontroly. Alex u mostu poradí cestu k věži.\n\nPC: E, myš nebo šipky / Tab a Enter; repliky také 1–4. Esc zavře panel.\nPICO: oba paprsky a trigger, B/Y zavře panel, A/X přemístí panel. Levý stick klik teleportuje při zavřeném panelu.\n\nCvičné ceny, offline hra. Hodnotíme volbu replik a splnění úkolu. Big Ben je zvon v Elizabeth Tower.",22)
		action("Začít / přeskočit seznámení",func():
			manager.progress.intro_seen=true; shell.ui.game.save(); page="home"; draw(),true)
	elif page.begins_with("listening"): preload("res://scripts/english/LondonListeningUI.gd").draw(self)
	elif page.begins_with("quiz"): preload("res://scripts/english/LondonQuizUI.gd").draw(self)
	elif page=="home": draw_home()
	elif page=="progress": draw_progress()
	else: draw_session()
	var footer=HFlowContainer.new(); footer.add_theme_constant_override("separation",14); layout.add_child(footer)
	for item in [["Pavilon [Esc]",shell.return_to_world],["Situace",func(): page="home"; draw()],["Moje výsledky",func(): page="progress"; draw()]]:
		var b=shell.ui.button(item[0],item[1]); b.custom_minimum_size.y=48; footer.add_child(b); buttons.append(b)
	if active_dialog and not (manager.session.completed or show_assessment or manager.session.get("exam_ended",false)):
		var review=shell.ui.button("Ukončit a vyhodnotit zkoušku" if manager.session.mode=="exam" else "Zhodnotit dosavadní pokus",func(): manager.review_attempt(); show_assessment=true; draw())
		footer.add_child(review); buttons.append(review)
	if page in ["home","dialog","listening_home","listening"]:
		var autoplay=CheckButton.new(); autoplay.text="Auto řeč · Jenny"; autoplay.tooltip_text="Automaticky přehrát dostupné repliky. Hlas Jenny (Dioco)."
		autoplay.button_pressed=shell.ui.display_settings.london_autoplay
		autoplay.toggled.connect(func(value): shell.ui.save_preference("london_autoplay",value))
		footer.add_child(autoplay); buttons.append(autoplay)
	if shell.ui.game.unsaved:
		var retry=shell.ui.button("NEULOŽENO — zkusit znovu",func(): shell.ui.game.save(); draw()); footer.add_child(retry); buttons.append(retry)
	# All buttons share visible native focus. Link arrows as well as Tab.
	for i in buttons.size():
		buttons[i].focus_neighbor_top=buttons[i].get_path_to(buttons[(i-1+buttons.size())%buttons.size()])
		buttons[i].focus_neighbor_bottom=buttons[i].get_path_to(buttons[(i+1)%buttons.size()])
	call_deferred("focus_first")

func focus_first():
	if not is_inside_tree() or not is_visible_in_tree(): return
	if page=="dialog":
		var replies=find_child("PlayerReplies",true,false)
		if replies!=null:
			for child in replies.get_children():
				if child is Button and child.is_inside_tree():
					child.grab_focus()
					for scroll in find_children("*","ScrollContainer",true,false): scroll.scroll_vertical=0
					return
	if is_inside_tree() and not buttons.is_empty() and buttons[0].is_inside_tree(): buttons[0].grab_focus()

func draw_home():
	if recommendation.get("area")=="english": label_text("Doporučená situace: "+recommendation.id+". Můžeš zachovat současný rozhovor/kvíz nebo výslovně vybrat nový pokus.",18)
	label_text("Vyber situaci. Nové spuštění zruší současný nákup; uložené výsledky zůstanou.",18)
	var row=HBoxContainer.new(); row.add_theme_constant_override("separation",12); content.add_child(row)
	for key in ["learn","practice","exam"]:
		var b=shell.ui.button(("✓ " if selected_mode==key else "")+{"learn":"Učím se","practice":"Procvičování","exam":"Zkouška"}[key],func(): selected_mode=key; draw())
		b.custom_minimum_size.y=50; row.add_child(b); buttons.append(b)
	label_text("Učím se: vysvětlení. Procvičování: stručná odezva. Zkouška: hodnocení až ve výsledku. Nákup dokončí použití lístku; cestu příchod a interakce u věže.",17)
	for i in range(scenario_page*3,mini(scenario_page*3+3,6)):
		var definition=manager.catalog.scenarios[i]
		var result=manager.progress.results.get(definition.id,{})
		action("%d / %s%s" % [i+1,definition.title,"  ✓ %d / 100" % int(result.best) if not result.is_empty() else ""],func():
			manager.cancel()
			if manager.start(definition.id,selected_mode):
				page="dialog"; help_text=""; show_translation=false
				# The directions conversation takes place with the information NPC.
				if not shell.world.english_room.near("info" if definition.id=="LON06" else "tickets"):
					shell.london_navigation.start("info" if definition.id=="LON06" else "tickets")
				else: draw())
	action("Další tři situace →" if scenario_page==0 else "← První tři situace",func(): scenario_page=1-scenario_page; draw())
	action("Otázky na Londýn / 20 otázek B1–B2",func(): page="quiz_home"; draw())
	action("Poslechové procvičování / 12 úloh",func(): page="listening_home"; draw())
	if not manager.session.is_empty(): action("Pokračovat v aktuální situaci",func(): page="dialog"; draw())

func draw_progress():
	action("Společný přehled znalostí",func(): shell.open_app("Moje znalosti"))
	label_text("Uložený postup  /  %d z 6 situací" % manager.progress.results.size(),24)
	if not manager.progress.archive.is_empty(): label_text("Starší A1–A2 výsledky: %d / 6 situací v archivu. Nezapočítávají se do nových B1–B2 výsledků." % manager.progress.archive.get("results",{}).size(),18)
	var scroll=ScrollContainer.new(); scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL; content.add_child(scroll)
	var lines=VBoxContainer.new(); lines.size_flags_horizontal=Control.SIZE_EXPAND_FILL; scroll.add_child(lines)
	for d in manager.catalog.scenarios:
		var result=manager.progress.results.get(d.id,{})
		lines.add_child(shell.ui.label(d.title+": "+("%d / 100 • dokončeno %d× • nápovědy %d" % [int(result.best),int(result.completed),int(result.hints)] if not result.is_empty() else "zatím nedokončeno"),21))
	lines.add_child(shell.ui.label("Procvičené formulace:\n"+"\n".join(manager.progress.phrases),19))
	for id in manager.progress.archive.get("results",{}): lines.add_child(shell.ui.label("Archiv A1–A2 / "+id+": "+str(int(manager.progress.archive.results[id].best))+" / 100",18))
	for record in manager.progress.attempts.slice(maxi(0,manager.progress.attempts.size()-6)):
		lines.add_child(shell.ui.label("%s / %s: %s · %d bodů, %d nápověd" % [record.id,record.mode,"SPLNĚNO" if record.get("passed",true) else "NESPLNĚNO",int(record.score),int(record.hints)],18))

func draw_session():
	preload("res://scripts/english/LondonPresentation.gd").draw(self)

func toggle_translation():
	if not show_translation and not manager.session.is_empty(): manager.session.translation_used=true
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
		if page=="listening": listening_choose(actions[index],manager.listening.revision)
		elif page=="quiz": quiz_choose(actions[index],manager.quiz.revision)
		else: choose(actions[index],manager.revision)
		get_viewport().set_input_as_handled()

func quiz_choose(id: String, token: int):
	if Time.get_ticks_msec()-last_dispatch<220: return
	last_dispatch=Time.get_ticks_msec()
	manager.quiz.answer(id,token); draw()

func audio_controls(text: String, speaker: String):
	if shell.speech.find_line(text,speaker).is_empty(): return
	var row=HBoxContainer.new(); row.add_theme_constant_override("separation",12); content.add_child(row)
	for item in [["Poslechnout / zopakovat",false],["Pomaleji",true]]:
		var b=shell.ui.button(item[0],func(): shell.speech.speak(text,speaker,item[1]))
		b.custom_minimum_size.y=48; row.add_child(b); buttons.append(b)
	var stop_button=shell.ui.button("Zastavit",shell.speech.stop_speech); row.add_child(stop_button); buttons.append(stop_button)

func listening_choose(id: String, token: int):
	if manager.listening.answer(id,token): draw()

func listening_autoplay(id: String, token: int):
	if is_inside_tree() and page=="listening" and shell.mode=="english" and manager.listening.revision==token and manager.listening.session.get("id")==id and not manager.listening.session.get("completed",true): shell.speech.listen(id)
