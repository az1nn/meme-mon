extends Node

const DuelEngine = preload("res://src/domain/duel_engine.gd")
const DeterministicBot = preload("res://src/domain/bot.gd")
const CollectionModel = preload("res://src/domain/collection_model.gd")
const CollectionStore = preload("res://src/data/collection_store.gd")
const DeckValidator = preload("res://src/domain/deck_validator.gd")
const PROFILE_PATH := "user://mememom/profile.json"
const NavigationShell = preload("res://src/presentation/navigation_shell.gd")
const DuelHud = preload("res://src/presentation/duel_hud.gd")

var engine = DuelEngine.new()
var bot = DeterministicBot.new("p2")
var status_label: Label
var event_label: Label
var duel_hud

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
	var shell = NavigationShell.new()
	add_child(shell)
	shell.route_selected.connect(Callable(self, "_on_global_route"))
	var root: VBoxContainer = shell.content

	var intro := Label.new()
	intro.text = "⚡ ARENA DE DUELO"
	intro.add_theme_color_override("font_color", NavigationShell.INK)
	intro.add_theme_font_size_override("font_size", 24)
	root.add_child(intro)

	duel_hud = DuelHud.new()
	duel_hud.name = "DuelHud"
	root.add_child(duel_hud)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", NavigationShell.INK)
	status_label.visible = false
	root.add_child(status_label)

	var buttons_title := Label.new()
	buttons_title.text = "SUAS AÇÕES"
	buttons_title.add_theme_color_override("font_color", NavigationShell.INK)
	buttons_title.add_theme_font_size_override("font_size", 17)
	root.add_child(buttons_title)
	var actions := HFlowContainer.new()
	actions.add_theme_constant_override("h_separation", 9)
	actions.add_theme_constant_override("v_separation", 9)
	root.add_child(actions)
	for spec in [["ATACAR", "_on_attack"], ["USAR CARTA", "_on_play"], ["PASSAR", "_on_pass"], ["AUTO DUELO", "_on_autorun"]]:
		var button := Button.new()
		button.text = spec[0]
		button.custom_minimum_size = Vector2(132, 56)
		button.focus_mode = Control.FOCUS_ALL
		button.add_theme_color_override("font_color", NavigationShell.INK)
		var skin := StyleBoxFlat.new()
		skin.bg_color = NavigationShell.CORAL if spec[1] == "_on_attack" else NavigationShell.YELLOW
		skin.set_corner_radius_all(14)
		skin.content_margin_left = 12.0
		skin.content_margin_right = 12.0
		skin.content_margin_top = 10.0
		skin.content_margin_bottom = 10.0
		button.add_theme_stylebox_override("normal", skin)
		button.pressed.connect(Callable(self, spec[1]))
		actions.add_child(button)

	var history_title := Label.new()
	history_title.text = "HISTÓRICO DA PARTIDA"
	history_title.add_theme_color_override("font_color", NavigationShell.INK)
	root.add_child(history_title)
	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.add_theme_color_override("font_color", NavigationShell.INK)
	event_label.add_theme_font_size_override("font_size", 12)
	root.add_child(event_label)

func _on_global_route(route: String) -> void:
	if route == "collection":
		_on_collection()

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
	if status_label == null or duel_hud == null or engine.state.is_empty():
		return
	duel_hud.update_from_match(engine.state, engine.cards)
	status_label.visible = false
	var recent: Array = engine.events.slice(maxi(0, engine.events.size() - 5))
	var messages := PackedStringArray()
	for event in recent:
		messages.append(str(event.get("event_type", "Evento")).replace("_", " ").capitalize())
	event_label.text = "ÚLTIMOS EVENTOS: " + (" • ".join(messages) if not messages.is_empty() else "Nenhum evento")

func _demo_deck() -> Array:
	var ids: Array = engine.cards.keys()
	ids.sort()
	var deck: Array = []
	for id in ids:
		deck.append(id)
	for i in range(10):
		deck.append(ids[i])
	return deck
