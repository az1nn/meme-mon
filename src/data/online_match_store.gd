class_name OnlineMatchStore
extends RefCounted

const PROTOCOL_VERSION := "online-1"

func path_for(directory: String, match_id: String) -> String:
	if directory.is_empty() or match_id.is_empty() or match_id.find("/") >= 0 or match_id.find("\\") >= 0:
		return ""
	return directory.path_join(match_id + ".json")

func load_record(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "code": "FILE_NOT_FOUND"}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	var record: Dictionary = parser.data
	if not _valid_record(record):
		return {"ok": false, "code": "UNKNOWN_PROTOCOL_VERSION"}
	return {"ok": true, "record": record}

func save_record(path: String, record: Dictionary) -> Dictionary:
	if FileAccess.file_exists(path):
		var current := load_record(path)
		if not current["ok"]:
			return {"ok": false, "code": "PERSISTED_MATCH_INVALID"}
		var old_events: Array = current["record"].get("events", [])
		var raw_new_events: Variant = record.get("events", null)
		if typeof(raw_new_events) == TYPE_ARRAY:
			var new_events: Array = raw_new_events
			if new_events.size() < old_events.size():
				return {"ok": false, "code": "EVENT_LOG_NOT_APPEND_ONLY"}
			for index in range(old_events.size()):
				if not _same_value(old_events[index], new_events[index]):
					return {"ok": false, "code": "EVENT_LOG_MUTATED"}
				if typeof(new_events[index]) != TYPE_DICTIONARY or int(new_events[index].get("event_seq", -1)) != index + 1:
					return {"ok": false, "code": "EVENT_SEQUENCE_INVALID"}
			if not new_events.is_empty() and typeof(record.get("state", null)) == TYPE_DICTIONARY and int(record["state"].get("next_event_seq", 0)) <= int(new_events[-1].get("event_seq", 0)):
				return {"ok": false, "code": "EVENT_SEQUENCE_INVALID"}
	if not _valid_record(record):
		return {"ok": false, "code": "UNKNOWN_PROTOCOL_VERSION"}
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())) != OK:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	file.store_string(JSON.stringify(record, "\t", true) + "\n")
	file.close()
	return {"ok": true}

func _valid_record(record: Dictionary) -> bool:
	if str(record.get("protocol_version", "")) != PROTOCOL_VERSION:
		return false
	if str(record.get("match_id", "")).is_empty():
		return false
	if typeof(record.get("events", null)) != TYPE_ARRAY or typeof(record.get("accepted_intents", null)) != TYPE_ARRAY:
		return false
	if typeof(record.get("catalog", null)) != TYPE_DICTIONARY or typeof(record.get("decks", null)) != TYPE_DICTIONARY:
		return false
	if typeof(record.get("state", null)) != TYPE_DICTIONARY or not record.has("seed"):
		return false
	if str(record.get("format_id", "")).is_empty() or str(record.get("rules_version", "")).is_empty() or str(record.get("engine_version", "")).is_empty():
		return false
	if str(record["state"].get("match_id", "")) != str(record["match_id"]) or int(record["state"].get("next_event_seq", 0)) != record["events"].size() + 1:
		return false
	for index in range(record["events"].size()):
		var event: Variant = record["events"][index]
		if typeof(event) != TYPE_DICTIONARY or int(event.get("event_seq", -1)) != index + 1 or str(event.get("match_id", "")) != str(record["match_id"]) or str(event.get("schema_version", "")) != "alpha-0.1" or str(event.get("rules_version", "")) != str(record["rules_version"]):
			return false
	for accepted in record["accepted_intents"]:
		if typeof(accepted) != TYPE_DICTIONARY or str(accepted.get("public_player_id", "")).is_empty() or typeof(accepted.get("intent", null)) != TYPE_DICTIONARY or str(accepted["intent"].get("match_id", "")) != str(record["match_id"]):
			return false
	return true

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
