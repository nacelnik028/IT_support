extends RefCounted

static func calculate(hints: int, errors: int, risks: int, version: int = 2) -> Dictionary:
	var hint_penalty=hints*4 if version>=2 else 0
	return {"version":version,"base":100,"hints":hints,"errors":errors,"risks":risks,"hint_penalty":hint_penalty,"error_penalty":errors*8,"risk_penalty":risks*15,"score":clampi(100-hint_penalty-errors*8-risks*15,0,100)}

static func describe(result: Dictionary, xp: int = 0) -> String:
	var lines=["Hodnocení / metodika %d" % int(result.version),"Základ: %d" % int(result.base)]
	lines.append("Nápovědy: %d × 4 = −%d" % [int(result.hints),int(result.hint_penalty)] if int(result.version)>=2 else "Nápovědy: původní metodika je neodečítala; ztracená historie se neodhaduje.")
	lines.append("Chyby: %d × 8 = −%d" % [int(result.errors),int(result.error_penalty)])
	lines.append("Rizika: %d × 15 = −%d" % [int(result.risks),int(result.risk_penalty)])
	lines.append("Výsledek: %d / 100\nSkutečně přidané XP: %d" % [int(result.score),xp])
	lines.append("Počítadla patří právě předávanému ticketu. Riziko je dodatečný odečet k chybě." if int(result.version)>=2 else "Starý rozpracovaný pokus zachovává původní kumulativní metodiku.")
	return "\n".join(lines)

static func valid(record) -> bool:
	if not record is Dictionary or not preload("res://scripts/programming/CodeDrafts.gd").number(record.get("version"),1,2): return false
	for field in ["hints","errors","risks"]:
		if not preload("res://scripts/programming/CodeDrafts.gd").number(record.get(field),0,1000000): return false
	var expected=calculate(int(record.hints),int(record.errors),int(record.risks),int(record.version))
	if record.size()!=expected.size(): return false
	for field in expected:
		if not record.has(field) or record[field]!=expected[field]: return false
	return true
