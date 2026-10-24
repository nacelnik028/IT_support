extends RefCounted

static func capacity(level: String, sizes: Array) -> float:
	var n = sizes.size()
	if n == 0: return 0.0
	var smallest = float(sizes.min())
	match level:
		"RAID 0", "Simple": return n * smallest if n >= 2 else 0.0
		"RAID 1", "ZFS mirror", "Mirror": return smallest if n == 2 else 0.0
		"RAID 5", "RAIDZ1", "Parity": return (n-1) * smallest if n >= 3 else 0.0
		"RAID 6", "RAIDZ2": return (n-2) * smallest if n >= 4 else 0.0
		"RAID 10": return n / 2.0 * smallest if n >= 4 and n % 2 == 0 else 0.0
	return 0.0

static func health(level: String, members: Array, disks: Dictionary) -> String:
	var failures = 0
	for id in members:
		if disks[id].health != "Healthy": failures += 1
	if failures == 0: return "Healthy"
	match level:
		"RAID 0", "Simple": return "Failed"
		"RAID 1", "ZFS mirror", "Mirror", "RAID 5", "RAIDZ1", "Parity": return "Degraded" if failures <= 1 else "Failed"
		"RAID 6", "RAIDZ2": return "Degraded" if failures <= 2 else "Failed"
		"RAID 10":
			for i in range(0, members.size(), 2):
				if disks[members[i]].health != "Healthy" and disks[members[i+1]].health != "Healthy": return "Failed"
			return "Degraded"
	return "Failed"

static func tb_to_tib(tb: float) -> float:
	return tb * 1000000000000.0 / 1099511627776.0
