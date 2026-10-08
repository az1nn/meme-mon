extends Node

const CollectionModel = preload("res://src/domain/collection_model.gd")
const CollectionStore = preload("res://src/data/collection_store.gd")

const PROFILE_PATH := "user://mememom/profile.json"
const ACTIVE_DECK := "starter"

var model = CollectionModel.new()
var store = CollectionStore.new()
var feedback_label: Label
var deck_label: Label
var owned_list: VBoxContainer
var query_input: LineEdit
var kind_filter: OptionButton
var type_filter: OptionButton
var tier_filter: OptionButton
var deck_picker: OptionButton
var deck_name_input: LineEdit
var active_deck_id: String = ACTIVE_DECK

func _ready() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/cards/alpha-test-cards.json"))
	if typeof(data) != TYPE_DICTIONARY or typeof(data.get("cards", null)) != TYPE_ARRAY:
		push_error("MM-05 catalog fixture missing")
		return
	var loaded: Dictionary = model.load_definitions(data["cards"])
	if not loaded["ok"]:
		push_error("MM-05 catalog load failed: %s" % loaded)
		return
	var initial_message := "Local Alpha test collection: not Canon."
	if FileAccess.file_exists(PROFILE_PATH):
		var existing: Dictionary = store.load_profile(PROFILE_PATH)
		if existing["ok"]:
			existing = model.import_profile(existing["profile"])
		if not existing["ok"]:
			initial_message = "Profile blocked: %s (no data overwritten)" % existing["code"]
	else:
		model.seed_alpha_starter(2)
		model.create_deck(ACTIVE_DECK, "Starter 30")
		var ids: Array = model.catalog.keys()
		ids.sort()
		for edition_id in ids:
			model.add_card(active_deck_id, edition_id)
		for i in range(10):
			model.add_card(active_deck_id, ids[i])
	_build_ui()
	_refresh_deck_picker()
	_show_message(initial_message)
	_render_cards()

func _build_ui() -> void:
	var root = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)
	var title = Label.new()
	title.text = "MEMEMOM — Collection / Deckbuilder (Alpha 0.1)"
	title.add_theme_font_size_override("font_size", 22)
	root.add_child(title)

	var toolbar = HBoxContainer.new()
	root.add_child(toolbar)
	query_input = LineEdit.new()
	query_input.placeholder_text = "Search card name or ID"
	query_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	query_input.text_changed.connect(Callable(self, "_on_filter_changed"))
	toolbar.add_child(query_input)
	kind_filter = _add_filter(toolbar, ["All kinds", "mememom", "reaction", "format"])
	type_filter = _add_filter(toolbar, ["All types", "classic", "reaction", "brainrot", "surreal", "wholesome"])
	tier_filter = _add_filter(toolbar, ["All tiers", "standard", "headliner"])

	var deck_toolbar = HBoxContainer.new()
	root.add_child(deck_toolbar)
	deck_picker = OptionButton.new()
	deck_picker.item_selected.connect(Callable(self, "_on_pick_deck"))
	deck_toolbar.add_child(deck_picker)
	deck_name_input = LineEdit.new()
	deck_name_input.placeholder_text = "Name for new deck"
	deck_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_toolbar.add_child(deck_name_input)
	var create_button = Button.new()
	create_button.text = "New deck"
	create_button.pressed.connect(Callable(self, "_create_new_deck"))
	deck_toolbar.add_child(create_button)

	deck_label = Label.new()
	root.add_child(deck_label)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	owned_list = VBoxContainer.new()
	owned_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(owned_list)

	var buttons = HBoxContainer.new()
	root.add_child(buttons)
	for action in [["Save local profile", "_save"], ["Reload profile", "_reload"], ["Play selected deck", "_play"], ["Back to duel", "_back"]]:
		var button = Button.new()
		button.text = action[0]
		button.pressed.connect(Callable(self, action[1]))
		buttons.add_child(button)
	feedback_label = Label.new()
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(feedback_label)

func _add_filter(parent: HBoxContainer, options: Array) -> OptionButton:
	var control = OptionButton.new()
	for option in options:
		control.add_item(str(option))
	control.item_selected.connect(Callable(self, "_on_filter_changed"))
	parent.add_child(control)
	return control

func _selected_option(control: OptionButton) -> String:
	if control.selected <= 0:
		return ""
	return control.get_item_text(control.selected)

func _on_filter_changed(_value = null) -> void:
	_render_cards()

func _refresh_deck_picker() -> void:
	if deck_picker == null:
		return
	deck_picker.clear()
	var ids: Array = model.decks.keys()
	ids.sort()
	if not ids.is_empty() and not model.decks.has(active_deck_id):
		active_deck_id = str(ids[0])
	for id in ids:
		var idx := deck_picker.item_count
		deck_picker.add_item(str(model.decks[id].get("name", id)))
		deck_picker.set_item_metadata(idx, str(id))
		if str(id) == active_deck_id:
			deck_picker.select(idx)

func _on_pick_deck(index: int) -> void:
	active_deck_id = str(deck_picker.get_item_metadata(index))
	_render_cards()

func _create_new_deck() -> void:
	var deck_num: int = model.decks.size() + 1
	var new_id := "local.%d" % deck_num
	while model.decks.has(new_id):
		deck_num += 1
		new_id = "local.%d" % deck_num
	var name := deck_name_input.text.strip_edges()
	if name.is_empty():
		name = "Deck %d" % deck_num
	var verdict: Dictionary = model.create_deck(new_id, name)
	if not verdict["ok"]:
		_show_message("New deck blocked: %s" % verdict["code"])
		return
	active_deck_id = new_id
	_refresh_deck_picker()
	_show_message("Created %s" % name)
	_render_cards()

func _render_cards() -> void:
	if owned_list == null:
		return
	for child in owned_list.get_children():
		child.queue_free()
	var search = model.filter_cards(query_input.text, _selected_option(kind_filter), _selected_option(type_filter), _selected_option(tier_filter))
	for card in search:
		var row = HBoxContainer.new()
		owned_list.add_child(row)
		var label = Label.new()
		var used := _used_copies(str(card["edition_id"]))
		label.text = "%s | %s / %s | owned %d, deck %d" % [card["name"], card["kind"], card["type"], card["owned"], used]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var add_button = Button.new()
		add_button.text = "+"
		add_button.pressed.connect(Callable(self, "_add").bind(str(card["edition_id"])))
		row.add_child(add_button)
		var remove_button = Button.new()
		remove_button.text = "−"
		remove_button.pressed.connect(Callable(self, "_remove").bind(str(card["edition_id"])))
		row.add_child(remove_button)
	_render_deck()

func _used_copies(edition_id: String) -> int:
	if not model.decks.has(active_deck_id):
		return 0
	var used := 0
	for entry in model.decks[active_deck_id]["cards"]:
		if str(entry["edition_id"]) == edition_id:
			used += 1
	return used

func _render_deck() -> void:
	if deck_label == null:
		return
	if not model.decks.has(active_deck_id):
		deck_label.text = "No active deck (profile needs repair)"
		return
	var count: int = model.decks[active_deck_id]["cards"].size()
	var verdict: Dictionary = model.validate(active_deck_id)
	deck_label.text = "Deck: %d/30 | %s" % [count, "LEGAL" if verdict["ok"] else str(verdict["code"])]

func _add(edition_id: String) -> void:
	var verdict: Dictionary = model.add_card(active_deck_id, edition_id)
	_show_message("Added card" if verdict["ok"] else str(verdict["code"]))
	_render_cards()

func _remove(edition_id: String) -> void:
	var verdict: Dictionary = model.remove_card(active_deck_id, edition_id)
	_show_message("Removed card" if verdict["ok"] else str(verdict["code"]))
	_render_cards()

func _save() -> void:
	var saved: Dictionary = store.save_profile(PROFILE_PATH, model.export_profile())
	_show_message("Saved local profile" if saved["ok"] else "Save blocked: %s" % saved["code"])

func _reload() -> void:
	var result: Dictionary = store.load_profile(PROFILE_PATH)
	if result["ok"]:
		result = model.import_profile(result["profile"])
	if result["ok"]:
		if not model.selected_deck_id.is_empty():
			active_deck_id = model.selected_deck_id
		_refresh_deck_picker()
	_show_message("Profile reloaded" if result["ok"] else "Reload blocked: %s" % result["code"])
	_render_cards()

func _play() -> void:
	var verdict: Dictionary = model.select_deck(active_deck_id)
	if not verdict["ok"]:
		_show_message("Cannot play: %s" % verdict["code"])
		return
	var saved: Dictionary = store.save_profile(PROFILE_PATH, model.export_profile())
	if not saved["ok"]:
		_show_message("Cannot play: save blocked (%s)" % saved["code"])
		return
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _show_message(message: String) -> void:
	if feedback_label != null:
		feedback_label.text = message
