extends Area2D

@export var attack_effects : Array[PackedScene]
@export var damage = 1

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox_player"):
		var hitbox : HitboxComponent = area as HitboxComponent
		var attack_info: AttackInfo = AttackInfo.new(damage,(global_position+hitbox.get_body().get_node("CollisionShape2D").global_position)/2,global_position,hitbox.get_body().get_node("CollisionShape2D").global_position)
		hitbox.damage(attack_info,attack_effects.map(func(scene: PackedScene): return scene.instantiate()))
