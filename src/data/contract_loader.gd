class_name ContractLoader
extends RefCounted

const CardValidator = preload("res://src/domain/card_validator.gd")

const SCHEMA_VERSION := "alpha-0.1"
const RULES_VERSION := "alpha-0.1"
const RNG_VERSION := "xorshift32-v1"

func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "code": "FILE_NOT_FOUND"}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	return {"ok": true, "data": parsed}

func catalog_from_definitions(definitions: Array) -> Dictionary:
	var validator = CardValidator.new()
	var loaded: Dictionary = {}
	for raw in definitions:
		if typeof(raw) != TYPE_DICTIONARY:
			return {"ok": false, "code": "SCHEMA_INVALID"}
		var card: Dictionary = raw
		var verdict: Dictionary = validator.validate_card(card)
		if not verdict["ok"]:
			return {"ok": false, "code": verdict["code"], "card_id": card.get("card_id", "")}
		if not card.has("edition_id"):
			return {"ok": false, "code": "UNKNOWN_CARD_EDITION"}
		loaded[str(card["edition_id"])] = card.duplicate(true)
	return {"ok": true, "count": loaded.size(), "cards": loaded}

func load_card_catalog(path: String) -> Dictionary:
	var parsed: Dictionary = load_json(path)
	if not parsed["ok"]:
		return parsed
	var data: Dictionary = parsed["data"]
	if str(data.get("schema_version", "")) != SCHEMA_VERSION:
		return {"ok": false, "code": "UNKNOWN_SCHEMA_VERSION"}
	if str(data.get("rules_version", "")) != RULES_VERSION:
		return {"ok": false, "code": "RULES_VERSION_MISMATCH"}
	if not data.has("cards") or typeof(data["cards"]) != TYPE_ARRAY:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	return catalog_from_definitions(data["cards"])

func validate_card_fixture(path: String) -> Dictionary:
	var parsed: Dictionary = load_json(path)
	if not parsed["ok"]:
		return parsed
	var validator = CardValidator.new()
	var verdict: Dictionary = validator.validate_card(parsed["data"])
	if not verdict["ok"]:
		return verdict
	return {"ok": true, "card": parsed["data"]}

func validate_match_state_file(path: String) -> Dictionary:
	var parsed: Dictionary = load_json(path)
	if not parsed["ok"]:
		return parsed
	return validate_match_state_data(parsed["data"])

func validate_match_state_data(data: Dictionary) -> Dictionary:
	if str(data.get("schema_version", "")) != SCHEMA_VERSION:
		return {"ok": false, "code": "UNKNOWN_SCHEMA_VERSION"}
	if str(data.get("rules_version", "")) != RULES_VERSION:
		return {"ok": false, "code": "RULES_VERSION_MISMATCH"}
	if str(data.get("rng_version", "")) != RNG_VERSION:
		return {"ok": false, "code": "UNKNOWN_RNG_VERSION"}
	for key in ["match_id", "match_seed", "rng_state", "rng_index", "turn_number", "phase", "active_player_id", "players", "pending_triggers", "next_event_seq", "terminal"]:
		if not data.has(key):
			return {"ok": false, "code": "SCHEMA_INVALID"}
	if str(data["match_id"]).is_empty():
		return {"ok": false, "code": "SCHEMA_INVALID"}
	if int(data["turn_number"]) < 1 or int(data["next_event_seq"]) < 1 or int(data["rng_index"]) < 0:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	if str(data["phase"]) not in ["setup", "start", "draw", "main", "end"]:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	if typeof(data["players"]) != TYPE_ARRAY or data["players"].size() != 2:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	for player in data["players"]:
		if typeof(player) != TYPE_DICTIONARY:
			return {"ok": false, "code": "SCHEMA_INVALID"}
		for key in ["player_id", "deck", "hand", "active", "queue", "archive", "format", "hype", "trend", "turn_markers"]:
			if not player.has(key):
				return {"ok": false, "code": "SCHEMA_INVALID"}
		if player["queue"].size() > 3:
			return {"ok": false, "code": "SCHEMA_INVALID"}
	return {"ok": true}
