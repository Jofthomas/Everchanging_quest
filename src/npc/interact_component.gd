extends Node2D
class_name InteractComponent

@export var actionNode: InteractAction
# play the "idle" and "idle_working" animation if specified
@export var _animated_sprite : AnimatedSprite2D 
# text shown to player
@export_multiline var textBB: String

@onready var interact_indicator : RichTextLabel = $InteractIndicator
var idle_position = "idle"
var focus_position = "idle_working"

func _ready():
	interact_indicator.text = textBB
	interact_indicator.visible = false
	if _animated_sprite:
		_animated_sprite.play(idle_position)
	

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if _animated_sprite:
			_animated_sprite.play(focus_position)
		interact_indicator.visible = true
		
func _on_body_exited(body):
	if body.is_in_group("player"):
		if _animated_sprite:
			_animated_sprite.play(idle_position)
		interact_indicator.visible = false
		actionNode.cancel()

		
func interact():
	interact_indicator.visible = false
	actionNode.interact()
