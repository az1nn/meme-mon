extends SceneTree
## ART-002: deterministic smoke of shared global navigation, not a visual sign-off.

const NavigationShell = preload("res://src/presentation/navigation_shell.gd")

var checks: int = 0
var failures: Array = []
var selected_route: String = ""

func _init() -> void:
	call_deferred("_run")

func _check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)

func _on_route(route: String) -> void:
	selected_route = route

func _run() -> void:
	var shell = NavigationShell.new()
	get_root().add_child(shell)
	shell.route_selected.connect(Callable(self, "_on_route"))
	_check(shell.content != null, "page content exists")
	_check(shell.menu_button != null, "single hamburger trigger exists")
	_check(shell.menu_button.custom_minimum_size.y >= 44.0, "hamburger touch size")
	_check(not shell.is_menu_open(), "global menu closed by default")
	_check(shell.menu_overlay != null, "drawer overlay available")
	_check(shell.menu_panel != null, "drawer available")
	_check(shell.find_child("Route_duel", true, false) != null, "duel route available")
	_check(shell.find_child("Route_collection", true, false) != null, "collection route available")
	_check(shell.find_child("Route_forge", true, false) == null, "unimplemented Forge route absent")
	shell.open_menu()
	_check(shell.is_menu_open(), "hamburger opens menu")
	shell.close_menu()
	_check(not shell.is_menu_open(), "close dismisses menu")
	shell.open_menu()
	shell._navigate("collection")
	_check(not shell.is_menu_open(), "route closes menu")
	_check(selected_route == "collection", "collection route emitted")
	for width in [360, 390, 768, 1100]:
		shell.size = Vector2(float(width), 720.0)
		shell._fit_drawer()
		_check(shell.menu_panel.offset_right <= minf(344.0, float(width) * 0.87) + 1.0, "drawer fits width %d" % width)
		_check(shell.menu_panel.offset_right >= 0.0, "nonnegative drawer width %d" % width)
	shell.queue_free()
	print("ART-002 navigation checks: %d, failures: %d" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	if failures.is_empty():
		print("ART-002 NAVIGATION GATES PASS")
		quit(0)
	else:
		quit(1)
