class_name AuthoritativeMatchService
extends RefCounted

# In-memory reference authority for MM-09.  Transport adapters must only call
# these methods after authenticating the session token; clients never mutate
# the DuelEngine directly.
const DuelEngine = preload("res://src/domain/duel_engine.gd")
const CardValidator = preload("res://src/domain/card_validator.gd")
const PROTOCOL_VERSION := "online-1"

var sessions: Dictionary = {}
var matches: Dictionary = {}

func register_session(player_id: String, token: String) -> Dictionary:
	if player_id.is_empty() or token.length() < 16 or sessions.has(token):
		return _fail("SESSION_INVALID")
	sessions[token] = player_id
	return {"ok": true}

func start_match(match_id: String, token_a: String, token_b: String, deck_a: Array, deck_b: Array, catalog: Dictionary, legal_editions: Dictionary, seed: int) -> Dictionary:
	if matches.has(match_id) or match_id.is_empty() or token_a == token_b or not sessions.has(token_a) or not sessions.has(token_b):
		return _fail("SESSION_INVALID")
	var lock_a := _lock_deck(deck_a, catalog, legal_editions)
	var lock_b := _lock_deck(deck_b, catalog, legal_editions)
	if not lock_a["ok"]:
		return lock_a
	if not lock_b["ok"]:
		return lock_b
	var engine = DuelEngine.new()
	var definitions: Array = []
	for edition_id in catalog:
		definitions.append(catalog[edition_id].duplicate(true))
	var loaded: Dictionary = engine.load_card_definitions(definitions)
	if not loaded["ok"]:
		return _fail(str(loaded["code"]))
	var started: Dictionary = engine.new_match(seed, lock_a["edition_ids"], lock_b["edition_ids"])
	if not started["ok"]:
		return _fail(str(started["code"]))
	engine.state["match_id"] = match_id
	for event in engine.events:
		event["match_id"] = match_id
	var player_a := str(sessions[token_a])
	var player_b := str(sessions[token_b])
	matches[match_id] = {"protocol_version": PROTOCOL_VERSION, "engine": engine, "players": {player_a: "p1", player_b: "p2"}, "tokens": {player_a: token_a, player_b: token_b}, "catalog": catalog.duplicate(true), "seed": seed, "decks": {"p1": lock_a["edition_ids"], "p2": lock_b["edition_ids"]}, "accepted_intents": [], "idempotency": {}}
	return {"ok": true, "match_id": match_id, "event_seq": int(engine.state["next_event_seq"]), "snapshot": _snapshot(engine)}

func apply_authoritative_intent(token: String, envelope: Dictionary) -> Dictionary:
	if str(envelope.get("protocol_version", "")) != PROTOCOL_VERSION or not sessions.has(token):
		return _fail("UNAUTHORIZED")
	var match_id := str(envelope.get("match_id", ""))
	if not matches.has(match_id):
		return _fail("UNKNOWN_MATCH")
	var match_record: Dictionary = matches[match_id]
	var public_player_id := str(sessions[token])
	if not match_record["players"].has(public_player_id) or str(match_record["tokens"][public_player_id]) != token:
		return _fail("UNAUTHORIZED")
	var key := str(envelope.get("idempotency_key", ""))
	if key.is_empty() or key.length() > 120:
		return _fail("IDEMPOTENCY_INVALID")
	if match_record["idempotency"].has(key):
		var cached: Dictionary = match_record["idempotency"][key]
		if str(cached["player_id"]) != public_player_id:
			return _fail("IDEMPOTENCY_CONFLICT")
		return cached["result"].duplicate(true)
	var intent: Dictionary = envelope.get("intent", {})
	if typeof(intent) != TYPE_DICTIONARY:
		return _fail("INTENT_INVALID")
	if str(intent.get("player_id", "")) != public_player_id:
		return _fail("CROSS_PLAYER_INTENT")
	var engine_intent := intent.duplicate(true)
	engine_intent["match_id"] = match_id
	engine_intent["player_id"] = str(match_record["players"][public_player_id])
	var result: Dictionary = match_record["engine"].apply_intent(engine_intent)
	var response := result.duplicate(true)
	if result["ok"]:
		response["event_seq"] = int(match_record["engine"].state["next_event_seq"])
		response["events"] = result.get("events", []).duplicate(true)
		match_record["accepted_intents"].append({"public_player_id": public_player_id, "intent": intent.duplicate(true)})
	match_record["idempotency"][key] = {"player_id": public_player_id, "result": response.duplicate(true)}
	matches[match_id] = match_record
	return response

func reconnect(token: String, match_id: String, acknowledged_event_seq: int) -> Dictionary:
	if not sessions.has(token) or not matches.has(match_id) or acknowledged_event_seq < 0:
		return _fail("UNAUTHORIZED")
	var match_record: Dictionary = matches[match_id]
	var player_id := str(sessions[token])
	if not match_record["players"].has(player_id) or str(match_record["tokens"][player_id]) != token:
		return _fail("UNAUTHORIZED")
	var events: Array = []
	for event in match_record["engine"].events:
		if int(event["event_seq"]) > acknowledged_event_seq:
			events.append(event.duplicate(true))
	return {"ok": true, "snapshot": _snapshot(match_record["engine"]), "events": events, "next_event_seq": int(match_record["engine"].state["next_event_seq"])}

func verify_replay(match_id: String) -> Dictionary:
	if not matches.has(match_id):
		return _fail("UNKNOWN_MATCH")
	var match_record: Dictionary = matches[match_id]
	var replay = DuelEngine.new()
	var definitions: Array = []
	for edition_id in match_record["catalog"]:
		definitions.append(match_record["catalog"][edition_id].duplicate(true))
	if not replay.load_card_definitions(definitions)["ok"] or not replay.new_match(int(match_record["seed"]), match_record["decks"]["p1"], match_record["decks"]["p2"])["ok"]:
		return _fail("REPLAY_BOOTSTRAP_FAILED")
	replay.state["match_id"] = match_id
	for accepted in match_record["accepted_intents"]:
		var original: Dictionary = accepted["intent"].duplicate(true)
		original["match_id"] = match_id
		original["player_id"] = str(match_record["players"][str(accepted["public_player_id"])])
		var verdict: Dictionary = replay.apply_intent(original)
		if not verdict["ok"]:
			return _fail("REPLAY_DIVERGED")
	var original_state := _snapshot(match_record["engine"])
	var replay_state := _snapshot(replay)
	if JSON.stringify(original_state) != JSON.stringify(replay_state):
		return _fail("REPLAY_DIVERGED")
	return {"ok": true, "event_count": replay.events.size(), "state": replay_state}

func export_match_record(match_id: String) -> Dictionary:
	if not matches.has(match_id):
		return _fail("UNKNOWN_MATCH")
	var match_record: Dictionary = matches[match_id]
	return {"ok": true, "record": {"protocol_version": PROTOCOL_VERSION, "match_id": match_id, "seed": match_record["seed"], "decks": match_record["decks"].duplicate(true), "accepted_intents": match_record["accepted_intents"].duplicate(true), "events": match_record["engine"].events.duplicate(true), "state": _snapshot(match_record["engine"]), "rules_version": "alpha-0.1"}}

func _lock_deck(deck: Array, catalog: Dictionary, legal_editions: Dictionary) -> Dictionary:
	if deck.size() != 30:
		return _fail("DECK_SIZE_INVALID")
	var ids: Array = []
	var validator := CardValidator.new()
	for raw in deck:
		if typeof(raw) != TYPE_DICTIONARY or raw.size() != 2:
			return _fail("DECK_INVALID")
		var edition_id := str(raw.get("edition_id", ""))
		var card_id := str(raw.get("card_id", ""))
		if not catalog.has(edition_id) or not legal_editions.has(edition_id) or str(catalog[edition_id].get("card_id", "")) != card_id or not validator.validate_card(catalog[edition_id])["ok"]:
			return _fail("FORMAT_ILLEGAL_CARD")
		ids.append(edition_id)
	return {"ok": true, "edition_ids": ids}

func _snapshot(engine) -> Dictionary:
	return engine.state.duplicate(true)

func _fail(code: String) -> Dictionary:
	return {"ok": false, "code": code}
