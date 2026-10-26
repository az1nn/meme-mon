extends SceneTree
## SCENE/ARCH-001 regression checks. Does NOT certify visual ART fidelity.

const CardVisualFrame = preload("res://src/presentation/card_visual_frame.gd")
var checks: int = 0
var failures: Array = []
var signals_emitted: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)

func _signal_handler(_is_back: bool) -> void:
	signals_emitted += 1

func _run() -> void:
	var card := CardVisualFrame.new()
	card.size = Vector2(300.0, 500.0)
	get_root().add_child(card)
	var fit: Rect2 = card.fitted_rect_for(card.size)
	_check(is_equal_approx(fit.size.x, 300.0), "fit width")
	_check(is_equal_approx(fit.size.y, 400.0), "fit height")
	_check(is_equal_approx(fit.position.y, 50.0), "centers vertically")
	_check(card.get_actual_frame_rect().is_equal_approx(fit), "render frame matches computed layout")
	_check(not card.set_frame_aspect_ratio(0.0), "reject zero aspect")
	_check(not card.set_frame_aspect_ratio(-1.0), "reject negative aspect")
	_check(not card.set_frame_aspect_ratio(INF), "reject infinite aspect")
	_check(card.set_frame_aspect_ratio(0.75), "accept explicit QA aspect")
	_check(card.set_safe_inset_fraction(0.05), "accept bounded inset")
	_check(not card.set_safe_inset_fraction(0.5), "reject unsafe inset")
	var safe: Rect2 = card.content_rect_for(card.size)
	_check(is_equal_approx(safe.size.x, 270.0), "safe region width")
	_check(is_equal_approx(safe.size.y, 360.0), "safe region height")
	_check(card.get_actual_safe_rect().is_equal_approx(safe), "actual safe region matches model")

	var sample_front: Image = Image.create(12, 16, false, Image.FORMAT_RGBA8)
	sample_front.fill(Color(0.0, 0.7, 0.85))
	var sample_back: Image = Image.create(12, 16, false, Image.FORMAT_RGBA8)
	sample_back.fill(Color(0.95, 0.65, 0.0))
	var front: Texture2D = ImageTexture.create_from_image(sample_front)
	var back: Texture2D = ImageTexture.create_from_image(sample_back)
	card.set_face_textures(front, back)
	_check(card.get_visible_texture() == front, "front visible by default")
	card.face_changed.connect(Callable(self, "_signal_handler"))
	card.set_back_visible(true)
	_check(card.is_back_visible(), "back state set")
	_check(card.get_visible_texture() == back, "back source visible")
	_check(signals_emitted == 1, "single face event")
	card.set_back_visible(true)
	_check(signals_emitted == 1, "idempotent face change")
	card.set_back_visible(false)
	_check(signals_emitted == 2, "return to front event")
	_check(card.get_visible_texture() == front, "return to front texture")

	var dimensions := [
		Vector2(360, 640),
		Vector2(390, 844),
		Vector2(768, 1024),
		Vector2(1100, 720),
		Vector2(160, 120),
	]
	for viewport_size in dimensions:
		card.size = viewport_size
		var rect: Rect2 = card.fitted_rect_for(viewport_size)
		_check(rect.position.x >= -0.01 and rect.position.y >= -0.01, "nonnegative origin for %s" % viewport_size)
		_check(rect.end.x <= viewport_size.x + 0.01 and rect.end.y <= viewport_size.y + 0.01, "no overflow for %s" % viewport_size)
		_check(absf(rect.size.x / rect.size.y - 0.75) < 0.001, "ratio preserved for %s" % viewport_size)
		_check(card.get_actual_frame_rect().is_equal_approx(rect), "resized frame for %s" % viewport_size)
		_check(card.get_actual_safe_rect().size.x <= rect.size.x, "safe rect fits frame %s" % viewport_size)

	var before := front.get_size()
	_check(before == Vector2(12, 16), "texture dimensions unchanged")
	_check(card.fitted_rect_for(Vector2.ZERO) == Rect2(), "empty viewport returns no frame")
	card.queue_free()
	_finish()

func _finish() -> void:
	print("SCENE/ARCH-001 checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("SCENE/ARCH-001 CARD FRAME GATES PASS")
		quit(0)
	else:
		quit(1)
