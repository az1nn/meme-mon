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
	var signing_key: CryptoKey = Crypto.new().generate_rsa(2048)
	var unsigned_variant := OS.get_environment("MEMEMOM_TEST_UNSIGNED_SET") == "1"
	var public_key_path := OS.get_environment("MEMEMOM_TEST_PUBLIC_KEY_PATH")
	if public_key_path.is_empty():
		public_key_path = "/tmp/mememom-mm09-public-key.pem"
	if not canon.publish(submission, card, "server.fixture.edition", at)["ok"] or not canon.create_set("server.fixture.set", "2026-h2", "alpha-0.1", at, ["server.fixture.edition"])["ok"]:
		push_error("fixture Canon creation failed")
		quit(1)
		return
	if not unsigned_variant and (not canon.sign_set("server.fixture.set", "fixture-key", signing_key.save_to_string(false), at)["ok"] or not canon.create_format("server-fixture", "alpha-0.1", at, ["server.fixture.edition"], "server.fixture.set")["ok"]):
		push_error("fixture signed Canon creation failed")
		quit(1)
		return
	if unsigned_variant and not canon.create_format("server-fixture", "alpha-0.1", at, ["server.fixture.edition"])["ok"]:
		push_error("fixture unsigned Canon creation failed")
		quit(1)
		return
	var public_key_file := FileAccess.open(public_key_path, FileAccess.WRITE)
	if public_key_file == null:
		push_error("fixture public key write failed")
		quit(1)
		return
	public_key_file.store_string(signing_key.save_to_string(true))
	public_key_file.close()
	var saved := CanonStore.new().save_state("user://mm09-server-tests/canon.json", canon.export_state())
	if not saved["ok"]:
		push_error("fixture Canon persistence failed")
		quit(1)
		return
	print("MM-09 SERVER FIXTURE READY")
	quit(0)
