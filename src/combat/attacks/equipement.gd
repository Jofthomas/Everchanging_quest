extends Node2D
class_name Equipement

@export var attack_effects : Array[PackedScene]

func attack(orientation, position: Vector2, damage: int):
	print("unimplemented attack equipement")

func get_texture() -> Texture:
	print("unimplemented get_texture equipement")
	return Texture.new()
