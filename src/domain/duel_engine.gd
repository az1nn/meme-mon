class_name DuelEngine
extends RefCounted

const MemeRng = preload("res://src/domain/rng.gd")
const ContractLoader = preload("res://src/data/contract_loader.gd")

var cards: Dictionary = {}
var state: Dictionary = {}
var events: Array = []
var rng = null
var last_rejection: String = ""
var _instance_counter: int = 0
var _resolving_triggers: bool = false
var _queued_trigger_events: Array = []

func load_card_definitions(definitions: Array) -> Dictionary:
	var result: Dictionary = ContractLoader.new().catalog_from_definitions(definitions)
	if result["ok"]:
		cards = result["cards"]
	return {"ok": result["ok"], "code": result.get("code", "OK"), "count": result.get("count", 0)}

func load_card_file(path: String) -> Dictionary:
	var result: Dictionary = ContractLoader.new().load_card_catalog(path)
	if result["ok"]:
		cards = result["cards"]
	return {"ok": result["ok"], "code": result.get("code", "OK"), "count": result.get("count", 0)}

func new_match(seed: int, deck_a: Array, deck_b: Array, first_player: String = "") -> Dictionary:
	events = []
	last_rejection = ""
	_instance_counter = 0
	rng = MemeRng.new(seed)
	var p1 := _make_player("p1", deck_a)
	var p2 := _make_player("p2", deck_b)
	if p1.is_empty() or p2.is_empty():
		return {"ok": false, "code": "UNKNOWN_CARD_EDITION"}
	p1["deck"] = rng.shuffle_array(p1["deck"])
	p2["deck"] = rng.shuffle_array(p2["deck"])
	var chosen := first_player
	if chosen == "":
		chosen = "p1" if rng.bounded(2) == 0 else "p2"
	state = {
		"schema_version": "alpha-0.1",
		"rules_version": "alpha-0.1",
		"rng_version": "xorshift32-v1",
		"match_id": "local",
		"match_seed": seed,
		"turn_number": 1,
		"phase": "setup",
		"active_player_id": chosen,
		"players": {"p1": p1, "p2": p2},
		"pending_replacements": [],
		"end_after_replacement": false,
		"next_event_seq": 1,
		"terminal": null
	}
	for pid in ["p1", "p2"]:
		for _i in range(5):
			if not _draw_card(pid, false):
				return {"ok": false, "code": "DECK_SIZE_INVALID"}
		_repair_opening_hand(pid)
		_auto_field(pid)
	_begin_turn()
	return {"ok": true}

func _make_player(pid: String, editions: Array) -> Dictionary:
	var deck: Array = []
	for edition in editions:
		var eid := str(edition)
		if not cards.has(eid):
			return {}
		deck.append(make_instance(pid, eid, "deck"))
	return {
		"player_id": pid,
		"deck": deck,
		"hand": [],
		"active": null,
		"queue": [],
		"archive": [],
		"format": null,
		"hype": 0,
		"trend": {"current": 0, "cap": 1},
		"turns_taken": 0,
		"turn_markers": {"baseline_attack_used": false, "voluntary_switch_used": false},
		"ability_used": {},
		"trigger_used": {}
	}

func make_instance(pid: String, edition_id: String, prefix: String = "card") -> Dictionary:
	_instance_counter += 1
	var card: Dictionary = cards.get(edition_id, {})
	var instance := {
		"instance_id": "%s.%s.%03d" % [pid, prefix, _instance_counter],
		"edition_id": edition_id
	}
	if str(card.get("kind", "")) == "mememom":
		instance["hp_remaining"] = int(card["mememom"]["hp"])
	return instance

func apply_intent(intent: Dictionary) -> Dictionary:
	var event_start := events.size()
	last_rejection = ""
	if state.is_empty():
		return _reject("MATCH_NOT_STARTED")
	if state["terminal"] != null:
		return _reject("MATCH_ALREADY_ENDED")
	if str(intent.get("schema_version", "")) != "alpha-0.1":
		return _reject("UNKNOWN_SCHEMA_VERSION")
	if str(intent.get("rules_version", "")) != "alpha-0.1":
		return _reject("RULES_VERSION_MISMATCH")
	if str(intent.get("intent_id", "")).is_empty():
		return _reject("SCHEMA_INVALID")
	if str(intent.get("match_id", "")) != str(state["match_id"]):
		return _reject("MATCH_ID_MISMATCH")
	if int(intent.get("expected_event_seq", state["next_event_seq"])) != int(state["next_event_seq"]):
		return _reject("STALE_EVENT_SEQ")
	var pid := str(intent.get("player_id", ""))
	var kind := str(intent.get("kind", ""))
	if pid not in ["p1", "p2"]:
		return _reject("UNKNOWN_PLAYER")
	if not state["pending_replacements"].is_empty():
		if kind != "choose_replacement" or pid != str(state["pending_replacements"][0]):
			return _reject("REPLACEMENT_REQUIRED")
		var result := _choose_replacement(pid, intent.get("payload", {}))
		if not result["ok"]:
			return result
		return {"ok": true, "events": events.slice(event_start)}
	if pid != str(state["active_player_id"]):
		return _reject("NOT_ACTIVE_PLAYER")
	if str(state["phase"]) != "main":
		return _reject("WRONG_PHASE")
	var result: Dictionary
	match kind:
		"play_card":
			result = _play_card(pid, intent.get("payload", {}))
		"switch_active":
			result = _switch_active(pid, intent.get("payload", {}))
		"activate_ability":
			result = _activate_ability(pid, intent.get("payload", {}))
		"attack":
			result = _attack(pid)
		"pass":
			_end_turn()
			result = {"ok": true}
		_:
			result = _reject("UNKNOWN_INTENT")
	if not result["ok"]:
		return result
	return {"ok": true, "events": events.slice(event_start)}

func _play_card(pid: String, payload: Dictionary) -> Dictionary:
	var player: Dictionary = state["players"][pid]
	var index := int(payload.get("hand_index", -1))
	if index < 0 or index >= player["hand"].size():
		return _reject("INVALID_TARGET")
	var instance: Dictionary = player["hand"][index]
	var card: Dictionary = cards[instance["edition_id"]]
	var cost := int(card["trend_cost"])
	if int(player["trend"]["current"]) < cost:
		return _reject("INSUFFICIENT_TREND")
	var kind := str(card["kind"])
	if kind == "mememom" and player["queue"].size() >= 3:
		return _reject("QUEUE_FULL")
	_spend_trend(pid, cost)
	player["hand"].remove_at(index)
	if kind == "mememom":
		player["queue"].append(instance)
	elif kind == "reaction":
		player["archive"].append(instance)
		_apply_effects(pid, card["reaction"]["effects"])
	elif kind == "format":
		if player["format"] != null:
			player["archive"].append(player["format"])
		player["format"] = instance
		_apply_effects(pid, card["format"].get("effects", []))
	_emit("CARD_PLAYED", pid, {"instance_id": instance["instance_id"], "edition_id": instance["edition_id"], "kind": kind})
	_resolve_triggers("entered_play")
	_checkpoint()
	return {"ok": true}

func _switch_active(pid: String, payload: Dictionary) -> Dictionary:
	var player: Dictionary = state["players"][pid]
	if bool(player["turn_markers"]["voluntary_switch_used"]):
		return _reject("SWITCH_LIMIT")
	if player["queue"].is_empty():
		return _reject("INVALID_TARGET")
	if int(player["trend"]["current"]) < 1:
		return _reject("INSUFFICIENT_TREND")
	var index := int(payload.get("queue_index", 0))
	if index < 0 or index >= player["queue"].size():
		return _reject("INVALID_TARGET")
	_spend_trend(pid, 1)
	var incoming: Dictionary = player["queue"][index]
	var outgoing = player["active"]
	player["queue"][index] = outgoing
	player["active"] = incoming
	player["turn_markers"]["voluntary_switch_used"] = true
	_emit("ACTIVE_SWITCHED", pid, {"instance_id": incoming["instance_id"], "voluntary": true})
	_resolve_triggers("switched_in")
	return {"ok": true}

func _activate_ability(pid: String, payload: Dictionary) -> Dictionary:
	var player: Dictionary = state["players"][pid]
	if player["active"] == null:
		return _reject("NO_ACTIVE")
	var instance: Dictionary = player["active"]
	var card: Dictionary = cards[instance["edition_id"]]
	var ability_id := str(payload.get("ability_id", ""))
	var ability: Dictionary = {}
	for candidate in card.get("mememom", {}).get("activated_abilities", []):
		if str(candidate.get("ability_id", "")) == ability_id:
			ability = candidate
			break
	if ability.is_empty():
		return _reject("INVALID_TARGET")
	var key := str(instance["instance_id"]) + ":" + ability_id
	if bool(ability.get("once_per_turn", false)) and player["ability_used"].has(key):
		return _reject("ABILITY_LIMIT")
	var cost := int(ability.get("trend_cost", 0))
	if int(player["trend"]["current"]) < cost:
		return _reject("INSUFFICIENT_TREND")
	_spend_trend(pid, cost)
	_apply_effects(pid, ability.get("effects", []))
	if bool(ability.get("once_per_turn", false)):
		player["ability_used"][key] = true
	_checkpoint()
	return {"ok": true}

func _attack(pid: String) -> Dictionary:
	var player: Dictionary = state["players"][pid]
	if player["active"] == null:
		return _reject("NO_ACTIVE")
	if bool(player["turn_markers"]["baseline_attack_used"]):
		return _reject("ATTACK_LIMIT")
	var opponent_id := _other(pid)
	var opponent: Dictionary = state["players"][opponent_id]
	if opponent["active"] == null:
		return _reject("INVALID_TARGET")
	var attacker: Dictionary = player["active"]
	var card: Dictionary = cards[attacker["edition_id"]]
	var attack: Dictionary = card["mememom"]["attack"]
	var cost := int(attack.get("trend_cost", 0))
	if int(player["trend"]["current"]) < cost:
		return _reject("INSUFFICIENT_TREND")
	_spend_trend(pid, cost)
	player["turn_markers"]["baseline_attack_used"] = true
	_emit("ATTACK_DECLARED", pid, {"instance_id": attacker["instance_id"], "attack_id": attack["attack_id"]})
	_resolve_triggers("attack_declared")
	if state["terminal"] != null:
		return {"ok": true}
	var target: Dictionary = opponent["active"]
	var damage := int(attack.get("damage", 0))
	target["hp_remaining"] = int(target["hp_remaining"]) - damage
	_emit("DAMAGE_APPLIED", pid, {"target_instance_id": target["instance_id"], "amount": damage})
	_apply_effects(pid, attack.get("effects", []))
	_checkpoint()
	if state["terminal"] == null:
		_resolve_triggers("damage_dealt")
		_checkpoint()
	if state["terminal"] == null:
		if state["pending_replacements"].is_empty():
			_end_turn()
		else:
			state["end_after_replacement"] = true
	return {"ok": true}

func _choose_replacement(pid: String, payload: Dictionary) -> Dictionary:
	var player: Dictionary = state["players"][pid]
	var source := str(payload.get("source", "queue"))
	var index := int(payload.get("index", 0))
	var incoming = null
	if not player["queue"].is_empty():
		if source != "queue" or index < 0 or index >= player["queue"].size():
			return _reject("REPLACEMENT_PRIORITY")
		incoming = player["queue"].pop_at(index)
	else:
		if source != "hand" or index < 0 or index >= player["hand"].size():
			return _reject("INVALID_TARGET")
		var candidate: Dictionary = player["hand"][index]
		if str(cards[candidate["edition_id"]]["kind"]) != "mememom":
			return _reject("INVALID_TARGET")
		incoming = candidate
		player["hand"].remove_at(index)
	player["active"] = incoming
	state["pending_replacements"].pop_front()
	_emit("REPLACEMENT_CHOSEN", pid, {"instance_id": incoming["instance_id"], "source": source})
	_emit("ACTIVE_SWITCHED", pid, {"instance_id": incoming["instance_id"], "voluntary": false})
	_resolve_triggers("switched_in")
	if state["pending_replacements"].is_empty() and bool(state["end_after_replacement"]) and state["terminal"] == null:
		state["end_after_replacement"] = false
		_end_turn()
	return {"ok": true}

func _spend_trend(pid: String, amount: int) -> void:
	if amount <= 0:
		return
	var player: Dictionary = state["players"][pid]
	player["trend"]["current"] = int(player["trend"]["current"]) - amount
	_emit("TREND_SPENT", pid, {"amount": amount})

func _begin_turn() -> void:
	if state["terminal"] != null:
		return
	var pid := str(state["active_player_id"])
	var player: Dictionary = state["players"][pid]
	for reset_pid in ["p1", "p2"]:
		state["players"][reset_pid]["trigger_used"] = {}
	state["phase"] = "start"
	player["turns_taken"] = int(player["turns_taken"]) + 1
	if int(player["turns_taken"]) > 1:
		player["trend"]["cap"] = min(5, int(player["trend"]["cap"]) + 1)
	player["trend"]["current"] = int(player["trend"]["cap"])
	player["turn_markers"]["baseline_attack_used"] = false
	player["turn_markers"]["voluntary_switch_used"] = false
	player["ability_used"] = {}
	_emit("TURN_STARTED", pid, {"turn_number": state["turn_number"], "trend_cap": player["trend"]["cap"]})
	_resolve_triggers("turn_started")
	_checkpoint()
	if state["terminal"] != null:
		return
	state["phase"] = "draw"
	if not _draw_card(pid, true):
		_end_match(_other(pid), "deck_out")
		return
	_resolve_triggers("card_drawn")
	_checkpoint()
	if state["terminal"] == null:
		state["phase"] = "main"

func _end_turn() -> void:
	if state["terminal"] != null:
		return
	var pid := str(state["active_player_id"])
	state["phase"] = "end"
	_emit("TURN_ENDING", pid, {})
	_resolve_triggers("turn_ending")
	_checkpoint()
	if state["terminal"] != null:
		return
	_emit("TURN_ENDED", pid, {})
	state["active_player_id"] = _other(pid)
	state["turn_number"] = int(state["turn_number"]) + 1
	_begin_turn()

func _draw_card(pid: String, emit_event: bool = true) -> bool:
	var player: Dictionary = state["players"][pid] if not state.is_empty() else {}
	if player.is_empty() or player["deck"].is_empty():
		return false
	var card = player["deck"].pop_back()
	player["hand"].append(card)
	if emit_event:
		_emit("CARD_DRAWN", pid, {"instance_id": card["instance_id"]})
	return true

func _repair_opening_hand(pid: String) -> void:
	var player: Dictionary = state["players"][pid]
	var guard := 0
	while not _zone_has_mememom(player["hand"]) and guard < 32:
		for instance in player["hand"]:
			player["deck"].append(instance)
		player["hand"] = []
		player["deck"] = rng.shuffle_array(player["deck"])
		for _i in range(min(5, player["deck"].size())):
			_draw_card(pid, false)
		guard += 1

func repair_opening_hand_for_test(pid: String) -> void:
	_repair_opening_hand(pid)

func _auto_field(pid: String) -> void:
	var player: Dictionary = state["players"][pid]
	for i in range(player["hand"].size()):
		var instance: Dictionary = player["hand"][i]
		if str(cards[instance["edition_id"]]["kind"]) == "mememom":
			player["active"] = instance
			player["hand"].remove_at(i)
			break
	var index: int = player["hand"].size() - 1
	while index >= 0 and player["queue"].size() < 3:
		var instance: Dictionary = player["hand"][index]
		if str(cards[instance["edition_id"]]["kind"]) == "mememom":
			player["queue"].append(instance)
			player["hand"].remove_at(index)
		index -= 1
	if player["active"] == null:
		_end_match(_other(pid), "no_field")

func _apply_effects(owner_pid: String, effects: Array) -> void:
	for effect in effects:
		_apply_effect(owner_pid, effect)
		if state["terminal"] != null:
			return

func _apply_effect(owner_pid: String, effect: Dictionary) -> void:
	var primitive := str(effect.get("primitive", ""))
	var target_info: Dictionary = effect.get("target", {})
	var target_pid := owner_pid if str(target_info.get("side", "self")) == "self" else _other(owner_pid)
	var target_player: Dictionary = state["players"][target_pid]
	match primitive:
		"deal_damage":
			if target_player["active"] != null:
				var amount := int(effect.get("amount", 0))
				target_player["active"]["hp_remaining"] = int(target_player["active"]["hp_remaining"]) - amount
				_emit("DAMAGE_APPLIED", owner_pid, {"target_instance_id": target_player["active"]["instance_id"], "amount": amount})
		"heal":
			if target_player["active"] != null:
				var instance: Dictionary = target_player["active"]
				var base_hp := int(cards[instance["edition_id"]]["mememom"]["hp"])
				var amount := int(effect.get("amount", 0))
				instance["hp_remaining"] = min(base_hp, int(instance["hp_remaining"]) + amount)
				_emit("HEAL_APPLIED", owner_pid, {"target_instance_id": instance["instance_id"], "amount": amount})
		"draw":
			for _i in range(int(effect.get("amount", 1))):
				if not _draw_card(target_pid, true):
					_end_match(_other(target_pid), "deck_out")
					return
				_resolve_triggers("card_drawn")
				_checkpoint()
				if state["terminal"] != null:
					return
		"gain_trend":
			var amount := int(effect.get("amount", 1))
			target_player["trend"]["current"] = min(int(target_player["trend"]["cap"]), int(target_player["trend"]["current"]) + amount)
		"force_switch":
			if not target_player["queue"].is_empty() and target_player["active"] != null:
				var incoming = target_player["queue"][0]
				target_player["queue"][0] = target_player["active"]
				target_player["active"] = incoming
				_emit("ACTIVE_SWITCHED", owner_pid, {"instance_id": incoming["instance_id"], "voluntary": false})
		"set_action_allowance":
			var allowance := str(effect.get("allowance", ""))
			var value := int(effect.get("value", 0))
			if allowance == "attack":
				target_player["turn_markers"]["baseline_attack_used"] = value <= 0
			elif allowance == "voluntary_switch":
				target_player["turn_markers"]["voluntary_switch_used"] = value <= 0

func _resolve_triggers(trigger_event: String) -> void:
	if state.is_empty() or state["terminal"] != null:
		return
	_queued_trigger_events.append(trigger_event)
	if _resolving_triggers:
		return
	_resolving_triggers = true
	while not _queued_trigger_events.is_empty() and state["terminal"] == null:
		var next_event: String = str(_queued_trigger_events.pop_front())
		_resolve_trigger_wave(next_event)
	_resolving_triggers = false

func _resolve_trigger_wave(trigger_event: String) -> void:
	var order: Array = [str(state["active_player_id"]), _other(str(state["active_player_id"]))]
	for pid in order:
		var player: Dictionary = state["players"][pid]
		var sources: Array = []
		if player["active"] != null:
			sources.append(player["active"])
		if player["format"] != null:
			sources.append(player["format"])
		for instance in sources:
			var card: Dictionary = cards[instance["edition_id"]]
			var triggers: Array = []
			if str(card["kind"]) == "mememom":
				triggers = card["mememom"].get("triggers", [])
			elif str(card["kind"]) == "format":
				triggers = card["format"].get("triggers", [])
			for trigger in triggers:
				if str(trigger.get("event", "")) != trigger_event:
					continue
				var trigger_key: String = str(instance["instance_id"]) + ":" + str(trigger["trigger_id"])
				if bool(trigger.get("once_per_turn", false)) and player["trigger_used"].has(trigger_key):
					continue
				if bool(trigger.get("once_per_turn", false)):
					player["trigger_used"][trigger_key] = true
				_emit("TRIGGER_ORDERED", pid, {"trigger_id": trigger["trigger_id"], "source_instance_id": instance["instance_id"], "event": trigger_event})
				_apply_effects(pid, trigger.get("effects", []))
				_checkpoint()
				if state["terminal"] != null:
					return

func resolve_trigger_event_for_test(trigger_event: String) -> void:
	_resolve_triggers(trigger_event)

func _checkpoint() -> void:
	if state.is_empty() or state["terminal"] != null:
		return
	var kos: Array = []
	for pid in ["p1", "p2"]:
		var player: Dictionary = state["players"][pid]
		if player["active"] != null and int(player["active"].get("hp_remaining", 1)) <= 0:
			kos.append({"owner": pid, "instance": player["active"]})
	for ko in kos:
		var owner := str(ko["owner"])
		var player: Dictionary = state["players"][owner]
		var instance: Dictionary = ko["instance"]
		player["active"] = null
		player["archive"].append(instance)
		_emit("MEMEMOM_KO", _other(owner), {"owner_player_id": owner, "instance_id": instance["instance_id"]})
		var card: Dictionary = cards[instance["edition_id"]]
		var award := 2 if str(card.get("tier", "standard")) == "headliner" else 1
		var scorer := _other(owner)
		state["players"][scorer]["hype"] = int(state["players"][scorer]["hype"]) + award
		_emit("HYPE_CHANGED", scorer, {"delta": award, "hype": state["players"][scorer]["hype"]})
	var p1_win := int(state["players"]["p1"]["hype"]) >= 5
	var p2_win := int(state["players"]["p2"]["hype"]) >= 5
	if p1_win and p2_win:
		_end_match("", "simultaneous")
		return
	if p1_win:
		_end_match("p1", "hype")
		return
	if p2_win:
		_end_match("p2", "hype")
		return
	for ko in kos:
		var owner := str(ko["owner"])
		var player: Dictionary = state["players"][owner]
		if player["active"] != null:
			continue
		if not player["queue"].is_empty() or _zone_has_mememom(player["hand"]):
			if owner not in state["pending_replacements"]:
				state["pending_replacements"].append(owner)
				_emit("REPLACEMENT_REQUIRED", owner, {})
		else:
			_end_match(_other(owner), "no_field")
			return

func checkpoint_for_test() -> void:
	_checkpoint()

func _end_match(winner: String, reason: String) -> void:
	if state.get("terminal", null) != null:
		return
	var result := "draw" if winner == "" else "player_win"
	state["terminal"] = {"result": result, "winner_player_id": winner, "reason": reason}
	state["phase"] = "terminal"
	_emit("MATCH_ENDED", winner, state["terminal"].duplicate(true))

func _emit(event_type: String, actor: String, payload: Dictionary) -> void:
	var event := {
		"schema_version": "alpha-0.1",
		"rules_version": "alpha-0.1",
		"match_id": str(state["match_id"]),
		"event_seq": int(state["next_event_seq"]),
		"event_type": event_type,
		"actor_player_id": actor,
		"payload": payload.duplicate(true)
	}
	events.append(event)
	state["next_event_seq"] = int(state["next_event_seq"]) + 1

func _zone_has_mememom(zone: Array) -> bool:
	for instance in zone:
		if str(cards[instance["edition_id"]]["kind"]) == "mememom":
			return true
	return false

func _other(pid: String) -> String:
	return "p2" if pid == "p1" else "p1"

func _reject(code: String) -> Dictionary:
	last_rejection = code
	return {"ok": false, "code": code}

func export_match_state() -> Dictionary:
	var players_out: Array = []
	for pid in ["p1", "p2"]:
		var player: Dictionary = state["players"][pid]
		players_out.append({
			"player_id": pid,
			"deck": _zone_editions(player["deck"]),
			"hand": _zone_editions(player["hand"]),
			"active": null if player["active"] == null else str(player["active"]["edition_id"]),
			"queue": _zone_editions(player["queue"]),
			"archive": _zone_editions(player["archive"]),
			"format": null if player["format"] == null else str(player["format"]["edition_id"]),
			"hype": int(player["hype"]),
			"trend": {"current": int(player["trend"]["current"]), "cap": int(player["trend"]["cap"])},
			"turn_markers": {
				"baseline_attack_used": bool(player["turn_markers"]["baseline_attack_used"]),
				"voluntary_switch_used": bool(player["turn_markers"]["voluntary_switch_used"])
			}
		})
	var pending: Array = []
	for trigger_event in _queued_trigger_events:
		pending.append({"event": str(trigger_event)})
	return {
		"schema_version": "alpha-0.1",
		"rules_version": "alpha-0.1",
		"rng_version": "xorshift32-v1",
		"match_id": str(state["match_id"]),
		"match_seed": int(state["match_seed"]),
		"rng_state": int(rng.state),
		"rng_index": int(rng.rng_index),
		"turn_number": int(state["turn_number"]),
		"phase": "end" if state["terminal"] != null else str(state["phase"]),
		"active_player_id": str(state["active_player_id"]),
		"players": players_out,
		"pending_triggers": pending,
		"next_event_seq": int(state["next_event_seq"]),
		"terminal": null if state["terminal"] == null else state["terminal"].duplicate(true)
	}

func _zone_editions(zone: Array) -> Array:
	var out: Array = []
	for instance in zone:
		out.append(str(instance["edition_id"]))
	return out

func normalized_snapshot() -> String:
	var snapshot := state.duplicate(true)
	if rng != null:
		snapshot["rng_state"] = rng.state
		snapshot["rng_index"] = rng.rng_index
	return JSON.stringify({"state": snapshot, "events": events})
