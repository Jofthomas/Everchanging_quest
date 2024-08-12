extends Node2D
class_name HealthComponent

signal hit
signal die

@export var max_health = 0

@onready var textLabel = $RichTextLabel
@onready var timer = $Timer

var health

func _ready():
	textLabel.visible = false
	health = max_health
#	textLabel.text = "[bgcolor=#d1e4e4]" + str(health) + "[/bgcolor]"

func set_max(max):
	max_health = max
	health = max
	
func _process(_delta):
	textLabel.text = "[center][color=red]" + str(health) + "[/color][/center]"
	
func damage(hitpoint):
	health -= hitpoint
	
	if health < 0:
		emit_signal("die")
		return
		
	emit_signal("hit")
	
	
	textLabel.visible = true
	timer.start()
		
func _on_timer_timeout():
	textLabel.visible = false
