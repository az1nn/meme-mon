extends Node

const DuelEngine = preload("res://src/domain/duel_engine.gd")
const DeterministicBot = preload("res://src/domain/bot.gd")

var engine = DuelEngine.new()
var bot = DeterministicBot.new("p2")
var status_label: Label
var event_label: Label

func _ready() -> void:
	var load_result: Dictionary = engine.load_card_file("res://data/cards/alpha-test-cards.json")
	if not load_result["ok"]:
		push_error("Card load failed: %s" % load_result)
		return
	var deck: Array = _demo_deck()
	var started: Dictionary = engine.new_match(123456789, deck, deck, "p1")
	if not started["ok"]:
		push_error("Match start failed: %s" % started)
		return
	_build_ui()
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
	for spec in [["Attack", "_on_attack"], ["Play first card", "_on_play"], ["Pass", "_on_pass"], ["Run bot-vs-bot", "_on_autorun"]]:
		var button: Button = Button.new()
		button.text = spec[0]
		button.pressed.connect(Callable(self, spec[1]))
		actions.add_child(button)
	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(event_label)

func _intent(kind: String, payload: Dictionary = {}) -> Dictionary:
	return {
		"match_id": "local",
		"player_id": "p1",
		"expected_event_seq": int(engine.state["next_event_seq"]),
		"kind": kind,
		"payload": payload
	}

func _on_attack() -> void:
	engine.apply_intent(_intent("attack"))
	_drive_bot_if_needed()
	_render()

func _on_play() -> void:
	var p: Dictionary = engine.state["players"]["p1"]
	if not p["hand"].is_empty():
		engine.apply_intent(_intent("play_card", {"hand_index": 0}))
	_drive_bot_if_needed()
	_render()

func _on_pass() -> void:
	engine.apply_intent(_intent("pass"))
	_drive_bot_if_needed()
	_render()

func _on_autorun() -> void:
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
