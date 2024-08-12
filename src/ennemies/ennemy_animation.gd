extends Node
class_name EnnemyAnimation2

signal end_death_animation

@export var back_texture: Texture
@export var side_texture: Texture
@export var front_texture: Texture
@export var flip_value = true

@onready var side = $Side
@onready var front = $Front
@onready var back = $Back
@onready var anim_player = $AnimationPlayer


const global = preload ("res://global.gd")

var orientation = global.ORIENTATION.DOWN
var prefix = "idle"
var suffix = "_front"
var busy = false

func _ready() -> void:
	side.texture = side_texture
	front.texture = front_texture
	back.texture = back_texture
	anim_player.play(prefix + suffix)

func change_orientation(p_orientation: global.ORIENTATION):
	side.visible = false
	front.visible = false
	back.visible = false
	orientation = p_orientation
	match p_orientation:
		global.ORIENTATION.DOWN:
			suffix = "_front"
			front.visible = true
		global.ORIENTATION.RIGHT:
			suffix = "_side"
			side.flip_h = not flip_value
			side.visible = true
		global.ORIENTATION.TOP:
			suffix = "_back"
			back.visible = true
		global.ORIENTATION.LEFT:
			suffix = "_side"
			side.flip_h = flip_value
			side.visible = true
	
	if not busy:
		anim_player.play(prefix + suffix)

func hit():
	anim_player.play("hit" + suffix)
	busy = true
	
func die():
	anim_player.play("death" + suffix)
	busy = true
	
func update_animation_parameters(is_moving: bool, p_orientation: global.ORIENTATION):
	
	if not is_moving:
		prefix = "idle"
	else:
		prefix = "run"
	
	change_orientation(p_orientation)

func _on_animation_player_animation_finished(anim_name: StringName):
	if anim_name.contains("death"):
		end_death_animation.emit()
		return
	busy = false
