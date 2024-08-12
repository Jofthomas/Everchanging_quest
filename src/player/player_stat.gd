extends Resource
class_name PlayerStat

@export var health: int = 10
@export var munitions: int
@export var magic: int= 10
@export var speed: int = 40
@export var xp: int = 0

func _init(p_health= health ,p_speed = speed,p_magic=magic,p_xp=xp ):
	health = Global.player_health
	magic = Global.player_mana
	speed = p_speed
	xp=Global.player_xp
