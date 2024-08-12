extends CharacterBody2D

@export var speed = 100

# hard timer if arrow does not hit body
@onready var timer = $Timer
var attack_effects : Array[PackedScene]
const global = preload("res://global.gd")
var direction : Vector2

func start(p_direction, p_attack_effects):
	attack_effects = p_attack_effects
	direction = p_direction
	rotate(direction.angle())
	timer.start()
	visible = true

func _physics_process(_delta: float) -> void:
	if visible:
		velocity = direction*speed
		move_and_slide()


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if visible && area.is_in_group("hitbox") and not area.is_in_group("hitbox_player"):
		var hitbox : HitboxComponent = area as HitboxComponent
		var attack_info: AttackInfo = AttackInfo.new(1,(position+hitbox.get_body().position)/2,position,hitbox.get_body().position )
		hitbox.damage(attack_info,attack_effects.map(func(scene: PackedScene): return scene.instantiate()))
		queue_free()	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible && not body.is_in_group("player"):
		queue_free()
