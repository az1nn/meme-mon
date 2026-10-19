class_name SandboxForgeStore
extends RefCounted

const SANDBOX_VERSION := "sandbox-1"

func load_records(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "code": "FILE_NOT_FOUND"}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	var envelope: Dictionary = parser.data
	if envelope.size() != 2 or str(envelope.get("sandbox_version", "")) != SANDBOX_VERSION or typeof(envelope.get("records", null)) != TYPE_ARRAY:
		return {"ok": false, "code": "UNKNOWN_SANDBOX_VERSION"}
	return {"ok": true, "records": envelope["records"]}

func save_records(path: String, records: Array) -> Dictionary:
	if FileAccess.file_exists(path):
		var current := load_records(path)
		if not current["ok"]:
			return {"ok": false, "code": "PERSISTED_SANDBOX_INVALID"}
	var directory := path.get_base_dir()
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	var target := FileAccess.open(path, FileAccess.WRITE)
	if target == null:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	target.store_string(JSON.stringify({"sandbox_version": SANDBOX_VERSION, "records": records}, "\t", true) + "\n")
	target.flush()
	target.close()
	return {"ok": true}
