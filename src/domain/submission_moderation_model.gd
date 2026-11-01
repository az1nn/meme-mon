class_name SubmissionModerationModel
extends RefCounted

# MM-07 is deliberately a domain authority, not a UI model.  A caller must
# supply authenticated actor identity/role; unknown input always fails closed.
const SUBMISSION_VERSION := "submission-1"
const REPORT_VERSION := "report-1"
const CREATOR_ROLE := "creator"
const MODERATOR_ROLES := ["moderator", "admin"]
const ACTIVE_STATES := ["submitted", "needs_information", "under_review"]
const ALL_STATES := ["submitted", "needs_information", "under_review", "approved_for_canon", "rejected", "withdrawn"]
const REPORT_CATEGORIES := ["rights_provenance", "impersonation", "abusive_illegal", "other"]
const DECISION_CATEGORIES := ["rights", "provenance", "safety", "quality", "other"]

var submissions: Dictionary = {}
var reports: Dictionary = {}

func submit(sandbox_record: Dictionary, creator_id: String, submission_id: String, media_digest: String, submitted_at: String) -> Dictionary:
	if submissions.has(submission_id) or submission_id.is_empty() or creator_id.is_empty() or not _valid_timestamp(submitted_at):
		return _fail("SCHEMA_INVALID")
	if not _valid_digest(media_digest):
		return _fail("MEDIA_DIGEST_INVALID")
	var snapshot := _snapshot(sandbox_record, media_digest)
	if not snapshot["ok"]:
		return snapshot
	for existing in submissions.values():
		if str(existing["sandbox_id"]) == str(snapshot["snapshot"]["sandbox_id"]) and str(existing["creator_id"]) == creator_id and str(existing["state"]) in ACTIVE_STATES:
			return _fail("DUPLICATE_ACTIVE_SUBMISSION")
	var record := {
		"submission_version": SUBMISSION_VERSION, "submission_id": submission_id, "creator_id": creator_id,
		"state": "submitted", "submitted_at": submitted_at, "sandbox_version": snapshot["snapshot"]["sandbox_version"],
		"sandbox_id": snapshot["snapshot"]["sandbox_id"], "snapshot": snapshot["snapshot"],
		"audit": [{"actor_id": creator_id, "actor_role": CREATOR_ROLE, "from_state": "draft", "to_state": "submitted", "at": submitted_at, "category": "", "rationale": ""}]
	}
	submissions[submission_id] = record
	return {"ok": true, "submission": record.duplicate(true)}

func transition(submission_id: String, actor_id: String, actor_role: String, next_state: String, category: String, rationale: String, at: String) -> Dictionary:
	if not submissions.has(submission_id):
		return _fail("UNKNOWN_SUBMISSION")
	if actor_id.is_empty() or not _valid_timestamp(at) or next_state not in ALL_STATES:
		return _fail("SCHEMA_INVALID")
	var current: Dictionary = submissions[submission_id]
	var from_state := str(current["state"])
	if not _allowed(current, actor_id, actor_role, next_state):
		return _fail("TRANSITION_FORBIDDEN")
	if next_state in ["needs_information", "rejected"] and (category not in DECISION_CATEGORIES or rationale.strip_edges().is_empty() or rationale.length() > 280):
		return _fail("DECISION_RATIONALE_INVALID")
	if next_state not in ["needs_information", "rejected"] and (category.length() > 40 or rationale.length() > 280):
		return _fail("DECISION_RATIONALE_INVALID")
	var next := current.duplicate(true)
	next["state"] = next_state
	next["audit"].append({"actor_id": actor_id, "actor_role": actor_role, "from_state": from_state, "to_state": next_state, "at": at, "category": category, "rationale": rationale})
	submissions[submission_id] = next
	return {"ok": true, "submission": next.duplicate(true)}

func create_report(submission_id: String, reporter_id: String, report_id: String, category: String, detail: String, at: String) -> Dictionary:
	if not submissions.has(submission_id):
		return _fail("UNKNOWN_SUBMISSION")
	if reports.has(report_id) or report_id.is_empty() or reporter_id.is_empty() or category not in REPORT_CATEGORIES or detail.strip_edges().is_empty() or detail.length() > 560 or not _valid_timestamp(at):
		return _fail("REPORT_INVALID")
	var report := {"report_version": REPORT_VERSION, "report_id": report_id, "submission_id": submission_id, "reporter_id": reporter_id, "category": category, "detail": detail, "created_at": at}
	reports[report_id] = report
	return {"ok": true, "report": report.duplicate(true)}

func get_submission(submission_id: String, actor_id: String = "", actor_role: String = "") -> Dictionary:
	if not submissions.has(submission_id):
		return _fail("UNKNOWN_SUBMISSION")
	var submission: Dictionary = submissions[submission_id]
	if actor_id.is_empty() or (actor_id != str(submission["creator_id"]) and actor_role not in MODERATOR_ROLES):
		return _fail("ACCESS_FORBIDDEN")
	return {"ok": true, "submission": submissions[submission_id].duplicate(true)}

func export_state() -> Dictionary:
	return {"submission_version": SUBMISSION_VERSION, "submissions": _sorted_values(submissions), "reports": _sorted_values(reports)}

func import_state(raw: Dictionary) -> Dictionary:
	if raw.size() != 3 or str(raw.get("submission_version", "")) != SUBMISSION_VERSION or typeof(raw.get("submissions", null)) != TYPE_ARRAY or typeof(raw.get("reports", null)) != TYPE_ARRAY:
		return _fail("UNKNOWN_SUBMISSION_VERSION")
	var next_submissions: Dictionary = {}
	for item in raw["submissions"]:
		if typeof(item) != TYPE_DICTIONARY or not _valid_submission(item) or next_submissions.has(str(item.get("submission_id", ""))):
			return _fail("SCHEMA_INVALID")
		next_submissions[str(item["submission_id"])] = item.duplicate(true)
	var next_reports: Dictionary = {}
	for item in raw["reports"]:
		if typeof(item) != TYPE_DICTIONARY or not _valid_report(item) or not next_submissions.has(str(item.get("submission_id", ""))) or next_reports.has(str(item.get("report_id", ""))):
			return _fail("SCHEMA_INVALID")
		next_reports[str(item["report_id"])] = item.duplicate(true)
	submissions = next_submissions
	reports = next_reports
	return {"ok": true, "submissions": submissions.size(), "reports": reports.size()}

func _snapshot(record: Dictionary, media_digest: String) -> Dictionary:
	var required := ["sandbox_version", "sandbox_id", "name", "type", "flavor", "tags", "media_reference", "attribution", "source_reference", "rights_basis"]
	if record.size() != required.size() or str(record.get("sandbox_version", "")) != "sandbox-1":
		return _fail("SANDBOX_SNAPSHOT_INVALID")
	for key in required:
		if not record.has(key):
			return _fail("SANDBOX_SNAPSHOT_INVALID")
	if str(record["sandbox_id"]).is_empty() or str(record["name"]).is_empty() or str(record["media_reference"]).is_empty() or str(record["attribution"]).is_empty() or str(record["source_reference"]).is_empty() or str(record["rights_basis"]).is_empty() or typeof(record["tags"]) != TYPE_ARRAY:
		return _fail("SANDBOX_SNAPSHOT_INVALID")
	var snapshot := record.duplicate(true)
	snapshot["media_digest"] = media_digest
	return {"ok": true, "snapshot": snapshot}

func _allowed(current: Dictionary, actor_id: String, role: String, next_state: String) -> bool:
	var from := str(current["state"])
	if role == CREATOR_ROLE:
		return actor_id == str(current["creator_id"]) and from in ["submitted", "needs_information"] and next_state == "withdrawn"
	if role not in MODERATOR_ROLES:
		return false
	if from == "submitted":
		return next_state in ["under_review", "needs_information"]
	if from == "needs_information":
		return next_state == "under_review"
	if from == "under_review":
		return next_state in ["needs_information", "approved_for_canon", "rejected"]
	return false

func _valid_submission(record: Dictionary) -> bool:
	for key in ["submission_version", "submission_id", "creator_id", "state", "submitted_at", "sandbox_version", "sandbox_id", "snapshot", "audit"]:
		if not record.has(key):
			return false
	if str(record.get("submission_version", "")) != SUBMISSION_VERSION or str(record.get("state", "")) not in ALL_STATES or typeof(record.get("snapshot", null)) != TYPE_DICTIONARY or typeof(record.get("audit", null)) != TYPE_ARRAY:
		return false
	if str(record.get("submission_id", "")).is_empty() or str(record.get("creator_id", "")).is_empty() or str(record.get("sandbox_version", "")) != "sandbox-1" or str(record.get("sandbox_id", "")).is_empty() or not _valid_timestamp(str(record.get("submitted_at", ""))):
		return false
	var raw_snapshot: Dictionary = record["snapshot"].duplicate(true)
	var media_digest := str(raw_snapshot.get("media_digest", ""))
	raw_snapshot.erase("media_digest")
	var snap := _snapshot(raw_snapshot, media_digest)
	return snap["ok"] and str(record.get("sandbox_id", "")) == str(record["snapshot"].get("sandbox_id", "")) and str(record.get("sandbox_version", "")) == str(record["snapshot"].get("sandbox_version", "")) and _valid_audit(record)

func _valid_audit(record: Dictionary) -> bool:
	var history: Array = record.get("audit", [])
	if history.is_empty():
		return false
	var expected_state := "draft"
	var current := record.duplicate(true)
	for index in range(history.size()):
		var entry: Variant = history[index]
		if typeof(entry) != TYPE_DICTIONARY:
			return false
		var audit: Dictionary = entry
		for key in ["actor_id", "actor_role", "from_state", "to_state", "at", "category", "rationale"]:
			if not audit.has(key):
				return false
		var actor_id := str(audit["actor_id"])
		var actor_role := str(audit["actor_role"])
		var from_state := str(audit["from_state"])
		var next_state := str(audit["to_state"])
		var category := str(audit["category"])
		var rationale := str(audit["rationale"])
		if actor_id.is_empty() or not _valid_timestamp(str(audit["at"])) or from_state != expected_state or next_state not in ALL_STATES or category.length() > 40 or rationale.length() > 280:
			return false
		if index == 0:
			if actor_id != str(record["creator_id"]) or actor_role != CREATOR_ROLE or from_state != "draft" or next_state != "submitted" or str(audit["at"]) != str(record["submitted_at"]) or not category.is_empty() or not rationale.is_empty():
				return false
		else:
			current["state"] = expected_state
			if not _allowed(current, actor_id, actor_role, next_state):
				return false
		if next_state in ["needs_information", "rejected"] and (category not in DECISION_CATEGORIES or rationale.strip_edges().is_empty()):
			return false
		expected_state = next_state
	return expected_state == str(record["state"])

func _valid_report(report: Dictionary) -> bool:
	for key in ["report_version", "report_id", "submission_id", "reporter_id", "category", "detail", "created_at"]:
		if not report.has(key):
			return false
	return str(report.get("report_version", "")) == REPORT_VERSION and not str(report.get("report_id", "")).is_empty() and not str(report.get("submission_id", "")).is_empty() and not str(report.get("reporter_id", "")).is_empty() and str(report.get("category", "")) in REPORT_CATEGORIES and not str(report.get("detail", "")).strip_edges().is_empty() and str(report.get("detail", "")).length() <= 560 and _valid_timestamp(str(report.get("created_at", "")))

func _sorted_values(items: Dictionary) -> Array:
	var ids: Array = items.keys()
	ids.sort()
	var output: Array = []
	for id in ids:
		output.append(items[id].duplicate(true))
	return output

func _valid_digest(value: String) -> bool:
	if value.length() != 64:
		return false
	for character in value.to_lower():
		if character not in "0123456789abcdef":
			return false
	return true

func _valid_timestamp(value: String) -> bool:
	return value.length() >= 20 and value.contains("T") and value.ends_with("Z")

func _fail(code: String) -> Dictionary:
	return {"ok": false, "code": code}
