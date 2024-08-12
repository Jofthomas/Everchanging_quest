extends Area2D
class_name Collectable
var item_scene : PackedScene = preload ("res://src/items/item.tscn")
@export var type = chest1
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var audio  = $AudioStreamPlayer2D
enum  { chest1 ,chest2 , coin, key1, key2}
var item : Item
@onready var http = $HTTPRequest
var url = "https://jofthomas-evbackend.hf.space/"

func _ready() -> void:
	sprite.play("idle")

func init(p_type, p_item = null):
	type = p_type
	if p_type == chest1 or p_type == chest2:
		item = p_item
		
func generate_item():
	# Example of making another HTTP request (commented out in your code)
	var object_prompt="picture of role playing game item,"+ str(item.item_desc)+", intricate details, RPG Maker, pixelated, 2d, video game"
	var item_body = JSON.new().stringify({
		"name":item.item_name,
		"prompt":object_prompt
		})
	print("sending request")
	print(item_body)
	http.request(url+"generate_image", ["Content-Type: application/json"], HTTPClient.METHOD_POST, item_body)
	
func get_item():
	return item

func type_to_anim(type):
	match type:
		chest1: return "chest1"
		chest2: return "chest2"
		coin: return "coin"
		key1: return "key1"
		key2: return "key2"

func play_sound():
	sprite.play('open')
	audio.play()
func _on_body_entered(body: Node2D) -> void:
	sprite.play('open')
	audio.play()
	
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("object received")

	var image = Image.new()
	# function used to load image from http request
	var error = image.load_png_from_buffer(body)
	if !error:
		pass
		# ImageTexture.create_from_image(image)
		
	var texture = ImageTexture.create_from_image(
		image
	)
	item.texture=texture
	
	
