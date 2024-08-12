extends ColorRect
class_name AttackSelection

@export var slot_number = 7

var border_size = 6
var icon_size = 32
var holder 
var selection_rect: Array[ColorRect] = []
var selected = 0
var sprites : Array[Sprite2D] = []

func _ready() -> void:
	
	var ecart = border_size + icon_size
	size = Vector2(ecart*slot_number+border_size, border_size*2 + icon_size)
	position.y -= size.y
	for i in slot_number:
		# Create the border rectangle
		var border_rect = ColorRect.new()
		border_rect.size = Vector2(icon_size + border_size * 2, icon_size + border_size * 2)
		border_rect.color = Color.DARK_RED # Change this to the desired border color
		border_rect.position = Vector2(i*ecart, 0)
		add_child(border_rect)
		
		# Create the inner rectangle
		var holder_rect = ColorRect.new()
		holder_rect.size = Vector2(icon_size, icon_size)
		holder_rect.color = Color.PAPAYA_WHIP
		holder_rect.position = Vector2(i*ecart + border_size, border_size)
		add_child(holder_rect)
		
		selection_rect.push_back(holder_rect)
		
	set_selected(selected)


func set_selected(index):
	if index >= slot_number:
		print("wrong index")
		return
	
	selected = index
	for i in slot_number:
		selection_rect[i].color = Color.PAPAYA_WHIP
	selection_rect[index].color = Color.LIGHT_CORAL

func set_icons(icons: Array[Texture]):
	for sprite in sprites:
		remove_child(sprite)
		sprite.queue_free()
	sprites = []
	for i in icons.size():
		var new_sprite = Sprite2D.new() 
		new_sprite.texture = icons[i]
		new_sprite.position = Vector2((icon_size+border_size)*i + border_size + icon_size/2 ,border_size +  icon_size/2)
		new_sprite.visible =  true
		add_child(new_sprite)
		sprites.push_back(new_sprite)
