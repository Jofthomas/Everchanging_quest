extends Area2D

@export var shape: CollisionShape2D
@export var hitbox: HitboxComponent

@export var damage_area: Area2D
@export var speed = 50
@export var accel = 1
@export var ennemy_name: String

@onready var body: CharacterBody2D = get_parent()
@onready var nav = $NavigationAgent2D
@onready var log_manager: LogManager = get_node("/root/Main/LogManager")
@onready var anim_player = $"../AnimatedSprite2D"
const global = preload("res://global.gd")

var player_body = null
var under_effect = false
var direction = Vector2(0, 0)
var busy = false
var attacking = false

var effects = []

func add_effects(arr):
	for effect in arr:
		add_child(effect)
	effects += arr

func apply_effects():
	var ended_effects = []
	for i in range(effects.size()):
		var effect = effects[i]
		if effect and not effect.apply_effect(body):
			ended_effects.push_front(i)

	for index in ended_effects:
		remove_child(effects[index])
		effects[index].queue_free()
		effects.remove_at(index)

func _physics_process(delta: float) -> void:
	body.velocity = Vector2(0, 0)
	if player_body != null:
		direction = nav.get_next_path_position() - body.global_position
		direction = direction.normalized()
		
		if not busy:
			body.velocity = direction * speed
			
			# Handle animation switching
			if not attacking:
				anim_player.play("run")
				
			# Handle orientation
			var orientation = get_orientation(direction)
			match orientation:
				global.ORIENTATION.LEFT:
					anim_player.flip_h = true
				global.ORIENTATION.RIGHT:
					anim_player.flip_h = false

		apply_effects()
		body.move_and_slide()
		nav.target_position = player_body.global_position


func attack():
	if not busy and not attacking:
		attacking = true
		busy = true
		anim_player.play("attack")
		# Trigger attack logic (e.g., dealing damage) here


func get_orientation(vec: Vector2):
	vec = vec.normalized()
	if vec.x > 0.3:
		return global.ORIENTATION.RIGHT
	elif vec.x < -0.3:
		return global.ORIENTATION.LEFT
	elif vec.y > 0:
		return global.ORIENTATION.DOWN
	else:
		return global.ORIENTATION.TOP

func _ready():
	anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	anim_player.play("idle")

func _on_animation_finished():
	if anim_player.animation == "attack":
		busy = false
		attacking = false
		anim_player.play("run")
	elif anim_player.animation == "die":
		_on_ennemy_animation_end_death_animation()

func _on_health_component_hit() -> void:
	anim_player.play("hit")
	busy = true

func _on_health_component_die() -> void:
	anim_player.play("die")
	busy = true
	#shape.disabled = true
	hitbox.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
	damage_area.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE

func _on_body_entered(p_body: Node2D) -> void:
	if p_body.is_in_group("player"):
		player_body = p_body

func _on_ennemy_animation_end_death_animation() -> void:
	get_parent().queue_free()
	log_manager.add_entry("player has killed enemy " + ennemy_name)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_body = null

