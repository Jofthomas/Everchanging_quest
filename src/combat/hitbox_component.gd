extends Area2D
class_name HitboxComponent

@export var health_comp : HealthComponent
# Node with add_effect function
@export var effect_component : Node
@export var body : PhysicsBody2D

func damage(attack_info, attack_effects):
	init_effects(attack_effects,attack_info)
	effect_component.add_effects(attack_effects)
	
	if health_comp:
		health_comp.damage(attack_info.damage)
	else:
		print("no health to damage")
		
func init_effects(attack_effects,attack_info: AttackInfo) :
	for effect in attack_effects:
		effect.set_attack_info(attack_info)
	
func get_body() -> PhysicsBody2D:
	return body
