extends Node2D

enum {torch,flag1,flag2}
@export var type = torch

func _ready():
	$AnimatedSprite.play(type_to_anim())

func type_to_anim():
	match type:
		torch: return "torch"
		flag1: return "flag1"
		flag2: return "flag2"
		
	
