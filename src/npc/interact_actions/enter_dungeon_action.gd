extends InteractAction

@onready var screen_manager : ScreenManager = get_node("/root/Main/ScreenManager")
@onready var http = $HTTPRequest
@onready var log_manager : LogManager = get_node("/root/Main/LogManager")
var url = "https://jofthomas-evbackend.hf.space/"
var failed_tries=0

func interact():
	if screen_manager.get_screen() == screen_manager.screen.DUNGEON:
		# get the player
		var player : MainPlayer = screen_manager.current_node.get_node("player")
		# get items of player
		var items = player.in_game_menu.menu_inventory.items + player.in_game_menu.menu_inventory.equiped_items

		
		var body = JSON.new().stringify({
				"objective":Global.current_objective,
				"logs":log_manager.log
			})
		print(body)
		http.request(url+"check_right_to_pass", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	elif screen_manager.get_screen() == screen_manager.screen.CHATEAU:
		Global.current_floor=Global.current_floor+1
		screen_manager.set_screen(screen_manager.screen.DUNGEON)
	
func cancel():
	pass


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result:
		print(parse_result)
		return
	var response = json.get_data()
	print(len(response.text))
	print(len("YES"))
	for c in response.text:
		print(c.to_ascii_buffer()[0])
	var clean_text = response.text.strip_edges()
	print(clean_text)
	if response_code == 200 and clean_text == "YES":
		print('Going back to chateau')
		if Global.current_floor==Global.max_floor:
			screen_manager.set_screen(screen_manager.screen.WIN)
		else:
			screen_manager.set_screen(screen_manager.screen.CHATEAU)
	if clean_text =="NO":
		failed_tries=failed_tries+1
	# this exists so that no-one gets stuck in case of non-feasible objectives
	if failed_tries >= Global.max_tries:
		print('Going back to chateau')
		if Global.current_floor==Global.max_floor:
			screen_manager.set_screen(screen_manager.screen.WIN)
		else:
			screen_manager.set_screen(screen_manager.screen.CHATEAU)
		
