extends RefCounted

# This parser reads and edits dictionaries only. It deliberately has no OS execution API.
static func execute(sim, line: String, context: String = "PVE-01", action_handler: Callable = Callable()) -> String:
	var command = line.strip_edges()
	if command == "": return ""
	for forbidden in [";","|","&",">","<","`","$(","\n"]:
		if forbidden in command: return "Parser: řetězení, přesměrování a shell expanze nejsou podporované. Použij jeden simulovaný příkaz."
	var pattern = RegEx.new()
	pattern.compile("\"([^\"]*)\"|'([^']*)'|(\\S+)")
	var args = []
	for token in pattern.search_all(command):
		args.append(token.get_string(1) if token.get_string(1) != "" else (token.get_string(2) if token.get_string(2) != "" else token.get_string(3)))
	if args.is_empty(): return "Parser: neplatný vstup."
	var verb = str(args[0]).to_lower()
	var s = sim.state
	if verb in ["help","?","get-help"]:
		return "LINUX / PVE:\nqm list | qm config 100 | qm start 100 | qm shutdown 100\npct list | pvesm status | pveversion -v\nzpool status | zpool list | lsblk | df -h | lvs\nip -br address | ip route | pvecm status\n\nPOWERSHELL / HYPER-V:\nGet-VM [-Name 'FS01'] | Get-VMHost | Get-VMSwitch\nGet-VMNetworkAdapter | Get-VMHardDiskDrive | Get-VMMemory\nGet-VMIntegrationService | Get-VMSnapshot\nGet-Disk | Get-Volume | Get-PhysicalDisk | Get-Service vmms\nGet-WinEvent | Start-VM -Name FS01 | Stop-VM -Name FS01\n\nPřepni cílový hostitel nad terminálem. Formuláře konzolí mění tentýž stav."
	if not s.hosts.has(context): return "Neznámý cílový hostitel. Vyber PVE-01, PVE-02, HV-01 nebo HV-02."
	var ps = verb.begins_with("get-") or verb in ["start-vm","stop-vm"]
	if ps and s.hosts[context].kind != "Hyper-V": return "Tento příkaz patří do PowerShellu. Vyber HV-01 nebo HV-02."
	if not ps and s.hosts[context].kind != "Proxmox": return "Tento příkaz patří na PVE hostitele. Vyber PVE-01 nebo PVE-02."
	s.diagnostic.viewed = true
	s.journal.append("Terminál " + context + ": " + command)
	if verb == "qm":
		if args.size()==2 and args[1]=="list": return vm_table(s,context)
		if args.size()!=3: return "Použití: qm list | qm config/start/shutdown VMID"
		var vm = sim.get_vm(str(args[2]))
		if vm.is_empty() or vm.host != context: return "qm: VMID na vybraném PVE uzlu neexistuje."
		if args[1]=="config": return JSON.stringify(vm,"  ")
		if args[1] in ["start","shutdown"]: return power(sim,str(args[2]),args[1]=="start",action_handler)
		return "qm: nepodporovaná operace. Použij help."
	if verb=="pct":
		if args.size()!=2 or args[1]!="list": return "Použití: pct list"
		return "Žádné CT." if s.ct.is_empty() else JSON.stringify(s.ct,"  ")
	if verb=="pvesm":
		if args.size()!=2 or args[1]!="status": return "Použití: pvesm status"
		return "Name        Type      Status    TotalGB UsedGB AvailableGB\nlocal-lvm   lvmthin   %s    %.0f     %.0f    %.0f\nPBS         pbs       %s" % ["active" if s.storage.used<s.storage.capacity else "full",float(s.storage.capacity),float(s.storage.used),float(s.storage.capacity-s.storage.used),"active" if s.backup.configured else "inactive"]
	if verb=="pveversion":
		if args.size()>2 or (args.size()==2 and args[1]!="-v"): return "Použití: pveversion [-v]"
		return "proxmox-ve: 9.2 (výuková simulace)\nRepo: %s / updated: %s" % [s.hosts[context].repo,s.hosts[context].updated]
	if verb=="zpool":
		if args.size()<2 or not args[1] in ["list","status"]: return "Použití: zpool status [-P] [tank] | zpool list"
		if args[1]=="list": return "NAME SIZE ALLOC FREE HEALTH\ntank %sG %sG %sG %s" % [s.zfs.capacity,s.storage.used,maxf(s.zfs.capacity-s.storage.used,0),s.zfs.health.to_upper()]
		var rows = ["pool: tank","state: " + s.zfs.health.to_upper(),"scan: resilver %s %%" % s.zfs.progress,"config:"]
		for id in s.zfs.disks: rows.append("  %s  %s  %s" % [id,s.zfs.disks[id].serial,s.zfs.disks[id].health])
		return "\n".join(rows)
	if verb=="lsblk":
		var rows = ["NAME SIZE SERIAL / ROLE","SYS-A 1000G PVE-SYS-A","SYS-B 1000G PVE-SYS-B","ARCHIVE-9 4000G ACCOUNTING (DATA)"]
		for id in s.zfs.disks: rows.append("tank-%s %sG %s" % [id,s.zfs.disks[id].capacity,s.zfs.disks[id].serial])
		return "\n".join(rows)
	if verb=="df":
		if args.size()!=2 or args[1]!="-h": return "Použití: df -h"
		return "Filesystem Size Used Avail Mounted\n/dev/host %.0fG %.0fG %.0fG /var/lib/vz\nPozor: df nepopisuje data a metadata celého thin poolu." % [float(s.storage.host_fs),float(s.storage.used),maxf(s.storage.host_fs-s.storage.used,0)]
	if verb=="lvs": return "LV thinpool | data %.1f%% | metadata %.1f%% | provisioned %.0f GB" % [float(s.storage.used)/s.storage.capacity*100,float(s.storage.metadata),float(s.storage.provisioned)]
	if verb=="ip":
		if args.size()==3 and args[1]=="-br" and args[2] in ["address","a"]: return "eno1 UP\nvmbr0 UP %s/24\nManagement IP patří bridge, nikoli eno1." % s.hosts[context].get("ip","192.168.10.11")
		if args.size()==2 and args[1]=="route": return "default via %s dev vmbr0\n192.168.10.0/24 dev vmbr0" % s.hosts[context].get("gateway","192.168.10.1")
		return "Použití: ip -br address | ip route"
	if verb=="pvecm":
		if args.size()!=2 or args[1]!="status": return "Použití: pvecm status"
		var votes=1+int(s.cluster.peer_online)+int(s.cluster.qdevice)
		return "Cluster: Academy-PVE\nExpected votes: 3\nTotal votes: %d\nQuorate: %s\nQDevice: %s" % [votes,"Yes" if votes>=2 else "No",s.cluster.qdevice]
	if ps:
		var name_filter=""
		var i=1
		while i<args.size():
			var key=str(args[i]).to_lower()
			if key in ["-name","-vmname","-logname","-maxevents"] and i+1<args.size():
				if key in ["-name","-vmname"]: name_filter=str(args[i+1])
				i+=2
			elif verb=="get-service" and key=="vmms": name_filter="vmms"; i+=1
			else: return "PowerShell parser: nepodporovaný nebo neúplný parametr " + str(args[i])
		if verb=="get-vmhost":
			var h=s.hosts[context]
			return "%s | RAM %s GB | reserve %s GB | VMMS %s" % [context,h.ram,h.get("reserve",4),h.vmms]
		if verb=="get-vmswitch": return JSON.stringify(s.network.switches,"  ")
		if verb=="get-service": return "vmms " + ("Running" if s.hosts[context].get("vmms",true) else "Stopped")
		if verb=="get-disk": return JSON.stringify(s.disk,"  ")
		if verb=="get-volume": return "Drive %s: | %s | Size %s GB | Used %s GB | Online %s" % [s.disk.letter,s.disk.fs,s.disk.size,s.disk.used,s.disk.online]
		if verb=="get-physicaldisk": return "Hardware RAID presents logical disk: %s / %.0f GB / %s\nSkutečné fyzické členy kontroluj v panelu RAID řadiče." % [s.raid.level,float(s.raid.capacity),s.raid.health]
		if verb=="get-winevent": return sim.diagnose("Events")
		var rows=[]
		for id in s.vms:
			var vm=s.vms[id]
			if not vm.get("exists",false) or vm.host != context: continue
			if name_filter!="" and vm.name.to_lower()!=name_filter.to_lower() and id!=name_filter: continue
			match verb:
				"get-vm": rows.append("%s %s %s Gen%s %s GB %s" % [id,vm.name,vm.status,vm.get("generation",2),vm.ram,vm.host])
				"get-vmnetworkadapter": rows.append("%s Switch=%s VLAN=%s IP=%s" % [vm.name,vm.bridge,vm.vlan,vm.ip])
				"get-vmharddiskdrive":
					rows.append("%s SCSI VHDX %s GB | guest FS %s GB | available=%s" % [vm.name,vm.disk,vm.filesystem,vm.disk_present])
					if vm.has("data_disk"): rows.append("Datový disk: "+JSON.stringify(vm.data_disk))
				"get-vmmemory": rows.append("%s Startup=%sGB Min=%sGB Max=%sGB Dynamic=%s" % [vm.name,vm.ram,vm.get("minimum",vm.ram),vm.get("maximum",vm.ram),vm.get("dynamic",false)])
				"get-vmintegrationservice": rows.append("%s Heartbeat=%s VSS=%s" % [vm.name,vm.agent,vm.get("vss",false)])
				"get-vmsnapshot": rows.append(vm.name+": "+JSON.stringify(vm.get("checkpoints",[])))
				"start-vm","stop-vm":
					if name_filter=="": return "Uveď -Name konkrétní VM. Hromadné zásahy nejsou podporované."
					return power(sim,str(id),verb=="start-vm",action_handler)
				_: return "Neznámý simulovaný příkaz. Zadej help."
		return "\n".join(rows) if not rows.is_empty() else "Žádná odpovídající VM. Ověř jméno / VMID."
	return "Neznámý simulovaný příkaz '%s'. Zadej help. Nic nebylo spuštěno v OS." % args[0]

static func power(sim, vm: String, start: bool, action_handler: Callable) -> String:
	var params={"vm":vm,"power":"Start" if start else "Shutdown"}
	# The game supplies its action pipeline; standalone simulator callers keep
	# the same API without depending on UI, sessions or persistence.
	var result=action_handler.call("power",params) if action_handler.is_valid() else sim.act("power",params)
	return result.text

static func vm_table(s: Dictionary, context: String) -> String:
	var rows=["VMID NAME STATE RAM(GB) DISK(GB) NODE"]
	for id in s.vms:
		var vm=s.vms[id]
		if vm.get("exists",false) and vm.host == context: rows.append("%s %s %s %s %s %s" % [id,vm.name,vm.status,vm.ram,vm.disk,vm.host])
	return "\n".join(rows)
