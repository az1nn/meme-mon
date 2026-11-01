class_name AuthoritativeMatchService
extends RefCounted

# In-memory reference authority for MM-09.  Transport adapters must only call
# these methods after authenticating the session token; clients never mutate
# the DuelEngine directly.
const DuelEngine = preload("res://src/domain/duel_engine.gd")
const CardValidator = preload("res://src/domain/card_validator.gd")
const OnlineMatchStore = preload("res://src/data/online_match_store.gd")
const PROTOCOL_VERSION := "online-1"
const ENGINE_VERSION := "duel-engine-1"
const REQUEST_WINDOW_MSEC := 10_000
const REQUEST_LIMIT := 60
const RECONNECT_WINDOW_MSEC := 30_000
const TURN_TIMEOUT_MSEC := 120_000

var sessions: Dictionary = {}
var matches: Dictionary = {}
var persistence_directory := ""
var match_store = OnlineMatchStore.new()
var request_timestamps: Dictionary = {}
var security_events: Array = []

func configure_persistence(directory: String) -> Dictionary:
	if directory.is_empty():
		persistence_directory = ""
		return {"ok": true, "enabled": false}
	persistence_directory = directory
	return {"ok": true, "enabled": true, "directory": directory}

func record_security_failure(code: String) -> void:
	var safe_code := code.strip_edges().left(80)
	if safe_code.is_empty():
		return
	security_events.append({"at_msec": _now_msec(), "code": safe_code})
	if security_events.size() > 256:
		security_events.pop_front()

func register_session(player_id: String, token: String) -> Dictionary:
	if player_id.is_empty() or token.length() < 16 or sessions.has(token):
		return _fail("SESSION_INVALID")
	sessions[token] = player_id
	request_timestamps[token] = []
	return {"ok": true}

func start_match(match_id: String, token_a: String, token_b: String, deck_a: Array, deck_b: Array, catalog: Dictionary, legal_editions: Dictionary, seed: int, format_id: String = "alpha-0.1") -> Dictionary:
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
	if format_id.is_empty():
		return _fail("FORMAT_INVALID")
	matches[match_id] = {"protocol_version": PROTOCOL_VERSION, "engine": engine, "players": {player_a: "p1", player_b: "p2"}, "tokens": {player_a: token_a, player_b: token_b}, "catalog": catalog.duplicate(true), "seed": seed, "format_id": format_id, "rules_version": "alpha-0.1", "engine_version": ENGINE_VERSION, "decks": {"p1": lock_a["edition_ids"], "p2": lock_b["edition_ids"]}, "accepted_intents": [], "idempotency": {}, "last_activity_msec": _now_msec(), "disconnect_deadlines": {}}
	var persisted := _persist_match(match_id)
	if not persisted["ok"]:
		matches.erase(match_id)
		return persisted
	return {"ok": true, "match_id": match_id, "event_seq": int(engine.state["next_event_seq"]), "snapshot": _snapshot(engine)}

func apply_authoritative_intent(token: String, envelope: Dictionary) -> Dictionary:
	if str(envelope.get("protocol_version", "")) != PROTOCOL_VERSION or not sessions.has(token):
		return _fail("UNAUTHORIZED")
	if not _allow_request(token):
		return _fail("RATE_LIMITED")
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
	var engine = match_record["engine"]
	var before_state: Dictionary = engine.state.duplicate(true)
	var before_events: Array = engine.events.duplicate(true)
	var before_rng_state := int(engine.rng.state)
	var before_rng_index := int(engine.rng.rng_index)
	var before_accepted: Array = match_record["accepted_intents"].duplicate(true)
	var before_idempotency: Dictionary = match_record["idempotency"].duplicate(true)
	var result: Dictionary = engine.apply_intent(engine_intent)
	var response := result.duplicate(true)
	if result["ok"]:
		response["event_seq"] = int(match_record["engine"].state["next_event_seq"])
		response["events"] = result.get("events", []).duplicate(true)
		match_record["accepted_intents"].append({"public_player_id": public_player_id, "intent": intent.duplicate(true)})
	match_record["last_activity_msec"] = _now_msec()
	match_record["disconnect_deadlines"].erase(public_player_id)
	match_record["idempotency"][key] = {"player_id": public_player_id, "result": response.duplicate(true)}
	matches[match_id] = match_record
	if result["ok"]:
		var persisted := _persist_match(match_id)
		if not persisted["ok"]:
			engine.state = before_state
			engine.events = before_events
			engine.rng.state = before_rng_state
			engine.rng.rng_index = before_rng_index
			match_record["accepted_intents"] = before_accepted
			match_record["idempotency"] = before_idempotency
			matches[match_id] = match_record
			return persisted
	return response

func reconnect(token: String, match_id: String, acknowledged_event_seq: int) -> Dictionary:
	if not sessions.has(token) or not matches.has(match_id) or acknowledged_event_seq < 0:
		return _fail("UNAUTHORIZED")
	if not _allow_request(token):
		return _fail("RATE_LIMITED")
	var expiry := _expire_match_if_needed(match_id, _now_msec())
	if not expiry["ok"]:
		return expiry
	var match_record: Dictionary = matches[match_id]
	var player_id := str(sessions[token])
	if not match_record["players"].has(player_id) or str(match_record["tokens"][player_id]) != token:
		return _fail("UNAUTHORIZED")
	var events: Array = []
	for event in match_record["engine"].events:
		if int(event["event_seq"]) > acknowledged_event_seq:
			events.append(event.duplicate(true))
	match_record["disconnect_deadlines"].erase(player_id)
	match_record["last_activity_msec"] = _now_msec()
	matches[match_id] = match_record
	return {"ok": true, "snapshot": _snapshot(match_record["engine"]), "events": events, "next_event_seq": int(match_record["engine"].state["next_event_seq"])}

func mark_disconnected(token: String, match_id: String, now_msec: int = -1) -> Dictionary:
	if not sessions.has(token) or not matches.has(match_id):
		return _fail("UNAUTHORIZED")
	var match_record: Dictionary = matches[match_id]
	var player_id := str(sessions[token])
	if not match_record["players"].has(player_id) or str(match_record["tokens"][player_id]) != token:
		return _fail("UNAUTHORIZED")
	match_record["disconnect_deadlines"][player_id] = _now_msec(now_msec) + RECONNECT_WINDOW_MSEC
	matches[match_id] = match_record
	return {"ok": true, "deadline_msec": match_record["disconnect_deadlines"][player_id]}

func mark_player_disconnected(token: String, now_msec: int = -1) -> Dictionary:
	if not sessions.has(token):
		return _fail("UNAUTHORIZED")
	var affected := 0
	for match_id in matches:
		var result := mark_disconnected(token, str(match_id), now_msec)
		if result["ok"]:
			affected += 1
	return {"ok": true, "matches": affected}

func tick(now_msec: int = -1) -> Dictionary:
	var current := _now_msec(now_msec)
	var expired: Array = []
	for match_id in matches.keys():
		var result := _expire_match_if_needed(str(match_id), current)
		if result.get("expired", false):
			expired.append(result)
	return {"ok": true, "expired": expired}

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
	for event in replay.events:
		event["match_id"] = match_id
	for accepted in match_record["accepted_intents"]:
		var original: Dictionary = accepted["intent"].duplicate(true)
		original["match_id"] = match_id
		original["player_id"] = str(match_record["players"][str(accepted["public_player_id"])])
		var verdict: Dictionary = replay.apply_intent(original)
		if not verdict["ok"]:
			return _fail("REPLAY_DIVERGED")
	var original_state := _snapshot(match_record["engine"])
	var replay_state := _snapshot(replay)
	if JSON.stringify(original_state) != JSON.stringify(replay_state) or not _same_value(match_record["engine"].events, replay.events):
		return _fail("REPLAY_DIVERGED")
	return {"ok": true, "event_count": replay.events.size(), "state": replay_state}

func restore_match_record(record: Dictionary, token_by_player: Dictionary) -> Dictionary:
	if str(record.get("protocol_version", "")) != PROTOCOL_VERSION or str(record.get("match_id", "")).is_empty():
		return _fail("UNKNOWN_PROTOCOL_VERSION")
	var match_id := str(record["match_id"])
	if matches.has(match_id) or typeof(record.get("catalog", null)) != TYPE_DICTIONARY or typeof(record.get("decks", null)) != TYPE_DICTIONARY:
		return _fail("PERSISTED_MATCH_INVALID")
	if str(record.get("rules_version", "")) != "alpha-0.1" or str(record.get("engine_version", "")) != ENGINE_VERSION or str(record.get("format_id", "")).is_empty():
		return _fail("UNKNOWN_PROTOCOL_VERSION")
	var players: Dictionary = record.get("players", {})
	if players.size() != 2:
		return _fail("PERSISTED_MATCH_INVALID")
	var catalog: Dictionary = record["catalog"].duplicate(true)
	var definitions: Array = []
	for edition_id in catalog:
		definitions.append(catalog[edition_id].duplicate(true))
	var engine = DuelEngine.new()
	if not engine.load_card_definitions(definitions)["ok"]:
		return _fail("REPLAY_BOOTSTRAP_FAILED")
	var decks: Dictionary = record["decks"]
	var started: Dictionary = engine.new_match(int(record["seed"]), decks.get("p1", []), decks.get("p2", []))
	if not started["ok"]:
		return _fail("REPLAY_BOOTSTRAP_FAILED")
	engine.state["match_id"] = match_id
	for event in engine.events:
		event["match_id"] = match_id
	var tokens: Dictionary = {}
	for public_id in players:
		if not token_by_player.has(public_id) or not sessions.has(str(token_by_player[public_id])) or str(sessions[str(token_by_player[public_id])]) != str(public_id):
			return _fail("SESSION_INVALID")
		tokens[str(public_id)] = str(token_by_player[public_id])
	var accepted: Array = record.get("accepted_intents", [])
	for item in accepted:
		if typeof(item) != TYPE_DICTIONARY:
			return _fail("PERSISTED_MATCH_INVALID")
		var public_id := str(item.get("public_player_id", ""))
		var original: Dictionary = item.get("intent", {}).duplicate(true)
		original["match_id"] = match_id
		original["player_id"] = str(players.get(public_id, ""))
		if not engine.apply_intent(original)["ok"]:
			return _fail("REPLAY_DIVERGED")
	if not _same_value(_snapshot(engine), record.get("state", {})) or not _same_value(engine.events, record.get("events", [])):
		return _fail("REPLAY_DIVERGED")
	var restored := {"protocol_version": PROTOCOL_VERSION, "engine": engine, "players": players.duplicate(true), "tokens": tokens, "catalog": catalog, "seed": int(record["seed"]), "format_id": str(record["format_id"]), "rules_version": str(record["rules_version"]), "engine_version": str(record["engine_version"]), "decks": decks.duplicate(true), "accepted_intents": accepted.duplicate(true), "idempotency": record.get("idempotency", {}).duplicate(true), "last_activity_msec": _now_msec(), "disconnect_deadlines": {}}
	matches[match_id] = restored
	return {"ok": true, "match_id": match_id, "event_seq": int(engine.state["next_event_seq"]), "snapshot": _snapshot(engine)}

func export_match_record(match_id: String) -> Dictionary:
	if not matches.has(match_id):
		return _fail("UNKNOWN_MATCH")
	var match_record: Dictionary = matches[match_id]
	return {"ok": true, "record": {"protocol_version": PROTOCOL_VERSION, "match_id": match_id, "players": match_record["players"].duplicate(true), "seed": match_record["seed"], "format_id": match_record["format_id"], "catalog": match_record["catalog"].duplicate(true), "decks": match_record["decks"].duplicate(true), "accepted_intents": match_record["accepted_intents"].duplicate(true), "idempotency": match_record["idempotency"].duplicate(true), "events": match_record["engine"].events.duplicate(true), "state": _snapshot(match_record["engine"]), "rules_version": match_record["rules_version"], "engine_version": match_record["engine_version"]}}

func _persist_match(match_id: String) -> Dictionary:
	if persistence_directory.is_empty():
		return {"ok": true, "enabled": false}
	var path := match_store.path_for(persistence_directory, match_id)
	if path.is_empty():
		return _fail("PERSISTENCE_PATH_INVALID")
	var exported := export_match_record(match_id)
	if not exported["ok"]:
		return exported
	var saved := match_store.save_record(path, exported["record"])
	if not saved["ok"]:
		return {"ok": false, "code": str(saved.get("code", "PERSISTENCE_FAILED"))}
	return {"ok": true, "path": path}

func _allow_request(token: String) -> bool:
	var now := _now_msec()
	var timestamps: Array = request_timestamps.get(token, [])
	var recent: Array = []
	for timestamp in timestamps:
		if now - int(timestamp) < REQUEST_WINDOW_MSEC:
			recent.append(timestamp)
	if recent.size() >= REQUEST_LIMIT:
		request_timestamps[token] = recent
		return false
	recent.append(now)
	request_timestamps[token] = recent
	return true

func _expire_match_if_needed(match_id: String, now_msec: int) -> Dictionary:
	if not matches.has(match_id):
		return _fail("UNKNOWN_MATCH")
	var match_record: Dictionary = matches[match_id]
	var engine = match_record["engine"]
	if engine.state["terminal"] != null:
		return {"ok": true, "expired": false}
	var loser := ""
	var reason := ""
	for public_id in match_record["disconnect_deadlines"]:
		if now_msec >= int(match_record["disconnect_deadlines"][public_id]):
			loser = str(match_record["players"][public_id])
			reason = "disconnect_timeout"
			break
	if loser.is_empty() and now_msec - int(match_record["last_activity_msec"]) >= TURN_TIMEOUT_MSEC:
		loser = str(engine.state["active_player_id"])
		reason = "turn_timeout"
	if loser.is_empty():
		return {"ok": true, "expired": false}
	var abandoned: Dictionary = engine.abandon_match(loser, reason)
	if not abandoned["ok"]:
		return abandoned
	match_record["last_activity_msec"] = now_msec
	match_record["disconnect_deadlines"].clear()
	matches[match_id] = match_record
	var persisted := _persist_match(match_id)
	if not persisted["ok"]:
		return persisted
	return {"ok": true, "expired": true, "match_id": match_id, "reason": reason, "loser_player_id": loser}

func _now_msec(override: int = -1) -> int:
	return Time.get_ticks_msec() if override < 0 else override

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
	record_security_failure(code)
	return {"ok": false, "code": code}

func _same_value(left: Variant, right: Variant) -> bool:
	var left_type := typeof(left)
	var right_type := typeof(right)
	if (left_type == TYPE_INT or left_type == TYPE_FLOAT) and (right_type == TYPE_INT or right_type == TYPE_FLOAT):
		return float(left) == float(right)
	if left_type != right_type:
		return false
	if left_type == TYPE_DICTIONARY:
		if left.size() != right.size():
			return false
		for key in left:
			if not right.has(key) or not _same_value(left[key], right[key]):
				return false
		return true
	if left_type == TYPE_ARRAY:
		if left.size() != right.size():
			return false
		for index in range(left.size()):
			if not _same_value(left[index], right[index]):
				return false
		return true
	return left == right
