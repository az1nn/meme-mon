extends SceneTree

# Closed-beta MM-09 transport adapter. Run only as a headless server:
#   godot --headless --path . --script res://server/authoritative_websocket.gd
# It intentionally starts with no authenticated sessions. Configure the
# operator-provided JSON map in MEMEMOM_BETA_SESSIONS, e.g.
# {"opaque-token-at-least-16":"player-id"}. Do not put this value in Git.

const AuthoritativeMatchService = preload("res://src/domain/authoritative_match_service.gd")
const CanonModel = preload("res://src/domain/canon_model.gd")
const CanonStore = preload("res://src/data/canon_store.gd")

var listener := TCPServer.new()
var authority := AuthoritativeMatchService.new()
var canon := CanonModel.new()
var peers: Dictionary = {}
var peer_tokens: Dictionary = {}

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
	if listener.listen(port) != OK:
		push_error("MM-09 could not bind WebSocket port %d" % port)
		quit(1)
		return
	print("MM-09 closed-beta WebSocket listening on port %d" % port)

func _process(_delta: float) -> bool:
	while listener.is_connection_available():
		var peer := WebSocketPeer.new()
		peer.accept_stream(listener.take_connection())
		peers[str(peer.get_instance_id())] = peer
	for peer_id in peers.keys():
		var peer: WebSocketPeer = peers[peer_id]
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_CLOSED:
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
		_send(peer, {"ok": false, "code": "MESSAGE_INVALID"})
		return
	var command := str(request.get("command", ""))
	if command == "authenticate":
		var token := str(request.get("token", ""))
		if not authority.sessions.has(token):
			_send(peer, {"ok": false, "code": "UNAUTHORIZED"})
			return
		peer_tokens[peer_id] = token
		_send(peer, {"ok": true, "player_id": authority.sessions[token]})
		return
	if not peer_tokens.has(peer_id):
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
			_send(peer, {"ok": false, "code": "COMMAND_UNKNOWN"})

func _start_match(token: String, request: Dictionary) -> Dictionary:
	var format_id := str(request.get("format_id", ""))
	if not canon.formats.has(format_id):
		return {"ok": false, "code": "FORMAT_ILLEGAL_CARD"}
	var format: Dictionary = canon.formats[format_id]
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
	return authority.start_match(str(request.get("match_id", "")), token, opponent_token, request.get("deck", []), request.get("opponent_deck", []), catalog, legal, int(request.get("seed", 0)))

func _send(peer: WebSocketPeer, payload: Dictionary) -> void:
	peer.send_text(JSON.stringify(payload))
