extends Node

enum ORIENTATION {TOP, DOWN, LEFT, RIGHT, TOPLEFT, DOWNRIGHT, DOWNLEFT ,TOPRIGHT};
# Define variables to store player stats
var player_health = 3
var player_mana = 3
var player_xp=1500
var player_inventory = []
var player=null
var player_interracting=false
var current_floor=0
var max_floor=2
var current_scene=null
var start_position=null
var current_objective=null
var max_tries=3
var Objects=null

var all_objects = [
	{
		"name": "bush",
		"description": "This a small ant  like ennemy. covered in a grass.",
		"type": "ennemy",
		"scene":"res://src/ennemies/bush.tscn"
	},
	{
		"name": "fur",
		"description": "This a small ant like ennemy.With some horns on it's head.",
		"type": "ennemy",
		"scene":"res://src/ennemies/fur.tscn"
	},
	{
		"name": "insect",
		"description": "This is a small mosquitto like ennemy.",
		"type": "ennemy",
		"scene":"res://src/ennemies/insect.tscn"
	},
		{
		"name": "Treasure chest",
		"description": "A treasur chest containing an item.",
		"type": "collectible",
		"scene":"res://src/items/collectable.tscn"
	}
]

func add_xp(amount):
	player.add_xp(amount)

func set_xp(xp):
	player_xp=xp
	
func set_player(incoming_player):
	player=incoming_player
	
func get_player():
	return player

func reset_stats():
	player_health = 3
	player_mana = 3
	player_inventory = []
	player_xp=0

static func orientation_to_direction(orientation : ORIENTATION):
	match orientation:
		ORIENTATION.TOP: return Vector2(0,-1)
		ORIENTATION.DOWN: return Vector2(0,1)
		ORIENTATION.LEFT:return Vector2(-1,0)
		ORIENTATION.RIGHT:return Vector2(1,0)
		ORIENTATION.TOPLEFT:return Vector2(-1,-1).normalized()
		ORIENTATION.DOWNLEFT:return Vector2(-1,1).normalized()
		ORIENTATION.TOPRIGHT:return Vector2(1,-1).normalized()
		ORIENTATION.DOWNRIGHT:return Vector2(1,1).normalized()
		
static func direction_to_orientation(direction : Vector2):
		
	var orientation = ORIENTATION.RIGHT
	var p_min = pow(direction.angle_to(Vector2.RIGHT),2)
	for i in range(8):
		var target_angle_vec = Vector2.RIGHT.rotated(-i*(PI/4))
		var distance = pow(direction.angle_to(target_angle_vec),2)
		if distance <p_min:
			p_min = distance
			match i:
				0 : orientation = ORIENTATION.RIGHT
				1 : orientation = ORIENTATION.TOPRIGHT
				2 : orientation = ORIENTATION.TOP
				3 : orientation = ORIENTATION.TOPLEFT
				4 : orientation = ORIENTATION.LEFT
				5 : orientation = ORIENTATION.DOWNLEFT
				6 : orientation = ORIENTATION.DOWN
				7 : orientation = ORIENTATION.DOWNRIGHT
	
	
	return orientation
