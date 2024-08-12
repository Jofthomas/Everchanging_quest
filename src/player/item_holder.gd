extends Panel
class_name ItemHolder

@export var group = "equipement"
@export var remove = true
@export var vanish = false
@export var default_texture: Texture

@onready var texture_rext = $TextureRect
var drop_condition : Callable = Callable(func (_data): return true)

signal data_dropped(data)
signal data_removed(data)
signal clicked(data)

var current = null
var last_current = null

func _ready() -> void:
	texture_rext.texture = default_texture
	
func set_item(node :Node):
	current = node
	if current:
		texture_rext.texture = node.get_texture()
	
func create_preview(texture):
	var preview_texture = TextureRect.new()
 
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(30,30)
 
	var preview = Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview)
	
func _get_drag_data(_at_position: Vector2) -> Variant:
	if current:
		create_preview(texture_rext.texture)
		if remove:
			last_current = current 
			current = null
			texture_rext.texture = default_texture
			data_removed.emit(last_current)
			return last_current
		return current
	return null
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not drop_condition.call(data):
		return false
	if vanish and current:
		return true
	return not current and data.is_in_group(group) and remove
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data and data.is_in_group(group) and remove:
		last_current = null
		current = data
		texture_rext.texture = data.get_texture()
		data_dropped.emit(data)

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if not is_drag_successful() and last_current and not vanish:
				current = last_current
				data_dropped.emit(current)
				$TextureRect.texture = current.get_texture()
			else:
				last_current = null
		


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		clicked.emit(current)
