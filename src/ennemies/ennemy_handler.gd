extends Area2D

@export var anim : EnnemyAnimation2
@export var shape : CollisionShape2D
@export var hitbox : HitboxComponent

@export var damage_area: Area2D
@export var speed = 50
@export var accel = 1
@export var ennemy_name: String

@onready var body : CharacterBody2D= get_parent()
@onready var nav = $NavigationAgent2D
@onready var log_manager : LogManager = get_node("/root/Main/LogManager")

const global = preload("res://global.gd")

var player_body = null
var under_effect = false
var direction = Vector2(0,0)
var busy = false

var effects  = []

func add_effects(arr):
	for effect in arr:
		add_child(effect)
	effects += arr
		
func apply_effects():
	var ended_effects = []
	for i in range(effects.size()):
		var effect = effects[i]
		if effect && not effect.apply_effect(body):
			ended_effects.push_front(i)

	for index in ended_effects:
		remove_child(effects[index])
		effects[index].queue_free()
		effects.remove_at(index)
			
func _physics_process(delta: float) -> void:
	body.velocity = Vector2(0,0)
	if player_body != null:
		direction = nav.get_next_path_position() - body.global_position
		direction = direction.normalized()
		if not busy:
			body.velocity = direction*speed
		apply_effects()
		body.move_and_slide()
		nav.target_position = player_body.global_position
		
func _process(delta: float) -> void:
	anim.update_animation_parameters(true, get_orientation(direction))

func get_orientation(vec: Vector2):
	vec = vec.normalized()
	if vec.x > 0.3:
		return global.ORIENTATION.LEFT
	elif vec.x < -0.3:
		return global.ORIENTATION.RIGHT
	elif vec.y > 0:
		return global.ORIENTATION.DOWN
	else:
		return global.ORIENTATION.TOP
	
func _on_health_component_hit() -> void:
	anim.hit()


func _on_health_component_die() -> void:
	busy = true
	shape.disabled = true
	hitbox.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
	damage_area.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
	anim.die()
	print(player_body)
	Global.add_xp(100)


func _on_body_entered(p_body: Node2D) -> void:
	if p_body.is_in_group("player"):
		player_body = p_body



func _on_ennemy_animation_end_death_animation() -> void:
	get_parent().queue_free()
	log_manager.add_entry("player has killed ennemy " + ennemy_name)
	


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_body = null
