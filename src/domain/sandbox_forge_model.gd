class_name SandboxForgeModel
extends RefCounted

const CardValidator = preload("res://src/domain/card_validator.gd")
const SANDBOX_VERSION := "sandbox-1"
const VALID_TYPES := ["classic", "reaction", "brainrot", "surreal", "wholesome"]
const MAX_NAME_LENGTH := 80
const MAX_FLAVOR_LENGTH := 280
const MAX_TAGS := 16
const MAX_TAG_LENGTH := 40
const MAX_SOURCE_LENGTH := 280
const MAX_MEDIA_REFERENCE_LENGTH := 1024

var records: Dictionary = {}

func create(input: Dictionary, record_id: String) -> Dictionary:
	if records.has(record_id):
		return _fail("DUPLICATE_SANDBOX_ID")
	var record := _build_record(input, record_id)
	if not record["ok"]:
		return record
	records[record_id] = record["record"].duplicate(true)
	return {"ok": true, "record": records[record_id].duplicate(true), "preview": record["preview"]}

func update(record_id: String, input: Dictionary) -> Dictionary:
	if not records.has(record_id):
		return _fail("UNKNOWN_SANDBOX_ID")
	var record := _build_record(input, record_id)
	if not record["ok"]:
		return record
	records[record_id] = record["record"].duplicate(true)
	return {"ok": true, "record": records[record_id].duplicate(true), "preview": record["preview"]}

func delete(record_id: String) -> Dictionary:
	if not records.has(record_id):
		return _fail("UNKNOWN_SANDBOX_ID")
	records.erase(record_id)
	return {"ok": true}

func preview(input: Dictionary) -> Dictionary:
	var checked := _validate_input(input)
	if not checked["ok"]:
		return checked
	var card := _preview_card(checked["name"], checked["type"])
	var verdict: Dictionary = CardValidator.new().validate_card(card)
	if not verdict["ok"]:
		return _fail("PREVIEW_BUDGET_INVALID")
	return {"ok": true, "card": card, "points": verdict["points"]}

func import_records(raw: Array) -> Dictionary:
	var next: Dictionary = {}
	for item in raw:
		if typeof(item) != TYPE_DICTIONARY:
			return _fail("SCHEMA_INVALID")
		var record: Dictionary = item
		var record_id := str(record.get("sandbox_id", ""))
		if record_id.is_empty() or next.has(record_id) or record.size() != 10 or str(record.get("sandbox_version", "")) != SANDBOX_VERSION:
			return _fail("SCHEMA_INVALID")
		var input := {
			"name": record.get("name", ""), "type": record.get("type", ""), "flavor": record.get("flavor", ""),
			"tags": record.get("tags", []), "media_reference": record.get("media_reference", ""),
			"attribution": record.get("attribution", ""), "source_reference": record.get("source_reference", ""), "rights_basis": record.get("rights_basis", "")
		}
		var built := _build_record(input, record_id)
		if not built["ok"]:
			return built
		next[record_id] = built["record"]
	records = next
	return {"ok": true, "count": records.size()}

func export_records() -> Array:
	var ids: Array = records.keys()
	ids.sort()
	var output: Array = []
	for record_id in ids:
		output.append(records[record_id].duplicate(true))
	return output

func _build_record(input: Dictionary, record_id: String) -> Dictionary:
	if record_id.is_empty() or record_id.length() > 120:
		return _fail("SCHEMA_INVALID")
	var checked := _validate_input(input)
	if not checked["ok"]:
		return checked
	var preview_result := preview(input)
	if not preview_result["ok"]:
		return preview_result
	return {"ok": true, "preview": preview_result["card"], "record": {
		"sandbox_version": SANDBOX_VERSION, "sandbox_id": record_id, "name": checked["name"], "type": checked["type"],
		"flavor": checked["flavor"], "tags": checked["tags"], "media_reference": checked["media_reference"],
		"attribution": checked["attribution"], "source_reference": checked["source_reference"], "rights_basis": checked["rights_basis"]
	}}

func _validate_input(input: Dictionary) -> Dictionary:
	var name := str(input.get("name", "")).strip_edges()
	var type_name := str(input.get("type", "")).strip_edges().to_lower()
	var flavor := str(input.get("flavor", "")).strip_edges()
	var media_reference := str(input.get("media_reference", "")).strip_edges()
	var attribution := str(input.get("attribution", "")).strip_edges()
	var source_reference := str(input.get("source_reference", "")).strip_edges()
	var rights_basis := str(input.get("rights_basis", "")).strip_edges()
	if name.is_empty() or name.length() > MAX_NAME_LENGTH:
		return _fail("NAME_INVALID")
	if type_name not in VALID_TYPES:
		return _fail("TYPE_INVALID")
	if flavor.length() > MAX_FLAVOR_LENGTH or attribution.length() > MAX_SOURCE_LENGTH or source_reference.length() > MAX_SOURCE_LENGTH:
		return _fail("TEXT_TOO_LONG")
	if media_reference.is_empty() or media_reference.length() > MAX_MEDIA_REFERENCE_LENGTH or media_reference.contains("\n"):
		return _fail("MEDIA_REFERENCE_INVALID")
	if attribution.is_empty() or source_reference.is_empty() or rights_basis.is_empty() or rights_basis.length() > MAX_SOURCE_LENGTH:
		return _fail("RIGHTS_BASIS_INVALID")
	if typeof(input.get("tags", null)) != TYPE_ARRAY:
		return _fail("TAGS_INVALID")
	var tags: Array = []
	for raw_tag in input["tags"]:
		var tag := str(raw_tag).strip_edges().to_lower()
		if tag.is_empty() or tag.length() > MAX_TAG_LENGTH or tags.has(tag):
			return _fail("TAGS_INVALID")
		tags.append(tag)
	if tags.size() > MAX_TAGS:
		return _fail("TAGS_INVALID")
	return {"ok": true, "name": name, "type": type_name, "flavor": flavor, "tags": tags, "media_reference": media_reference, "attribution": attribution, "source_reference": source_reference, "rights_basis": rights_basis}

func _preview_card(name: String, type_name: String) -> Dictionary:
	var budgets := {
		"classic": {"cost": 2, "hp": 55, "damage": 25}, "reaction": {"cost": 2, "hp": 55, "damage": 25},
		"brainrot": {"cost": 2, "hp": 55, "damage": 25}, "surreal": {"cost": 3, "hp": 75, "damage": 35},
		"wholesome": {"cost": 3, "hp": 75, "damage": 35}
	}
	var budget: Dictionary = budgets[type_name]
	return {"schema_version": "alpha-0.1", "rules_version": "alpha-0.1", "card_id": "sandbox.preview." + type_name,
		"kind": "mememom", "type": type_name, "tier": "standard", "trend_cost": budget["cost"], "name": name,
		"mememom": {"hp": budget["hp"], "attack": {"attack_id": "sandbox-preview-attack", "trend_cost": 1, "damage": budget["damage"], "effects": []}, "triggers": [], "activated_abilities": []}}

func _fail(code: String) -> Dictionary:
	return {"ok": false, "code": code}
