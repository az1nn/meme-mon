class_name CardValidator
extends RefCounted

const VALID_TYPES := ["classic", "reaction", "brainrot", "surreal", "wholesome"]
const VALID_KINDS := ["mememom", "reaction", "format"]
const VALID_PRIMITIVES := ["deal_damage", "heal", "draw", "gain_trend", "modify_stat", "force_switch", "move_card", "set_action_allowance"]
const VALID_TRIGGERS := ["turn_started", "turn_ending", "card_drawn", "entered_play", "attack_declared", "damage_dealt", "mememom_ko", "switched_in"]

func validate_card(card: Dictionary) -> Dictionary:
	if str(card.get("schema_version", "")) != "alpha-0.1":
		return _fail("UNKNOWN_SCHEMA_VERSION")
	if str(card.get("rules_version", "alpha-0.1")) != "alpha-0.1":
		return _fail("FORMAT_ILLEGAL_CARD")
	for key in ["card_id", "kind", "type", "tier", "trend_cost", "name"]:
		if not card.has(key):
			return _fail("SCHEMA_INVALID")
	var kind := str(card["kind"])
	if kind not in VALID_KINDS or str(card["type"]) not in VALID_TYPES:
		return _fail("SCHEMA_INVALID")
	var cost := int(card["trend_cost"])
	if cost < 0 or cost > 5:
		return _fail("SCHEMA_INVALID")
	if kind != "mememom" and str(card["tier"]) != "standard":
		return _fail("SCHEMA_INVALID")
	if kind == "mememom":
		return _validate_mememom(card)
	if kind == "reaction":
		if not card.has("reaction") or not card["reaction"].has("effects"):
			return _fail("SCHEMA_INVALID")
		var reaction_points := _effects_points(card["reaction"]["effects"])
		if reaction_points < 0:
			return _fail("UNKNOWN_EFFECT_PRIMITIVE")
		if reaction_points > _spell_budget(cost):
			return _fail("CARD_BUDGET_EXCEEDED")
		return _ok(reaction_points)
	if not card.has("format"):
		return _fail("SCHEMA_INVALID")
	var format_points := 0
	for effect in card["format"].get("effects", []):
		var p := _effect_points(effect)
		if p < 0:
			return _fail("UNKNOWN_EFFECT_PRIMITIVE")
		format_points += p + 1
	for trigger in card["format"].get("triggers", []):
		var p := _trigger_points(trigger)
		if p < 0:
			return _fail("UNKNOWN_TRIGGER_EVENT")
		format_points += p
	if format_points > _spell_budget(cost):
		return _fail("CARD_BUDGET_EXCEEDED")
	return _ok(format_points)

func _validate_mememom(card: Dictionary) -> Dictionary:
	if not card.has("mememom"):
		return _fail("SCHEMA_INVALID")
	var payload: Dictionary = card["mememom"]
	if not payload.has("hp") or not payload.has("attack"):
		return _fail("SCHEMA_INVALID")
	var cost := int(card["trend_cost"])
	var hp_min := [30, 40, 60, 80, 100][cost - 1] if cost > 0 else 1
	var hp_max := [50, 70, 90, 110, 140][cost - 1] if cost > 0 else 30
	var attack_max := [20, 30, 40, 50, 70][cost - 1] if cost > 0 else 10
	var points_max := [2, 3, 4, 5, 6][cost - 1] if cost > 0 else 1
	if str(card["tier"]) == "headliner":
		hp_max += 20
		attack_max += 10
		points_max += 1
	var hp := int(payload["hp"])
	var attack: Dictionary = payload["attack"]
	var damage := int(attack.get("damage", -1))
	if hp < hp_min or hp > hp_max or damage < 0 or damage > attack_max:
		return _fail("CARD_STAT_OUT_OF_RANGE")
	var points := 0
	for trigger in payload.get("triggers", []):
		var trigger_points := _trigger_points(trigger)
		if trigger_points < 0:
			return _fail("UNKNOWN_TRIGGER_EVENT")
		points += trigger_points
	for ability in payload.get("activated_abilities", []):
		var ability_points := _effects_points(ability.get("effects", []))
		if ability_points < 0:
			return _fail("UNKNOWN_EFFECT_PRIMITIVE")
		if bool(ability.get("once_per_turn", false)):
			ability_points -= 1
		ability_points -= int(ability.get("trend_cost", 0))
		points += max(1, ability_points)
	if points > points_max:
		return _fail("CARD_BUDGET_EXCEEDED")
	return _ok(points)

func _spell_budget(cost: int) -> int:
	return [1, 3, 5, 7, 9, 11][cost]

func _trigger_points(trigger: Dictionary) -> int:
	var event := str(trigger.get("event", ""))
	if event not in VALID_TRIGGERS:
		return -1
	var points := _effects_points(trigger.get("effects", []))
	if points < 0:
		return -1
	points += 1
	if event in ["card_drawn", "damage_dealt", "mememom_ko"]:
		points += 1
	if bool(trigger.get("once_per_turn", false)):
		points -= 1
	return max(1, points)

func _effects_points(effects: Array) -> int:
	var total := 0
	for effect in effects:
		var points := _effect_points(effect)
		if points < 0:
			return -1
		total += points
	return total

func _effect_points(effect: Dictionary) -> int:
	var primitive := str(effect.get("primitive", ""))
	if primitive not in VALID_PRIMITIVES:
		return -1
	var points := 0
	match primitive:
		"deal_damage":
			points = int(ceil(float(effect.get("amount", 0)) / 10.0))
		"heal":
			points = int(ceil(float(effect.get("amount", 0)) / 20.0))
		"draw":
			points = 2 * int(effect.get("amount", 1))
		"gain_trend":
			points = 3 * int(effect.get("amount", 1))
		"modify_stat":
			points = int(ceil(abs(float(effect.get("delta", 0))) / 10.0))
		"force_switch":
			points = 2
		"move_card":
			points = 2 * int(effect.get("amount", 1))
		"set_action_allowance":
			points = 3
	var target: Dictionary = effect.get("target", {})
	if str(target.get("selection", "")) == "random":
		points += 1
	elif str(target.get("selection", "")) == "all":
		points += 2
	return max(1, points)

func _ok(points: int) -> Dictionary:
	return {"ok": true, "code": "OK", "points": points}

func _fail(code: String) -> Dictionary:
	return {"ok": false, "code": code, "points": 0}
