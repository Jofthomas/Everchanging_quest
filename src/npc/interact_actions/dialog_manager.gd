extends InteractAction

@export var npc_type: String = ""
@export var npc_genre: String = ""
@export var is_merchant: bool = false

@onready var canvas =$CanvasLayer
@onready var line : LineEdit = $CanvasLayer/Control/LineEdit
@onready var shop = $CanvasLayer/Shop
@onready var text_container : VBoxContainer = $CanvasLayer/Control/ScrollContainer/VBoxContainer
@onready var http_req : HTTPRequest = $CanvasLayer/HTTPRequest
@onready var name_holder = $CanvasLayer/NPCNAME

var http_request :HTTPRequest
var url = "https://jofthomas-evbackend.hf.space/"
var wav_url = "https://jofthomas-evbackend.hf.space/generate_voice_eleven"
var song_url="https://jofthomas-evbackend.hf.space/generate_song"
var headers = ["Content-Type: application/json"]
var loading = false
var dialog : Array[String] = []
var last_reponse=""
var audio_player : AudioStreamPlayer
var stream : AudioStreamWAV
var items_added=false
var bard_message_added =false

var Can_send=true

func _ready() -> void:
	canvas.visible = false
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
func interact():
	Global.player_interracting=true
	canvas.visible = true
	shop.set_npc(npc_type)
	name_holder.visible=true
	name_holder.text = npc_type
	if items_added==false:
		shop.load_items_for_npc(npc_type)
		items_added=true
	line.grab_focus()
	if is_merchant==false:
		shop.visible=false
	if npc_type=="Bard" and not bard_message_added :
		add_message("Bard : Hello, I sing for you. Please tell me what you want your music to be about. ")
		bard_message_added=true
func cancel():
	Global.player_interracting=false
	canvas.visible = false
	name_holder.visible=false
	line.release_focus()
	if audio_player and audio_player.playing:
		audio_player.stop()

func _on_line_edit_text_submitted(new_text):
	if !loading and Can_send:
		Can_send=false
		dialog.push_back(line.text)
		send_request(dialog)
		add_message(line.text, false)
		line.text = ""
		loading = true
		
func add_message(text: String, left = true):
	var margi = MarginContainer.new()
	margi.add_theme_constant_override("margin_top", 0)
	margi.add_theme_constant_override("margin_left", 10)
	#margi.add_theme_constant_override("margin_bottom", 5)
	margi.add_theme_constant_override("margin_right", 10)
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	if left:
		label.text = text + "\n"
	else:
		label.text= "[right]" + text+ "[/right]\n"
	label.scroll_active = false
	margi.add_child(label)
	text_container.add_child(margi)
	
func send_request(dialog: Array[String]):
	var type = npc_type
	print(dialog)
	if dialog:
		if npc_type=="Bard":
			print("talked with bard:")
			var http_request2 = HTTPRequest.new()
			add_child(http_request2)
			http_request2.connect("request_completed", stream_first_audio)
			var body2 = JSON.new().stringify({
			
				"prompt": dialog[-1],
				"tags": []
			})
			print(body2)
			
			var error = http_request2.request(song_url, ["Content-Type: application/json"], HTTPClient.METHOD_GET, body2)

		else:
			var body = JSON.new().stringify({
				"npc":npc_type,
				"messages" : dialog,
			})
			var error = http_req.request(url+"api/generate", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
			
			if error != OK:
				print("Something Went Wrong!")
	
func message_back(result, response_code, headers, body):
	#var json = JSON.parse_string(body.get_string_from_utf8())
	loading = false

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result:
		print(parse_result)
		return
	var response = json.get_data()
	if response is Dictionary:
		print("Response", response)
		if response.has("error"):
			printt("Error", response['error'])
			return
	else:
		print("Response is not a Dictionary", headers)
		return
	
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_voice_request_completed)
	var body2 = JSON.new().stringify({
	
		"input": response.text,
		"language": "en",
		"npc": npc_type,
		"genre":npc_genre
	})
	var error = http_request.request(wav_url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body2)

	last_reponse=response.text


func _on_voice_request_completed(result, response_code, headers, body):
	print('voice answered')
	var stream = AudioStreamMP3.new()
	stream.data = body
	#stream.format = AudioStreamWAV.FORMAT_16_BITS
	#stream.mix_rate = 24000
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = stream
	add_message(str(npc_type)+": " + str(last_reponse))
	dialog.push_back(last_reponse)
	add_child(audio_player)
	audio_player.play()
	Can_send=true

func _input(event):
	if canvas.visible:
		if Input.is_action_just_pressed("escape"):
			cancel()

# Callback function for when the HTTP request is completed	
func stream_first_audio(result, response_code, headers, body):
	# Parse the JSON data
	add_message("Bard : Let me compose something ! It might take around 30s")
	var json_data=body.get_string_from_utf8()
	var json = JSON.new()
	#json_data=json_data.left(-1)
	
	print(json_data)
	json.parse(json_data)
	var data = json.get_data()
	if not data:
		add_message("Bard : Sorry I'm out of inspiration")
		print("Failed to parse JSON")
		return
	print("data",data)
	# Check if the data is an array and has at least one element
	if data == null:
		print("No items in JSON data")
		return
	# Get the audio URL of the first item
	var first_item = data[0]
	var audio_url = first_item.get("audio_url", "")
	if audio_url == "":
		print("No audio URL found")
		return
	print(audio_url)
	# Make an HTTP request to download the audio file`
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_song_request_completed)
	http_request.request(audio_url)
	

func _on_song_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		add_message("Bard : Sorry I'm out of inspiration")
		print("Failed to download audio file")
		return
	print('song answered')
	var stream = AudioStreamMP3.new()
	stream.data = body
	#stream.format = AudioStreamWAV.FORMAT_16_BITS
	#stream.mix_rate = 24000
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = stream
	add_child(audio_player)
	audio_player.play()
