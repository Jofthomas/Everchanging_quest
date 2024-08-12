extends Equipement

@export var rootNode: CharacterBody2D

@onready var icetemplate = $Ice

const global = preload("res://global.gd")

func attack(orientation: global.ORIENTATION, _position: Vector2, damage):
	var new_arrow: CharacterBody2D = icetemplate.duplicate()
	new_arrow.position = (rootNode.get_node("CollisionShape2D") as CollisionShape2D).global_position
	rootNode.get_parent().add_child(new_arrow)
	new_arrow.start(global.orientation_to_direction(orientation), attack_effects,  rootNode.position)

func get_texture():
	return $Icon.texture
