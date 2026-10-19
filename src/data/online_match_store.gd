class_name OnlineMatchStore
extends RefCounted

const PROTOCOL_VERSION := "online-1"

func load_record(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "code": "FILE_NOT_FOUND"}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	var record: Dictionary = parser.data
	if str(record.get("protocol_version", "")) != PROTOCOL_VERSION or str(record.get("match_id", "")).is_empty() or typeof(record.get("events", null)) != TYPE_ARRAY or typeof(record.get("accepted_intents", null)) != TYPE_ARRAY:
		return {"ok": false, "code": "UNKNOWN_PROTOCOL_VERSION"}
	return {"ok": true, "record": record}

func save_record(path: String, record: Dictionary) -> Dictionary:
	if str(record.get("protocol_version", "")) != PROTOCOL_VERSION:
		return {"ok": false, "code": "UNKNOWN_PROTOCOL_VERSION"}
	if FileAccess.file_exists(path):
		var current := load_record(path)
		if not current["ok"]:
			return {"ok": false, "code": "PERSISTED_MATCH_INVALID"}
		if int(record.get("events", []).size()) < int(current["record"].get("events", []).size()):
			return {"ok": false, "code": "EVENT_LOG_NOT_APPEND_ONLY"}
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())) != OK:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	file.store_string(JSON.stringify(record, "\t", true) + "\n")
	file.close()
	return {"ok": true}
