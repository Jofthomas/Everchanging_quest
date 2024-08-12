extends Equipement

@export var rootNode: CharacterBody2D

const global = preload("res://global.gd")


func attack(orientation, position: Vector2, damage):
	$AnimatedSprite2D.play("heal")
	rootNode.heal()

func get_texture():
	return $Icon.texture
