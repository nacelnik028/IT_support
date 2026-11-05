extends "res://tests/pause_repair.gd"

# Reuse isolated saves, complete mouse/XR clicks and capture helpers.
func pixel_rect(control: Control) -> Rect2:
	var transform=control.get_global_transform_with_canvas()
	return Rect2(transform.origin,control.size*transform.get_scale())

func visible_rows(control: TextEdit) -> int:
	if not control.is_visible_in_tree(): return 0
	var rect=pixel_rect(control); var factor=control.get_global_transform_with_canvas().get_scale().y
	var style=control.get_theme_stylebox("read_only" if not control.editable else "normal")
	rect.position.y+=style.get_margin(SIDE_TOP)*factor
	rect.size.y-=style.get_minimum_size().y*factor
	if control.get_h_scroll_bar().is_visible_in_tree(): rect.size.y-=control.get_h_scroll_bar().size.y*factor
	var origin=rect.position.y-fposmod(control.scroll_vertical,1.0)*control.get_line_height()*factor
	var clipped=rect.intersection(control.get_viewport().get_visible_rect())
	var parent=control.get_parent()
	while parent!=null:
		if parent is Control and parent.clip_contents: clipped=clipped.intersection(pixel_rect(parent))
		parent=parent.get_parent()
	var line_height=control.get_line_height()*factor
	return maxi(0,floori((clipped.end.y-origin)/line_height)-ceili((clipped.position.y-origin)/line_height))

func check_workspace(code, title: String):
	var rows=visible_rows(code.verification if code.output_tabs.current_tab==2 and code.verification.visible else code.console)
	check(rows>=5,title+": alespoň pět skutečně celých řádků po všech ořezech (%d)" % rows)
	if not code.results_enlarged: check(visible_rows(code.editor)>=5,"Editor současně zachová pět celých řádků")
	for control in [code.run_button,code.test_button,code.results_button,code.workspace_split]:
		check(control.get_viewport().get_visible_rect().encloses(pixel_rect(control)),"Základní akce/pracovní plocha není oříznutá")
	print("VISIBLE ROWS ",suffix," ",title,": ",rows,"; code=",visible_rows(code.editor))

func select_tab(code, index: int, hand: int):
	var bar=code.output_tabs.get_tab_bar(); var local=bar.get_tab_rect(index).get_center(); var at=bar.get_global_transform_with_canvas()*local
	if hand<0:
		var viewport=code.get_viewport(); var move=InputEventMouseMotion.new(); move.position=at; viewport.push_input(move,true)
		for down in [true,false]:
			var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; viewport.push_input(event,true)
	else:
		point(hand,at)
		for tick in 2: await physics_frame
		rig.pressed(rig.left if hand==0 else rig.right,"trigger_click"); await frames(2); rig.released(rig.left if hand==0 else rig.right,"trigger_click")
	await frames()
	check(code.output_tabs.current_tab==index,"Skutečný klik přepne záložku "+str(index))

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
		point(hand,at)
		for tick in 2: await physics_frame
		await frames(); rig.pressed(rig.left if hand==0 else rig.right,"trigger_click"); await frames(2)
		point(hand,finish)
		for tick in 3: await physics_frame
		await frames(3); rig.released(rig.left if hand==0 else rig.right,"trigger_click")
	await frames()
	check(code.workspace_split.split_offset!=before,"Skutečné tažení mění výšku spodního panelu")

func point(hand: int, at: Vector2):
	var monitor=rig.monitor
	var pixel=Vector3((at.x/1600-0.5)*monitor.dimensions.x,(0.5-at.y/1200)*monitor.dimensions.y,0)
	var pose=rig.global_transform.affine_inverse()*Transform3D(monitor.global_basis,monitor.to_global(pixel)+monitor.global_basis.z*0.8)
	trackers[hand+1].set_pose("aim",pose,Vector3.ZERO,Vector3.ZERO,XRPose.XR_TRACKING_CONFIDENCE_HIGH)

func scroll_output(control: TextEdit, hand: int):
	control.scroll_vertical=0
	if hand>=0:
		# Aim the other hand away: either hand can own the panel's hover ray.
		point(1-hand,Vector2(-200,-200)); point(hand,pixel_rect(control).get_center())
		trackers[2].set_input("primary",Vector2(0,-1))
		for tick in 22: await physics_frame
		trackers[2].set_input("primary",Vector2.ZERO)
	else:
		var viewport=control.get_viewport(); var at=pixel_rect(control).get_center()
		for i in 3:
			for down in [true,false]:
				var event=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_WHEEL_DOWN; event.pressed=down; viewport.push_input(event,true)
	await frames()
	check(control.scroll_vertical>0,"Skutečný scroll funguje uvnitř "+("výstupu" if control==shell.code_editor.console else "podrobností"))

func exercise(hand: int = -1):
	var code=shell.code_editor
	code.manager.progress.settings.font_size=22; code.zoom(0)
	code.mode_picker.select(1); code.launch("PY01",false); await frames()
	for window in code.find_children("*","AcceptDialog",true,false):
		if window.visible and window.title.begins_with("Rozepsaná"): await click(button("Začít znovu / nahradit tento koncept"),hand)
	await frames()
	check(code.workspace_split is VSplitContainer,"Výstup má skutečný svislý oddělovač")
	check(code.workspace_split.get_theme_constant("autohide")==0 and code.workspace_split.get_theme_constant("minimum_grab_thickness")>=18,"Dělicí lišta je stále viditelná a má pohodlnou zásahovou plochu")
	check_workspace(code,"Výstup při otevření")
	await capture("editor-short-output",rig.monitor.viewport if hand>=0 else null)
	code.editor.text="for i in range(80):\n    print(i)"
	await click(code.run_button,hand)
	check(code.console.text.strip_edges().ends_with("79") and code.manager.last_result.is_empty(),"Spustit vypíše celý výstup bez hodnocení")
	await scroll_output(code.console,hand)
	code.console.scroll_vertical=0.5; await frames(); check_workspace(code,"Výstup s necelým posuvem")
	code.console.scroll_vertical=2000; await frames()
	check(code.console.scroll_vertical>0,"Dlouhý výstup se posouvá uvnitř panelu")
	await drag_split(code,hand); check(code.editor.text.contains("range(80)"),"Tažení nezmění kód")
	await capture("editor-output",rig.monitor.viewport if hand>=0 else null)
	await click(code.input_toggle,hand); check(code.input_box.visible,"Vstupy lze rozbalit")
	check_workspace(code,"Výstup s rozbalenými vstupy")
	code.input_console.text="vlastní vstup"; code.editor.text="print(input())"
	await click(code.run_button,hand); check(code.console.text.contains("vlastní vstup"),"Rozbalené input() skutečně ovlivní běh")
	await click(code.input_toggle,hand); check(not code.input_box.visible and code.input_console.text=="vlastní vstup","Sbalení zachová vstupy")
	code.editor.text="print(unknown_name)"; await click(code.run_button,hand)
	check(code.output_tabs.current_tab==1 and code.errors_list.get_child_count()>0,"Chyba přepne na diagnostiku")
	await capture("editor-error",rig.monitor.viewport if hand>=0 else null)
	await click(code.errors_list.get_child(0),hand); check(code.editor.get_caret_line()==0,"Odkaz chyby stále vede na skutečný řádek")
	code.editor.text="print('wrong')\nfor i in range(80):\n    print(i)"; await click(code.test_button,hand)
	check(code.output_tabs.current_tab==2 and code.verification_state.text.begins_with("NESPLNĚNO"),"Ověření ukáže nesplněno, testy a skóre")
	check("testů" in code.verification_state.text and "skóre" in code.verification_state.text,"Hlavní výsledek obsahuje počty i skóre")
	await click(code.verification_details,hand)
	check(code.verification.visible and "Očekáváno:" in code.verification.text and "wrong" in code.verification.text,"Podrobnosti mají skutečný a očekávaný výstup")
	check_workspace(code,"Rozbalené podrobnosti testů")
	await scroll_output(code.verification,hand)
	await select_tab(code,0,hand); check_workspace(code,"Výstup po přepnutí záložky")
	await select_tab(code,2,hand); check_workspace(code,"Podrobnosti po návratu na záložku")
	await click(code.input_toggle,hand); check_workspace(code,"Podrobnosti a rozbalené vstupy")
	await capture("editor-verification-inputs",rig.monitor.viewport if hand>=0 else null)
	await click(code.input_toggle,hand)
	var files=code.manager.files.duplicate(true); var attempt=code.manager.current.duplicate(true)
	await click(code.results_button,hand); check_workspace(code,"Zvětšené podrobnosti")
	await capture("editor-enlarged",rig.monitor.viewport if hand>=0 else null)
	await click(code.results_button,hand); check_workspace(code,"Návrat k běžnému rozložení")
	check(code.manager.files==files and code.manager.current==attempt,"Zvětšení a návrat zachovají kód i pokus")
	if hand<0:
		var resolution=shell.ui.display_settings.resolution
		shell.ui.apply_display_settings(Vector2i(1920,1080) if resolution.x==1280 else Vector2i(1280,720),false); await frames(); check_workspace(code,"Podrobnosti po resize")
		shell.ui.apply_display_settings(resolution,false); await frames(); check_workspace(code,"Podrobnosti po návratu velikosti")
	await capture("editor-verification",rig.monitor.viewport if hand>=0 else null)
	code.editor.select_all(); code.editor.insert_text_at_caret("print('Ahoj, světe!')"); await frames()
	check("ZASTARALÉ" in code.verification_state.text,"Úprava označí ověření za zastaralé")
	await click(code.test_button,hand); check(code.manager.last_result.ok and code.verification_state.text.begins_with("SPLNĚNO"),"Správné řešení projde skutečnými testy")
	check_workspace(code,"Úspěšné ověření")
	await capture("editor-passed",rig.monitor.viewport if hand>=0 else null)
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
