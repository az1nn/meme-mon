extends VBoxContainer
## ART-002 wave 2: responsive duel HUD. Rendering only; never mutates match state.

const NavigationShell = preload("res://src/presentation/navigation_shell.gd")

var turn_label: Label
var rival_summary: Label
var player_summary: Label
var rival_active_row: HFlowContainer
var player_active_row: HFlowContainer
var player_queue_row: HFlowContainer
var player_hand_row: HFlowContainer
var rival_hand_label: Label
var terminal_label: Label

func _ready() -> void:
	add_theme_constant_override("separation", 12)
	_build()

func _build() -> void:
	turn_label = _text(self, "AGUARDANDO PARTIDA", 17, NavigationShell.INK)
	turn_label.name = "RoundStatus"

	var rival := _panel("RIVAL • CAMPO", NavigationShell.CORAL)
	rival_summary = _text(rival, "", 15, NavigationShell.INK)
	rival_hand_label = _text(rival, "", 13, NavigationShell.INK)
	_text(rival, "MEMEMOM ATIVO", 12, NavigationShell.INK)
	rival_active_row = _wrap(rival, "RivalActive")

	var yours := _panel("VOCÊ • CAMPO", NavigationShell.CYAN)
	player_summary = _text(yours, "", 15, NavigationShell.INK)
	_text(yours, "MEMEMOM ATIVO", 12, NavigationShell.INK)
	player_active_row = _wrap(yours, "PlayerActive")
	_text(yours, "SUA QUEUE", 12, NavigationShell.INK)
	player_queue_row = _wrap(yours, "PlayerQueue")
	_text(yours, "SUA MÃO", 12, NavigationShell.INK)
	player_hand_row = _wrap(yours, "PlayerHand")

	terminal_label = _text(self, "", 18, NavigationShell.INK)
	terminal_label.name = "TerminalResult"
	terminal_label.visible = false

func _panel(title: String, accent: Color) -> VBoxContainer:
	var frame := PanelContainer.new()
	var skin := StyleBoxFlat.new()
	skin.bg_color = NavigationShell.CREAM
	skin.border_color = NavigationShell.INK
	skin.set_border_width_all(2)
	skin.set_corner_radius_all(18)
	skin.content_margin_left = 12
	skin.content_margin_right = 12
	skin.content_margin_top = 12
	skin.content_margin_bottom = 12
	frame.add_theme_stylebox_override("panel", skin)
	add_child(frame)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 9)
	frame.add_child(layout)
	var caption := _text(layout, title, 19, NavigationShell.INK)
	caption.add_theme_color_override("font_shadow_color", accent)
	return layout

func _text(parent: Node, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _wrap(parent: Node, node_name: String) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.name = node_name
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	parent.add_child(flow)
	return flow

func _clear(row: HFlowContainer) -> void:
	for child in row.get_children():
		row.remove_child(child)
		child.queue_free()

func _chip(row: HFlowContainer, content: String, fill: Color, featured: bool = false) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(166 if featured else 142, 105 if featured else 82)
	var skin := StyleBoxFlat.new()
	skin.bg_color = fill
	skin.border_color = NavigationShell.INK
	skin.set_border_width_all(2)
	skin.set_corner_radius_all(15)
	skin.content_margin_left = 10
	skin.content_margin_right = 10
	skin.content_margin_top = 10
	skin.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", skin)
	row.add_child(card)
	_text(card, content, 14 if featured else 12, NavigationShell.INK)

func _card_fill(kind: String) -> Color:
	match kind:
		"mememom":
			return NavigationShell.YELLOW
		"reaction":
			return NavigationShell.CORAL
		"format":
			return NavigationShell.CYAN
		_:
			return NavigationShell.CREAM

func _render_card(row: HFlowContainer, instance: Dictionary, catalog: Dictionary, featured: bool = false) -> void:
	var definition: Dictionary = catalog.get(str(instance.get("edition_id", "")), {})
	if definition.is_empty():
		_chip(row, "Carta indisponível", NavigationShell.CREAM, featured)
		return
	var kind := str(definition.get("kind", ""))
	var name := str(definition.get("name", "Carta sem nome"))
	var meta := "%s • %s  |  Trend %s" % [kind.to_upper(), str(definition.get("type", "")), str(definition.get("trend_cost", 0))]
	var detail := ""
	if kind == "mememom":
		var stats: Dictionary = definition.get("mememom", {})
		var attack: Dictionary = stats.get("attack", {})
		detail = "\nHP %d/%d  •  Dano %d" % [int(instance.get("hp_remaining", stats.get("hp", 0))), int(stats.get("hp", 0)), int(attack.get("damage", 0))]
	_chip(row, "%s\n%s%s" % [name, meta, detail], _card_fill(kind), featured)

func _show_zone(row: HFlowContainer, cards: Array, catalog: Dictionary, limit: int = 6) -> void:
	_clear(row)
	if cards.is_empty():
		_chip(row, "Nenhuma carta", NavigationShell.CREAM)
		return
	for i in range(mini(cards.size(), limit)):
		var instance: Dictionary = cards[i]
		_render_card(row, instance, catalog)

func _show_active(row: HFlowContainer, active: Variant, catalog: Dictionary) -> void:
	_clear(row)
	if typeof(active) != TYPE_DICTIONARY:
		_chip(row, "Sem ativo • reposição pendente", NavigationShell.CREAM, true)
		return
	_render_card(row, active, catalog, true)

func update_from_match(state: Dictionary, catalog: Dictionary) -> void:
	if state.is_empty() or not state.has("players"):
		return
	var players: Dictionary = state["players"]
	if not players.has("p1") or not players.has("p2"):
		return
	var mine: Dictionary = players["p1"]
	var enemy: Dictionary = players["p2"]
	var actor := "Sua vez" if str(state.get("active_player_id", "")) == "p1" else "Vez do rival"
	turn_label.text = "TURNO %d  •  %s  •  %s" % [int(state.get("turn_number", 0)), actor, str(state.get("phase", "")).to_upper()]
	rival_summary.text = "Hype %d/5  •  Trend %d/%d  •  Queue %d" % [int(enemy.get("hype", 0)), int(enemy["trend"]["current"]), int(enemy["trend"]["cap"]), enemy["queue"].size()]
	player_summary.text = "Hype %d/5  •  Trend %d/%d  •  Queue %d" % [int(mine.get("hype", 0)), int(mine["trend"]["current"]), int(mine["trend"]["cap"]), mine["queue"].size()]
	rival_hand_label.text = "Mão do rival: %d cartas (ocultas)" % enemy["hand"].size()
	_show_active(rival_active_row, enemy.get("active", null), catalog)
	_show_active(player_active_row, mine.get("active", null), catalog)
	_show_zone(player_queue_row, mine["queue"], catalog, 3)
	_show_zone(player_hand_row, mine["hand"], catalog)
	var terminal = state.get("terminal", null)
	terminal_label.visible = terminal != null
	if typeof(terminal) == TYPE_DICTIONARY:
		var who := str(terminal.get("winner_player_id", ""))
		var result := "EMPATE" if who.is_empty() else ("VOCÊ VENCEU" if who == "p1" else "RIVAL VENCEU")
		terminal_label.text = "PARTIDA ENCERRADA • %s" % result
