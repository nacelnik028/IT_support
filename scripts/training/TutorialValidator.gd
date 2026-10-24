extends RefCounted

const Evaluator=preload("res://scripts/evaluation/ObjectiveEvaluator.gd")

static func accepts(step: Dictionary,state: Dictionary,event: Dictionary) -> bool:
	var expected=step.get("event",{})
	if not expected.is_empty():
		for key in expected:
			if not Evaluator.equal_values(event.get(key),expected[key]): return false
	for goal in Evaluator.evaluate(state,step.get("checks",[])):
		if not goal.passed: return false
	return not expected.is_empty() or not step.get("checks",[]).is_empty()
