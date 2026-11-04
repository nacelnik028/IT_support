extends "res://tests/pause_repair.gd"

# Reuse isolated saves, complete mouse/XR clicks and capture helpers.
func drag_split(code, hand: int = -1):
	var rect=code.code_split.get_global_rect()
	var at=Vector2(rect.get_center().x,rect.end.y+code.workspace_split.get_theme_constant("separation")*shell.ui.scale.y*0.5)
	var direction=1 if code.code_split.size.y<code.code_split.get_combined_minimum_size().y+1 else -1
	var finish=at+Vector2(0,direction*45*shell.ui.scale.y)
	var before=code.workspace_split.split_offset
	if hand<0:
		var viewport=code.get_viewport()
		var move=InputEventMouseMotion.new(); move.position=at; viewport.push_input(move,true)
		var press=InputEventMouseButton.new(); press.position=at; press.button_index=MOUSE_BUTTON_LEFT; press.button_mask=MOUSE_BUTTON_MASK_LEFT; press.pressed=true; viewport.push_input(press,true)
		move=InputEventMouseMotion.new(); move.position=finish; move.relative=finish-at; move.button_mask=MOUSE_BUTTON_MASK_LEFT; viewport.push_input(move,true)
		press=InputEventMouseButton.new(); press.position=finish; press.button_index=MOUSE_BUTTON_LEFT; press.pressed=false; viewport.push_input(press,true)
	else:
		point(hand,at); await frames(); rig.pressed(rig.left if hand==0 else rig.right,"trigger_click"); await frames(2)
		point(hand,finish); await frames(3); rig.released(rig.left if hand==0 else rig.right,"trigger_click")
	await frames()
	check(code.workspace_split.split_offset!=before,"Skutečné tažení mění výšku spodního panelu")

func point(hand: int, at: Vector2):
	var monitor=rig.monitor
	var pixel=Vector3((at.x/1600-0.5)*monitor.dimensions.x,(0.5-at.y/1200)*monitor.dimensions.y,0)
	var pose=rig.global_transform.affine_inverse()*Transform3D(monitor.global_basis,monitor.to_global(pixel)+monitor.global_basis.z*0.8)
	trackers[hand+1].set_pose("aim",pose,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)

func exercise(hand: int = -1):
	var code=shell.code_editor
	code.mode_picker.select(1); code.launch("PY01",false); await frames()
	for window in code.find_children("*","AcceptDialog",true,false):
		if window.visible and window.title.begins_with("Rozepsaná"): await click(button("Začít znovu / nahradit tento koncept"),hand)
	await frames()
	check(code.workspace_split is VSplitContainer,"Výstup má skutečný svislý oddělovač")
	check(code.console.size.y>=code.console.get_theme_font_size("font_size")*5,"Výstup má místo alespoň na pět řádků i ve výchozí poloze")
	code.editor.text="for i in range(80):\n    print(i)"
	await click(code.run_button,hand)
	check(code.console.text.strip_edges().ends_with("79") and code.manager.last_result.is_empty(),"Spustit vypíše celý výstup bez hodnocení")
	code.console.scroll_vertical=2000; await frames()
	check(code.console.scroll_vertical>0,"Dlouhý výstup se posouvá uvnitř panelu")
	await drag_split(code,hand); check(code.editor.text.contains("range(80)"),"Tažení nezmění kód")
	await capture("editor-output",rig.monitor.viewport if hand>=0 else null)
	await click(code.input_toggle,hand); check(code.input_box.visible,"Vstupy lze rozbalit")
	code.input_console.text="vlastní vstup"; code.editor.text="print(input())"
	await click(code.run_button,hand); check(code.console.text.contains("vlastní vstup"),"Rozbalené input() skutečně ovlivní běh")
	await click(code.input_toggle,hand); check(not code.input_box.visible and code.input_console.text=="vlastní vstup","Sbalení zachová vstupy")
	code.editor.text="print(unknown_name)"; await click(code.run_button,hand)
	check(code.output_tabs.current_tab==1 and code.errors_list.get_child_count()>0,"Chyba přepne na diagnostiku")
	await click(code.errors_list.get_child(0),hand); check(code.editor.get_caret_line()==0,"Odkaz chyby stále vede na skutečný řádek")
	code.editor.text="print('wrong')"; await click(code.test_button,hand)
	check(code.output_tabs.current_tab==2 and code.verification_state.text.begins_with("NESPLNĚNO"),"Ověření ukáže nesplněno, testy a skóre")
	check("testů" in code.verification_state.text and "skóre" in code.verification_state.text,"Hlavní výsledek obsahuje počty i skóre")
	await click(code.verification_details,hand)
	check(code.verification.visible and "Očekáváno:" in code.verification.text and "wrong" in code.verification.text,"Podrobnosti mají skutečný a očekávaný výstup")
	await capture("editor-verification",rig.monitor.viewport if hand>=0 else null)
	code.editor.select_all(); code.editor.insert_text_at_caret("print('Ahoj, světe!')"); await frames()
	check("ZASTARALÉ" in code.verification_state.text,"Úprava označí ověření za zastaralé")
	await click(code.test_button,hand); check(code.manager.last_result.ok and code.verification_state.text.begins_with("SPLNĚNO"),"Správné řešení projde skutečnými testy")
	await click(button("Celé zadání"),hand)
	var dialog=code.find_children("*","AcceptDialog",true,false).filter(func(n): return n.visible)[0]
	check(dialog.find_children("*","RichTextLabel",true,false)[0].text==code.brief_text,"Celé zadání je dostupné bez ořezu")
	await capture("editor-task",rig.monitor.viewport if hand>=0 else null)
	await click(dialog.get_ok_button(),hand)
	check(not is_instance_valid(dialog) or not dialog.visible,"Celé zadání se zavře skutečným klikem")
	await click(button("Nástroje kódu"),hand); check(button("Resetovat")!=null,"Méně časté nástroje jsou dostupné v nabídce")
	await click(button("A+"),hand); check(code.editor.get_theme_font_size("font_size")>=24,"Nabídka mění velikost kódu")
	await click(button("Studium a postup"),hand); await click(button("Rozepsaná práce"),hand)
	check(code.find_children("*","AcceptDialog",true,false).any(func(n): return n.visible),"Přesunuté koncepty otevřou skutečný dialog")
	for window in code.find_children("*","Window",true,false):
		window.hide()
		if window is AcceptDialog: window.queue_free()
	await frames()
	code.change_mode(2); await frames()
	for window in code.find_children("*","AcceptDialog",true,false):
		if window.visible and window.title.begins_with("Rozepsaná"): await click(button("Začít znovu / nahradit tento koncept"),hand)
	code.editor.text="print('wrong')"; code.test_code()
	check(code.hint_button.disabled and code.example_button.disabled,"Přesun nástrojů zachová pravidla zkoušky")
	check(not code.verification.text.contains("Očekáváno:"),"Zkouška neprozradí očekávané testové výstupy")

func run():
	root.gui_embed_subwindows=true
	DirAccess.make_dir_recursive_absolute("res://docs/ui-review/2026-11-04-interface")
	shell=load("res://scenes/world/Game.tscn").instantiate(); root.add_child(shell); await frames()
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(3840,2160)]:
		for text_scale in [1.0,1.3]:
			suffix="%d-%d" % [resolution.x,roundi(text_scale*100)]
			shell.ui.apply_display_settings(resolution,false); shell.ui.save_preference("text_scale",text_scale)
			shell.enter_world("Programming Academy"); shell.open_programming("python"); await frames()
			await exercise()
	shell.ui.apply_display_settings(Vector2i(1600,900),false)
	rig=load("res://scenes/xr/XRPlayer.tscn").instantiate(); rig.shell=shell; shell.xr_rig=rig; shell.world.player.add_child(rig)
	var head=XRPositionalTracker.new(); head.name="head"; head.type=XRServer.TRACKER_HEAD; head.set_pose("default",Transform3D(Basis(),Vector3(0,1.68,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(head); trackers.append(head)
	for name_value in ["left_hand","right_hand"]:
		var tracker=XRControllerTracker.new(); tracker.name=name_value; tracker.type=XRServer.TRACKER_CONTROLLER; tracker.set_input("primary",Vector2.ZERO); tracker.set_input("trigger_click",false)
		tracker.set_pose("aim",Transform3D(Basis(),Vector3(0,1.3,0)),Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH); XRServer.add_tracker(tracker); trackers.append(tracker)
	shell.vr_active=true; rig.activate(false); await frames()
	for text_scale in [1.0,1.3]:
		shell.ui.save_preference("text_scale",text_scale); suffix="vr-%d" % roundi(text_scale*100)
		for hand in [0,1]:
			shell.enter_world("Programming Academy"); shell.open_programming("python"); await frames(); await exercise(hand)
	rig.deactivate(); shell.vr_active=false
	for tracker in trackers: XRServer.remove_tracker(tracker)
	shell.queue_free(); await frames()
	print("EDITOR REPAIR: %d checks, %d failures; PC and synthetic XR" % [checks,failures]); quit(1 if failures else 0)
