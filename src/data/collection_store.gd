class_name CollectionStore
extends RefCounted

const PROFILE_VERSION := "local-1"

# Explicit local path allows isolated headless tests; production uses user://.
func load_profile(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "code": "FILE_NOT_FOUND"}
	var content := FileAccess.get_file_as_string(path)
	var parser = JSON.new()
	if parser.parse(content) != OK:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	var parsed = parser.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "code": "SCHEMA_INVALID"}
	var profile: Dictionary = parsed
	if str(profile.get("profile_version", "")) != PROFILE_VERSION:
		return {"ok": false, "code": "UNKNOWN_PROFILE_VERSION"}
	return {"ok": true, "profile": profile}

# Never clobber an unreadable or unknown-version on-disk profile.
func save_profile(path: String, profile: Dictionary) -> Dictionary:
	if str(profile.get("profile_version", "")) != PROFILE_VERSION:
		return {"ok": false, "code": "UNKNOWN_PROFILE_VERSION"}
	if FileAccess.file_exists(path):
		var current: Dictionary = load_profile(path)
		if not current["ok"]:
			return {"ok": false, "code": "PERSISTED_PROFILE_INVALID"}
	var directory := path.get_base_dir()
	var mkdir_status := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	if mkdir_status != OK:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	var target := FileAccess.open(path, FileAccess.WRITE)
	if target == null:
		return {"ok": false, "code": "FILE_WRITE_FAILED"}
	target.store_string(JSON.stringify(profile, "\t", true) + "\n")
	target.flush()
	target.close()
	return {"ok": true, "code": "OK"}
