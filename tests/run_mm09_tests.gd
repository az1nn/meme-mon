extends SceneTree

const AuthoritativeMatchService = preload("res://src/domain/authoritative_match_service.gd")
const OnlineMatchStore = preload("res://src/data/online_match_store.gd")
const OnlineMatchClient = preload("res://src/data/online_match_client.gd")

var checks := 0
var failures: Array = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _catalog() -> Dictionary:
	var parser := JSON.new()
	parser.parse(FileAccess.get_file_as_string("res://data/cards/alpha-test-cards.json"))
	var catalog: Dictionary = {}
	for card in parser.data["cards"]:
		catalog[str(card["edition_id"])] = card
	return catalog

func _deck(card: Dictionary) -> Array:
	var deck: Array = []
	for _i in range(30):
		deck.append({"card_id": card["card_id"], "edition_id": card["edition_id"]})
	return deck

func _run() -> void:
	var catalog := _catalog()
	var legal: Dictionary = {}
	for edition_id in catalog:
		legal[edition_id] = true
	var chosen: Dictionary = catalog.values()[0]
	var service := AuthoritativeMatchService.new()
	var persistence_dir := "user://mm09-tests/records"
	var persisted_test_path := OnlineMatchStore.new().path_for(persistence_dir, "match.online.1")
	if FileAccess.file_exists(persisted_test_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(persisted_test_path))
	service.configure_persistence(persistence_dir)
	var alice_token := "aaaaaaaaaaaaaaaa"
	var bob_token := "bbbbbbbbbbbbbbbb"
	_check(service.register_session("alice", alice_token)["ok"], "authoritative service registers first session")
	_check(service.register_session("bob", bob_token)["ok"], "authoritative service registers second session")
	var started: Dictionary = service.start_match("match.online.1", alice_token, bob_token, _deck(chosen), _deck(chosen), catalog, legal, 12345)
	_check(started["ok"], "authority locks legal canonical deck and starts seeded match")
	if not started["ok"]:
		push_error("MM-09 setup failed: %s" % started)
		quit(1)
		return
	var player_to_move := ""
	for public_id in service.matches["match.online.1"]["players"]:
		if str(service.matches["match.online.1"]["players"][public_id]) == str(service.matches["match.online.1"]["engine"].state["active_player_id"]):
			player_to_move = public_id
	var token := alice_token if player_to_move == "alice" else bob_token
	var wrong_token := bob_token if player_to_move == "alice" else alice_token
	var intent := {"schema_version": "alpha-0.1", "rules_version": "alpha-0.1", "intent_id": "pass-1", "match_id": "match.online.1", "player_id": player_to_move, "expected_event_seq": int(service.matches["match.online.1"]["engine"].state["next_event_seq"]), "kind": "pass", "payload": {}}
	var envelope := {"protocol_version": "online-1", "match_id": "match.online.1", "idempotency_key": "key-1", "intent": intent}
	_check(service.apply_authoritative_intent(wrong_token, envelope)["code"] == "CROSS_PLAYER_INTENT", "cross-player intent is rejected before mutation")
	var applied: Dictionary = service.apply_authoritative_intent(token, envelope)
	_check(applied["ok"], "active authenticated player intent is resolved by authority")
	var duplicate: Dictionary = service.apply_authoritative_intent(token, envelope)
	_check(duplicate["ok"] and JSON.stringify(duplicate) == JSON.stringify(applied), "idempotency returns original result without duplicate events")
	var stale := intent.duplicate(true)
	stale["intent_id"] = "pass-stale"
	stale["expected_event_seq"] = 0
	var stale_result: Dictionary = service.apply_authoritative_intent(token, {"protocol_version": "online-1", "match_id": "match.online.1", "idempotency_key": "key-2", "intent": stale})
	_check(stale_result["code"] == "STALE_EVENT_SEQ", "stale event sequence fails closed")
	var reconnected: Dictionary = service.reconnect(token, "match.online.1", 0)
	_check(reconnected["ok"] and not reconnected["events"].is_empty(), "reconnect returns authoritative snapshot and missing events")
	_check(service.reconnect("invalid", "match.online.1", 0)["code"] == "UNAUTHORIZED", "unauthenticated reconnect is denied")
	_check(service.verify_replay("match.online.1")["ok"], "stored accepted intents reproduce authoritative state")
	var original_event: Dictionary = service.matches["match.online.1"]["engine"].events[0].duplicate(true)
	service.matches["match.online.1"]["engine"].events[0]["event_type"] = "FORGED_EVENT"
	_check(service.verify_replay("match.online.1")["code"] == "REPLAY_DIVERGED", "in-memory event tampering fails replay verification")
	service.matches["match.online.1"]["engine"].events[0] = original_event
	var online_store := OnlineMatchStore.new()
	var online_path := "user://mm09-tests/match.json"
	var record: Dictionary = service.export_match_record("match.online.1")
	_check(record["ok"] and online_store.save_record(online_path, record["record"])["ok"], "authoritative match record persists append-only events")
	_check(record["ok"] and record["record"].get("format_id", "") == "alpha-0.1" and record["record"].get("engine_version", "") == "duel-engine-1", "replay record pins format and engine versions")
	_check(online_store.load_record(online_path)["ok"], "authoritative match record reloads")
	var truncated: Dictionary = record["record"].duplicate(true)
	truncated["events"] = []
	_check(online_store.save_record(online_path, truncated)["code"] == "EVENT_LOG_NOT_APPEND_ONLY", "persisted event log cannot be truncated")
	var mutated: Dictionary = record["record"].duplicate(true)
	mutated["events"] = record["record"]["events"].duplicate(true)
	mutated["events"][0] = mutated["events"][0].duplicate(true)
	mutated["events"][0]["event_type"] = "FORGED_EVENT"
	_check(online_store.save_record(online_path, mutated)["code"] == "EVENT_LOG_MUTATED", "persisted event log cannot mutate historical events")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(online_path))
	var illegal: Array = _deck(chosen)
	illegal[0] = {"card_id": "sandbox.preview.classic", "edition_id": "sandbox.local.1"}
	_check(service.start_match("match.online.bad", alice_token, bob_token, illegal, _deck(chosen), catalog, legal, 1)["code"] == "FORMAT_ILLEGAL_CARD", "Sandbox/non-Canon deck reference cannot start online match")
	var persisted_path := OnlineMatchStore.new().path_for(persistence_dir, "match.online.1")
	var persisted := OnlineMatchStore.new().load_record(persisted_path)
	_check(persisted["ok"], "authority writes a complete restart record")
	var restored_service := AuthoritativeMatchService.new()
	_check(restored_service.register_session("alice", alice_token)["ok"] and restored_service.register_session("bob", bob_token)["ok"], "restart authority restores session bindings")
	var restored := restored_service.restore_match_record(persisted["record"], {"alice": alice_token, "bob": bob_token})
	_check(restored["ok"], "restart authority rebuilds match from persisted replay")
	_check(restored["ok"] and restored_service.verify_replay("match.online.1")["ok"], "restored match still verifies deterministically")
	_check(restored["ok"] and restored_service.matches["match.online.1"]["idempotency"].has("key-1"), "restart authority restores idempotency cache")
	var tampered_record: Dictionary = persisted["record"].duplicate(true)
	tampered_record["state"] = tampered_record["state"].duplicate(true)
	tampered_record["state"]["turn_number"] = int(tampered_record["state"]["turn_number"]) + 1
	var tampered_service := AuthoritativeMatchService.new()
	_check(tampered_service.register_session("alice", alice_token)["ok"] and tampered_service.register_session("bob", bob_token)["ok"], "tamper-check authority registers sessions")
	_check(tampered_service.restore_match_record(tampered_record, {"alice": alice_token, "bob": bob_token})["code"] == "REPLAY_DIVERGED", "tampered persisted replay state fails closed")
	var tampered_events: Dictionary = persisted["record"].duplicate(true)
	tampered_events["events"] = tampered_events["events"].duplicate(true)
	tampered_events["events"][0] = tampered_events["events"][0].duplicate(true)
	tampered_events["events"][0]["event_type"] = "FORGED_EVENT"
	var event_tamper_service := AuthoritativeMatchService.new()
	_check(event_tamper_service.register_session("alice", alice_token)["ok"] and event_tamper_service.register_session("bob", bob_token)["ok"], "event-tamper authority registers sessions")
	_check(event_tamper_service.restore_match_record(tampered_events, {"alice": alice_token, "bob": bob_token})["code"] == "REPLAY_DIVERGED", "tampered persisted replay event fails closed")
	var timeout_service := AuthoritativeMatchService.new()
	_check(timeout_service.register_session("alice", alice_token)["ok"] and timeout_service.register_session("bob", bob_token)["ok"], "timeout authority registers sessions")
	_check(timeout_service.start_match("match.timeout", alice_token, bob_token, _deck(chosen), _deck(chosen), catalog, legal, 77)["ok"], "timeout authority starts match")
	_check(timeout_service.mark_player_disconnected(alice_token, 1)["ok"], "disconnect starts bounded reconnect window")
	var expired := timeout_service.tick(1 + timeout_service.RECONNECT_WINDOW_MSEC + 1)
	_check(expired["ok"] and expired["expired"].size() == 1 and timeout_service.matches["match.timeout"]["engine"].state["terminal"] != null, "expired disconnect abandons match authoritatively")
	var rate_service := AuthoritativeMatchService.new()
	_check(rate_service.register_session("alice", alice_token)["ok"] and rate_service.register_session("bob", bob_token)["ok"], "rate-limit authority registers sessions")
	_check(rate_service.start_match("match.rate", alice_token, bob_token, _deck(chosen), _deck(chosen), catalog, legal, 88)["ok"], "rate-limit authority starts match")
	for _i in range(rate_service.REQUEST_LIMIT):
		rate_service.reconnect(alice_token, "match.rate", 0)
	_check(rate_service.reconnect(alice_token, "match.rate", 0)["code"] == "RATE_LIMITED", "authority rate-limits session requests")
	_check(not rate_service.security_events.is_empty() and not JSON.stringify(rate_service.security_events).contains(alice_token), "security audit omits session tokens")
	var client := OnlineMatchClient.new()
	_check(client.connect_to_url("https://not-a-websocket.example")['code'] == "URL_INVALID", "client rejects non-WebSocket URL")
	_check(client.reconnect()["code"] == "URL_UNKNOWN", "client requires a known endpoint before reconnecting")
	_check(client.handle_server_message(JSON.stringify({"ok": true, "player_id": "alice"}))["ok"], "client accepts authenticated server response")
	var client_start := client.handle_server_message(JSON.stringify({"ok": true, "match_id": "match.online.1", "event_seq": 2, "snapshot": {"match_id": "match.online.1"}}))
	_check(client_start["ok"] and client.acknowledged_event_seq == 1, "client acknowledges snapshot sequence")
	var client_event := client.handle_server_message(JSON.stringify({"ok": true, "event_seq": 3, "events": [{"event_seq": 2, "event_type": "PASS"}]}))
	_check(client_event["ok"] and client.acknowledged_event_seq == 2, "client advances contiguous event sequence")
	_check(client.handle_server_message(JSON.stringify({"ok": true, "event_seq": 5, "events": [{"event_seq": 5, "event_type": "GAP"}]}))["code"] == "EVENT_GAP", "client fails closed on event gaps")

	print("MM-09 checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("MM-09 HEADLESS GATES PASS")
	quit(0 if failures.is_empty() else 1)
