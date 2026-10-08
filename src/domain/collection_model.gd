class_name CollectionModel
extends RefCounted

const ContractLoader = preload("res://src/data/contract_loader.gd")
const DeckValidator = preload("res://src/domain/deck_validator.gd")
const PROFILE_VERSION := "local-1"

var catalog: Dictionary = {}
var owned: Dictionary = {}
var decks: Dictionary = {}
var selected_deck_id: String = ""

func load_definitions(definitions: Array) -> Dictionary:
	var result: Dictionary = ContractLoader.new().catalog_from_definitions(definitions)
	if not result["ok"]:
		return result
	catalog = result["cards"].duplicate(true)
	owned = {}
	decks = {}
	selected_deck_id = ""
	return {"ok": true, "count": catalog.size()}

# For offline Alpha fixtures only: seed is explicitly local, never Canon.
func seed_alpha_starter(quantity: int = 2) -> Dictionary:
	if quantity < 0:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	for edition_id in catalog:
		owned[str(edition_id)] = quantity
	return {"ok": true}

func filter_cards(query: String = "", kind: String = "", type_name: String = "", tier: String = "") -> Array:
	var results: Array = []
	var needle := query.to_lower()
	for edition_id in catalog:
		var card: Dictionary = catalog[edition_id]
		if int(owned.get(edition_id, 0)) < 1:
			continue
		if not needle.is_empty() and needle not in str(card.get("name", "")).to_lower() and needle not in str(card["card_id"]).to_lower():
			continue
		if not kind.is_empty() and str(card["kind"]) != kind:
			continue
		if not type_name.is_empty() and str(card["type"]) != type_name:
			continue
		if not tier.is_empty() and str(card["tier"]) != tier:
			continue
		results.append({"edition_id": str(edition_id), "card_id": str(card["card_id"]), "name": str(card["name"]), "kind": str(card["kind"]), "type": str(card["type"]), "tier": str(card["tier"]), "owned": int(owned[edition_id])})
	results.sort_custom(Callable(self, "_sort_cards"))
	return results

func _sort_cards(a: Dictionary, b: Dictionary) -> bool:
	if str(a["card_id"]) == str(b["card_id"]):
		return str(a["edition_id"]) < str(b["edition_id"])
	return str(a["card_id"]) < str(b["card_id"])

func create_deck(deck_id: String, name: String) -> Dictionary:
	if deck_id.is_empty() or name.is_empty() or name.length() > 80 or decks.has(deck_id):
		return {"ok": false, "code": "SCHEMA_INVALID"}
	decks[deck_id] = {"schema_version": "alpha-0.1", "rules_version": "alpha-0.1", "deck_id": deck_id, "format_id": "alpha-0.1", "name": name, "cards": []}
	return {"ok": true}

func add_card(deck_id: String, edition_id: String) -> Dictionary:
	if not decks.has(deck_id):
		return {"ok": false, "code": "UNKNOWN_DECK"}
	if not catalog.has(edition_id):
		return {"ok": false, "code": "UNKNOWN_CARD_EDITION"}
	var deck: Dictionary = decks[deck_id]
	var used := 0
	for entry in deck["cards"]:
		if str(entry["edition_id"]) == edition_id:
			used += 1
	if used >= int(owned.get(edition_id, 0)):
		return {"ok": false, "code": "CARD_NOT_OWNED"}
	deck["cards"].append({"card_id": str(catalog[edition_id]["card_id"]), "edition_id": edition_id})
	if selected_deck_id == deck_id:
		selected_deck_id = ""
	return {"ok": true, "count": deck["cards"].size()}

func remove_card(deck_id: String, edition_id: String) -> Dictionary:
	if not decks.has(deck_id):
		return {"ok": false, "code": "UNKNOWN_DECK"}
	var deck: Dictionary = decks[deck_id]
	for i in range(deck["cards"].size() - 1, -1, -1):
		if str(deck["cards"][i]["edition_id"]) == edition_id:
			deck["cards"].remove_at(i)
			if selected_deck_id == deck_id:
				selected_deck_id = ""
			return {"ok": true}
	return {"ok": false, "code": "CARD_NOT_IN_DECK"}

func validate(deck_id: String) -> Dictionary:
	if not decks.has(deck_id):
		return {"ok": false, "code": "UNKNOWN_DECK"}
	return DeckValidator.new().validate_deck(decks[deck_id], catalog, owned, true)

func select_deck(deck_id: String) -> Dictionary:
	var verdict: Dictionary = validate(deck_id)
	if not verdict["ok"]:
		return verdict
	selected_deck_id = deck_id
	return {"ok": true, "code": "OK"}

func selected_edition_ids() -> Dictionary:
	var verdict: Dictionary = validate(selected_deck_id)
	if not verdict["ok"]:
		return verdict
	return {"ok": true, "edition_ids": DeckValidator.new().edition_ids(decks[selected_deck_id])}

func export_profile() -> Dictionary:
	var ids: Array = decks.keys()
	ids.sort()
	var ordered_decks: Array = []
	for deck_id in ids:
		ordered_decks.append(decks[deck_id].duplicate(true))
	return {"profile_version": PROFILE_VERSION, "schema_version": "alpha-0.1", "rules_version": "alpha-0.1", "owned": owned.duplicate(true), "decks": ordered_decks, "selected_deck_id": selected_deck_id}

# Atomic in-memory import: validate the full payload before updating any state.
func import_profile(profile: Dictionary) -> Dictionary:
	if str(profile.get("profile_version", "")) != PROFILE_VERSION:
		return {"ok": false, "code": "UNKNOWN_PROFILE_VERSION"}
	if str(profile.get("schema_version", "")) != "alpha-0.1":
		return {"ok": false, "code": "UNKNOWN_SCHEMA_VERSION"}
	if str(profile.get("rules_version", "")) != "alpha-0.1":
		return {"ok": false, "code": "RULES_VERSION_MISMATCH"}
	if profile.size() != 6 or typeof(profile.get("owned", null)) != TYPE_DICTIONARY or typeof(profile.get("decks", null)) != TYPE_ARRAY or typeof(profile.get("selected_deck_id", null)) != TYPE_STRING:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	var next_owned: Dictionary = profile["owned"].duplicate(true)
	for edition_id in next_owned:
		var quantity = next_owned[edition_id]
		if not catalog.has(edition_id) or typeof(quantity) not in [TYPE_INT, TYPE_FLOAT] or float(quantity) < 0.0 or floor(float(quantity)) != float(quantity):
			return {"ok": false, "code": "SCHEMA_INVALID"}
		next_owned[edition_id] = int(quantity)
	var next_decks: Dictionary = {}
	for raw in profile["decks"]:
		if typeof(raw) != TYPE_DICTIONARY:
			return {"ok": false, "code": "SCHEMA_INVALID"}
		var deck: Dictionary = raw
		var deck_id := str(deck.get("deck_id", ""))
		if deck_id.is_empty() or next_decks.has(deck_id) or str(deck.get("schema_version", "")) != "alpha-0.1" or str(deck.get("rules_version", "")) != "alpha-0.1" or str(deck.get("format_id", "")) != "alpha-0.1" or typeof(deck.get("cards", null)) != TYPE_ARRAY:
			return {"ok": false, "code": "SCHEMA_INVALID"}
		if deck.size() != 6 or typeof(deck.get("name", null)) != TYPE_STRING or str(deck["name"]).is_empty() or str(deck["name"]).length() > 80:
			return {"ok": false, "code": "SCHEMA_INVALID"}
		var uses: Dictionary = {}
		for raw_ref in deck["cards"]:
			if typeof(raw_ref) != TYPE_DICTIONARY:
				return {"ok": false, "code": "SCHEMA_INVALID"}
			var ref: Dictionary = raw_ref
			if ref.size() != 2 or not ref.has("edition_id") or not ref.has("card_id"):
				return {"ok": false, "code": "SCHEMA_INVALID"}
			var edition_id := str(ref["edition_id"])
			if not catalog.has(edition_id) or str(catalog[edition_id]["card_id"]) != str(ref["card_id"]):
				return {"ok": false, "code": "UNKNOWN_CARD_EDITION"}
			uses[edition_id] = int(uses.get(edition_id, 0)) + 1
			if int(uses[edition_id]) > int(next_owned.get(edition_id, 0)):
				return {"ok": false, "code": "CARD_NOT_OWNED"}
		next_decks[deck_id] = deck.duplicate(true)
	var next_selected := str(profile["selected_deck_id"])
	if not next_selected.is_empty():
		if not next_decks.has(next_selected):
			return {"ok": false, "code": "UNKNOWN_DECK"}
		var verdict: Dictionary = DeckValidator.new().validate_deck(next_decks[next_selected], catalog, next_owned, true)
		if not verdict["ok"]:
			return verdict
	owned = next_owned
	decks = next_decks
	selected_deck_id = next_selected
	return {"ok": true, "code": "OK"}
