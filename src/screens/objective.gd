extends CanvasLayer

@onready var textLabel = $RichTextLabel
@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display(objective):
	self.visible = true
	textLabel.visible=true
	anim.play("idle")
	timer.start()
	textLabel.text = "[color=black] " + str(objective) + "[/color]"

func undisplay():
	self.visible = false

func _on_timer_timeout() -> void:
	textLabel.visible=false
	anim.play("close")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "close":
		undisplay()

