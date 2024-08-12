extends Control
class_name Item

var item_name
var item_desc
var text
var cost
var stats = {}

func get_texture():
	return text

func init(texture: Texture, p_name, description,p_cost, p_stats: Dictionary) -> void:
	text = texture
	item_name = p_name
	item_desc = description
	cost=p_cost
	stats = p_stats
