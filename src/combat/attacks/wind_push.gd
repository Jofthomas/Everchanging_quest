extends Equipement

@export var number_of_flamme = 5
@export var rootNode: Node2D

@onready var timer : Timer= $Timer
@onready var flamme_template = $FlammeTemplate

const global = preload("res://global.gd")

var gap_before_first = 50
var gap = 20

var direction
var last_position
var cpt

func attack(orientation, position: Vector2, damage):
	
	direction = global.orientation_to_direction(orientation)
	
	last_position = rootNode.position + direction * gap_before_first
	spawn_flamme(last_position,orientation)
	cpt = 1
	
	timer.start()

func get_texture():
	return $Icon.texture
	
func spawn_flamme(position,orientation):
	var flamme: Node2D = flamme_template.duplicate()
	flamme.position = position
	flamme.visible = true
	rootNode.get_parent().add_child(flamme)
	flamme.start(attack_effects,global.orientation_to_direction(orientation))
	
func _on_timer_timeout(orientation) -> void:
	if cpt < number_of_flamme:
		last_position = last_position + direction * gap
		spawn_flamme(last_position,orientation)
		cpt += 1
		timer.start()