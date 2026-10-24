extends RefCounted

const Network = preload("res://scripts/simulation/NetworkSimulator.gd")
const Raid = preload("res://scripts/simulation/RAIDSimulator.gd")
var state: Dictionary = {}

func reset(patch: Dictionary):
	state = JSON.parse_string(FileAccess.get_file_as_string("res://data/infrastructure/baseline.json"))
	merge(state,patch)
	state.verified = {}
	state.diagnostic = {"viewed":false}
	state.journal = []
	state.errors = 0
	state.risks = 0
	state.revision = 0

static func merge(target: Dictionary, patch: Dictionary):
	for key in patch:
		if patch[key] is Dictionary and target.get(key) is Dictionary: merge(target[key],patch[key])
		else: target[key] = patch[key].duplicate(true) if patch[key] is Dictionary or patch[key] is Array else patch[key]

func reject(message: String, risk: bool = false) -> Dictionary:
	state.errors += 1
	if risk: state.risks += 1
	var text = message + "\nZměna nebyla provedena. Ověř identitu, závislosti a podmínky operace; potom ji zopakuj bezpečně."
	state.journal.append("ODMÍTNUTO • " + message)
	return {"ok":false,"text":text}

func success(message: String, change: bool = true) -> Dictionary:
	if change:
		state.revision += 1
		state.verified.clear()
	state.journal.append(message)
	return {"ok":true,"text":message}

func act(action: String, p: Dictionary = {}) -> Dictionary:
	match action:
		"inspect":
			state.diagnostic.viewed = true
			state.diagnostic[p.get("scope","Inventory")] = true
			return success("Diagnostika zaznamenána: " + p.get("scope","Inventory"),false)
		"prepare":
			var h = state.hosts["PVE-01"]
			if not p.get("vt",false): return reject("Bez VT-x/AMD-V nelze provozovat KVM VM.")
			if p.get("mode","RAID") != "HBA": return reject("ZFS potřebuje disky přímo. RAID řadič s cache není vhodný podklad.")
			h.vt = p.vt
			h.iommu = p.get("iommu",false)
			h.mode = p.mode
			h.ups = p.get("ups",false)
			h.console = p.get("console",false)
			return success("Firmware a provozní příprava serveru uloženy. IOMMU slouží pro PCIe passthrough.")
		"management":
			if not valid_ip(p.get("ip","")) or not valid_ip(p.get("gateway","")) or not valid_ip(p.get("dns","")): return reject("Neplatná IPv4 adresa.")
			var h = state.hosts["PVE-01"]
			for k in ["ip","gateway","dns","hostname"]: h[k] = p[k]
			return success("Management konfigurace uložena na bridge vmbr0.")
		"verify":
			var h = state.hosts["PVE-01"]
			state.verified = {"preflight":h.vt and h.mode == "HBA" and h.ups and h.console and h.ip == "192.168.10.10" and h.gateway == "192.168.10.1" and h.dns == "192.168.10.2", "service_pve":Network.probe(state,"100").app, "service_hv":Network.probe(state,"200").app}
			return success("Ověření dokončeno. Kontroly odrážejí aktuální konfiguraci.\n" + JSON.stringify(state.verified,"  "),false)
		_: return reject("Operace není implementována: " + action)

static func valid_ip(address: String) -> bool:
	var pieces = address.split(".")
	if pieces.size() != 4: return false
	for part in pieces:
		if not part.is_valid_int() or int(part) < 0 or int(part) > 255: return false
	return true
