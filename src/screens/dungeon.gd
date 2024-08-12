extends Node2D
class_name Dungeon

signal dungeon_generated

var ennemies: Array[PackedScene] = [ 
	preload ("res://src/ennemies/insect.tscn"),
	preload ("res://src/ennemies/fur.tscn"),
	preload ("res://src/ennemies/bush.tscn")
]
var decorations: PackedScene = preload ("res://src/items/decoration.tscn")
@onready var portal_scene : PackedScene= load ("res://src/npc/npcs/portal.tscn")
var collectable_scene : PackedScene = preload ("res://src/items/collectable.tscn")
var item_scene : PackedScene = preload ("res://src/items/item.tscn")
var url = "https://jofthomas-evbackend.hf.space/"

@onready var player = $player

@onready var map = $NavigationRegion2D/TileMap
@onready var http1 = $HTTPRequest1
@onready var http2 = $HTTPRequest2
@onready var loading_screen: LoadingScreen = $LoadingScreen
@onready var log_manager : LogManager = get_node("/root/Main/LogManager")
@onready var objective_node = $objective
#@onready var objective_anim = $objective/AnimatedSprite2D
var count=0
var items = []
var objective = null
var objects = null
var enemies = null
var boss = null
var npcs = null

enum {
	TOP_OPEN, BOTTOM_OPEN, LEFT_OPEN, RIGHT_OPEN, # 3*3
	TOP, RIGHT, BOTTOM, LEFT, # 1*3
	CORNER_DOWN_LEFT, CORNER_DOWN_RIGHT, CORNER_TOP_RIGHT, CORNER_TOP_LEFT, # 3*3
	FLOOR, # 1*1
	FLOOR_PATTERN1, FLOOR_PATTERN2, # max 3 by 3
	VOID # 1*1
}

var room_size = 7
var tile_size = 16
var real_room_lenght = room_size * 2 + 9

var room_number = 10
var rng = RandomNumberGenerator.new()
var tile_set: TileSet
var dungeon_generating = true
var visited_rooms: Array[Vector2] = [Vector2(0, 0)]
var start_position = Vector2(1,1)*(room_size + 4)*16
var screen_manager: ScreenManager
var room_of_interest =  null
var index_exit =  null
var exit  =  null

func set_player(incoming_player):
	player=incoming_player
func _ready():
	loading_screen.start_loading(2)
	tile_set = map.tile_set
	# Algo de placement des salles
	# salles à visiter
	var next_rooms: Array[Vector2] = [Vector2(0, 0)]
	
	var i = 0
	
	while i < room_number:
		
		if next_rooms.size() == 0:
			break
		
		next_rooms.shuffle()
		var unvisited = get_unvisited_neighbours(next_rooms[0], visited_rooms)
		next_rooms.pop_front()
		
		unvisited.shuffle()
		
		if unvisited.size() == 0:
			continue
			
		var number_of_neighbours = rng.randi_range(1, unvisited.size())
		
		for j in range(number_of_neighbours):
			if get_is_side_open(unvisited[j], visited_rooms).count(true) <= 1:
				i += 1
				visited_rooms.push_back(unvisited[j])
				next_rooms.push_back(unvisited[j])
	room_of_interest = get_interest_room(6, visited_rooms)
	index_exit = get_exit_room(Vector2(0,0),room_of_interest)
	exit = room_of_interest[index_exit]
	room_of_interest.remove_at(index_exit)
	var body = JSON.new().stringify({
				"rooms":visited_rooms,
				"room_of_interest" : room_of_interest,
				"index_exit":index_exit,
				"possible_entities":Global.all_objects,
				"logs":log_manager.log
			})
	print(body)
	http2.request(url+"generate_level", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	#http2.request("https://google.com")
	

func place_item(room):
	pass # place_room(room, [VOID])

func placement_point(position):
	var room_center = position*(room_size * 2 + 9)*16 + Vector2(1,1)*(room_size * 2 + 9)*8
	var points = [ 
		room_center + Vector2(4*tile_size,0),
		room_center + Vector2(4*tile_size,-4*tile_size),
		room_center + Vector2(4*tile_size,4*tile_size),
		room_center + Vector2(0,4*tile_size),
		room_center + Vector2(0,-4*tile_size),
		room_center + Vector2(-4*tile_size,0),
		room_center + Vector2(-4*tile_size,-4*tile_size),
		room_center + Vector2(-4*tile_size,4*tile_size),
	]
	return points

func place_ennemies(placements_points):
	var nb = 0
	var r = rng.randf()
	var ennemy1 = rng.randi_range(0,2)
	var ennemy2 = rng.randi_range(0,2)
	
	if  r < 0.2:
		return
	elif r < 0.5:
		place_ennemy(ennemy1,placements_points[0])
	elif r < 0.8:
		place_ennemy(ennemy1,placements_points[0])
		place_ennemy(ennemy1,placements_points[1])
	elif r < 0.99:
		place_ennemy(ennemy1,placements_points[0])
		place_ennemy(ennemy1,placements_points[1])
		place_ennemy(ennemy2,placements_points[2])
	else:
		place_ennemy(ennemy1,placements_points[0])
		place_ennemy(ennemy1,placements_points[1])
		place_ennemy(ennemy2,placements_points[2])
		place_ennemy(ennemy1,placements_points[3])
		place_ennemy(ennemy1,placements_points[4])
		place_ennemy(ennemy2,placements_points[5])
		
func place_ennemy(index, position):
	var ennemy = ennemies[index].instantiate()
	ennemy.position = position
	add_child(ennemy)

func place_enemy_from_api(enemy_name,placements_points):
	var enemy_scene=load("res://src/ennemies/"+str(enemy_name)+'.tscn')
	var ennemy = enemy_scene.instantiate()
	ennemy.position = placements_points[0]
	add_child(ennemy)
	
func get_interest_room(target_size, visited_rooms):
	visited_rooms.shuffle()
	var interest_room = []
	var limit = 1
	
	if target_size > visited_rooms.size() - 1:
		print("err: get_interest_room")
		return []
		
	while interest_room.size() < target_size:
		for room in visited_rooms:
			var cpt = 0
			if room == Vector2(0, 0):
				continue
			if room + Vector2(1, 0) in visited_rooms:
				cpt += 1
			if room + Vector2( - 1, 0) in visited_rooms:
				cpt += 1
			if room + Vector2(0, -1) in visited_rooms:
				cpt += 1
			if room + Vector2(0, 1) in visited_rooms:
				cpt += 1
			if cpt == limit:
				interest_room.push_back(room)
		limit += 1
	return interest_room.slice(0, target_size)
	
func get_unvisited_neighbours(room: Vector2, visited_rooms: Array[Vector2]):
	var unvisited: Array[Vector2] = []
	if room + Vector2(1, 0) not in visited_rooms:
		unvisited.push_back(room + Vector2(1, 0))
	if room + Vector2( - 1, 0) not in visited_rooms:
		unvisited.push_back(room + Vector2( - 1, 0))
	if room + Vector2(0, 1) not in visited_rooms:
		unvisited.push_back(room + Vector2(0, 1))
	if room + Vector2(0, -1) not in visited_rooms:
		unvisited.push_back(room + Vector2(0, -1))
	return unvisited
	
func get_is_side_open(room, visited_rooms):
	var dict = [false, false, false, false]
	if room + Vector2( - 1, 0) in visited_rooms:
		dict[0] = true # left
	if room + Vector2(1, 0) in visited_rooms:
		dict[1] = true # right
	if room + Vector2(0, 1) in visited_rooms:
		dict[2] = true # top
	if room + Vector2(0, -1) in visited_rooms:
		dict[3] = true # down
	return dict

func wall_array(size, tile, x):
	var arr = []
	for i in size:
		arr.push_back([Vector2(1, 0) if x else Vector2(0, 1), tile])
	return arr

func create_data(corner1, corner2, wall, size, x, is_open, open_tile):
	var direction = Vector2(3, 0) if x else Vector2(0, 3)
	var data = [[direction, corner1]]
	data += wall_array(size, wall, x)
	data += wall_array(3, wall, x) if not is_open else [[direction, open_tile]]
	data += wall_array(size, wall, x)
	data += [[direction, corner2]]
	return data

func place_from_data(base_offset, data):
	var offset = base_offset
	for placement_info in data:
		map.set_pattern(0, offset, map.tile_set.get_pattern(placement_info[1]))
		offset += placement_info[0]

	
func place_room(position, size, is_side_open):
	
	var real_room_size = size * 2 + 9
	var offset = Vector2(0, 0)
	
	var top_data = create_data(CORNER_TOP_LEFT, CORNER_TOP_RIGHT, TOP, size, true, is_side_open[3], TOP_OPEN)
	place_from_data(position * real_room_size, top_data)
	
	var right_data = create_data(CORNER_TOP_RIGHT, CORNER_DOWN_RIGHT, RIGHT, size, false, is_side_open[1], RIGHT_OPEN)
	place_from_data(position * real_room_size + Vector2(size * 2 + 6, 0), right_data)
	
	var bottom_data = create_data(CORNER_DOWN_LEFT, CORNER_DOWN_RIGHT, BOTTOM, size, true, is_side_open[2], BOTTOM_OPEN)
	place_from_data(position * real_room_size + Vector2(0, size * 2 + 6), bottom_data)
	
	var left_data = create_data(CORNER_TOP_LEFT, CORNER_DOWN_LEFT, LEFT, size, false, is_side_open[0], LEFT_OPEN)
	place_from_data(position * real_room_size, left_data)
	
	var floor_data = []
	var floor_size = size * 2 + 3
	for x in floor_size:
		for y in floor_size - 1:
			floor_data.push_back([Vector2(1, 0), FLOOR])
		floor_data.push_back([Vector2( - floor_size + 1, 1), FLOOR])
	place_from_data(position * real_room_size + Vector2(3, 3), floor_data)
	
	var floor_pattern = []
	for i in range(rng.randi_range(1, size)):
		var x = rng.randi_range(0, floor_size - 2)
		var y = rng.randi_range(0, floor_size - 2)
		map.set_pattern(0, position * real_room_size + Vector2(x, y) + Vector2(3, 3), map.tile_set.get_pattern(FLOOR_PATTERN2 if rng.randf() < 0.5 else FLOOR_PATTERN1))

func paint_black(room_size, area):
	var void_data = []
	for x in room_size * area:
		for y in room_size * area - 1:
			void_data.push_back([Vector2(1, 0), VOID])
		void_data.push_back([Vector2( - room_size * area + 1, 1), VOID])
	place_from_data(Vector2( - area * room_size / 2, -area * room_size / 2), void_data)
	

func get_exit_room(start , interest_rooms):
	var max = start.distance_to(interest_rooms[0])
	var i = 0
	for j in interest_rooms.size():
		var dist = interest_rooms[j].distance_to(start)
		if dist > max:
			i = j
			max = dist
	return i
	
func place_decorations(room):
	var left = room*(room_size * 2 + 9)*tile_size + Vector2(1,0)*(room_size * 2 + 9)*4 + Vector2(0,1)* 24
	var right = room*(room_size * 2 + 9)*tile_size + Vector2(1,0)*(room_size * 2 + 9)*12 + Vector2(0,1)* 24

	if 0.5 < rng.randf():
		var deco1 : Node2D= decorations.instantiate()
		deco1.position = left
		var deco2 : Node2D= decorations.instantiate()
		deco2.position = right
		var r = randi_range(0,2)
		deco1.type = r
		deco2.type = r
		add_child(deco1)
		add_child(deco2)
		
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	loading_screen.progress_loading()
	pass



func _on_http_request_2_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	loading_screen.progress_loading()
	
	var json = JSON.new()
	var json2 = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result:
		print(parse_result)
		return
	var response = json.get_data()
	if response is Dictionary:
		if response.has("error"):
			printt("Error", response['error'])
	else:
		print("Response is not a Dictionary", headers)
	json2.parse(response)
	var response2 = json2.get_data()
	objective = response2["objective"]
	Global.current_objective=objective
	objects = response2.objects
	enemies = response2.enemies
	boss = response2.boss
	npcs = response2.npcs
	
	Global.Objects=objects
	for object in objects:
		print(object)
		
		var texture = ImageTexture.create_from_image(
			Image.load_from_file("res://assets/dialog.png")
		)
		var stregth_stat=0
		var speed_stat=0
		var item = item_scene.instantiate()
		if "strength" in object :
			if object["strength"] :
				stregth_stat = object["strength"]

		if "speed" in object :
			if object["speed"] :
				speed_stat = object["speed"]
		
		item.init(
			texture, 
			object.name,
			object.description,
			0,
			{"armorType": "torso", "strength":stregth_stat,"speed" :speed_stat}
		)
		print(item)
		items.push_back(item)
		var collectable : Collectable = collectable_scene.instantiate()
		collectable.init(Collectable.chest1,item)
		var placement= object.placement
		var points = placement_point(visited_rooms[placement])
		collectable.position = points[6]
		add_child(collectable)
		#http1.request(url+"generate_image", ["Content-Type: application/json"], HTTPClient.METHOD_POST, item_body)
		#http2.request("https://google.com")
	# placing exit
	loading_screen.progress_loading()
	var portal: Node2D = portal_scene.instantiate()
	portal.position = exit*(room_size * 2 + 9)*16 + Vector2(1,1)*(room_size * 2 + 9)*8
	add_child(portal)
		
	paint_black(room_size * 2 + 9, 20)
	for room in visited_rooms:
		place_room(room, room_size, get_is_side_open(room, visited_rooms))
		place_decorations(room)
		if room in room_of_interest or room == exit or room == Vector2(0,0):
			pass
		else:
			#place_ennemies(placement_point(room))
			pass
	for enemy in enemies:
		print(enemy)
		var placement=placement_point(visited_rooms[enemy.placement])
		place_enemy_from_api(enemy.name,placement)
	
	loading_screen.finish_loading()
	player.position=start_position
	print(player)
	player.set_map(visited_rooms, room_of_interest + [exit] )
	player.add_objective(objective)
	emit_signal("dungeon_generated", visited_rooms, room_of_interest)
	objective_node.display(objective)
	
	
	
