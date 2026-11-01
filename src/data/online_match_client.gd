class_name OnlineMatchClient
extends RefCounted

## Godot-side MM-09 transport boundary. It owns wire state only; authoritative
## match truth remains in the server and arrives through snapshots/events.

signal connection_state_changed(state: String)
signal match_state_changed(snapshot: Dictionary, events: Array)
signal error_received(code: String)
signal reconnect_required

const PROTOCOL_VERSION := "online-1"

var peer: WebSocketPeer
var server_url := ""
var connection_state := "disconnected"
var session_token := ""
var match_id := ""
var acknowledged_event_seq := 0
var last_snapshot: Dictionary = {}
var event_log: Array = []
var pending_auth := false
var reconnect_attempts := 0

func connect_to_url(url: String) -> Dictionary:
	if url.is_empty() or not (url.begins_with("ws://") or url.begins_with("wss://")):
		return _fail("URL_INVALID")
	peer = WebSocketPeer.new()
	server_url = url
	var result := peer.connect_to_url(url)
	if result != OK:
		peer = null
		_set_state("error")
		return _fail("CONNECT_FAILED")
	_set_state("connecting")
	return {"ok": true}

func authenticate(token: String) -> Dictionary:
	if token.length() < 16:
		return _fail("SESSION_INVALID")
	session_token = token
	pending_auth = true
	if peer != null and peer.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		return {"ok": true, "queued": true}
	if not _send({"command": "authenticate", "token": token}):
		return _fail("NOT_CONNECTED")
	return {"ok": true}

func poll() -> void:
	if peer == null:
		return
	peer.poll()
	var ready := peer.get_ready_state()
	if ready == WebSocketPeer.STATE_OPEN and connection_state == "connecting":
		_set_state("connected")
		if not session_token.is_empty() and pending_auth:
			_send({"command": "authenticate", "token": session_token})
	if ready == WebSocketPeer.STATE_CLOSED:
		if connection_state == "connected" or connection_state == "authenticated":
			_set_state("disconnected")
			reconnect_required.emit()
		_set_state("closed")
		return
	while peer.get_available_packet_count() > 0:
		if peer.was_string_packet():
			handle_server_message(peer.get_packet().get_string_from_utf8())

func authenticate_again() -> Dictionary:
	if session_token.is_empty():
		return _fail("SESSION_INVALID")
	pending_auth = true
	return authenticate(session_token)

func reconnect() -> Dictionary:
	if server_url.is_empty():
		return _fail("URL_UNKNOWN")
	if peer != null:
		peer.close()
	peer = null
	reconnect_attempts += 1
	return connect_to_url(server_url)

func start_match(opponent_player_id: String, deck: Array, opponent_deck: Array, format_id: String, requested_match_id: String, seed: int = 0) -> Dictionary:
	return _request({"command": "start_match", "opponent_player_id": opponent_player_id, "deck": deck, "opponent_deck": opponent_deck, "format_id": format_id, "match_id": requested_match_id, "seed": seed})

func send_intent(intent: Dictionary, idempotency_key: String) -> Dictionary:
	if match_id.is_empty() or idempotency_key.is_empty():
		return _fail("REQUEST_INVALID")
	return _request({"command": "intent", "envelope": {"protocol_version": PROTOCOL_VERSION, "match_id": match_id, "idempotency_key": idempotency_key, "intent": intent}})

func request_reconnect() -> Dictionary:
	if match_id.is_empty():
		return _fail("MATCH_UNKNOWN")
	return _request({"command": "reconnect", "match_id": match_id, "acknowledged_event_seq": acknowledged_event_seq})

func request_replay() -> Dictionary:
	if match_id.is_empty():
		return _fail("MATCH_UNKNOWN")
	return _request({"command": "replay", "match_id": match_id})

func disconnect_client() -> void:
	if peer != null:
		peer.close()
	_set_state("disconnected")

func handle_server_message(text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_set_error("MESSAGE_INVALID")
		return _fail("MESSAGE_INVALID")
	var message: Dictionary = parsed
	if not bool(message.get("ok", false)):
		_set_error(str(message.get("code", "SERVER_REJECTED")))
		return message
	if message.has("player_id"):
		pending_auth = false
		_set_state("authenticated")
	if message.has("match_id"):
		match_id = str(message["match_id"])
	if message.has("snapshot") and typeof(message["snapshot"]) == TYPE_DICTIONARY:
		last_snapshot = message["snapshot"].duplicate(true)
	var incoming: Array = message.get("events", []) if typeof(message.get("events", [])) == TYPE_ARRAY else []
	for event in incoming:
		if typeof(event) != TYPE_DICTIONARY:
			_set_error("EVENT_INVALID")
			return _fail("EVENT_INVALID")
		var sequence := int(event.get("event_seq", -1))
		if sequence != acknowledged_event_seq + 1:
			_set_error("EVENT_GAP")
			return _fail("EVENT_GAP")
		event_log.append(event.duplicate(true))
		acknowledged_event_seq = sequence
	var next_seq := int(message.get("next_event_seq", message.get("event_seq", -1)))
	if incoming.is_empty() and message.has("snapshot") and next_seq > 0:
		# A snapshot includes all state through next_seq - 1, even when the
		# response intentionally omits the private event history.
		acknowledged_event_seq = next_seq - 1
	if next_seq > 0 and next_seq != acknowledged_event_seq + 1:
		_set_error("EVENT_SEQUENCE_INVALID")
		return _fail("EVENT_SEQUENCE_INVALID")
	if message.has("snapshot") or not incoming.is_empty():
		match_state_changed.emit(last_snapshot.duplicate(true), incoming.duplicate(true))
	return message

func _request(payload: Dictionary) -> Dictionary:
	if not _send(payload):
		return _fail("NOT_CONNECTED")
	return {"ok": true, "queued": false}

func _send(payload: Dictionary) -> bool:
	if peer == null or peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return false
	peer.send_text(JSON.stringify(payload))
	return true

func _set_state(next: String) -> void:
	if connection_state == next:
		return
	connection_state = next
	connection_state_changed.emit(next)

func _set_error(code: String) -> void:
	error_received.emit(code)

func _fail(code: String) -> Dictionary:
	_set_error(code)
	return {"ok": false, "code": code}
