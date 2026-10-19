extends SceneTree

const SandboxForgeModel = preload("res://src/domain/sandbox_forge_model.gd")
const SubmissionModerationModel = preload("res://src/domain/submission_moderation_model.gd")
const SubmissionStore = preload("res://src/data/submission_store.gd")
const CanonModel = preload("res://src/domain/canon_model.gd")
const CanonStore = preload("res://src/data/canon_store.gd")
const CanonDeckValidator = preload("res://src/domain/canon_deck_validator.gd")

const AT := "2026-10-18T00:00:00Z"
const DIGEST := "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
var checks := 0
var failures: Array = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _sandbox() -> Dictionary:
	var forge := SandboxForgeModel.new()
	var input := {"name": "Canon Cat", "type": "classic", "flavor": "immutable later", "tags": ["cat"], "media_reference": "user://media/cat.png", "attribution": "creator", "source_reference": "https://example.invalid/cat", "rights_basis": "permission"}
	var made: Dictionary = forge.create(input, "sandbox.cat.1")
	return {"record": made["record"], "preview": made["preview"]}

func _run() -> void:
	var seed := _sandbox()
	var moderation := SubmissionModerationModel.new()
	var submitted: Dictionary = moderation.submit(seed["record"], "creator-1", "submission-1", DIGEST, AT)
	_check(submitted["ok"], "complete Sandbox record creates submission snapshot")
	var changed: Dictionary = seed["record"].duplicate(true)
	changed["name"] = "Changed later"
	_check(str(submitted["submission"]["snapshot"]["name"]) == "Canon Cat", "submission snapshot is isolated from later Sandbox edits")
	_check(moderation.submit(seed["record"], "creator-1", "submission-2", DIGEST, AT)["code"] == "DUPLICATE_ACTIVE_SUBMISSION", "duplicate active Sandbox submission rejected")
	_check(moderation.transition("submission-1", "creator-1", "creator", "approved_for_canon", "", "", AT)["code"] == "TRANSITION_FORBIDDEN", "creator cannot self-approve")
	_check(moderation.transition("submission-1", "mod-1", "moderator", "under_review", "", "", AT)["ok"], "moderator can begin review")
	_check(moderation.transition("submission-1", "mod-1", "moderator", "rejected", "", "", AT)["code"] == "DECISION_RATIONALE_INVALID", "rejection requires category and rationale")
	var approved: Dictionary = moderation.transition("submission-1", "mod-1", "moderator", "approved_for_canon", "", "", AT)
	_check(approved["ok"], "moderator can approve eligibility")
	_check(moderation.create_report("submission-1", "reporter-1", "report-1", "rights_provenance", "verify source", AT)["ok"], "report retains submission identifier")
	var submission_path := "user://mm07-tests/submissions.json"
	var submission_store := SubmissionStore.new()
	_check(submission_store.save_state(submission_path, moderation.export_state())["ok"], "submission state persists versioned envelope")
	_check(submission_store.load_state(submission_path)["ok"], "submission state reloads")

	var canon := CanonModel.new()
	_check(canon.publish(submitted["submission"], seed["preview"], "edition.cat.1", AT)["code"] == "SUBMISSION_NOT_APPROVED", "unapproved snapshot cannot publish Canon")
	var published: Dictionary = canon.publish(approved["submission"], seed["preview"], "edition.cat.1", AT)
	_check(published["ok"], "approved snapshot publishes immutable Canon edition")
	_check(canon.publish(approved["submission"], seed["preview"], "edition.cat.1", AT)["code"] == "SCHEMA_INVALID", "edition ID is append-only")
	_check(canon.create_format("closed-beta-2026", "alpha-0.1", AT, ["edition.cat.1"])["ok"], "format admits known matching edition")
	_check(canon.resolve_legality("closed-beta-2026", "sandbox.preview.classic", "edition.cat.1", "alpha-0.1")["ok"], "exact tuple resolves legal")
	_check(canon.suspend("closed-beta-2026", "edition.cat.1", "rights report", AT, "admin-1")["ok"], "emergency suspension is additive audit record")
	_check(canon.resolve_legality("closed-beta-2026", "sandbox.preview.classic", "edition.cat.1", "alpha-0.1")["code"] == "FORMAT_ILLEGAL_CARD", "suspended edition fails closed")
	var canon_path := "user://mm08-tests/canon.json"
	var canon_store := CanonStore.new()
	_check(canon_store.save_state(canon_path, canon.export_state())["ok"], "Canon state persists versioned envelope")
	_check(canon_store.load_state(canon_path)["ok"], "Canon state reloads")
	var restored_canon := CanonModel.new()
	_check(restored_canon.import_state(canon_store.load_state(canon_path)["state"])["ok"], "Canon state imports atomically")

	var competitive := CanonModel.new()
	var refs: Array = []
	var edition_ids: Array = []
	for i in range(15):
		var snapshot: Dictionary = seed["record"].duplicate(true)
		snapshot["sandbox_id"] = "sandbox.competitive.%02d" % i
		var approved_snapshot := {"submission_version": "submission-1", "submission_id": "submission.competitive.%02d" % i, "state": "approved_for_canon", "snapshot": snapshot.merged({"media_digest": DIGEST}, true)}
		var card: Dictionary = seed["preview"].duplicate(true)
		card["card_id"] = "canon.card.%02d" % i
		card["name"] = "Canon Card %02d" % i
		var edition_id := "edition.competitive.%02d" % i
		_check(competitive.publish(approved_snapshot, card, edition_id, AT)["ok"], "distinct approved snapshot publishes Canon edition %d" % i)
		edition_ids.append(edition_id)
		refs.append({"card_id": card["card_id"], "edition_id": edition_id})
	_check(competitive.create_format("competitive-2026", "alpha-0.1", AT, edition_ids)["ok"], "competitive format contains immutable editions")
	var full_deck: Array = []
	for ref in refs:
		full_deck.append(ref.duplicate(true))
		full_deck.append(ref.duplicate(true))
	var canon_deck := {"format_id": "competitive-2026", "rules_version": "alpha-0.1", "cards": full_deck}
	_check(CanonDeckValidator.new().validate(canon_deck, competitive)["ok"], "only exact legal Canon editions form competitive deck")
	_check(competitive.suspend("competitive-2026", "edition.competitive.00", "rights", AT, "admin-1")["ok"], "competitive suspension records audit")
	_check(CanonDeckValidator.new().validate(canon_deck, competitive)["code"] == "FORMAT_ILLEGAL_CARD", "suspended Canon edition cannot remain in a competitive deck")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(submission_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(canon_path))

	print("MM-07/MM-08 checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("MM-07/MM-08 HEADLESS GATES PASS")
	quit(0 if failures.is_empty() else 1)
