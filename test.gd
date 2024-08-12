extends Node2D
@onready var http_request : HTTPRequest = $HTTPRequest
var audio_player : AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Example JSON data (as a string)
	var json_data = '[{"id": "9b708ce5-3d73-41f2-b0d5-807b41d11f72", "title": "Everchangin_Quest_song", "image_url": "https://cdn2.suno.ai/image_9b708ce5-3d73-41f2-b0d5-807b41d11f72.jpeg", "lyric": "[Verse]\\nLittle girl in the woods\\nDressed in bright red hood\\nWalkin\' paths so good\\nThrough the whispering trees\\n[Verse 2]\\nBaskets full of treats\\nFor her granny’s feast\\nFear not the beast\\nWith bravery she proceeds\\n[Chorus]\\nOh young one so bold\\nWith a story to be told\\nIn the forest dark and cold\\nHer courage pure as gold\\n[Verse 3]\\nWolf with eyes of gray\\nLurkin\' on her way\\nBut she\'ll not be prey\\nWith heart so brave she stays\\n[Bridge]\\nIn the night so deep\\nNo cries no tears to weep\\nGuardians of her sleep\\nWatch the girl in red hood keep\\n[Verse 4]\\nGranny\'s house in view\\nKindness shining through\\nA tale old yet new\\nOf the girl in red hood true", "audio_url": "https://audiopipe.suno.ai/?item_id=9b708ce5-3d73-41f2-b0d5-807b41d11f72", "video_url": "", "created_at": "2024-08-08T08:47:53.205Z", "model_name": "chirp-v3.5", "status": "streaming", "gpt_description_prompt": null, "prompt": "[Verse]\\nLittle girl in the woods\\nDressed in bright red hood\\nWalkin\' paths so good\\nThrough the whispering trees\\n\\n[Verse 2]\\nBaskets full of treats\\nFor her granny’s feast\\nFear not the beast\\nWith bravery she proceeds\\n\\n[Chorus]\\nOh young one so bold\\nWith a story to be told\\nIn the forest dark and cold\\nHer courage pure as gold\\n\\n[Verse 3]\\nWolf with eyes of gray\\nLurkin\' on her way\\nBut she\'ll not be prey\\nWith heart so brave she stays\\n\\n[Bridge]\\nIn the night so deep\\nNo cries no tears to weep\\nGuardians of her sleep\\nWatch the girl in red hood keep\\n\\n[Verse 4]\\nGranny\'s house in view\\nKindness shining through\\nA tale old yet new\\nOf the girl in red hood true", "type": "gen", "tags": "male bard", "duration": null, "error_message": null}, {"id": "a4e8fabe-4c72-4b39-b181-eddb623ea097", "title": "Everchangin_Quest_song", "image_url": "https://cdn2.suno.ai/image_a4e8fabe-4c72-4b39-b181-eddb623ea097.jpeg", "lyric": "[Verse]\\nLittle girl in the woods\\nDressed in bright red hood\\nWalkin\' paths so good\\nThrough the whispering trees\\n[Verse 2]\\nBaskets full of treats\\nFor her granny’s feast\\nFear not the beast\\nWith bravery she proceeds\\n[Chorus]\\nOh young one so bold\\nWith a story to be told\\nIn the forest dark and cold\\nHer courage pure as gold\\n[Verse 3]\\nWolf with eyes of gray\\nLurkin\' on her way\\nBut she\'ll not be prey\\nWith heart so brave she stays\\n[Bridge]\\nIn the night so deep\\nNo cries no tears to weep\\nGuardians of her sleep\\nWatch the girl in red hood keep\\n[Verse 4]\\nGranny\'s house in view\\nKindness shining through\\nA tale old yet new\\nOf the girl in red hood true", "audio_url": "https://audiopipe.suno.ai/?item_id=f278cc8a-ddda-4b5d-b0af-c07f516a04c8", "video_url": "", "created_at": "2024-08-08T08:47:53.205Z", "model_name": "chirp-v3.5", "status": "streaming", "gpt_description_prompt": null, "prompt": "[Verse]\\nLittle girl in the woods\\nDressed in bright red hood\\nWalkin\' paths so good\\nThrough the whispering trees\\n\\n[Verse 2]\\nBaskets full of treats\\nFor her granny’s feast\\nFear not the beast\\nWith bravery she proceeds\\n\\n[Chorus]\\nOh young one so bold\\nWith a story to be told\\nIn the forest dark and cold\\nHer courage pure as gold\\n\\n[Verse 3]\\nWolf with eyes of gray\\nLurkin\' on her way\\nBut she\'ll not be prey\\nWith heart so brave she stays\\n\\n[Bridge]\\nIn the night so deep\\nNo cries no tears to weep\\nGuardians of her sleep\\nWatch the girl in red hood keep\\n\\n[Verse 4]\\nGranny\'s house in view\\nKindness shining through\\nA tale old yet new\\nOf the girl in red hood true", "type": "gen", "tags": "male bard", "duration": null, "error_message": null}]'

	# Call the function to stream the first audio
	stream_first_audio(json_data)

# Callback function for when the HTTP request is completed	
func stream_first_audio(json_data):
	# Parse the JSON data
	var json = JSON.new()
	#json_data=json_data.left(-1)
	
	print(json_data)
	json.parse(json_data)
	var data = json.get_data()
	if not data:
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
	audio_url="https://audiopipe.suno.ai/?item_id=f278cc8a-ddda-4b5d-b0af-c07f516a04c8"
	if audio_url == "":
		print("No audio URL found")
		return

	# Make an HTTP request to download the audio file`
	http_request.request(audio_url)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		print("Failed to download audio file")
		return
	print(body)
	print('song answered')
	var stream = AudioStreamMP3.new()
	stream.data = body
	#stream.format = AudioStreamWAV.FORMAT_16_BITS
	#stream.mix_rate = 24000
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = stream
	add_child(audio_player)
	audio_player.play()
