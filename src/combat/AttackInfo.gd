extends Node
class_name AttackInfo

@export var damage: int
@export var attack_position: Vector2
@export var attacker_position: Vector2
@export var attacked_position: Vector2

func _init(p_attack:int,p_attack_position: Vector2,p_attacker_position :Vector2, p_attacked_position:Vector2):
	damage = p_attack
	attack_position = p_attack_position
	attacker_position = p_attacker_position
	attacked_position = p_attacked_position
