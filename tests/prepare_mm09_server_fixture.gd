extends SceneTree

const CanonModel = preload("res://src/domain/canon_model.gd")
const CanonStore = preload("res://src/data/canon_store.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var canon := CanonModel.new()
	var snapshot := {"sandbox_version": "sandbox-1", "sandbox_id": "server.fixture", "name": "Server Cat", "type": "classic", "flavor": "fixture", "tags": [], "media_reference": "fixture.png", "attribution": "fixture", "source_reference": "https://example.invalid", "rights_basis": "fixture", "media_digest": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
	var submission := {"submission_version": "submission-1", "submission_id": "server.fixture.submission", "state": "approved_for_canon", "snapshot": snapshot}
	var card := {"schema_version": "alpha-0.1", "rules_version": "alpha-0.1", "card_id": "server.fixture.cat", "kind": "mememom", "type": "classic", "tier": "standard", "trend_cost": 1, "name": "Server Cat", "mememom": {"hp": 40, "attack": {"attack_id": "fixture", "trend_cost": 1, "damage": 20, "effects": []}, "triggers": [], "activated_abilities": []}}
	var at := "2026-10-18T00:00:00Z"
	if not canon.publish(submission, card, "server.fixture.edition", at)["ok"] or not canon.create_format("server-fixture", "alpha-0.1", at, ["server.fixture.edition"])["ok"]:
		push_error("fixture Canon creation failed")
		quit(1)
		return
	var saved := CanonStore.new().save_state("user://mm09-server-tests/canon.json", canon.export_state())
	if not saved["ok"]:
		push_error("fixture Canon persistence failed")
		quit(1)
		return
	print("MM-09 SERVER FIXTURE READY")
	quit(0)
