class_name SubmissionStore
extends RefCounted

const SUBMISSION_VERSION := "submission-1"

func load_state(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "code": "FILE_NOT_FOUND"}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	if str(parser.data.get("submission_version", "")) != SUBMISSION_VERSION:
		return {"ok": false, "code": "UNKNOWN_SUBMISSION_VERSION"}
	return {"ok": true, "state": parser.data}

func save_state(path: String, state: Dictionary) -> Dictionary:
	if str(state.get("submission_version", "")) != SUBMISSION_VERSION:
		return {"ok": false, "code": "UNKNOWN_SUBMISSION_VERSION"}
	if FileAccess.file_exists(path) and not load_state(path)["ok"]:
		return {"ok": false, "code": "PERSISTED_SUBMISSION_INVALID"}
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())) != OK:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	file.store_string(JSON.stringify(state, "\t", true) + "\n")
	file.close()
	return {"ok": true}
