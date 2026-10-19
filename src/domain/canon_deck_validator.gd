class_name CanonDeckValidator
extends RefCounted

const CardValidator = preload("res://src/domain/card_validator.gd")

# This validator is deliberately separate from the local Alpha collection.
# It accepts only MM-08 CanonModel resolutions and therefore cannot turn a
# Sandbox record or moderation status into a competitive deck card.
func validate(deck: Dictionary, canon) -> Dictionary:
	if typeof(deck.get("cards", null)) != TYPE_ARRAY or str(deck.get("format_id", "")).is_empty() or str(deck.get("rules_version", "")) != "alpha-0.1":
		return _fail("SCHEMA_INVALID")
	var refs: Array = deck["cards"]
	if refs.size() != 30:
		return _fail("DECK_SIZE_INVALID")
	var copies: Dictionary = {}
	var mememom_count := 0
	var headliner_count := 0
	var cards: Array = []
	for raw in refs:
		if typeof(raw) != TYPE_DICTIONARY or raw.size() != 2:
			return _fail("SCHEMA_INVALID")
		var card_id := str(raw.get("card_id", ""))
		var edition_id := str(raw.get("edition_id", ""))
		var legal: Dictionary = canon.resolve_legality(str(deck["format_id"]), card_id, edition_id, str(deck["rules_version"]))
		if not legal["ok"]:
			return _fail(str(legal["code"]))
		var card: Dictionary = legal["edition"]["card"]
		if not CardValidator.new().validate_card(card)["ok"]:
			return _fail("FORMAT_ILLEGAL_CARD")
		copies[card_id] = int(copies.get(card_id, 0)) + 1
		if int(copies[card_id]) > 2:
			return _fail("DECK_COPY_LIMIT")
		if str(card["kind"]) == "mememom":
			mememom_count += 1
		if str(card["tier"]) == "headliner":
			headliner_count += 1
			if headliner_count > 2:
				return _fail("DECK_HEADLINER_LIMIT")
		cards.append(card)
	if mememom_count < 8:
		return _fail("DECK_MIN_MEMEMOM")
	return {"ok": true, "cards": cards, "edition_ids": refs.map(func(item): return str(item["edition_id"]))}

func _fail(code: String) -> Dictionary:
	return {"ok": false, "code": code}
