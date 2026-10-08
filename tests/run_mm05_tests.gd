extends SceneTree

const CollectionModel = preload("res://src/domain/collection_model.gd")
const DeckValidator = preload("res://src/domain/deck_validator.gd")
const CollectionStore = preload("res://src/data/collection_store.gd")

var checks: int = 0
var failures: Array = []

func _init() -> void:
	call_deferred("_run")

func _assert(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _run() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/cards/alpha-test-cards.json"))
	var model = CollectionModel.new()
	var result: Dictionary = model.load_definitions(data["cards"])
	_assert(result["ok"] and result["count"] == 20, "load 20 MM-03 test cards")
	_assert(model.seed_alpha_starter(2)["ok"], "seed explicit local collection")
	_assert(model.filter_cards().size() == 20, "browse all owned cards")
	var search: Array = model.filter_cards("TEST MEMEMOM", "mememom", "classic", "standard")
	_assert(search.size() > 0, "case-insensitive combined filters")
	var stable: Array = model.filter_cards()
	_assert(JSON.stringify(stable) == JSON.stringify(model.filter_cards()), "filter stable ordering")
	for i in range(1, stable.size()):
		_assert(str(stable[i - 1]["card_id"]) <= str(stable[i]["card_id"]), "sort by card_id")

	_assert(model.create_deck("alpha", "Starter 30")["ok"], "create deck")
	var ids: Array = model.catalog.keys()
	ids.sort()
	for edition_id in ids:
		_assert(model.add_card("alpha", edition_id)["ok"], "add each owned edition")
	for i in range(10):
		_assert(model.add_card("alpha", ids[i])["ok"], "add second owned copy")
	_assert(model.decks["alpha"]["cards"].size() == 30, "30-card deck assembled")
	var validator = DeckValidator.new()
	var legal: Dictionary = model.validate("alpha")
	_assert(legal["ok"] and legal["size"] == 30 and legal["mememom"] >= 8, "MM-03 legal deck")
	_assert(model.select_deck("alpha")["ok"], "select legal deck")
	_assert(model.selected_edition_ids()["edition_ids"].size() == 30, "selected deck returns edition IDs")

	var valid: Dictionary = model.decks["alpha"].duplicate(true)
	var short: Dictionary = valid.duplicate(true)
	short["cards"].pop_back()
	_assert(validator.validate_deck(short, model.catalog)["code"] == "DECK_SIZE_INVALID", "29-card deck rejected")
	var long_deck: Dictionary = valid.duplicate(true)
	long_deck["cards"].append(valid["cards"][0].duplicate(true))
	_assert(validator.validate_deck(long_deck, model.catalog)["code"] == "DECK_SIZE_INVALID", "31-card deck rejected")
	var copy_over: Dictionary = valid.duplicate(true)
	copy_over["cards"][29] = valid["cards"][0].duplicate(true)
	_assert(validator.validate_deck(copy_over, model.catalog)["code"] == "DECK_COPY_LIMIT", "third copy by card_id rejected")
	var bad_format: Dictionary = valid.duplicate(true)
	bad_format["format_id"] = "other"
	_assert(validator.validate_deck(bad_format, model.catalog)["code"] == "FORMAT_ILLEGAL_CARD", "unknown format rejected")
	var bad_schema: Dictionary = valid.duplicate(true)
	bad_schema["schema_version"] = "future"
	_assert(validator.validate_deck(bad_schema, model.catalog)["code"] == "UNKNOWN_SCHEMA_VERSION", "unknown schema rejected")
	var bad_rules: Dictionary = valid.duplicate(true)
	bad_rules["rules_version"] = "future"
	_assert(validator.validate_deck(bad_rules, model.catalog)["code"] == "RULES_VERSION_MISMATCH", "unknown rules rejected")
	var missing: Dictionary = valid.duplicate(true)
	missing["cards"][0]["edition_id"] = "unknown@future"
	_assert(validator.validate_deck(missing, model.catalog)["code"] == "UNKNOWN_CARD_EDITION", "unknown edition rejected")
	var wrong_card: Dictionary = valid.duplicate(true)
	wrong_card["cards"][0]["card_id"] = "wrong.card"
	_assert(validator.validate_deck(wrong_card, model.catalog)["code"] == "UNKNOWN_CARD_EDITION", "mismatched card and edition rejected")
	var not_owned: Dictionary = model.owned.duplicate(true)
	not_owned[ids[0]] = 0
	_assert(validator.validate_deck(valid, model.catalog, not_owned, true)["code"] == "CARD_NOT_OWNED", "insufficient owned copies rejected")
	var no_inventory = CollectionModel.new()
	no_inventory.load_definitions(data["cards"])
	no_inventory.create_deck("x", "Empty")
	_assert(no_inventory.add_card("x", ids[0])["code"] == "CARD_NOT_OWNED", "draft cannot add unowned cards")
	_assert(model.add_card("alpha", ids[0])["code"] == "CARD_NOT_OWNED", "draft cannot exceed owned amount")

	# Copy limit is per card_id even when a logical card has multiple editions.
	var edition_catalog: Dictionary = model.catalog.duplicate(true)
	var variant_card: Dictionary = edition_catalog[ids[0]].duplicate(true)
	var variant_id := str(ids[0]) + "-alternate"
	variant_card["edition_id"] = variant_id
	edition_catalog[variant_id] = variant_card
	var cross: Dictionary = valid.duplicate(true)
	cross["cards"][29] = {"card_id": variant_card["card_id"], "edition_id": variant_id}
	_assert(validator.validate_deck(cross, edition_catalog)["code"] == "DECK_COPY_LIMIT", "cross-edition copy ceiling")

	# Headliner aggregate across distinct card IDs, independent of copy limit.
	var head_id := "test.mememom.12@alpha.1"
	var head_catalog: Dictionary = model.catalog.duplicate(true)
	var too_many_heads: Dictionary = valid.duplicate(true)
	for idx in [0, 1]:
		var card: Dictionary = head_catalog[head_id].duplicate(true)
		card["card_id"] = "test.extra.headliner.%d" % idx
		card["edition_id"] = card["card_id"] + "@alpha.1"
		head_catalog[card["edition_id"]] = card
		too_many_heads["cards"][idx] = {"card_id": card["card_id"], "edition_id": card["edition_id"]}
	_assert(validator.validate_deck(too_many_heads, head_catalog)["code"] == "DECK_HEADLINER_LIMIT", "third distinct Headliner rejected")

	# Fewer than eight Mememom (all other constraints otherwise legal).
	var reactions: Array = []
	var memes: Array = []
	for ref in valid["cards"]:
		if str(model.catalog[ref["edition_id"]]["kind"]) == "mememom":
			memes.append(ref.duplicate(true))
		else:
			reactions.append(ref.duplicate(true))
	var min_catalog: Dictionary = model.catalog.duplicate(true)
	var low_meme: Dictionary = valid.duplicate(true)
	var revised: Array = memes.slice(0, 7)
	revised.append_array(reactions)
	var template: Dictionary = model.catalog["test.reaction.draw@alpha.1"].duplicate(true)
	while revised.size() < 30:
		var clone: Dictionary = template.duplicate(true)
		clone["card_id"] = "test.reaction.extra.%d" % revised.size()
		clone["edition_id"] = clone["card_id"] + "@alpha.1"
		min_catalog[clone["edition_id"]] = clone
		revised.append({"card_id": clone["card_id"], "edition_id": clone["edition_id"]})
	low_meme["cards"] = revised
	_assert(validator.validate_deck(low_meme, min_catalog)["code"] == "DECK_MIN_MEMEMOM", "minimum eight Mememom enforced")

	_assert(model.create_deck("secondary", "Second deck")["ok"], "create second named deck")
	_assert(model.add_card("secondary", ids[0])["ok"], "different deck may reuse owned cards")
	var store = CollectionStore.new()
	var path := "user://mm05-tests/profile.json"
	var profile: Dictionary = model.export_profile()
	var write: Dictionary = store.save_profile(path, profile)
	_assert(write["ok"], "save local versioned profile")
	var loaded: Dictionary = store.load_profile(path)
	_assert(loaded["ok"], "load local profile")
	var other = CollectionModel.new()
	other.load_definitions(data["cards"])
	_assert(other.import_profile(loaded["profile"])["ok"], "import verified profile")
	_assert(other.decks.size() == 2, "multiple named decks survive persistence")
	_assert(JSON.stringify(other.export_profile()) == JSON.stringify(profile), "profile round-trip deterministic")
	_assert(other.selected_edition_ids()["ok"], "selected deck survives restart")
	var before := JSON.stringify(other.export_profile())
	var future: Dictionary = loaded["profile"].duplicate(true)
	future["profile_version"] = "local-2"
	_assert(other.import_profile(future)["code"] == "UNKNOWN_PROFILE_VERSION", "unsupported profile rejected")
	_assert(JSON.stringify(other.export_profile()) == before, "rejected import is atomic")
	var broken: Dictionary = loaded["profile"].duplicate(true)
	broken["decks"][0]["cards"][0]["edition_id"] = "not-an-edition"
	_assert(other.import_profile(broken)["code"] == "UNKNOWN_CARD_EDITION", "invalid saved edition rejected")
	_assert(JSON.stringify(other.export_profile()) == before, "rejected bad deck does not mutate state")
	_assert(model.remove_card("alpha", ids[0])["ok"], "remove drafted edition")
	_assert(model.selected_deck_id.is_empty(), "remove invalidates previous selection")
	_assert(model.select_deck("alpha")["code"] == "DECK_SIZE_INVALID", "edited deck must be legal to reselect")
	_assert(model.add_card("alpha", ids[0])["ok"], "restore missing card to draft")
	_assert(model.selected_deck_id.is_empty(), "add cannot silently restore selection")
	_assert(model.select_deck("alpha")["ok"], "repaired deck can be selected")

	var temp = FileAccess.open(path, FileAccess.WRITE)
	if temp != null:
		temp.store_string("{bad json")
		temp.close()
	var corrupt: Dictionary = store.load_profile(path)
	_assert(corrupt["code"] == "SCHEMA_INVALID", "corrupt JSON fails closed")
	_assert(store.save_profile(path, profile)["code"] == "PERSISTED_PROFILE_INVALID", "cannot overwrite corrupt profile")
	_assert(FileAccess.get_file_as_string(path) == "{bad json", "corrupt profile left untouched")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	print("MM-05 checks: %d, failures: %d" % [checks, failures.size()])
	for error in failures:
		push_error(error)
	if failures.is_empty():
		print("MM-05 HEADLESS GATES PASS")
		quit(0)
	else:
		quit(1)
