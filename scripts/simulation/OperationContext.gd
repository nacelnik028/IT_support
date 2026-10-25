extends RefCounted

# Shared by the model and presentation. Generic power/network/backup operations
# deliberately remain platform independent; conversion has its own workflow.
const HV_VM = ["memory","integration","attach_vhd","guest_volume","replica","replica_test","checkpoint","checkpoint_action","live_migrate","export","hv_recreate","data_resize","lab_update"]
const PVE_VM = ["vm_media","vm_resources","vm_disk","vm_network","vm_install","pve_resources","vm_options","guest_driver","cross_check","cross_cutover"]
const PVE_HOST = ["prepare","management","install","web","repositories","update","bridge","security","create_vm","create_ct","vm_identity","zfs_create"]
const HV_HOST = ["hv_prepare","hv_role","hv_restart","switch","hypervisor_boot","hv_create"]

static func platform(state: Dictionary, vm: Dictionary) -> String:
	return state.hosts.get(vm.get("host",""),{}).get("kind","")

static func required(action: String) -> String:
	if action in HV_VM: return "Hyper-V"
	if action in PVE_VM: return "Proxmox"
	return ""

static func fixed_host(action: String) -> String:
	if action in PVE_HOST: return "PVE-01"
	if action in HV_HOST: return "HV-01"
	return ""

static func validate(state: Dictionary, action: String, params: Dictionary) -> String:
	var expected = required(action)
	if expected != "":
		var vm = state.vms.get(str(params.get("vm","")),{})
		if not vm.get("exists",false) or platform(state,vm) != expected:
			return "Operace %s vyžaduje existující VM na hostiteli platformy %s. Ověř ID a zdrojového hostitele." % [action,expected]
	if action in ["live_migrate","replica","import"]:
		var target = state.hosts.get(str(params.get("target","")),{})
		if target.get("kind","") != "Hyper-V": return "Cíl musí být existující Hyper-V hostitel. Pro jinou platformu použij offline převod."
		if action != "import" and state.vms[str(params.vm)].host == params.target: return "Zdrojový a cílový hostitel musejí být různí."
	if action == "import" and platform(state,state.migration.get("export",{})) != "Hyper-V": return "Nativní import vyžaduje úplný Hyper-V export."
	if action == "cross_import" and platform(state,state.migration.get("export",{})) != "Hyper-V": return "Offline převod vyžaduje úplný export zdrojové Hyper-V VM."
	return ""
