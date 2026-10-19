class_name CanonModel
extends RefCounted

const CardValidator = preload("res://src/domain/card_validator.gd")
const CANON_VERSION := "canon-1"
const LEGALITY_VERSION := "format-1"

var editions: Dictionary = {}
var formats: Dictionary = {}
var legality_audit: Array = []

func publish(approved_submission: Dictionary, card_payload: Dictionary, edition_id: String, published_at: String) -> Dictionary:
	if editions.has(edition_id) or edition_id.is_empty() or not _timestamp(published_at):
		return _fail("SCHEMA_INVALID")
	if str(approved_submission.get("submission_version", "")) != "submission-1" or str(approved_submission.get("state", "")) != "approved_for_canon":
		return _fail("SUBMISSION_NOT_APPROVED")
	var snapshot: Dictionary = approved_submission.get("snapshot", {})
	if snapshot.is_empty() or not _digest(str(snapshot.get("media_digest", ""))):
		return _fail("SUBMISSION_SNAPSHOT_INVALID")
	var card := card_payload.duplicate(true)
	if card.has("edition_id"):
		return _fail("CARD_ALREADY_EDITED")
	card["edition_id"] = edition_id
	var validation: Dictionary = CardValidator.new().validate_card(card)
	if not validation["ok"]:
		return _fail(str(validation["code"]))
	var edition := {"canon_version": CANON_VERSION, "edition_id": edition_id, "submission_id": str(approved_submission.get("submission_id", "")), "card_id": str(card.get("card_id", "")), "schema_version": str(card.get("schema_version", "")), "rules_version": str(card.get("rules_version", "")), "content_digest": _sha256(JSON.stringify({"card": card, "snapshot": snapshot}, "", true)), "provenance_snapshot": snapshot.duplicate(true), "card": card, "published_at": published_at}
	if edition["submission_id"].is_empty() or edition["card_id"].is_empty():
		return _fail("SCHEMA_INVALID")
	editions[edition_id] = edition
	return {"ok": true, "edition": edition.duplicate(true)}

func create_format(format_id: String, rules_version: String, starts_at: String, edition_ids: Array) -> Dictionary:
	if formats.has(format_id) or format_id.is_empty() or rules_version != "alpha-0.1" or not _timestamp(starts_at) or edition_ids.is_empty():
		return _fail("FORMAT_INVALID")
	var allowed := {}
	for edition_id in edition_ids:
		var id := str(edition_id)
		if not editions.has(id) or allowed.has(id) or str(editions[id]["rules_version"]) != rules_version:
			return _fail("FORMAT_INVALID")
		allowed[id] = true
	formats[format_id] = {"legality_version": LEGALITY_VERSION, "format_id": format_id, "rules_version": rules_version, "starts_at": starts_at, "allowed_editions": allowed, "suspensions": {}, "retired_at": ""}
	return {"ok": true, "format": _export_format(formats[format_id])}

func suspend(format_id: String, edition_id: String, reason: String, at: String, actor_id: String) -> Dictionary:
	if not formats.has(format_id) or not _timestamp(at) or reason.strip_edges().is_empty() or reason.length() > 280 or actor_id.is_empty():
		return _fail("SUSPENSION_INVALID")
	var format: Dictionary = formats[format_id]
	if not format["allowed_editions"].has(edition_id) or format["suspensions"].has(edition_id):
		return _fail("SUSPENSION_INVALID")
	format["suspensions"][edition_id] = {"edition_id": edition_id, "reason": reason, "at": at, "actor_id": actor_id}
	formats[format_id] = format
	legality_audit.append({"action": "suspended", "format_id": format_id, "edition_id": edition_id, "reason": reason, "at": at, "actor_id": actor_id})
	return {"ok": true}

func retire_format(format_id: String, at: String, actor_id: String) -> Dictionary:
	if not formats.has(format_id) or not _timestamp(at) or actor_id.is_empty() or not str(formats[format_id]["retired_at"]).is_empty():
		return _fail("RETIREMENT_INVALID")
	formats[format_id]["retired_at"] = at
	legality_audit.append({"action": "retired", "format_id": format_id, "edition_id": "", "reason": "", "at": at, "actor_id": actor_id})
	return {"ok": true}

func resolve_legality(format_id: String, card_id: String, edition_id: String, rules_version: String) -> Dictionary:
	if not formats.has(format_id) or not editions.has(edition_id):
		return _fail("FORMAT_ILLEGAL_CARD")
	var format: Dictionary = formats[format_id]
	var edition: Dictionary = editions[edition_id]
	if not str(format["retired_at"]).is_empty() or str(format["rules_version"]) != rules_version or str(edition["rules_version"]) != rules_version or str(edition["card_id"]) != card_id or not format["allowed_editions"].has(edition_id) or format["suspensions"].has(edition_id):
		return _fail("FORMAT_ILLEGAL_CARD")
	return {"ok": true, "edition": edition.duplicate(true), "format": _export_format(format)}

func export_state() -> Dictionary:
	return {"canon_version": CANON_VERSION, "editions": _sorted(editions), "formats": _sorted_formats(), "legality_audit": legality_audit.duplicate(true)}

func import_state(raw: Dictionary) -> Dictionary:
	if raw.size() != 4 or str(raw.get("canon_version", "")) != CANON_VERSION or typeof(raw.get("editions", null)) != TYPE_ARRAY or typeof(raw.get("formats", null)) != TYPE_ARRAY or typeof(raw.get("legality_audit", null)) != TYPE_ARRAY:
		return _fail("UNKNOWN_CANON_VERSION")
	var next_editions: Dictionary = {}
	for raw_edition in raw["editions"]:
		if typeof(raw_edition) != TYPE_DICTIONARY:
			return _fail("SCHEMA_INVALID")
		var edition: Dictionary = raw_edition
		var edition_id := str(edition.get("edition_id", ""))
		if edition_id.is_empty() or next_editions.has(edition_id) or str(edition.get("canon_version", "")) != CANON_VERSION or not _digest(str(edition.get("content_digest", ""))) or typeof(edition.get("card", null)) != TYPE_DICTIONARY or not CardValidator.new().validate_card(edition["card"])["ok"]:
			return _fail("SCHEMA_INVALID")
		next_editions[edition_id] = edition.duplicate(true)
	var next_formats: Dictionary = {}
	for raw_format in raw["formats"]:
		if typeof(raw_format) != TYPE_DICTIONARY:
			return _fail("SCHEMA_INVALID")
		var format: Dictionary = raw_format
		var format_id := str(format.get("format_id", ""))
		if format_id.is_empty() or next_formats.has(format_id) or str(format.get("legality_version", "")) != LEGALITY_VERSION or typeof(format.get("allowed_editions", null)) != TYPE_ARRAY or typeof(format.get("suspensions", null)) != TYPE_ARRAY:
			return _fail("SCHEMA_INVALID")
		var allowed := {}
		for raw_id in format["allowed_editions"]:
			var edition_id := str(raw_id)
			if not next_editions.has(edition_id) or allowed.has(edition_id):
				return _fail("SCHEMA_INVALID")
			allowed[edition_id] = true
		var suspensions := {}
		for raw_suspension in format["suspensions"]:
			if typeof(raw_suspension) != TYPE_DICTIONARY:
				return _fail("SCHEMA_INVALID")
			var suspension: Dictionary = raw_suspension
			var suspended_id := str(suspension.get("edition_id", ""))
			if not allowed.has(suspended_id) or suspensions.has(suspended_id) or not _timestamp(str(suspension.get("at", ""))):
				return _fail("SCHEMA_INVALID")
			suspensions[suspended_id] = suspension.duplicate(true)
		next_formats[format_id] = {"legality_version": LEGALITY_VERSION, "format_id": format_id, "rules_version": str(format.get("rules_version", "")), "starts_at": str(format.get("starts_at", "")), "allowed_editions": allowed, "suspensions": suspensions, "retired_at": str(format.get("retired_at", ""))}
	editions = next_editions
	formats = next_formats
	legality_audit = raw["legality_audit"].duplicate(true)
	return {"ok": true, "editions": editions.size(), "formats": formats.size()}

func _export_format(format: Dictionary) -> Dictionary:
	var output := format.duplicate(true)
	var ids: Array = output["allowed_editions"].keys()
	ids.sort()
	output["allowed_editions"] = ids
	var suspensions: Array = output["suspensions"].values()
	suspensions.sort_custom(func(a, b): return str(a["edition_id"]) < str(b["edition_id"]))
	output["suspensions"] = suspensions
	return output

func _sorted(values: Dictionary) -> Array:
	var ids: Array = values.keys()
	ids.sort()
	var result: Array = []
	for id in ids:
		result.append(values[id].duplicate(true))
	return result

func _sorted_formats() -> Array:
	var ids: Array = formats.keys()
	ids.sort()
	var result: Array = []
	for id in ids:
		result.append(_export_format(formats[id]))
	return result

func _sha256(text: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(text.to_utf8_buffer())
	return context.finish().hex_encode()

func _digest(value: String) -> bool:
	if value.length() != 64:
		return false
	for character in value.to_lower():
		if character not in "0123456789abcdef":
			return false
	return true

func _timestamp(value: String) -> bool:
	return value.length() >= 20 and value.contains("T") and value.ends_with("Z")

func _fail(code: String) -> Dictionary:
	return {"ok": false, "code": code}
