extends Node2D
class_name ScreenManager

enum screen {MAIN_MENU, CHATEAU, DUNGEON, DEATH,WIN}

var current_screen: screen
var current_node: Node
var player: MainPlayer

var chateau = preload("res://src/screens/chateau.tscn")
var main_menu = preload("res://src/screens/main_menu.tscn")
var dungeon = preload("res://src/screens/dungeon.tscn")
@onready var death = load("res://src/screens/death_screen.tscn")
@onready var win = load("res://src/screens/win.tscn")

func _ready():
	set_screen(screen.MAIN_MENU)

func get_screen():
	return current_screen 
func set_screen(sc: screen):
	var temp_player = null

	if current_node:
		if current_node.has_node("player"):
			temp_player = current_node.get_node("player")
			current_node.remove_child(temp_player)
		remove_child(current_node)
		current_node.queue_free()

		# Ensure current node is fully freed
		#await(get_tree().create_timer(0.1), "timeout")

	match sc:
		screen.MAIN_MENU:
			Global.current_scene="main_menu"
			current_node = main_menu.instantiate()
		screen.CHATEAU:
			Global.current_scene="chateau"
			current_node = chateau.instantiate()

			if Global.current_floor != 0 and temp_player:
				var player_to_remove = current_node.get_node("player")
				if player_to_remove:
					current_node.remove_child(player_to_remove)
					player_to_remove.queue_free()

				temp_player.position = Vector2(185, 90)
				temp_player.reset_map()
				current_node.add_child(temp_player)
				temp_player.set_owner(current_node)
			else:
				var new_player = current_node.get_node("player")
				if new_player:
					Global.player = new_player
		screen.DUNGEON:
			Global.current_scene="dungeon"
			current_node = dungeon.instantiate()

			if temp_player:
				temp_player.position = Vector2(185, 90)
				current_node.add_child(temp_player)
				temp_player.set_owner(current_node)
		screen.DEATH:
			Global.current_scene="death"
			current_node = death.instantiate()
		screen.WIN:
			Global.current_scene="win"
			current_node = win.instantiate()

	current_node.screen_manager = self
	add_child(current_node)
	current_screen = sc
