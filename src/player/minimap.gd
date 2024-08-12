extends CanvasLayer


var room_size = 15
var current_rooms = []
var room_nodes = []
var current_interest = []
var interest_nodes = []

@onready var animation=$AnimatedSprite2D

var last_mark: Node
var player_pos
var player_node

@onready var center = $map_center

func set_map(rooms, rooms_of_interest):
	
	if Global.current_floor!=0 and Global.current_scene=="dungeon":
		self.visible=true
		animation.play('open')
		current_rooms = rooms
		current_interest = []
		interest_nodes = []
		room_nodes = []
		for room in rooms:
			room_nodes.push_back(place_square(room))
			if room in rooms_of_interest:
				interest_nodes.push_back(place_mark(room))
				current_interest.push_back(room)
	
func remove_map():
	animation.play('open')
	self.visible=false
	for element in interest_nodes:
		remove_child(element)
		element.queue_free()
	for element in room_nodes:
		remove_child(element)
		element.queue_free()
	current_interest = []
	current_rooms = []

func set_player_icon(position):
	
	# position has not changed
	if player_pos and position == player_pos:
		return
	
	# remove last player
	if player_node:
		remove_child(player_node)
		player_node.queue_free()
	
	# reset last mark
	if last_mark:
		add_child(last_mark)
		last_mark = null
		
	# place new player
	player_pos = position
	player_node = place_player(position)

	# remove potential mark
	var index = current_interest.find(position)
	
	if index != -1:
		last_mark = interest_nodes[index]
		remove_child(last_mark)
	
func place_player(position):
	var panel = RichTextLabel.new()
	panel.size = Vector2(room_size,room_size)
	panel.text ="[center]X[/center]"
	panel.bbcode_enabled = true
	panel.scroll_active = false
	panel.position = center.position + position * room_size
	add_child(panel)
	return panel
	
func place_square(position):
	var panel = Panel.new()
	panel.size = Vector2(room_size,room_size)
	panel.position = center.position + position * room_size
	add_child(panel)
	return panel
	
func place_mark(position):
	var panel = RichTextLabel.new()
	panel.size = Vector2(room_size,room_size)
	panel.text ="[center]?[/center]"
	panel.bbcode_enabled = true
	panel.scroll_active = false
	panel.position = center.position + position * room_size
	add_child(panel)
	return panel


func _on_animated_sprite_2d_animation_finished() -> void:
	pass