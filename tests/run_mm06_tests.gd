extends SceneTree

const SandboxForgeModel = preload("res://src/domain/sandbox_forge_model.gd")
const SandboxForgeStore = preload("res://src/data/sandbox_forge_store.gd")
const CardValidator = preload("res://src/domain/card_validator.gd")

var checks := 0
var failures: Array = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _input() -> Dictionary:
	return {"name": "Keyboard Cat", "type": "classic", "flavor": "Plays the turn out.", "tags": ["music", "classic"], "media_reference": "user://mememom/media/keyboard-cat.png", "attribution": "Original creator credited in source", "source_reference": "https://example.invalid/keyboard-cat", "rights_basis": "I have permission to use this private Sandbox reference."}

func _run() -> void:
	var model = SandboxForgeModel.new()
	var input := _input()
	var created: Dictionary = model.create(input, "sandbox.local.1")
	_check(created["ok"], "valid Sandbox record creates")
	_check(CardValidator.new().validate_card(created["preview"])["ok"], "generated preview satisfies MM-03 validator")
	_check(not created["preview"].has("edition_id"), "Sandbox preview has no competitive edition")
	var changed := input.duplicate(true)
	changed["flavor"] = "Different identity text."
	changed["tags"] = ["different"]
	_check(JSON.stringify(model.preview(input)["card"]["mememom"]) == JSON.stringify(model.preview(changed)["card"]["mememom"]), "identity text cannot change generated combat budget")
	_check(model.create(input, "sandbox.local.1")["code"] == "DUPLICATE_SANDBOX_ID", "duplicate ID rejected")
	var before := JSON.stringify(model.export_records())
	var invalid := input.duplicate(true)
	invalid["rights_basis"] = ""
	_check(model.update("sandbox.local.1", invalid)["code"] == "RIGHTS_BASIS_INVALID", "missing rights declaration rejected")
	_check(JSON.stringify(model.export_records()) == before, "invalid update is atomic")
	invalid = input.duplicate(true)
	invalid["tags"] = ["same", "same"]
	_check(model.create(invalid, "sandbox.local.2")["code"] == "TAGS_INVALID", "duplicate tags rejected")
	invalid = input.duplicate(true)
	invalid["media_reference"] = ""
	_check(model.create(invalid, "sandbox.local.2")["code"] == "MEDIA_REFERENCE_INVALID", "missing media reference rejected")

	var store = SandboxForgeStore.new()
	var path := "user://mm06-tests/sandbox.json"
	_check(store.save_records(path, model.export_records())["ok"], "save versioned Sandbox envelope")
	var loaded := store.load_records(path)
	_check(loaded["ok"], "load Sandbox envelope")
	var restored = SandboxForgeModel.new()
	_check(restored.import_records(loaded["records"])["ok"], "import saved records atomically")
	_check(JSON.stringify(restored.export_records()) == before, "Sandbox persistence is deterministic")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{bad json")
	file.close()
	_check(store.save_records(path, model.export_records())["code"] == "PERSISTED_SANDBOX_INVALID", "corrupt store is never overwritten")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	print("MM-06 checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("MM-06 HEADLESS GATES PASS")
	quit(0 if failures.is_empty() else 1)
