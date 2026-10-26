extends Control
## SCENE/ARCH-001: isolated face container. No rules, art ownership, or animations.
## Caller chooses the actual aspect ratio; C01 concept-sheet pixels are NOT runtime authority.

signal face_changed(back_visible: bool)

var _aspect: float = 0.75 # QA default, NOT an ART-approved card dimension.
var _safe_inset: float = 0.0
var _back_visible: bool = false
var _front_source: Texture2D
var _back_source: Texture2D

var _frame: Control
var _safe: Control
var _front: TextureRect
var _back: TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_frame = Control.new()
	_frame.name = "VisualFrame"
	_frame.clip_contents = true # Rectangular clipping only; NOT a rounded C01 mask.
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)

	_safe = Control.new()
	_safe.name = "SafeArea"
	_safe.clip_contents = true
	_safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_safe)

	_front = _texture_view("FrontTexture")
	_back = _texture_view("BackTexture")
	_safe.add_child(_front)
	_safe.add_child(_back)
	_front.texture = _front_source
	_back.texture = _back_source
	_refresh_face()
	resized.connect(_layout)
	_layout()

func _texture_view(node_name: String) -> TextureRect:
	var view := TextureRect.new()
	view.name = node_name
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return view

func set_face_textures(front: Texture2D, back: Texture2D) -> void:
	_front_source = front
	_back_source = back
	if _front != null:
		_front.texture = front
		_back.texture = back

func get_visible_texture() -> Texture2D:
	return _back_source if _back_visible else _front_source

func set_back_visible(value: bool) -> void:
	if _back_visible == value:
		return
	_back_visible = value
	_refresh_face()
	face_changed.emit(_back_visible)

func is_back_visible() -> bool:
	return _back_visible

func _refresh_face() -> void:
	if _front == null:
		return
	_front.visible = not _back_visible
	_back.visible = _back_visible

func set_frame_aspect_ratio(value: float) -> bool:
	if value <= 0.0 or is_nan(value) or is_inf(value):
		return false
	_aspect = value
	_layout()
	return true

func get_frame_aspect_ratio() -> float:
	return _aspect

func set_safe_inset_fraction(value: float) -> bool:
	if value < 0.0 or value > 0.25 or is_nan(value) or is_inf(value):
		return false
	_safe_inset = value
	_layout()
	return true

func get_safe_inset_fraction() -> float:
	return _safe_inset

func fitted_rect_for(bounds: Vector2) -> Rect2:
	if bounds.x <= 0.0 or bounds.y <= 0.0:
		return Rect2()
	var width: float = minf(bounds.x, bounds.y * _aspect)
	var height: float = width / _aspect
	return Rect2((bounds - Vector2(width, height)) * 0.5, Vector2(width, height))

func content_rect_for(bounds: Vector2) -> Rect2:
	var frame_rect: Rect2 = fitted_rect_for(bounds)
	var inset := Vector2(frame_rect.size.x * _safe_inset, frame_rect.size.y * _safe_inset)
	return Rect2(frame_rect.position + inset, frame_rect.size - inset * 2.0)

func get_actual_frame_rect() -> Rect2:
	if _frame == null:
		return Rect2()
	return Rect2(_frame.position, _frame.size)

func get_actual_safe_rect() -> Rect2:
	if _safe == null:
		return Rect2()
	return Rect2(_frame.position + _safe.position, _safe.size)

func _layout() -> void:
	if _frame == null:
		return
	var bounds: Rect2 = fitted_rect_for(size)
	_frame.position = bounds.position
	_frame.size = bounds.size
	var inset := Vector2(bounds.size.x * _safe_inset, bounds.size.y * _safe_inset)
	_safe.position = inset
	_safe.size = bounds.size - inset * 2.0
	_front.position = Vector2.ZERO
	_front.size = _safe.size
	_back.position = Vector2.ZERO
	_back.size = _safe.size
