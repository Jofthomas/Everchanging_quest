extends Control
class_name StatBar 

@export var start_full : Texture
@export var end_full : Texture
@export var chevron_full : Texture
@export var start_empty : Texture
@export var end_empty : Texture
@export var chevron_empty : Texture

var childs = []
var max_value = 10
var ma_scale = Vector2(2,2)

func _ready() -> void:
	draw(11)
	
func set_max(number):
	max_value = number
	draw(max_value)

func draw(value: int):
	for child in childs:
		remove_child(child)
	var sp 
	if value > 1:
		sp = add_sprite(start_full, Vector2(0,0))
	else:
		sp = add_sprite(start_empty, Vector2(0,0))
	var offset = sp.texture.get_size().x * ma_scale.x
	for i in range (2,max_value-1):
		if value > i:
			sp = add_sprite(chevron_full, Vector2(offset,0))
		else:
			sp = add_sprite(chevron_empty, Vector2(offset,0))
		offset += sp.texture.get_size().x * ma_scale.x
	if value > max_value-1:
		sp = add_sprite(end_full, Vector2(offset,0))
	else:
		sp = add_sprite(end_empty, Vector2(offset,0))
	


func add_sprite(texture, position):
	var sprite = TextureRect.new()
	sprite.texture = texture
	sprite.position = position
	sprite.scale = ma_scale
	add_child(sprite)
	childs.push_back(sprite)
	return sprite
