extends Control

# Read-only screens render from the same state as the full management apps.
var game
var application = "Proxmox"
var overview = false
var laboratory = false
const INK = Color("dce9f3")
const MUTED = Color("8197ad")
const ACCENT = Color("58dac8")

func _draw():
	var font = ThemeDB.fallback_font
	var w = size.x
	draw_rect(Rect2(Vector2.ZERO,size),Color("08111d"))
	draw_rect(Rect2(0,0,w,58),Color("101e2e"))
	draw_rect(Rect2(0,57,w,2),ACCENT)
	var brand = "NORTHSTAR  /  PROVOZNÍ DOHLED" if overview else application.to_upper()+"  /  SPRÁVA INFRASTRUKTURY"
	draw_string(font,Vector2(28,37),brand,HORIZONTAL_ALIGNMENT_LEFT,-1,23,INK)
	draw_string(font,Vector2(w-166,35),"● ŽIVÝ STAV",HORIZONTAL_ALIGNMENT_LEFT,-1,16,ACCENT)
	if game==null or game.sim.state.is_empty(): return
	var s = game.training_sim.state if laboratory else game.main_sim.state
	if application=="Trénink":
		draw_string(font,Vector2(35,120),"IT TRAINING ACADEMY",HORIZONTAL_ALIGNMENT_LEFT,-1,36,INK)
		for i in 3:
			draw_rect(Rect2(35,155+i*95,w-70,75),Color("152638"))
			draw_string(font,Vector2(60,200+i*95),["01   UČÍM SE","02   PROCVIČOVÁNÍ","03   ZKOUŠKA"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,25,ACCENT)
		draw_string(font,Vector2(35,510),"21 LEKCÍ  /  VLASTNÍ LABORATORNÍ INFRASTRUKTURA",HORIZONTAL_ALIGNMENT_LEFT,-1,18,MUTED)
		return
	var sidebar = 165.0 if not overview else 0.0
	if not overview:
		draw_rect(Rect2(0,59,sidebar,size.y-59),Color("0d1928"))
		for i in 6:
			var title = ["PŘEHLED","HOSTITELÉ","VIRTUÁLNÍ STROJE","ÚLOŽIŠTĚ","ZÁLOHY","UDÁLOSTI"][i]
			if i==0: draw_rect(Rect2(10,82+i*50,145,36),Color("17443f"))
			draw_string(font,Vector2(23,106+i*50),title,HORIZONTAL_ALIGNMENT_LEFT,-1,14,INK if i==0 else MUTED)
	var left = sidebar+26
	var width = (w-left-40)/3.0
	var running = 0
	var cpus = 0
	var ram = 0.0
	for vm in s.vms.values():
		if vm.get("exists",false) and vm.status=="Running": running+=1; cpus+=int(vm.cpu); ram+=float(vm.ram)
	var values = [str(running),str(cpus),"%d / %d GB" % [s.storage.used,s.storage.capacity]]
	for i in 3:
		var x = left+i*(width+5)
		draw_rect(Rect2(x,81,width-7,100),Color("122336"))
		draw_rect(Rect2(x,81,3,100),ACCENT if i!=2 or s.storage.used<s.storage.capacity*0.9 else Color("ffba61"))
		draw_string(font,Vector2(x+18,111),["BĚŽÍCÍ VM","PŘIDĚLENO vCPU","FYZICKÉ STORAGE"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,14,MUTED)
		draw_string(font,Vector2(x+18,154),values[i],HORIZONTAL_ALIGNMENT_LEFT,-1,31,INK)
	draw_string(font,Vector2(left,218),"VMID       NÁZEV                           HOSTITEL                   STAV",HORIZONTAL_ALIGNMENT_LEFT,-1,16,MUTED)
	var row = 0
	for vm in s.vms.values():
		if not vm.get("exists",false): continue
		var y = 251+row*42
		if y>size.y-68: break
		draw_rect(Rect2(left,y-25,w-left-24,36),Color("0f1f2e") if row%2==0 else Color("132536"))
		draw_string(font,Vector2(left+12,y),str(vm.id),HORIZONTAL_ALIGNMENT_LEFT,-1,18,INK)
		draw_string(font,Vector2(left+94,y),str(vm.name),HORIZONTAL_ALIGNMENT_LEFT,-1,18,INK)
		draw_string(font,Vector2(left+width*1.25,y),str(vm.host),HORIZONTAL_ALIGNMENT_LEFT,-1,17,MUTED)
		draw_string(font,Vector2(w-177,y),"● BĚŽÍ" if vm.status=="Running" else "○ VYPNUTO",HORIZONTAL_ALIGNMENT_LEFT,-1,17,ACCENT if vm.status=="Running" else Color("ffbd74"))
		row+=1
	var status = "RAID: %s   /   ZFS: %s   /   RAM VM: %d GB" % [health(s.raid.health),health(s.zfs.health),ram]
	draw_rect(Rect2(0,size.y-44,w,44),Color("122437"))
	draw_string(font,Vector2(24,size.y-16),status,HORIZONTAL_ALIGNMENT_LEFT,-1,17,ACCENT)

static func health(value: String) -> String:
	return {"Healthy":"V POŘÁDKU","Degraded":"DEGRADOVANÉ","Recovering":"OBNOVA","Failed":"SELHÁNÍ"}.get(value,value)
