extends CanvasLayer

@onready var screen_manager : ScreenManager = get_node("/root/Main/ScreenManager")

func _on_timer_timeout() -> void:
	screen_manager.set_screen(screen_manager.screen.CHATEAU)
