extends SceneTree

const AuthoritativeMatchService = preload("res://src/domain/authoritative_match_service.gd")
const OnlineMatchStore = preload("res://src/data/online_match_store.gd")

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
	var alice_token := "aaaaaaaaaaaaaaaa"
	var bob_token := "bbbbbbbbbbbbbbbb"
	_check(service.register_session("alice", alice_token)["ok"], "authoritative service registers first session")
	_check(service.register_session("bob", bob_token)["ok"], "authoritative service registers second session")
	var started: Dictionary = service.start_match("match.online.1", alice_token, bob_token, _deck(chosen), _deck(chosen), catalog, legal, 12345)
	_check(started["ok"], "authority locks legal canonical deck and starts seeded match")
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
	var online_store := OnlineMatchStore.new()
	var online_path := "user://mm09-tests/match.json"
	var record: Dictionary = service.export_match_record("match.online.1")
	_check(record["ok"] and online_store.save_record(online_path, record["record"])["ok"], "authoritative match record persists append-only events")
	_check(online_store.load_record(online_path)["ok"], "authoritative match record reloads")
	var truncated: Dictionary = record["record"].duplicate(true)
	truncated["events"] = []
	_check(online_store.save_record(online_path, truncated)["code"] == "EVENT_LOG_NOT_APPEND_ONLY", "persisted event log cannot be truncated")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(online_path))
	var illegal: Array = _deck(chosen)
	illegal[0] = {"card_id": "sandbox.preview.classic", "edition_id": "sandbox.local.1"}
	_check(service.start_match("match.online.bad", alice_token, bob_token, illegal, _deck(chosen), catalog, legal, 1)["code"] == "FORMAT_ILLEGAL_CARD", "Sandbox/non-Canon deck reference cannot start online match")

	print("MM-09 checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("MM-09 HEADLESS GATES PASS")
	quit(0 if failures.is_empty() else 1)
