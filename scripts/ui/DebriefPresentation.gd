extends RefCounted

const Review=preload("res://scripts/evaluation/AttemptReview.gd")

static func show(ui, record: Dictionary):
	if not Review.valid_review(record): ui.show_message("Rozbor není dostupný","Záznam má neplatnou strukturu nebo pochází ze staršího pokusu bez podrobného rozboru."); return
	var dialog=AcceptDialog.new(); dialog.title="Rozbor příčin a ověřeného výsledku"; dialog.ok_button_text="Zavřít / výsledek zůstává uložený"
	var scroll=ScrollContainer.new(); scroll.follow_focus=true; scroll.custom_minimum_size=Vector2(760,380); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; dialog.add_child(scroll)
	var body=VBoxContainer.new(); body.size_flags_horizontal=Control.SIZE_EXPAND_FILL; scroll.add_child(body)
	var text=ui.label(Review.explanation(record),15); text.custom_minimum_size.x=710; body.add_child(text)
	var question=Review.question(record)
	body.add_child(ui.label("Dobrovolná otázka / bez dalších XP\n"+question.text,18,ui.ORANGE))
	if record.answer=="":
		for option in question.options:
			body.add_child(ui.button(option[1],func():
				for saved in ui.game.work.data.reviews:
					if saved.id==record.id and saved.answer=="":
						saved.answer=option[0]; ui.game.save()
						dialog.hide(); dialog.queue_free(); show(ui,saved)
						return))
	else:
		body.add_child(ui.label(("Pochopení potvrzeno. " if record.answer==question.answer else "Tuto souvislost ještě procvič. ")+question.explanation+" Dosažené skóre se nemění.",16))
	dialog.confirmed.connect(dialog.queue_free); dialog.canceled.connect(dialog.queue_free)
	ui.add_child(dialog); ui.bind_dialog_escape(dialog); dialog.popup_centered(Vector2i(800,540))
