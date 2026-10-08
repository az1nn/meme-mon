class_name DeckValidator
extends RefCounted

const CardValidator = preload("res://src/domain/card_validator.gd")
const SCHEMA_VERSION := "alpha-0.1"
const RULES_VERSION := "alpha-0.1"
const FORMAT_ID := "alpha-0.1"

# MM-03 is the source of deck legality. A draft may be incomplete; only
# validate_deck() marks a complete deck fit for a competitive match.
func validate_deck(deck: Dictionary, catalog: Dictionary, owned: Dictionary = {}, enforce_ownership: bool = false) -> Dictionary:
	if str(deck.get("schema_version", "")) != SCHEMA_VERSION:
		return _fail("UNKNOWN_SCHEMA_VERSION")
	if str(deck.get("rules_version", "")) != RULES_VERSION:
		return _fail("RULES_VERSION_MISMATCH")
	if typeof(deck.get("deck_id", null)) != TYPE_STRING or str(deck["deck_id"]).is_empty():
		return _fail("SCHEMA_INVALID")
	if typeof(deck.get("format_id", null)) != TYPE_STRING:
		return _fail("SCHEMA_INVALID")
	if str(deck["format_id"]) != FORMAT_ID:
		return _fail("FORMAT_ILLEGAL_CARD")
	if deck.has("name") and (typeof(deck["name"]) != TYPE_STRING or str(deck["name"]).is_empty() or str(deck["name"]).length() > 80):
		return _fail("SCHEMA_INVALID")
	for field in deck.keys():
		if field not in ["schema_version", "rules_version", "deck_id", "format_id", "name", "cards"]:
			return _fail("SCHEMA_INVALID")
	if typeof(deck.get("cards", null)) != TYPE_ARRAY:
		return _fail("SCHEMA_INVALID")
	var refs: Array = deck["cards"]
	if refs.size() != 30:
		return _fail("DECK_SIZE_INVALID")

	var copies: Dictionary = {}
	var owned_uses: Dictionary = {}
	var mememom_count := 0
	var headliner_count := 0
	var validator = CardValidator.new()
	for raw_ref in refs:
		if typeof(raw_ref) != TYPE_DICTIONARY:
			return _fail("SCHEMA_INVALID")
		var entry: Dictionary = raw_ref
		if entry.size() != 2 or not entry.has("card_id") or not entry.has("edition_id"):
			return _fail("SCHEMA_INVALID")
		if typeof(entry["card_id"]) != TYPE_STRING or typeof(entry["edition_id"]) != TYPE_STRING:
			return _fail("SCHEMA_INVALID")
		var card_id := str(entry["card_id"])
		var edition_id := str(entry["edition_id"])
		if card_id.length() < 3 or edition_id.length() < 3:
			return _fail("SCHEMA_INVALID")
		if not catalog.has(edition_id):
			return _fail("UNKNOWN_CARD_EDITION")
		var card: Dictionary = catalog[edition_id]
		if str(card.get("card_id", "")) != card_id or str(card.get("edition_id", "")) != edition_id:
			return _fail("UNKNOWN_CARD_EDITION")
		if str(card.get("rules_version", "")) != RULES_VERSION:
			return _fail("FORMAT_ILLEGAL_CARD")
		var verdict: Dictionary = validator.validate_card(card)
		if not verdict["ok"]:
			return _fail(str(verdict["code"]))
		copies[card_id] = int(copies.get(card_id, 0)) + 1
		owned_uses[edition_id] = int(owned_uses.get(edition_id, 0)) + 1
		if int(copies[card_id]) > 2:
			return _fail("DECK_COPY_LIMIT")
		if str(card["kind"]) == "mememom":
			mememom_count += 1
		if str(card["tier"]) == "headliner":
			headliner_count += 1
			if headliner_count > 2:
				return _fail("DECK_HEADLINER_LIMIT")

	if mememom_count < 8:
		return _fail("DECK_MIN_MEMEMOM")
	if enforce_ownership:
		for edition_id in owned_uses:
			if int(owned.get(edition_id, 0)) < int(owned_uses[edition_id]):
				return _fail("CARD_NOT_OWNED")
	return {"ok": true, "code": "OK", "size": refs.size(), "mememom": mememom_count, "headliners": headliner_count}

func edition_ids(deck: Dictionary) -> Array:
	var ids: Array = []
	for ref in deck.get("cards", []):
		ids.append(str(ref["edition_id"]))
	return ids

func _fail(code: String) -> Dictionary:
	return {"ok": false, "code": code}
