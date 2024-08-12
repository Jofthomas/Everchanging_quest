extends Control
var screen_manager: ScreenManager

func _on_play_pressed():
	screen_manager.set_screen(screen_manager.screen.CHATEAU)

func _on_exit_pressed():
	get_tree().quit()
