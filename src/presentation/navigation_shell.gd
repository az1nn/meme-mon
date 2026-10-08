extends Control
## ART-002: one global navigation entry for desktop, web and touch.
## Presentational only: emits routes, never owns duel/deck rules.

signal route_selected(route: String)

const INK := Color(0.13, 0.14, 0.27)
const NAVY := Color(0.035, 0.10, 0.25)
const CREAM := Color(1.0, 0.956, 0.862)
const CYAN := Color(0.28, 0.85, 0.82)
const CORAL := Color(0.965, 0.416, 0.333)
const YELLOW := Color(1.0, 0.78, 0.29)

var content: VBoxContainer
var menu_button: Button
var menu_overlay: Control
var menu_panel: PanelContainer
var outside_area: ColorRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build()
	resized.connect(Callable(self, "_fit_drawer"))
	_fit_drawer()

func _build() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = CREAM
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 0)
	add_child(column)

	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", _surface(NAVY, 0))
	column.add_child(header)
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 8)
	header.add_child(header_row)

	menu_button = Button.new()
	menu_button.name = "MenuTrigger"
	menu_button.text = "☰ MENU"
	menu_button.tooltip_text = "Abrir menu de navegação"
	menu_button.custom_minimum_size = Vector2(88, 56)
	menu_button.focus_mode = Control.FOCUS_ALL
	menu_button.add_theme_color_override("font_color", INK)
	menu_button.add_theme_stylebox_override("normal", _surface(YELLOW, 14))
	menu_button.pressed.connect(Callable(self, "open_menu"))
	header_row.add_child(menu_button)

	var logo := Label.new()
	logo.text = "MEMEMOM"
	logo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	logo.add_theme_color_override("font_color", Color.WHITE)
	logo.add_theme_font_size_override("font_size", 21)
	logo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	logo.clip_text = true
	header_row.add_child(logo)

	var version := Label.new()
	version.text = "ALPHA 0.1"
	version.add_theme_color_override("font_color", CYAN)
	version.add_theme_font_size_override("font_size", 11)
	version.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header_row.add_child(version)

	var viewport_scroll := ScrollContainer.new()
	viewport_scroll.name = "PageScroll"
	viewport_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(viewport_scroll)
	var page_margin := MarginContainer.new()
	page_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		page_margin.add_theme_constant_override(side, 12)
	viewport_scroll.add_child(page_margin)
	content = VBoxContainer.new()
	content.name = "PageContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	page_margin.add_child(content)

	menu_overlay = Control.new()
	menu_overlay.name = "NavigationOverlay"
	menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(menu_overlay)

	outside_area = ColorRect.new()
	outside_area.name = "OutsideDismiss"
	outside_area.color = Color(0.02, 0.04, 0.10, 0.65)
	outside_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outside_area.mouse_filter = Control.MOUSE_FILTER_STOP
	outside_area.gui_input.connect(Callable(self, "_outside_input"))
	menu_overlay.add_child(outside_area)

	menu_panel = PanelContainer.new()
	menu_panel.name = "MenuDrawer"
	menu_panel.anchor_bottom = 1.0
	menu_panel.offset_bottom = 0.0
	menu_panel.add_theme_stylebox_override("panel", _surface(NAVY, 0))
	menu_overlay.add_child(menu_panel)
	var drawer_margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		drawer_margin.add_theme_constant_override(side, 16)
	menu_panel.add_child(drawer_margin)
	var entries := VBoxContainer.new()
	entries.add_theme_constant_override("separation", 14)
	drawer_margin.add_child(entries)

	var top := HBoxContainer.new()
	entries.add_child(top)
	var menu_title := Label.new()
	menu_title.text = "NAVEGAÇÃO"
	menu_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_title.add_theme_color_override("font_color", Color.WHITE)
	menu_title.add_theme_font_size_override("font_size", 19)
	top.add_child(menu_title)
	var close_button := Button.new()
	close_button.name = "CloseMenu"
	close_button.text = "✕"
	close_button.tooltip_text = "Fechar menu"
	close_button.custom_minimum_size = Vector2(48, 48)
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.pressed.connect(Callable(self, "close_menu"))
	top.add_child(close_button)
	_add_route(entries, "⚔  Duelo", "duel")
	_add_route(entries, "▣  Coleção / Deckbuilder", "collection")
	var note := Label.new()
	note.text = "Forge e outros recursos chegam em futuras versões."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", CYAN)
	entries.add_child(note)

	menu_overlay.visible = false

func _surface(color: Color, radius: int = 16) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.content_margin_left = 12.0
	box.content_margin_right = 12.0
	box.content_margin_top = 7.0
	box.content_margin_bottom = 7.0
	return box

func _add_route(parent: VBoxContainer, label: String, route: String) -> void:
	var button := Button.new()
	button.text = label
	button.name = "Route_" + route
	button.custom_minimum_size = Vector2(0, 54)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _surface(CYAN, 12))
	button.pressed.connect(Callable(self, "_navigate").bind(route))
	parent.add_child(button)

func _navigate(route: String) -> void:
	close_menu()
	route_selected.emit(route)

func is_menu_open() -> bool:
	return menu_overlay != null and menu_overlay.visible

func open_menu() -> void:
	if is_menu_open():
		return
	menu_overlay.visible = true
	_fit_drawer()
	var close_button := menu_panel.find_child("CloseMenu", true, false) as Button
	if close_button != null:
		close_button.grab_focus()

func close_menu() -> void:
	if not is_menu_open():
		return
	menu_overlay.visible = false
	if menu_button != null and is_inside_tree():
		menu_button.grab_focus()

func _outside_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		close_menu()
		accept_event()

func _unhandled_input(event: InputEvent) -> void:
	if is_menu_open() and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_BACK:
			close_menu()
			get_viewport().set_input_as_handled()

func _fit_drawer() -> void:
	if menu_panel != null:
		menu_panel.offset_right = minf(344.0, size.x * 0.87)
