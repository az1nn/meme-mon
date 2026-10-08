extends Node

const DuelEngine = preload("res://src/domain/duel_engine.gd")
const DeterministicBot = preload("res://src/domain/bot.gd")
const CollectionModel = preload("res://src/domain/collection_model.gd")
const CollectionStore = preload("res://src/data/collection_store.gd")
const DeckValidator = preload("res://src/domain/deck_validator.gd")
const PROFILE_PATH := "user://mememom/profile.json"

var engine = DuelEngine.new()
var bot = DeterministicBot.new("p2")
var status_label: Label
var event_label: Label

func _ready() -> void:
	_build_ui()
	var load_result: Dictionary = engine.load_card_file("res://data/cards/alpha-test-cards.json")
	if not load_result["ok"]:
		status_label.text = "Card load blocked: %s" % load_result["code"]
		push_error(status_label.text)
		return
	var deck: Array = _demo_deck()
	var draft_refs: Array = []
	for edition_id in deck:
		draft_refs.append({"card_id": str(engine.cards[edition_id]["card_id"]), "edition_id": edition_id})
	var fallback: Dictionary = {"schema_version": "alpha-0.1", "rules_version": "alpha-0.1", "deck_id": "local-demo", "format_id": "alpha-0.1", "cards": draft_refs}
	var legal: Dictionary = DeckValidator.new().validate_deck(fallback, engine.cards)
	if not legal["ok"]:
		status_label.text = "Demo deck rejected: %s" % legal["code"]
		push_error(status_label.text)
		return
	if FileAccess.file_exists(PROFILE_PATH):
		var stored: Dictionary = CollectionStore.new().load_profile(PROFILE_PATH)
		if not stored["ok"]:
			status_label.text = "Local profile rejected: %s" % stored["code"]
			return
		var model = CollectionModel.new()
		var fixture = JSON.parse_string(FileAccess.get_file_as_string("res://data/cards/alpha-test-cards.json"))
		var catalog_result: Dictionary = model.load_definitions(fixture["cards"])
		if not catalog_result["ok"]:
			status_label.text = "Catalog rejected: %s" % catalog_result["code"]
			return
		var imported: Dictionary = model.import_profile(stored["profile"])
		if not imported["ok"]:
			status_label.text = "Profile rejected: %s" % imported["code"]
			return
		if not model.selected_deck_id.is_empty():
			var selected: Dictionary = model.selected_edition_ids()
			if not selected["ok"]:
				status_label.text = "Selected deck rejected: %s" % selected["code"]
				return
			deck = selected["edition_ids"]
	var started: Dictionary = engine.new_match(123456789, deck, _demo_deck(), "p1")
	if not started["ok"]:
		status_label.text = "Match start blocked: %s" % started["code"]
		push_error(status_label.text)
		return
	_render()

func _build_ui() -> void:
	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var title: Label = Label.new()
	title.text = "MEMEMOM — MM-04 deterministic local duel"
	title.add_theme_font_size_override("font_size", 24)
	root.add_child(title)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)
	var actions: HBoxContainer = HBoxContainer.new()
	root.add_child(actions)
	for spec in [["Attack", "_on_attack"], ["Play first card", "_on_play"], ["Pass", "_on_pass"], ["Run bot-vs-bot", "_on_autorun"], ["Collection / Deckbuilder", "_on_collection"]]:
		var button: Button = Button.new()
		button.text = spec[0]
		button.pressed.connect(Callable(self, spec[1]))
		actions.add_child(button)
	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(event_label)

func _intent(kind: String, payload: Dictionary = {}) -> Dictionary:
	return {
		"schema_version": "alpha-0.1",
		"rules_version": "alpha-0.1",
		"intent_id": "human.p1.%d.%s" % [int(engine.state["next_event_seq"]), kind],
		"match_id": str(engine.state["match_id"]),
		"player_id": "p1",
		"expected_event_seq": int(engine.state["next_event_seq"]),
		"kind": kind,
		"payload": payload
	}

func _on_collection() -> void:
	get_tree().change_scene_to_file("res://scenes/Collection.tscn")

func _on_attack() -> void:
	if engine.state.is_empty():
		return
	engine.apply_intent(_intent("attack"))
	_drive_bot_if_needed()
	_render()

func _on_play() -> void:
	if engine.state.is_empty():
		return
	var p: Dictionary = engine.state["players"]["p1"]
	if not p["hand"].is_empty():
		engine.apply_intent(_intent("play_card", {"hand_index": 0}))
	_drive_bot_if_needed()
	_render()

func _on_pass() -> void:
	if engine.state.is_empty():
		return
	engine.apply_intent(_intent("pass"))
	_drive_bot_if_needed()
	_render()

func _on_autorun() -> void:
	if engine.state.is_empty():
		return
	var human_bot = DeterministicBot.new("p1")
	var guard: int = 0
	while engine.state["terminal"] == null and guard < 500:
		var current: String = str(engine.state["active_player_id"])
		var actor = human_bot if current == "p1" else bot
		var result: Dictionary = engine.apply_intent(actor.choose_intent(engine))
		if not result["ok"]:
			push_error("Bot intent rejected: %s" % result)
			break
		guard += 1
	_render()

func _drive_bot_if_needed() -> void:
	var guard: int = 0
	while engine.state["terminal"] == null and (str(engine.state["active_player_id"]) == "p2" or (not engine.state["pending_replacements"].is_empty() and str(engine.state["pending_replacements"][0]) == "p2")) and guard < 20:
		var result: Dictionary = engine.apply_intent(bot.choose_intent(engine))
		if not result["ok"]:
			break
		guard += 1

func _render() -> void:
	if status_label == null:
		return
	var s: Dictionary = engine.state
	var p1: Dictionary = s["players"]["p1"]
	var p2: Dictionary = s["players"]["p2"]
	status_label.text = "Turn %s | phase %s | active %s\nP1 Hype %s Trend %s/%s Hand %s Queue %s\nP2 Hype %s Trend %s/%s Hand %s Queue %s\nTerminal: %s" % [
		s["turn_number"], s["phase"], s["active_player_id"],
		p1["hype"], p1["trend"]["current"], p1["trend"]["cap"], p1["hand"].size(), p1["queue"].size(),
		p2["hype"], p2["trend"]["current"], p2["trend"]["cap"], p2["hand"].size(), p2["queue"].size(),
		str(s["terminal"])
	]
	var recent: Array = engine.events.slice(max(0, engine.events.size() - 8))
	event_label.text = "Recent events:\n" + JSON.stringify(recent, "  ")

func _demo_deck() -> Array:
	var ids: Array = engine.cards.keys()
	ids.sort()
	var deck: Array = []
	for id in ids:
		deck.append(id)
	for i in range(10):
		deck.append(ids[i])
	return deck
