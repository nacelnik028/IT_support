extends SceneTree

const Sim = preload("res://scripts/simulation/InfrastructureSimulator.gd")
var failures = 0
var checks = 0

func check(ok, message):
	checks += 1
	if not ok: failures += 1; push_error(message)

func _init():
	preload("res://scripts/progression/SaveManager.gd").path_override = "user://academy_test_platform.json"
	preload("res://scripts/core/DisplaySettings.gd").path_override = "user://academy_test_platform.cfg"
	var sim = Sim.new()
	for action in ["memory","integration","attach_vhd","guest_volume","replica","replica_test","checkpoint","checkpoint_action","live_migrate","export","hv_recreate","data_resize","lab_update"]:
		sim.reset({"vms":{"100":{"status":"Off"}},"migration":{"cpu_compatible":true}})
		var before = sim.state.duplicate(true)
		var result = sim.act(action,{"vm":"100","dynamic":true,"minimum":2,"ram":6,"maximum":8,"target":"HV-02","auth":"Kerberos","storage":true})
		check(not result.ok,"Hyper-V odmítá PVE zdroj: "+action)
		for key in before:
			if key in ["journal","errors","risks"]: continue
			check(before[key] == sim.state[key],"Odmítnutí nemění "+key+" / "+action)
	sim.reset({"vms":{"200":{"host":"HV-02","status":"Off"}}})
	check(sim.act("memory",{"vm":"200","dynamic":true,"minimum":2,"ram":6,"maximum":8}).ok,"RAM se ověřuje na skutečném HV-02")
	for target in ["HV-02","PVE-02","NEEXISTUJE"]:
		check(not sim.act("live_migrate",{"vm":"200","target":target,"auth":"Kerberos","storage":true}).ok,"Migrace odmítá stejný/nekompatibilní/neznámý cíl")
	sim.reset({"migration":{"cpu_compatible":true}})
	check(sim.act("live_migrate",{"vm":"200","target":"HV-02","auth":"Kerberos","storage":true}).ok,"Platná Hyper-V migrace funguje")
	check(not sim.act("pve_resources",{"vm":"200","cpu":2,"ram":4}).ok,"PVE odmítá Hyper-V VM")
	print("PLATFORM CONTEXT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
