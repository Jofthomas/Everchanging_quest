extends Node2D
var attack_effects : Array[PackedScene]

func _ready() -> void:
	if visible:
		$AnimatedSprite2D.play("default")

func start(p_attack_effects):
	attack_effects = p_attack_effects

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if visible && area.is_in_group("hitbox") and not area.is_in_group("hitbox_player"):
			var hitbox : HitboxComponent = area as HitboxComponent
			var attack_info: AttackInfo = AttackInfo.new(1,(position+hitbox.get_body().position)/2,position,hitbox.get_body().position)
			hitbox.damage(attack_info,attack_effects.map(func(scene: PackedScene): return scene.instantiate()))
