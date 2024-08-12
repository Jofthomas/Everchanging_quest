extends AttackEffect
class_name StunEffect

@onready var timer: Timer = $Timer

var finished = false

func apply_effect(body: PhysicsBody2D):
	if finished:
		return false
	if timer.is_stopped():
		timer.start()
	body.velocity = Vector2(0,0)
	return true

	
func _on_timer_timeout() -> void:
	finished = true
	
