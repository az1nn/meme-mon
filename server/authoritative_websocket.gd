extends SceneTree

# Closed-beta MM-09 transport adapter. Run only as a headless server:
#   godot --headless --path . --script res://server/authoritative_websocket.gd
# It intentionally starts with no authenticated sessions. Configure the
# operator-provided JSON map in MEMEMOM_BETA_SESSIONS, e.g.
# {"opaque-token-at-least-16":"player-id"}. Do not put this value in Git.

const AuthoritativeMatchService = preload("res://src/domain/authoritative_match_service.gd")
const CanonModel = preload("res://src/domain/canon_model.gd")
const CanonStore = preload("res://src/data/canon_store.gd")
const OnlineMatchStore = preload("res://src/data/online_match_store.gd")

var listener := TCPServer.new()
var authority := AuthoritativeMatchService.new()
var canon := CanonModel.new()
var peers: Dictionary = {}
var peer_tokens: Dictionary = {}
var canon_public_keys: Dictionary = {}

func _init() -> void:
	var port: int = int(OS.get_environment("MEMEMOM_WS_PORT"))
	if port <= 0:
		port = 9080
	var canon_path: String = OS.get_environment("MEMEMOM_CANON_PATH")
	if canon_path.is_empty():
		canon_path = "user://mememom/canon.json"
	var stored: Dictionary = CanonStore.new().load_state(canon_path)
	if not stored["ok"] or not canon.import_state(stored["state"])["ok"]:
		push_error("MM-09 refuses to start without a valid Canon state at " + canon_path)
		quit(1)
		return
	var public_keys_env := OS.get_environment("MEMEMOM_CANON_PUBLIC_KEYS")
	var public_keys_raw: Variant = null
	if not public_keys_env.is_empty():
		public_keys_raw = JSON.parse_string(public_keys_env)
		if typeof(public_keys_raw) != TYPE_DICTIONARY:
			push_error("MM-09 refuses invalid MEMEMOM_CANON_PUBLIC_KEYS JSON")
			quit(1)
			return
		canon_public_keys = public_keys_raw
	for set_id in canon.sets:
		var set: Dictionary = canon.sets[set_id]
		var signature: Variant = set.get("signature", null)
		if signature == null:
			push_error("MM-09 refuses unsigned Canon set: " + str(set_id))
			quit(1)
			return
		var key_id := str(signature.get("key_id", ""))
		if not canon_public_keys.has(key_id) or not canon.verify_set_signature(str(set_id), str(canon_public_keys[key_id]))["ok"]:
			push_error("MM-09 refuses Canon set with unverifiable signature: " + str(set_id))
			quit(1)
			return
	var sessions_raw: Variant = JSON.parse_string(OS.get_environment("MEMEMOM_BETA_SESSIONS"))
	if typeof(sessions_raw) != TYPE_DICTIONARY:
		push_error("MM-09 refuses to start without MEMEMOM_BETA_SESSIONS JSON")
		quit(1)
		return
	for token in sessions_raw:
		var registered := authority.register_session(str(sessions_raw[token]), str(token))
		if not registered["ok"]:
			push_error("MM-09 session configuration rejected")
			quit(1)
			return
	var match_directory := OS.get_environment("MEMEMOM_MATCH_DATA_PATH")
	if match_directory.is_empty():
		match_directory = "user://mememom/matches"
	var persistence := authority.configure_persistence(match_directory)
	if not persistence["ok"]:
		push_error("MM-09 refuses invalid match persistence configuration")
		quit(1)
		return
	if not _restore_matches(match_directory):
		push_error("MM-09 refuses to start with an invalid persisted match")
		quit(1)
		return
	if listener.listen(port) != OK:
		push_error("MM-09 could not bind WebSocket port %d" % port)
		quit(1)
		return
	print("MM-09 closed-beta WebSocket listening on port %d" % port)

func _process(_delta: float) -> bool:
	authority.tick()
	while listener.is_connection_available():
		var peer := WebSocketPeer.new()
		peer.accept_stream(listener.take_connection())
		peers[str(peer.get_instance_id())] = peer
	for peer_id in peers.keys():
		var peer: WebSocketPeer = peers[peer_id]
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			if peer_tokens.has(peer_id):
				authority.mark_player_disconnected(str(peer_tokens[peer_id]))
			peers.erase(peer_id)
			peer_tokens.erase(peer_id)
			continue
		if peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
			continue
		while peer.get_available_packet_count() > 0:
			if peer.was_string_packet():
				_handle(peer_id, peer, peer.get_packet().get_string_from_utf8())
	return false

func _handle(peer_id: String, peer: WebSocketPeer, text: String) -> void:
	var request: Variant = JSON.parse_string(text)
	if typeof(request) != TYPE_DICTIONARY:
		authority.record_security_failure("MESSAGE_INVALID")
		_send(peer, {"ok": false, "code": "MESSAGE_INVALID"})
		return
	var command := str(request.get("command", ""))
	if command == "authenticate":
		var token := str(request.get("token", ""))
		if not authority.sessions.has(token):
			authority.record_security_failure("UNAUTHORIZED")
			_send(peer, {"ok": false, "code": "UNAUTHORIZED"})
			return
		peer_tokens[peer_id] = token
		_send(peer, {"ok": true, "player_id": authority.sessions[token]})
		return
	if not peer_tokens.has(peer_id):
		authority.record_security_failure("UNAUTHORIZED")
		_send(peer, {"ok": false, "code": "UNAUTHORIZED"})
		return
	var token: String = peer_tokens[peer_id]
	match command:
		"start_match":
			_send(peer, _start_match(token, request))
		"intent":
			_send(peer, authority.apply_authoritative_intent(token, request.get("envelope", {})))
		"reconnect":
			_send(peer, authority.reconnect(token, str(request.get("match_id", "")), int(request.get("acknowledged_event_seq", -1))))
		"replay":
			_send(peer, authority.verify_replay(str(request.get("match_id", ""))))
		_:
			authority.record_security_failure("COMMAND_UNKNOWN")
			_send(peer, {"ok": false, "code": "COMMAND_UNKNOWN"})

func _start_match(token: String, request: Dictionary) -> Dictionary:
	var format_id := str(request.get("format_id", ""))
	if not canon.formats.has(format_id):
		return {"ok": false, "code": "FORMAT_ILLEGAL_CARD"}
	var format: Dictionary = canon.formats[format_id]
	var set_id := str(format.get("set_id", ""))
	if str(format.get("legality_version", "")) != "format-1" or str(format.get("rules_version", "")) != "alpha-0.1" or set_id.is_empty() or not canon.sets.has(set_id) or canon.sets[set_id].get("signature", null) == null:
		return {"ok": false, "code": "FORMAT_ILLEGAL_CARD"}
	if not str(format["retired_at"]).is_empty():
		return {"ok": false, "code": "FORMAT_ILLEGAL_CARD"}
	var opponent_id := str(request.get("opponent_player_id", ""))
	var opponent_token := ""
	for candidate_token in authority.sessions:
		if str(authority.sessions[candidate_token]) == opponent_id:
			opponent_token = str(candidate_token)
			break
	if opponent_token.is_empty() or opponent_token == token:
		return {"ok": false, "code": "OPPONENT_UNAVAILABLE"}
	var catalog: Dictionary = {}
	var legal: Dictionary = {}
	for edition_id in format["allowed_editions"]:
		if not format["suspensions"].has(edition_id):
			catalog[edition_id] = canon.editions[edition_id]["card"].duplicate(true)
			legal[edition_id] = true
	return authority.start_match(str(request.get("match_id", "")), token, opponent_token, request.get("deck", []), request.get("opponent_deck", []), catalog, legal, _authoritative_seed(), format_id)

func _authoritative_seed() -> int:
	var random_bytes := Crypto.new().generate_random_bytes(4)
	if random_bytes.size() == 4:
		var seed := int(random_bytes[0]) | (int(random_bytes[1]) << 8) | (int(random_bytes[2]) << 16) | (int(random_bytes[3]) << 24)
		return seed if seed != 0 else 1
	var fallback := int(Time.get_unix_time_from_system()) ^ int(Time.get_ticks_msec())
	return fallback if fallback != 0 else 1

func _restore_matches(directory_path: String) -> bool:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return true
	directory.list_dir_begin()
	var file_name := directory.get_next()
	var store := OnlineMatchStore.new()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.ends_with(".json"):
			var loaded := store.load_record(directory_path.path_join(file_name))
			if not loaded["ok"]:
				directory.list_dir_end()
				return false
			var record: Dictionary = loaded["record"]
			var token_by_player := {}
			for public_id in record.get("players", {}):
				var found := ""
				for token in authority.sessions:
					if str(authority.sessions[token]) == str(public_id):
						found = str(token)
						break
				if found.is_empty():
					directory.list_dir_end()
					return false
				token_by_player[str(public_id)] = found
			if not authority.restore_match_record(record, token_by_player)["ok"]:
				directory.list_dir_end()
				return false
		file_name = directory.get_next()
	directory.list_dir_end()
	return true

func _send(peer: WebSocketPeer, payload: Dictionary) -> void:
	peer.send_text(JSON.stringify(payload))
