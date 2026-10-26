extends Control
## Isolated QA preview using generated flat swatches, NOT approved art or runtime acceptance.

const CardVisualFrame = preload("res://src/presentation/card_visual_frame.gd")

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color(0.04, 0.07, 0.13)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var content := VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 16
	content.offset_top = 16
	content.offset_right = -16
	content.offset_bottom = -16
	content.add_theme_constant_override("separation", 12)
	add_child(content)

	var title := Label.new()
	title.text = "SCENE/ARCH-001 | CardVisualFrame — QA de geometria (sem arte C05)"
	content.add_child(title)
	var hint := Label.new()
	hint.text = "Duas faces de teste; nenhuma imagem foi integrada ao produto."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(hint)

	var pair := HBoxContainer.new()
	pair.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(pair)
	var front := CardVisualFrame.new()
	var back := CardVisualFrame.new()
	for card in [front, back]:
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.set_frame_aspect_ratio(0.75)
		card.set_safe_inset_fraction(0.04)
		pair.add_child(card)
	var front_image := _sample_texture(Color(0.1, 0.64, 0.78))
	var back_image := _sample_texture(Color(0.96, 0.60, 0.15))
	front.set_face_textures(front_image, back_image)
	back.set_face_textures(front_image, back_image)
	back.set_back_visible(true)

func _sample_texture(fill: Color) -> Texture2D:
	var image := Image.create(12, 16, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	return ImageTexture.create_from_image(image)
