extends SceneTree

const MemeRng = preload("res://src/domain/rng.gd")
const CardValidator = preload("res://src/domain/card_validator.gd")
const DuelEngine = preload("res://src/domain/duel_engine.gd")
const DeterministicBot = preload("res://src/domain/bot.gd")

var failures: Array = []
var checks: int = 0
var definitions: Array = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/cards/alpha-test-cards.json"))
	definitions = parsed["cards"]
	_test_rng_known_sequence()
	_test_rng_zero_seed()
	_test_rng_shuffle_replay()
	_test_mm03_fixtures()
	_test_twenty_cards_legal()
	_test_setup_replay()
	_test_opening_repair()
	_test_trend_progression()
	_test_illegal_intent_zero_side_effects()
	_test_queue_and_switch()
	_test_attack_ends_main()
	_test_normal_ko()
	_test_headliner_ko()
	_test_forced_replacement_queue()
	_test_forced_replacement_hand()
	_test_no_field()
	_test_deck_out()
	_test_hype_win()
	_test_simultaneous_hype_draw()
	_test_activated_ability()
	_test_trigger_on_switch()
	_test_deterministic_bot_choice()
	_test_complete_bot_duel()
	print("MM-04 checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("MM-04 HEADLESS GATES PASS")
		quit(0)
	else:
		quit(1)

func _assert(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)

func _engine(seed: int = 123456789, first: String = "p1"):
	var engine = DuelEngine.new()
	var loaded: Dictionary = engine.load_card_definitions(definitions)
	_assert(bool(loaded["ok"]), "card definitions load")
	var deck: Array = _demo_deck(engine)
	var started: Dictionary = engine.new_match(seed, deck, deck, first)
	_assert(bool(started["ok"]), "match starts")
	return engine

func _demo_deck(engine) -> Array:
	var ids: Array = engine.cards.keys()
	ids.sort()
	var deck: Array = []
	for id in ids:
		deck.append(id)
	for i in range(10):
		deck.append(ids[i])
	return deck

func _intent(engine, pid: String, kind: String, payload: Dictionary = {}) -> Dictionary:
	return {"match_id":"local","player_id":pid,"expected_event_seq":int(engine.state["next_event_seq"]),"kind":kind,"payload":payload}

func _test_rng_known_sequence() -> void:
	var r = MemeRng.new(123456789)
	var got := []
	for _i in range(5):
		got.append(r.next_u32())
	_assert(got == [2714967881,2238813396,1250077441,3820100336,3177519686], "xorshift32 known sequence")
	_assert(r.rng_index == 5, "rng index increments")

func _test_rng_zero_seed() -> void:
	var r = MemeRng.new(0)
	_assert(r.state == 0x6D2B79F5, "zero seed remap")
	_assert(r.next_u32() == 1085196063, "zero-remap first value")

func _test_rng_shuffle_replay() -> void:
	var a = MemeRng.new(99)
	var b = MemeRng.new(99)
	var source := [1,2,3,4,5,6,7,8,9]
	_assert(a.shuffle_array(source) == b.shuffle_array(source), "Fisher-Yates deterministic replay")
	var bounded_ok := true
	for _i in range(100):
		var v := a.bounded(7)
		if v < 0 or v >= 7:
			bounded_ok = false
	_assert(bounded_ok, "bounded RNG range")

func _test_mm03_fixtures() -> void:
	var validator = CardValidator.new()
	var legal = JSON.parse_string(FileAccess.get_file_as_string("res://contracts/fixtures/mm-03-card-keyboard-cat.json"))
	var invalid = JSON.parse_string(FileAccess.get_file_as_string("res://contracts/fixtures/mm-03-invalid-overbudget-card.json"))
	_assert(validator.validate_card(legal)["ok"], "MM-03 legal fixture accepted")
	_assert(validator.validate_card(invalid)["code"] == "CARD_STAT_OUT_OF_RANGE", "MM-03 overbudget fixture rejected")

func _test_twenty_cards_legal() -> void:
	var validator = CardValidator.new()
	_assert(definitions.size() >= 20, "at least 20 test cards")
	for card in definitions:
		var verdict: Dictionary = validator.validate_card(card)
		_assert(verdict["ok"], "legal test card %s" % card["card_id"])

func _test_setup_replay() -> void:
	var a = _engine(444, "")
	var b = _engine(444, "")
	_assert(a.normalized_snapshot() == b.normalized_snapshot(), "setup replay identity")

func _test_opening_repair() -> void:
	var e = _engine()
	var p: Dictionary = e.state["players"]["p1"]
	var non_memes: Array = []
	for id in e.cards:
		if str(e.cards[id]["kind"]) != "mememom":
			non_memes.append(e.make_instance("p1", id, "repair"))
	p["hand"] = non_memes.slice(0, min(5, non_memes.size()))
	p["deck"] = []
	for id in e.cards:
		if str(e.cards[id]["kind"]) == "mememom":
			p["deck"].append(e.make_instance("p1", id, "repairdeck"))
	e.repair_opening_hand_for_test("p1")
	var found := false
	for instance in p["hand"]:
		if str(e.cards[instance["edition_id"]]["kind"]) == "mememom":
			found = true
	_assert(found, "opening repair yields Mememom")

func _test_trend_progression() -> void:
	var e = _engine()
	var observed := [int(e.state["players"]["p1"]["trend"]["cap"])]
	for _i in range(8):
		var pid := str(e.state["active_player_id"])
		e.apply_intent(_intent(e, pid, "pass"))
		if str(e.state["active_player_id"]) == "p1":
			observed.append(int(e.state["players"]["p1"]["trend"]["cap"]))
	_assert(observed[0] == 1, "first turn cap is 1")
	_assert(observed.max() <= 5 and observed.max() >= 4, "trend progresses toward cap 5")

func _test_illegal_intent_zero_side_effects() -> void:
	var e = _engine()
	var before := e.normalized_snapshot()
	var before_rng: int = e.rng.rng_index
	var before_seq := int(e.state["next_event_seq"])
	var result: Dictionary = e.apply_intent(_intent(e, "p2", "attack"))
	_assert(not result["ok"] and result["code"] == "NOT_ACTIVE_PLAYER", "illegal wrong-player rejected")
	_assert(e.rng.rng_index == before_rng, "illegal intent consumes no RNG")
	_assert(int(e.state["next_event_seq"]) == before_seq, "illegal intent emits no event")
	_assert(e.normalized_snapshot() == before, "illegal intent changes no state")

func _test_queue_and_switch() -> void:
	var e = _engine()
	var p: Dictionary = e.state["players"]["p1"]
	p["trend"]["current"] = 5
	if p["queue"].is_empty():
		for i in range(p["hand"].size()):
			if str(e.cards[p["hand"][i]["edition_id"]]["kind"]) == "mememom":
				p["queue"].append(p["hand"].pop_at(i))
				break
	var result: Dictionary = e.apply_intent(_intent(e, "p1", "switch_active", {"queue_index":0}))
	_assert(result["ok"], "legal voluntary switch")
	var seq := int(e.state["next_event_seq"])
	var second: Dictionary = e.apply_intent(_intent(e, "p1", "switch_active", {"queue_index":0}))
	_assert(not second["ok"] and second["code"] == "SWITCH_LIMIT", "second switch rejected")
	_assert(int(e.state["next_event_seq"]) == seq, "second switch no events")

func _test_attack_ends_main() -> void:
	var e = _engine()
	e.state["players"]["p1"]["trend"]["current"] = 5
	var result: Dictionary = e.apply_intent(_intent(e, "p1", "attack"))
	_assert(result["ok"], "legal attack")
	_assert(str(e.state["active_player_id"]) == "p2" or not e.state["pending_replacements"].is_empty() or e.state["terminal"] != null, "attack leaves Main after resolution")

func _test_normal_ko() -> void:
	var e = _engine()
	e.state["players"]["p2"]["active"] = e.make_instance("p2", "test.mememom.03@alpha.1", "normal-ko")
	e.state["players"]["p2"]["active"]["hp_remaining"] = 1
	e.state["players"]["p1"]["trend"]["current"] = 5
	var before := int(e.state["players"]["p1"]["hype"])
	e.apply_intent(_intent(e, "p1", "attack"))
	_assert(int(e.state["players"]["p1"]["hype"]) == before + 1, "normal KO grants exactly 1 Hype")

func _test_headliner_ko() -> void:
	var e = _engine()
	var headliner_id := ""
	for id in e.cards:
		if str(e.cards[id]["tier"]) == "headliner":
			headliner_id = id
			break
	e.state["players"]["p2"]["active"] = e.make_instance("p2", headliner_id, "headliner")
	e.state["players"]["p2"]["active"]["hp_remaining"] = 1
	e.state["players"]["p1"]["trend"]["current"] = 5
	e.state["players"]["p1"]["hype"] = 0
	e.apply_intent(_intent(e, "p1", "attack"))
	_assert(int(e.state["players"]["p1"]["hype"]) == 2, "Headliner KO grants 2 Hype")

func _test_forced_replacement_queue() -> void:
	var e = _engine()
	var p: Dictionary = e.state["players"]["p2"]
	_assert(not p["queue"].is_empty(), "queue exists for replacement test")
	p["active"]["hp_remaining"] = 0
	e.checkpoint_for_test()
	_assert(str(e.state["pending_replacements"][0]) == "p2", "replacement required from queue")
	var result: Dictionary = e.apply_intent(_intent(e, "p2", "choose_replacement", {"source":"queue","index":0}))
	_assert(result["ok"] and p["active"] != null, "forced replacement from queue")

func _test_forced_replacement_hand() -> void:
	var e = _engine()
	var p: Dictionary = e.state["players"]["p2"]
	p["queue"] = []
	var meme = null
	for i in range(p["hand"].size()):
		if str(e.cards[p["hand"][i]["edition_id"]]["kind"]) == "mememom":
			meme = p["hand"][i]
			break
	if meme == null:
		for id in e.cards:
			if str(e.cards[id]["kind"]) == "mememom":
				meme = e.make_instance("p2", id, "handreplace")
				p["hand"].append(meme)
				break
	p["active"]["hp_remaining"] = 0
	e.checkpoint_for_test()
	var idx: int = p["hand"].find(meme)
	var result: Dictionary = e.apply_intent(_intent(e, "p2", "choose_replacement", {"source":"hand","index":idx}))
	_assert(result["ok"] and p["active"] != null, "forced replacement from hand")

func _test_no_field() -> void:
	var e = _engine()
	var p: Dictionary = e.state["players"]["p2"]
	p["queue"] = []
	p["hand"] = []
	p["active"]["hp_remaining"] = 0
	e.checkpoint_for_test()
	_assert(e.state["terminal"] != null and e.state["terminal"]["reason"] == "no_field" and e.state["terminal"]["winner_player_id"] == "p1", "no-field terminal loss")

func _test_deck_out() -> void:
	var e = _engine()
	e.state["players"]["p2"]["deck"] = []
	e.apply_intent(_intent(e, "p1", "pass"))
	_assert(e.state["terminal"] != null and e.state["terminal"]["reason"] == "deck_out" and e.state["terminal"]["winner_player_id"] == "p1", "deck-out terminal loss")

func _test_hype_win() -> void:
	var e = _engine()
	e.state["players"]["p1"]["hype"] = 4
	e.state["players"]["p2"]["active"]["hp_remaining"] = 0
	e.checkpoint_for_test()
	_assert(e.state["terminal"] != null and e.state["terminal"]["winner_player_id"] == "p1" and e.state["terminal"]["reason"] == "hype", "first to 5 Hype wins")

func _test_simultaneous_hype_draw() -> void:
	var e = _engine()
	e.state["players"]["p1"]["hype"] = 4
	e.state["players"]["p2"]["hype"] = 4
	e.state["players"]["p1"]["active"]["hp_remaining"] = 0
	e.state["players"]["p2"]["active"]["hp_remaining"] = 0
	e.checkpoint_for_test()
	_assert(e.state["terminal"] != null and e.state["terminal"]["result"] == "draw" and e.state["terminal"]["reason"] == "simultaneous_hype", "simultaneous Hype is draw")

func _test_activated_ability() -> void:
	var e = _engine()
	var ability_id := "test.mememom.01@alpha.1"
	e.state["players"]["p1"]["active"] = e.make_instance("p1", ability_id, "ability")
	e.state["players"]["p1"]["active"]["hp_remaining"] -= 20
	e.state["players"]["p1"]["trend"]["current"] = 5
	var before := int(e.state["players"]["p1"]["active"]["hp_remaining"])
	var result: Dictionary = e.apply_intent(_intent(e, "p1", "activate_ability", {"ability_id":"small-heal"}))
	_assert(result["ok"] and int(e.state["players"]["p1"]["active"]["hp_remaining"]) > before, "activated ability resolves")

func _test_trigger_on_switch() -> void:
	var e = _engine()
	var trigger_id := "test.mememom.02@alpha.1"
	e.state["players"]["p1"]["queue"] = [e.make_instance("p1", trigger_id, "trigger")]
	e.state["players"]["p1"]["queue"][0]["hp_remaining"] -= 10
	e.state["players"]["p1"]["trend"]["current"] = 5
	e.apply_intent(_intent(e, "p1", "switch_active", {"queue_index":0}))
	var active: Dictionary = e.state["players"]["p1"]["active"]
	var max_hp := int(e.cards[active["edition_id"]]["mememom"]["hp"])
	_assert(int(active["hp_remaining"]) == max_hp, "switched_in trigger heals deterministically")

func _test_deterministic_bot_choice() -> void:
	var a = _engine(77)
	var b = _engine(77)
	var bot_a = DeterministicBot.new("p1")
	var bot_b = DeterministicBot.new("p1")
	_assert(bot_a.choose_intent(a) == bot_b.choose_intent(b), "deterministic bot repeats choice")

func _test_complete_bot_duel() -> void:
	var e = _engine(20261007)
	var bots := {"p1": DeterministicBot.new("p1"), "p2": DeterministicBot.new("p2")}
	var guard := 0
	while e.state["terminal"] == null and guard < 500:
		var actor_id := str(e.state["pending_replacements"][0]) if not e.state["pending_replacements"].is_empty() else str(e.state["active_player_id"])
		var result: Dictionary = e.apply_intent(bots[actor_id].choose_intent(e))
		if not result["ok"]:
			failures.append("bot duel rejected intent: %s" % result)
			break
		guard += 1
	_assert(e.state["terminal"] != null, "complete deterministic bot duel terminates")
	_assert(guard < 500, "bot duel bounded")

