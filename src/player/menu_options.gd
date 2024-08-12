extends Control

var mode = DisplayServer.WINDOW_MODE_WINDOWED

func _on_button_2_pressed() -> void:
	if mode == DisplayServer.WINDOW_MODE_WINDOWED:
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(mode)
	else:
		mode = DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(mode)
func _on_button_pressed2() -> void:
	pass # Replace with function body.
