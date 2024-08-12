extends Equipement
class_name BowComponent

@export var rootNode: CharacterBody2D
@onready var arrowTemplate = $Arrow

const global = preload("res://global.gd")

func attack(orientation: global.ORIENTATION, _position: Vector2, damage):
	var new_arrow : CharacterBody2D = arrowTemplate.duplicate()
	
	new_arrow.position = (rootNode.get_node("CollisionShape2D") as CollisionShape2D).global_position
	rootNode.get_parent().add_child(new_arrow)
	new_arrow.start(global.orientation_to_direction(orientation),attack_effects)

func get_texture() -> Texture:
	return $Sprite2D.texture
