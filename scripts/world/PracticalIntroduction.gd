extends Node

var shell
var active=false
var step=0
var stash={}
var marker
var initial_forward=Vector3.FORWARD
var return_mode="world"
var return_page="menu"
const TEXTS=[
	"Rozhlédni se podle čtyř označených průchodů v hale.",
	"Projdi portálem 01 do serverovny. Dojdi na zlatou značku u dveří IT tréninku.",
	"Použij pevný ovladač DOOR-CONTROL-OPS u dveří IT tréninku.",
	"Projdi skutečně otevřenými dveřmi do IT tréninku.",
	"Zaměř monitor TRAIN-PC-PVE a otevři jej.",
	"Na otevřeném monitoru stiskni Ověřit cvičný přehled.",
	"Dojdi k laboratorní skříni TRAIN-SPARES. Vezmi označený SPARE-2T.",
	"Vrať SPARE-2T do stejné laboratorní skříně.",
	"Znovu otevři TRAIN-PC-PVE. Ověř, že se cvičný díl vrátil do skříně.",
	"Otevři pauzu a zvol Pokračovat. Tím dokončíš praktický úvod."]

func start():
	if active: finish(false)
	var g=shell.ui.game
	shell.ui.capture_form_drafts()
	if g.save()!=OK:
		shell.ui.show_message("Úvod zatím nelze spustit","Změny čekají na uložení. Zkus nejdřív uložit znovu."); return
	return_mode=shell.introduction_return_mode if shell.mode=="introduction" else shell.mode
	return_page=shell.ui.page
	g.suspend_session()
	stash={"sim":g.sim,"main_sim":g.main_sim,"training_sim":g.training_sim,"active":g.active,"current":g.current,"session_kind":g.session_kind,"training":g.training,"finished":g.finished,"room":g.game_mode.current,"pose":shell.world.player.transform,"pitch":shell.world.player.camera.rotation,"door":shell.world.door_open,"drafts":shell.ui.form_drafts.duplicate(true)}
	stash.cable=shell.pending_cable; stash.selected=shell.selected; stash.notice=shell.room_notice.text; stash.notice_time=shell.notice_time
	g.introduction_active=true
	g.active=false; g.current={}; g.session_kind="introduction"
	g.game_mode.current=0
	var temporary=g.Simulator.new(); temporary.reset({})
	g.sim=temporary; g.main_sim=temporary; g.training_sim=temporary
	shell.pending_cable=""; shell.selected=null; shell.notice_time=0
	active=true; step=0
	shell.world.player.position=shell.world.hub.SPAWN
	shell.world.player.rotation=Vector3.ZERO; shell.world.player.camera.rotation=Vector3.ZERO
	shell.world.move_door(false)
	shell.set_mode("world")
	initial_forward=head().global_basis.z
	marker=preload("res://scripts/world/Geometry.gd").box(shell.world,Vector3(7.5,0.035,3.5),Vector3(0.85,0.02,0.85),Color("ffd579"),0,0.8)
	marker.hide()

func head():
	return shell.xr_rig.head if shell.vr_active else shell.world.player.camera

func _process(_delta):
	if not active: return
	if step==0 and head().global_basis.z.dot(initial_forward)<0.94: advance()
	elif step==1 and Vector2(shell.world.player.position.x-7.5,shell.world.player.position.z-3.5).length()<0.85: advance()
	elif step==3 and shell.world.door_open and shell.world.player.position.x>9.5 and absf(shell.world.player.position.z-3.5)<1.4: advance()
	marker.visible=step==1

func advance():
	step+=1
	shell.update_time=1.0

func target_id() -> String:
	return {2:"DOOR-CONTROL-OPS",4:"TRAIN-PC-PVE",5:"TRAIN-PC-PVE",6:"TRAIN-SPARES",7:"TRAIN-SPARES",8:"TRAIN-PC-PVE"}.get(step,"")

func interact(object):
	if not active: return false
	if object.device_id!=target_id(): return true
	match step:
		2:
			if not shell.world.door_open and shell.world.toggle_door(): advance()
		4,5:
			if step==4: advance()
			shell.set_mode("detail")
			var v=shell.panel("TRAIN-PC-PVE / cvičný přehled","Toto je bezpečný dočasný stav. Ověř přehled skutečným tlačítkem.")
			v.add_child(shell.ui.button("Ověřit cvičný přehled",func():
				if active and step==5:
					var result=shell.ui.game.sim.act("physical_monitor",{})
					if result.ok: advance(); shell.return_to_world(),true))
		6,7: cabinet()
		8:
			shell.set_mode("detail")
			var v=shell.panel("Ověření výsledku zásahu","Zkontroluj, že je díl skutečně ve skříni a nic neneseš.")
			v.add_child(shell.ui.button("Ověřit výsledek zásahu",func():
				if active and step==8 and shell.ui.game.sim.state.world.held=="":
					var result=shell.ui.game.sim.act("physical_monitor",{})
					if result.ok: advance(); shell.return_to_world(),true))
	return true

func cabinet():
	shell.set_mode("detail")
	var v=shell.panel("TRAIN-SPARES / SPARE-2T","Cvičný disk se nikdy neukládá do pracovní relace.")
	if step==6: v.add_child(shell.ui.button("Vzít cvičný SPARE-2T",func(): take(); shell.return_to_world(),true))
	elif step==7: v.add_child(shell.ui.button("Vrátit cvičný SPARE-2T",func(): return_spare(); shell.return_to_world(),true))
	v.add_child(shell.ui.button("Zpět",shell.return_to_world))

func take() -> bool:
	if not active or step!=6: return false
	var result=shell.ui.game.sim.act("physical_spare",{"spare":"SPARE-2T"})
	if result.ok: advance()
	return result.ok

func return_spare() -> bool:
	if not active or step!=7 or shell.ui.game.sim.state.world.held!="SPARE-2T": return false
	var result=shell.ui.game.sim.act("physical_return_spare",{})
	if result.ok: advance()
	return result.ok

func pause():
	if step==9: advance()
	shell.set_mode("pause")
	var v=shell.panel("Praktický úvod / pauza","Pokračuj, nebo úvod bezpečně zruš. Původní relace se obnoví.")
	v.add_child(shell.ui.button("Pokračovat",func():
		if step==10: finish(true)
		else: shell.return_to_world(),true))
	v.add_child(shell.ui.button("Zrušit / přeskočit úvod",func(): finish(false)))

func guidance():
	if not active: return
	var keys=shell.ui.display_settings.bindings
	var move="Teleport / levý joystick" if shell.vr_active else "%s/%s/%s/%s" % [OS.get_keycode_string(keys.walk_forward),OS.get_keycode_string(keys.walk_left),OS.get_keycode_string(keys.walk_back),OS.get_keycode_string(keys.walk_right)]
	var use="Namiř paprsek a stiskni trigger." if shell.vr_active else "Zaměř středem obrazu a stiskni %s." % OS.get_keycode_string(keys.interact)
	var controls={0:"Otoč hlavu / pravý joystick." if shell.vr_active else "Rozhlédni se myší.",1:move,2:use,3:move,4:use,5:"Namiř na tlačítko a stiskni trigger." if shell.vr_active else "Klikni myší nebo vyber Tab a Enter.",6:use,7:use,8:use,9:"B/Y: pauza a Pokračovat." if shell.vr_active else "Esc: pauza a Pokračovat."}
	shell.instruction.text="PRAKTICKÝ ÚVOD / %d z 10\n%s\n%s" % [mini(step+1,10),TEXTS[mini(step,9)],controls.get(step,"")]
	var id=target_id()
	if shell.world.devices.has(id):
		var target=shell.world.devices[id]; target.set_guided(true)
		shell.direction.text=target.caption+" / %.1f m" % shell.world.player.position.distance_to(target.position)

func finish(completed: bool):
	if not active: return
	active=false
	if is_instance_valid(marker): marker.queue_free()
	var g=shell.ui.game
	for key in ["sim","main_sim","training_sim","active","current","session_kind","training","finished"]: g.set(key,stash[key])
	g.game_mode.current=stash.room; g.introduction_active=false
	shell.world.player.transform=stash.pose; shell.world.player.camera.rotation=stash.pitch
	shell.world.player.velocity=Vector3.ZERO
	shell.world.move_door(stash.door)
	shell.pending_cable=stash.cable; shell.selected=stash.selected
	if shell.vr_active:
		shell.xr_rig.hold_hand=null
		shell.world.carried_disk.reparent(shell.world.player.camera)
		shell.world.carried_disk.position=Vector3(0.32,-0.3,-0.65)
	shell.ui.form_drafts=stash.drafts
	if shell.leaving_scene:
		shell.ui.display_settings.introduction_seen=true; shell.ui.display_settings.save_settings(); stash={}; return
	shell.ui.save_preference("introduction_seen",true)
	shell.ui.page=return_page
	if return_mode=="menu": shell.ui.draw_ui()
	shell.set_mode(return_mode if return_mode in ["world","menu","app","coding"] else "world"); shell.world.sync_state(); shell.update_guidance()
	shell.room_notice.text="Úvod dokončen. V hale vyber průchod 01–04; směny jsou v nabídce serverovny." if completed else "Úvod ukončen. Původní pracovní relace obnovena. Zopakování: Pauza → Seznámení."
	shell.notice_time=8.0
	stash={}
