extends Control
class_name StatHolder

signal plus
signal minus

@export var stat_name = "health"
@export var max_level = 20
@export var base_level = 1

var cost
var level

@onready var max_node = $max
@onready var name_node = $name
@onready var level_node = $value
@onready var cost_node = $cost

func _ready() -> void:
	max_node.text = str(max_level)
	name_node.text = stat_name
	level_node.text = str(base_level)
	cost = base_level
	cost_node.text= str(cost)
	level = base_level
	
func add() -> void:
	level += 1
	cost = level
	level_node.text = str(level)
	cost_node.text= str(cost)


func remove() -> void:
	level -= 1
	cost = level
	level_node.text = str(level)
	cost_node.text= str(cost)


func _on_button_plus_pressed() -> void:
	plus.emit()


func _on_button_minus_pressed() -> void:
	minus.emit()
