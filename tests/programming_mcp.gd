extends Node

func _ready():
	preload("res://scripts/progression/SaveManager.gd").path_override="user://programming_mcp_test.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override="user://programming_mcp_test.cfg"
	var shell=preload("res://scenes/world/Game.tscn").instantiate(); add_child(shell)
	await get_tree().process_frame
	shell.enter_world("Programming Academy")
	assert(shell.ui.game.game_mode.is_programming())
	shell.interact(shell.world.devices["PYTHON-PC"])
	var editor=shell.code_editor
	editor.launch("PY22",false)
	editor.editor.text="def obsah_obdelniku(sirka, vyska):\n    return vyska * sirka"
	editor.test_code()
	assert(shell.ui.game.programming.last_result.ok)
	print("PROGRAMMING MCP: 3D Python station, CodeEdit, equivalent solution and 3 function tests PASS")
	editor.launch("WEB28",false)
	for filename in shell.ui.game.programming.current.example: shell.ui.game.programming.edit(filename,shell.ui.game.programming.current.example[filename])
	editor.switch_file("index.html"); editor.run_code()
	var doc=editor.preview.document
	doc.click(doc.query("#tlacitko")[0]); editor.preview.render_document()
	assert(doc.text_content(doc.query("#vysledek")[0])=="Ahoj!")
	for i in 8: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://test-output/programming-mcp-web.png")
	print("PROGRAMMING MCP: parsed HTML/CSS/JS, real DOM event and preview PASS")
	shell.enter_world("Hlavní serverovna")
	assert(shell.ui.game.programming.current.is_empty() and shell.mode=="world")
	shell.enter_world("Programming Academy")
	assert(shell.ui.game.programming.current.is_empty())
	print("PROGRAMMING MCP: exit cancels editor; reentry never restores unfinished exercise PASS")
