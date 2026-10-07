class_name DeterministicBot
extends RefCounted

var player_id: String

func _init(pid: String) -> void:
	player_id = pid

func choose_intent(engine) -> Dictionary:
	var state: Dictionary = engine.state
	var base := {
		"match_id": "local",
		"player_id": player_id,
		"expected_event_seq": int(state["next_event_seq"])
	}
	if not state["pending_replacements"].is_empty() and str(state["pending_replacements"][0]) == player_id:
		var p: Dictionary = state["players"][player_id]
		base["kind"] = "choose_replacement"
		if not p["queue"].is_empty():
			base["payload"] = {"source": "queue", "index": 0}
		else:
			for i in range(p["hand"].size()):
				var instance: Dictionary = p["hand"][i]
				if str(engine.cards[instance["edition_id"]]["kind"]) == "mememom":
					base["payload"] = {"source": "hand", "index": i}
					return base
			base["payload"] = {"source": "hand", "index": 0}
		return base
	if str(state["active_player_id"]) != player_id or str(state["phase"]) != "main":
		base["kind"] = "pass"
		return base
	var player: Dictionary = state["players"][player_id]
	if player["active"] != null:
		var card: Dictionary = engine.cards[player["active"]["edition_id"]]
		var attack_cost := int(card["mememom"]["attack"].get("trend_cost", 0))
		if int(player["trend"]["current"]) >= attack_cost:
			base["kind"] = "attack"
			return base
	if player["queue"].size() < 3:
		for i in range(player["hand"].size()):
			var instance: Dictionary = player["hand"][i]
			var card: Dictionary = engine.cards[instance["edition_id"]]
			if str(card["kind"]) == "mememom" and int(card["trend_cost"]) <= int(player["trend"]["current"]):
				base["kind"] = "play_card"
				base["payload"] = {"hand_index": i}
				return base
	for i in range(player["hand"].size()):
		var instance: Dictionary = player["hand"][i]
		var card: Dictionary = engine.cards[instance["edition_id"]]
		if str(card["kind"]) in ["reaction", "format"] and int(card["trend_cost"]) <= int(player["trend"]["current"]):
			base["kind"] = "play_card"
			base["payload"] = {"hand_index": i}
			return base
	base["kind"] = "pass"
	return base
