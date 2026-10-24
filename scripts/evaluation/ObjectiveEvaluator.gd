extends RefCounted

static func read_path(state: Dictionary, path: String, fallback = null):
	var value = state
	for key in path.split("."):
		if not value is Dictionary or not value.has(key): return fallback
		value = value[key]
	return value

static func evaluate(state: Dictionary, objectives: Array) -> Array:
	var results = []
	for goal in objectives:
		var actual = read_path(state, goal.path)
		var passed = false
		match goal.get("op", "eq"):
			"eq": passed = actual == goal.value
			"gte": passed = actual != null and float(actual) >= float(goal.value)
			"lte": passed = actual != null and float(actual) <= float(goal.value)
			"contains": passed = actual != null and goal.value in actual
		results.append({"label":goal.label,"passed":passed,"actual":actual})
	return results
