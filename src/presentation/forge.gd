extends Node

const SandboxForgeModel = preload("res://src/domain/sandbox_forge_model.gd")
const SandboxForgeStore = preload("res://src/data/sandbox_forge_store.gd")
const NavigationShell = preload("res://src/presentation/navigation_shell.gd")
const SANDBOX_PATH := "user://mememom/sandbox.json"

var model = SandboxForgeModel.new()
var store = SandboxForgeStore.new()
var name_input: LineEdit
var type_picker: OptionButton
var flavor_input: TextEdit
var tags_input: LineEdit
var media_input: LineEdit
var attribution_input: LineEdit
var source_input: LineEdit
var rights_input: TextEdit
var record_picker: OptionButton
var preview_label: Label
var feedback_label: Label
var image_preview: TextureRect
var picker: FileDialog
var active_id := ""

func _ready() -> void:
	var loaded := store.load_records(SANDBOX_PATH)
	if loaded["ok"]:
		var imported: Dictionary = model.import_records(loaded["records"])
		if not imported["ok"]:
			push_error("Sandbox records rejected: %s" % imported["code"])
	_build_ui()
	_refresh_picker()
	_render_preview()

func _build_ui() -> void:
	var shell = NavigationShell.new()
	add_child(shell)
	shell.route_selected.connect(Callable(self, "_on_route"))
	var root: VBoxContainer = shell.content
	var title := Label.new()
	title.text = "✦ MEME FORGE"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", NavigationShell.INK)
	root.add_child(title)
	var notice := Label.new()
	notice.text = "Sandbox privado: não entra em decks, duelos ou Canon. Você declara a origem; publicação exige revisão futura."
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_color_override("font_color", NavigationShell.INK)
	root.add_child(notice)
	record_picker = OptionButton.new()
	record_picker.custom_minimum_size = Vector2(0, 48)
	record_picker.item_selected.connect(Callable(self, "_pick_record"))
	root.add_child(record_picker)
	name_input = _line(root, "Nome do Mememom (obrigatório)")
	type_picker = OptionButton.new()
	type_picker.custom_minimum_size = Vector2(0, 48)
	for type_name in SandboxForgeModel.VALID_TYPES:
		type_picker.add_item(type_name.capitalize())
	type_picker.item_selected.connect(Callable(self, "_render_preview"))
	root.add_child(type_picker)
	flavor_input = _text(root, "Flavor (opcional)", 70)
	tags_input = _line(root, "Tags separadas por vírgula (opcional)")
	media_input = _line(root, "Referência local da imagem (obrigatória)")
	var choose_image := Button.new()
	choose_image.text = "ESCOLHER IMAGEM LOCAL"
	choose_image.custom_minimum_size = Vector2(0, 48)
	choose_image.pressed.connect(Callable(self, "_open_image_picker"))
	root.add_child(choose_image)
	image_preview = TextureRect.new()
	image_preview.custom_minimum_size = Vector2(0, 180)
	image_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(image_preview)
	attribution_input = _line(root, "Atribuição/origem (obrigatória)")
	source_input = _line(root, "URL ou referência da fonte (obrigatória)")
	rights_input = _text(root, "Base de direitos/permissão (obrigatória)", 70)
	for input in [name_input, tags_input, media_input, attribution_input, source_input]:
		input.text_changed.connect(Callable(self, "_render_preview"))
	flavor_input.text_changed.connect(Callable(self, "_render_preview"))
	rights_input.text_changed.connect(Callable(self, "_render_preview"))
	preview_label = Label.new()
	preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_label.add_theme_color_override("font_color", NavigationShell.INK)
	root.add_child(preview_label)
	var actions := HFlowContainer.new()
	root.add_child(actions)
	for action in [["SALVAR SANDBOX", "_save"], ["NOVO", "_new_record"], ["EXCLUIR", "_delete"]]:
		var button := Button.new()
		button.text = action[0]
		button.custom_minimum_size = Vector2(140, 52)
		button.pressed.connect(Callable(self, action[1]))
		actions.add_child(button)
	feedback_label = Label.new()
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_color_override("font_color", NavigationShell.INK)
	root.add_child(feedback_label)
	picker = FileDialog.new()
	picker.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	picker.access = FileDialog.ACCESS_FILESYSTEM
	picker.filters = PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp ; Imagens"])
	picker.file_selected.connect(Callable(self, "_on_image_selected"))
	add_child(picker)

func _line(parent: Container, placeholder: String) -> LineEdit:
	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.custom_minimum_size = Vector2(0, 48)
	parent.add_child(input)
	return input

func _text(parent: Container, placeholder: String, height: float) -> TextEdit:
	var input := TextEdit.new()
	input.placeholder_text = placeholder
	input.custom_minimum_size = Vector2(0, height)
	input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	parent.add_child(input)
	return input

func _forge_input() -> Dictionary:
	var tags: Array = []
	for tag in tags_input.text.split(",", false):
		tags.append(tag)
	return {"name": name_input.text, "type": SandboxForgeModel.VALID_TYPES[type_picker.selected], "flavor": flavor_input.text, "tags": tags, "media_reference": media_input.text, "attribution": attribution_input.text, "source_reference": source_input.text, "rights_basis": rights_input.text}

func _render_preview(_ignored = null) -> void:
	if preview_label == null:
		return
	var result: Dictionary = model.preview(_forge_input())
	if not result["ok"]:
		preview_label.text = "Prévia bloqueada: %s" % result["code"]
		return
	var card: Dictionary = result["card"]
	preview_label.text = "PRÉVIA GERADA (não competitiva): %s | %s | custo %d | HP %d | dano %d" % [card["name"], card["type"], card["trend_cost"], card["mememom"]["hp"], card["mememom"]["attack"]["damage"]]

func _save() -> void:
	var result: Dictionary
	if active_id.is_empty():
		var candidate_id := "sandbox.local.%d" % (model.records.size() + 1)
		while model.records.has(candidate_id):
			candidate_id += "x"
		result = model.create(_forge_input(), candidate_id)
		if result["ok"]:
			active_id = candidate_id
	else:
		result = model.update(active_id, _forge_input())
	if not result["ok"]:
		_show("Salvar bloqueado: %s" % result["code"])
		return
	var saved := store.save_records(SANDBOX_PATH, model.export_records())
	_show("Sandbox salvo localmente" if saved["ok"] else "Salvar bloqueado: %s" % saved["code"])
	_refresh_picker()

func _new_record() -> void:
	active_id = ""
	name_input.clear(); flavor_input.clear(); tags_input.clear(); media_input.clear(); attribution_input.clear(); source_input.clear(); rights_input.clear()
	image_preview.texture = null
	type_picker.select(0)
	_show("Novo Sandbox (ainda não salvo)")
	_render_preview()

func _delete() -> void:
	if active_id.is_empty():
		_show("Nenhum Sandbox selecionado")
		return
	var result := model.delete(active_id)
	if result["ok"]:
		var saved := store.save_records(SANDBOX_PATH, model.export_records())
		_show("Sandbox excluído" if saved["ok"] else "Exclusão local pendente: %s" % saved["code"])
		_new_record(); _refresh_picker()
	else:
		_show("Exclusão bloqueada: %s" % result["code"])

func _refresh_picker() -> void:
	if record_picker == null:
		return
	record_picker.clear()
	record_picker.add_item("Novo Sandbox")
	record_picker.set_item_metadata(0, "")
	for record in model.export_records():
		var index := record_picker.item_count
		record_picker.add_item(str(record["name"]))
		record_picker.set_item_metadata(index, str(record["sandbox_id"]))

func _pick_record(index: int) -> void:
	active_id = str(record_picker.get_item_metadata(index))
	if active_id.is_empty():
		_new_record()
		return
	var record: Dictionary = model.records[active_id]
	name_input.text = record["name"]; flavor_input.text = record["flavor"]; tags_input.text = ", ".join(record["tags"])
	media_input.text = record["media_reference"]; attribution_input.text = record["attribution"]; source_input.text = record["source_reference"]; rights_input.text = record["rights_basis"]
	type_picker.select(SandboxForgeModel.VALID_TYPES.find(record["type"]))
	_load_preview_image(media_input.text)
	_render_preview()

func _open_image_picker() -> void:
	picker.popup_centered_ratio(0.8)

func _on_image_selected(path: String) -> void:
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		_show("Imagem bloqueada: formato não suportado")
		return
	var media_dir := "user://mememom/media"
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(media_dir)) != OK:
		_show("Imagem bloqueada: armazenamento indisponível")
		return
	var safe_id := active_id if not active_id.is_empty() else "draft-%d" % Time.get_unix_time_from_system()
	var destination := "%s/%s.png" % [media_dir, safe_id.validate_filename()]
	if image.save_png(destination) != OK:
		_show("Imagem bloqueada: falha ao copiar para Sandbox privado")
		return
	media_input.text = destination
	_load_preview_image(destination)
	_render_preview()
	_show("Imagem copiada para Sandbox privado")

func _load_preview_image(path: String) -> void:
	if image_preview == null:
		return
	var image := Image.load_from_file(path)
	image_preview.texture = ImageTexture.create_from_image(image) if image != null and not image.is_empty() else null

func _on_route(route: String) -> void:
	if route == "duel": get_tree().change_scene_to_file("res://scenes/Main.tscn")
	elif route == "collection": get_tree().change_scene_to_file("res://scenes/Collection.tscn")

func _show(message: String) -> void:
	feedback_label.text = message
