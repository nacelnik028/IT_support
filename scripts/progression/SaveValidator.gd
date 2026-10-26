extends RefCounted

# Check before merging data or reading typed fields. Missing schema1 branches
# retain defaults; present values must be valid. JSON numbers include floats.
const Sim = preload("res://scripts/simulation/InfrastructureSimulator.gd")
var missions: Array = []
var lessons: Array = []
var baseline: Dictionary = {}
var checked_sessions: Dictionary = {}

func _init():
	missions=JSON.parse_string(FileAccess.get_file_as_string("res://data/missions/campaign.json"))
	lessons=JSON.parse_string(FileAccess.get_file_as_string("res://data/training/lessons.json"))
	baseline=JSON.parse_string(FileAccess.get_file_as_string("res://data/infrastructure/baseline.json"))
	Sim.merge(baseline,JSON.parse_string(FileAccess.get_file_as_string("res://data/infrastructure/academy_defaults.json")))
	baseline.merge({"verified":{},"diagnostic":{"viewed":false},"journal":[],"errors":0,"risks":0,"revision":0})

static func integer(value, minimum: int, maximum: int = 2147483647) -> bool:
	return typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(value)) and float(value)==floor(float(value)) and value>=minimum and value<=maximum

func lesson_by_id(id: int) -> Dictionary:
	for item in lessons:
		if int(item.id)==id: return item
	return {}

func valid(data) -> bool:
	if not data is Dictionary or not integer(data.get("schema"),1,2): return false
	for key in ["progress","education","session","suspended_campaign"]:
		if data.has(key) and not data[key] is Dictionary: return false
	var progress=data.get("progress",{})
	if not shape(progress,{"xp":0,"scores":{},"mistakes":{},"achievements":[],"last_mission":1}): return false
	if not integer(progress.get("xp",0),0) or not integer(progress.get("last_mission",1),1,missions.size()): return false
	for key in progress.get("scores",{}):
		if not str(key).is_valid_float() or not integer(float(key),1,missions.size()) or not integer(progress.scores[key],0,100): return false
	for value in progress.get("mistakes",{}).values():
		if not integer(value,0): return false
	for value in progress.get("achievements",[]):
		if not value is String: return false
	if not session(data.get("session",{})) or not session(data.get("suspended_campaign",{}),"campaign"): return false
	if not education(data.get("education",{})): return false
	if not programming(data.get("programming",{})): return false
	var active=data.get("session",{})
	if active.get("kind","")=="random":
		var batch=data.get("education",{}).get("random",{})
		if batch.is_empty() or not batch.has("session"): return false
		if int(active.id)!=int(batch.queue[int(batch.position)].id) or active.definition!=batch.queue[int(batch.position)]: return false
	return true

func programming(data) -> bool:
	if not data is Dictionary: return false
	if not shape(data,{"results":{},"lessons":{},"attempts":[],"mistakes":{},"xp":0,"settings":{},"drafts":{},"unlocked":[]}): return false
	if not integer(data.get("xp",0),0): return false
	for id in data.get("results",{}):
		var record=data.results[id]
		if not record is Dictionary or not required(record,{"best":0,"passed":false,"exam":0}): return false
		if not integer(record.best,0,100) or not integer(record.exam,0,100): return false
		if record.has("paid") and not integer(record.paid,0,100): return false
	for value in data.get("lessons",{}).values():
		if not value is bool: return false
	for value in data.get("mistakes",{}).values():
		if not integer(value,0): return false
	if data.get("attempts",[]).size()>200: return false
	for record in data.get("attempts",[]):
		if not record is Dictionary or not required(record,{"id":"","score":0,"mode":"","hints":0,"passed":false}): return false
		if not integer(record.score,0,100) or not integer(record.hints,0) or not record.mode in ["learn","practice","exam"]: return false
	var settings=data.get("settings",{})
	if settings.has("font_size") and not integer(settings.font_size,16,36): return false
	return true

func session(data, expected_kind: String = "") -> bool:
	if not data is Dictionary: return false
	if data.is_empty(): return true
	var kind=data.get("kind","campaign")
	if not kind in ["campaign","lesson","random"] or (expected_kind!="" and kind!=expected_kind): return false
	# Stored lesson snapshots repeat in every autosave. Cache only a deep copy
	# of validated data and compare equality too, so hash collisions cannot pass.
	var fingerprint=data.hash()
	if checked_sessions.has(fingerprint) and checked_sessions[fingerprint]==data: return true
	if not session_contents(data,kind): return false
	if checked_sessions.size()>=256: checked_sessions.erase(checked_sessions.keys()[0])
	checked_sessions[fingerprint]=data.duplicate(true)
	return true

func session_contents(data: Dictionary, kind: String) -> bool:
	if not integer(data.get("id"),1): return false
	if not shape(data,{"state":{},"definition":{},"training":false,"finished":false,"hints":0,"tutorial":{}}): return false
	if not integer(data.get("hints",0),0): return false
	var definition={}
	match kind:
		"campaign":
			if int(data.id)>missions.size(): return false
			definition=missions[int(data.id)-1]
		"lesson":
			definition=lesson_by_id(int(data.id))
			if definition.is_empty() or not tutorial(data.get("tutorial"),definition): return false
		"random":
			definition=data.get("definition",{})
			if not scenario(definition) or int(definition.id)!=int(data.id): return false
	return state(data.get("state",{}),definition.initial_state)

func tutorial(data, definition: Dictionary) -> bool:
	if not data is Dictionary: return false
	if not integer(data.get("lesson_id"),int(definition.id),int(definition.id)): return false
	if not data.get("mode") in ["learn","practice","exam"]: return false
	if not integer(data.get("step"),0,definition.steps.size()): return false
	if not required(data,{"hints":0,"mistakes":[],"complete":false}) or not shape(data,{"page":"","tab":"","host":""}): return false
	if not integer(data.get("hints",0),0): return false
	for mistake in data.get("mistakes",[]):
		if not mistake is Dictionary or not required(mistake,{"action":"","kind":"","text":""}): return false
	return true

func scenario(data) -> bool:
	if not data is Dictionary or not integer(data.get("id"),20000,20019): return false
	if not required(data,{"title":"","category":"","server":"","topic":"","difficulty":"","priority":"","description":"","symptoms":"","explanations":"","initial_state":{},"available_actions":[],"objectives":[],"hints":[]}): return false
	if not data.category in ["Proxmox","Hyper-V","Storage"] or not baseline.hosts.has(data.server): return false
	if not shape(data,{"tags":[]}): return false
	for key in ["available_actions","hints","tags"]:
		for item in data.get(key,[]):
			if not item is String: return false
	if data.hints.size()<3: return false
	for goal in data.objectives:
		if not goal is Dictionary or not required(goal,{"path":"","label":""}) or not goal.has("value"): return false
	return state(data.initial_state,{})

func education(data: Dictionary) -> bool:
	# Contents are validated below. Do not recursively scan every archived
	# snapshot before reaching session() and its equality-checked cache.
	var branches={"lessons":TYPE_DICTIONARY,"sessions":TYPE_DICTIONARY,"attempts":TYPE_ARRAY,"random":TYPE_DICTIONARY}
	for key in data:
		if branches.has(key):
			if typeof(data[key])!=branches[key]: return false
		elif not json_value(data[key]): return false
	for key in data.get("lessons",{}):
		if not str(key).is_valid_float() or not integer(float(key),1) or lesson_by_id(int(float(key))).is_empty(): return false
		var record=data.lessons[key]
		if not record is Dictionary or not required(record,{"status":"","best":0}) or not integer(record.best,0,100): return false
	for key in data.get("sessions",{}):
		var record=data.sessions[key]
		if not session(record,"lesson") or record.is_empty(): return false
		var parts=str(key).split(":")
		if parts.size()>2 or not parts[0].is_valid_float() or float(parts[0])!=int(record.id): return false
		if parts.size()==2 and parts[1]!=record.tutorial.mode: return false
	for record in data.get("attempts",[]):
		if not attempt(record): return false
	var batch=data.get("random",{})
	if batch.is_empty(): return true
	if not required(batch,{"queue":[],"position":0,"hints_allowed":false,"results":[]}): return false
	if batch.queue.is_empty() or batch.queue.size()>20 or not integer(batch.position,0,batch.queue.size()-1): return false
	for i in batch.queue.size():
		if not scenario(batch.queue[i]) or int(batch.queue[i].id)!=20000+i: return false
	for record in batch.results:
		if not attempt(record) or record.kind!="random": return false
	if batch.has("session"):
		if not session(batch.session,"random") or batch.session.is_empty(): return false
		if int(batch.session.id)!=int(batch.queue[int(batch.position)].id): return false
		if batch.session.definition!=batch.queue[int(batch.position)]: return false
	return true

func attempt(data) -> bool:
	if not data is Dictionary or not required(data,{"id":0,"title":"","kind":"","mode":"","score":0,"hints":0,"errors":0,"risks":0,"tags":[],"mistakes":[],"journal":[]}): return false
	if not integer(data.score,0,100) or not integer(data.hints,0) or not integer(data.errors,0) or not integer(data.risks,0): return false
	match data.kind:
		"campaign": return integer(data.id,1,missions.size())
		"lesson": return integer(data.id,1) and not lesson_by_id(int(data.id)).is_empty()
		"random": return integer(data.id,20000,20019)
	return false

func state(patch: Dictionary, initial: Dictionary) -> bool:
	var template=baseline.duplicate(true)
	# Legacy installer stores a disk choice string after installation, an empty
	# array before it. Both representations are part of schema1/schema2.
	if patch.get("install",{}) is Dictionary and initial.get("install",{}) is Dictionary:
		var disks=patch.get("install",{}).get("disks",initial.get("install",{}).get("disks",[]))
		if disks is String: template.install.disks=""
	if not shape(patch,template): return false
	var effective=baseline.duplicate(true)
	Sim.merge(effective,initial)
	Sim.merge(effective,patch)
	for counter in ["errors","risks","revision"]:
		if not integer(effective[counter],0): return false
	for line in effective.journal:
		if not line is String: return false
	# Fixed branches must remain readable after empty-dictionary merges.
	for key in baseline:
		if key in ["vms","ct","network","backup"]: continue
		if not required(effective[key],template[key]): return false
	for id in effective.hosts:
		if not baseline.hosts.has(id): return false
	if not effective.vms.has("100") or not effective.vms.has("200"): return false
	var vm_required=baseline.vms["100"].duplicate(true)
	# Optional fields added by schema2 are computed/defaulted on restore.
	for key in ["ram_mib","virtio_drivers","disk_bus"]: vm_required.erase(key)
	for id in effective.vms:
		var vm=effective.vms[id]
		if not str(id).is_valid_int() or int(id)<100 or int(id)>9999 or not vm is Dictionary: return false
		if not required(vm,vm_required) or not shape(vm,baseline.vms["200"]): return false
		if vm.id!=id or not effective.hosts.has(vm.host): return false
		if vm.host.begins_with("HV") and not required(vm,{"minimum":0,"maximum":0,"dynamic":false,"generation":0,"vss":false,"checkpoints":[]}): return false
		if not shape(vm,{"data_disk":{"path":"","capacity":0,"filesystem":0,"new":false},"replica":{"snapshot":{},"target":"","interval":0,"points":0,"health":""}}): return false
		if not integer(vm.get("vlan"),0,4094) or not integer(vm.get("prefix"),0,32): return false
		for cp in vm.get("checkpoints",[]):
			if not cp is Dictionary or not required(cp,{"name":"","type":"","service":false,"data":""}) or not shape(cp,{"ram_saved":false}): return false
	for id in effective.ct:
		if not str(id).is_valid_int() or int(id)<100 or not effective.ct[id] is Dictionary or not required(effective.ct[id],{"name":"","status":""}): return false
	if not required(effective.network,{"switches":{}}): return false
	for id in ["vmbr0","vSwitch-LAN","LAB"]:
		if not effective.network.switches.has(id): return false
	for sw in effective.network.switches.values():
		if not sw is Dictionary or not required(sw,baseline.network.switches.vmbr0): return false
	var backup_required=baseline.backup.duplicate(true)
	backup_required.records={}
	if not required(effective.backup,backup_required): return false
	for record in effective.backup.records.values():
		if not required(record,vm_required): return false
	if not world_state(effective): return false
	return true

func world_state(s: Dictionary) -> bool:
	var w = s.world
	if w.devices.keys().size()!=baseline.hosts.keys().size(): return false
	for id in w.devices:
		if not baseline.hosts.has(id): return false
		var d = w.devices[id]
		if not integer(d.port,1,12) or not integer(d.expected_port,1,12): return false
	if w.held!="" and (not w.stock.has(w.held) or w.stock[w.held].available): return false
	for disk in w.stock.values():
		if not required(disk,{"serial":"","capacity":0,"interface":"","available":false}): return false
		if not integer(disk.capacity,1) or not disk.interface in ["SAS","SATA"] or disk.serial.is_empty(): return false
	for key in w.removed:
		var parts = str(key).split(":")
		if parts.size()!=2 or not parts[0] in ["RAID","ZFS"]: return false
		var disks = s.disks if parts[0]=="RAID" else s.zfs.disks
		if not disks.has(parts[1]) or disks[parts[1]].health!="Missing": return false
		if not required(w.removed[key],{"serial":"","capacity":0,"health":""}): return false
	for collection in [w.inspected,w.restarted]:
		for id in collection:
			if not baseline.hosts.has(id) or not collection[id] is bool: return false
	for value in w.data_loss.values():
		if not value is bool: return false
	if absf(w.player.x)>21 or absf(w.player.z)>7 or absf(w.player.pitch)>1.5: return false
	return true

static func shape(value, template) -> bool:
	if typeof(template) in [TYPE_INT,TYPE_FLOAT]: return typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(value))
	if typeof(value)!=typeof(template): return false
	if value is Dictionary:
		for key in value:
			if template.has(key):
				if not shape(value[key],template[key]): return false
			elif not json_value(value[key]): return false
	elif value is Array:
		for item in value:
			if not json_value(item): return false
	return true

static func required(value, template) -> bool:
	if not shape(value,template): return false
	if template is Dictionary:
		for key in template:
			if not value.has(key) or not required(value[key],template[key]): return false
	return true

static func json_value(value) -> bool:
	if value is Dictionary:
		for item in value.values():
			if not json_value(item): return false
	elif value is Array:
		for item in value:
			if not json_value(item): return false
	elif typeof(value) in [TYPE_INT,TYPE_FLOAT]: return is_finite(float(value))
	elif not typeof(value) in [TYPE_STRING,TYPE_BOOL]: return false
	return true
