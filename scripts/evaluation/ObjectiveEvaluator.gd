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
			"eq": passed = equal_values(actual,goal.value)
			"gte": passed = numeric(actual) and numeric(goal.value) and float(actual) >= float(goal.value)
			"lte": passed = numeric(actual) and numeric(goal.value) and float(actual) <= float(goal.value)
			"contains":
				if actual is Array or actual is Dictionary: passed = actual.has(goal.value)
				elif actual is String and goal.value is String: passed = actual.contains(goal.value)
		results.append({"label":goal.label,"passed":passed,"actual":actual})
	return results

static func numeric(value) -> bool:
	return typeof(value) in [TYPE_INT,TYPE_FLOAT]

static func equal_values(actual, expected) -> bool:
	if numeric(actual) and numeric(expected): return float(actual)==float(expected)
	if typeof(actual)!=typeof(expected): return false
	return actual==expected
