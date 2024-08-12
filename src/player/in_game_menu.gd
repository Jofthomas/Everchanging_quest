extends CanvasLayer
class_name InGameMenu

@onready var _animated_sprite = $AnimatedSprite2D
@onready var menu = $menu_items
@onready var menu_inventory: MenuInventory = $menu_items/menu_inventory
@onready var menu_stats : MenuStats= $menu_items/menu_stats
@onready var menu_logs: MenuLogs = $menu_items/menu_logs
@onready var menu_quests: MenuQuest = $menu_items/menu_quest
@onready var menus : Array[Control] = [ 
	$menu_items/menu_logs, $menu_items/menu_stats,
	$menu_items/menu_inventory, $menu_items/menu_quest, 
	$menu_items/menu_save, $menu_items/menu_options
]
@onready var log_manager : LogManager = get_node("/root/Main/LogManager")

signal update_active_spells
signal update_max_health(max)
signal update_max_magic(max)

var is_open = false
var busy = false
enum menu_items {LOG, STATS, INVENTORY, QUEST, SAVE, OPTIONS}

var active_menu = menu_items.STATS
var items : Array[Collectable] = []
var open_tab = 2

func get_xp():
	return menu_stats.xp

func get_active_spell():
	return menu_stats.active_spells

func get_active_spell_len():
	return menu_stats.active_spells_len
	
func _ready():
	open_menu(open_tab)
	visible = false
	menu.visible = false

func close():
	menu.visible = false
	if not busy and is_open:
		_animated_sprite.play("close_book")
		busy = true
	
func open():
	if not busy and not is_open:
		_animated_sprite.play("open_book")
		busy = true
		visible = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == "open_book":
		is_open = true
		busy = false
		open_menu(open_tab)
		menu.visible = true
	elif _animated_sprite.animation == "close_book":
		visible = false
		is_open = false
		busy = false

func _on_button_pressed1():
	open_tab = 1
	menu_logs.set_log(log_manager.log)
	open_menu(1)

func _on_button_pressed2():
	open_tab = 2
	open_menu(2)

func _on_button_pressed3():
	open_tab = 3
	open_menu(3)

func _on_button_pressed4():
	open_tab = 4
	open_menu(4)

func _on_button_pressed5():
	open_tab = 5
	open_menu(5)

func _on_button_pressed6():
	open_tab = 6
	open_menu(6)
	
func open_menu(i):
	_animated_sprite.play(str(i))
	for j in range(menus.size()):
		menus[j].visible = (i -1) == j


func _on_menu_stats_update_active_spells() -> void:
	update_active_spells.emit()


func _on_menu_stats_health(max: Variant) -> void:
	update_max_health.emit(max)


func _on_menu_stats_magic(max: Variant) -> void:
	update_max_magic.emit(max)
