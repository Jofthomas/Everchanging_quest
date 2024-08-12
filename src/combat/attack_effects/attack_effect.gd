extends Node2D
class_name AttackEffect

var attack_info :AttackInfo

func set_attack_info(p_attack_info : AttackInfo):
	attack_info =  p_attack_info

func apply_effect(body: PhysicsBody2D) -> bool:
	print("AttackEffect interface -> switch for implementation")
	return false
