class_name OnlineMatchStatus
extends VBoxContainer

signal reconnect_requested

const NavigationShell = preload("res://src/presentation/navigation_shell.gd")

var state_label: Label
var detail_label: Label
var reconnect_button: Button

func _ready() -> void:
	add_theme_constant_override("separation", 4)
	state_label = Label.new()
	state_label.text = "ONLINE • LOCAL"
	state_label.add_theme_font_size_override("font_size", 13)
	state_label.add_theme_color_override("font_color", NavigationShell.INK)
	add_child(state_label)
	detail_label = Label.new()
	detail_label.text = "A partida local continua disponível."
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_color_override("font_color", NavigationShell.INK)
	add_child(detail_label)
	reconnect_button = Button.new()
	reconnect_button.text = "TENTAR RECONECTAR"
	reconnect_button.custom_minimum_size = Vector2(0, 48)
	reconnect_button.focus_mode = Control.FOCUS_ALL
	reconnect_button.visible = false
	reconnect_button.pressed.connect(func() -> void: reconnect_requested.emit())
	add_child(reconnect_button)

func set_connection_state(state: String, detail: String = "") -> void:
	state_label.text = "ONLINE • " + state.to_upper()
	detail_label.text = detail if not detail.is_empty() else _default_detail(state)
	reconnect_button.visible = state == "disconnected" or state == "error" or state == "closed"

func bind_client(client: Object) -> void:
	if client == null:
		return
	client.connection_state_changed.connect(Callable(self, "set_connection_state"))
	client.reconnect_required.connect(Callable(self, "_on_reconnect_required"))

func _on_reconnect_required() -> void:
	set_connection_state("disconnected", "A conexão caiu; o estado autoritativo será recuperado ao reconectar.")

func _default_detail(state: String) -> String:
	match state:
		"connected": return "Canal WebSocket conectado; aguardando autenticação."
		"authenticated": return "Sessão autenticada pelo servidor autoritativo."
		"connecting": return "Conectando ao servidor autoritativo…"
		"disconnected", "closed", "error": return "Sem conexão online; nenhuma decisão competitiva é feita localmente."
		_: return "A partida local continua disponível."
