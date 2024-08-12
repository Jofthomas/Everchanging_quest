extends CharacterBody2D

@export var speed = 150

# Hard timer if arrow does not hit body
@onready var timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D
var attack_effects : Array[PackedScene]
const global = preload("res://global.gd")
var direction : Vector2
var should_queue_free_after_hit = false

func start(p_direction, p_attack_effects, start_position: Vector2):
	visible = true
	attack_effects = p_attack_effects
	direction = p_direction
	position = start_position
	rotate(direction.angle())
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	play_animation("start")

func _physics_process(_delta: float) -> void:
	if visible:
		velocity = direction * speed
		if animated_sprite.animation=="fly":
			move_and_slide()

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if visible and area.is_in_group("hitbox") and not area.is_in_group("hitbox_player"):
		var hitbox : HitboxComponent = area as HitboxComponent
		play_animation("hit")
		var attack_info: AttackInfo = AttackInfo.new(1, (position + hitbox.get_body().position) / 2, position, hitbox.get_body().position)
		hitbox.damage(attack_info, attack_effects.map(func(scene: PackedScene): return scene.instantiate()))

		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible and not body.is_in_group("player"):
		play_animation("hit")
		should_queue_free_after_hit = true

func play_animation(animation_name: String):
	
	animated_sprite.play(animation_name)

func _on_animation_finished():
	print("called")
	if should_queue_free_after_hit and animated_sprite.animation == "hit":
		queue_free()
	if animated_sprite.animation=="start":
		play_animation("fly")
