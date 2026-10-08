extends SceneTree
## ART-002 wave 2: only tests Godot-rendered data bindings; not image approval.

const DuelEngine = preload("res://src/domain/duel_engine.gd")
const DuelHud = preload("res://src/presentation/duel_hud.gd")

var checks: int = 0
var failures: Array = []

func _init() -> void:
	call_deferred("_run")

func _check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)

func _run() -> void:
	var engine = DuelEngine.new()
	var loaded: Dictionary = engine.load_card_file("res://data/cards/alpha-test-cards.json")
	_check(bool(loaded["ok"]), "Alpha fixture loaded")
	if not loaded["ok"]:
		_finish()
		return
	var deck: Array = engine.cards.keys()
	deck.sort()
	for i in range(10):
		deck.append(deck[i])
	var started: Dictionary = engine.new_match(123456789, deck, deck, "p1")
	_check(bool(started["ok"]), "deterministic match created")
	if not started["ok"]:
		_finish()
		return

	var hud = DuelHud.new()
	get_root().add_child(hud)
	var before: String = engine.normalized_snapshot()
	hud.update_from_match(engine.state, engine.cards)
	_check(engine.normalized_snapshot() == before, "HUD may not mutate authoritative domain state")
	_check(hud.turn_label.text.contains("TURNO 1"), "turn bound from state")
	var mine: Dictionary = engine.state["players"]["p1"]
	var enemy: Dictionary = engine.state["players"]["p2"]
	_check(hud.player_summary.text.contains("Hype %d/5" % int(mine["hype"])), "player Hype bound")
	_check(hud.player_summary.text.contains("Trend %d/%d" % [int(mine["trend"]["current"]), int(mine["trend"]["cap"])]), "player Trend bound")
	_check(hud.rival_summary.text.contains("Hype %d/5" % int(enemy["hype"])), "opponent Hype bound")
	_check(hud.rival_hand_label.text.contains("%d cartas (ocultas)" % enemy["hand"].size()), "rival hand redacted")
	if not enemy["hand"].is_empty():
		_check(not hud.rival_hand_label.text.contains(str(enemy["hand"][0]["edition_id"])), "rival card identities hidden")
	_check(hud.player_hand_row.get_child_count() == mini(mine["hand"].size(), 6), "hand cards bound to state")
	_check(hud.player_active_row.get_child_count() == 1, "one active card rendered")
	if typeof(mine["active"]) == TYPE_DICTIONARY:
		var definition: Dictionary = engine.cards[mine["active"]["edition_id"]]
		var chip: PanelContainer = hud.player_active_row.get_child(0)
		var chip_text: Label = chip.get_child(0)
		_check(chip_text.text.contains(str(definition["name"])), "active name from catalog")
		_check(chip_text.text.contains("HP "), "actual active HP visible")
		_check(chip_text.text.contains("Trend "), "active card cost visible")

	var simulation: Dictionary = engine.state.duplicate(true)
	simulation["players"]["p1"]["hype"] = 3
	simulation["players"]["p1"]["trend"]["current"] = 2
	simulation["players"]["p1"]["trend"]["cap"] = 4
	simulation["players"]["p1"]["active"] = null
	simulation["terminal"] = {"winner_player_id": "p1", "reason": "hype"}
	simulation["phase"] = "terminal"
	hud.update_from_match(simulation, engine.cards)
	_check(hud.player_summary.text.contains("Hype 3/5"), "Hype reacts to new state")
	_check(hud.player_summary.text.contains("Trend 2/4"), "Trend reacts to new state")
	var empty_card: PanelContainer = hud.player_active_row.get_child(0)
	var empty_text: Label = empty_card.get_child(0)
	_check(empty_text.text.contains("Sem ativo"), "empty active state legible")
	_check(hud.terminal_label.visible and hud.terminal_label.text.contains("VOCÊ VENCEU"), "terminal state legible")
	_check(engine.normalized_snapshot() == before, "simulated view changes never write to engine")
	hud.queue_free()
	_finish()

func _finish() -> void:
	print("ART-002 HUD checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("ART-002 HUD GATES PASS")
		quit(0)
	else:
		quit(1)
