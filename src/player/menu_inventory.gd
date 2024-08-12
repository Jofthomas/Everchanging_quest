extends Control
class_name MenuInventory

@onready var inventory = $inventaire

var items : Array[Item] = []
var equiped_items : Array[Item] = []

var items_len = 4 * 7
var coins = 0
var keys = []

var cases1 : Array[ItemHolder] = []

@onready var holder_head = $HolderHead
@onready var holder_feets = $HolderFeets
@onready var holder_pants = $HolderPants
@onready var holder_belt = $HolderBelt
@onready var holder_torso = $HolderTorso
@onready var holder_hands = $HolderHands

# item description
@onready var item_desc = $item_description
@onready var item_name = $item_description/name
@onready var item_description = $item_description/desc
@onready var item_sprite : TextureRect = $item_description/TextureRect
@onready var item_stats = $item_description/stats

@onready var item_holder_scene : PackedScene = preload("res://src/player/item_holder.tscn")

func add_item(item: Item):
	if items.size() < items_len:
		items.push_back(item)
	update()

func add_coin(number):
	coins += number

func add_key(id):
	keys.push_back(id)
	
func create_cadre(cadre, row, column, group, remove = true, vanish = false):
	var cases: Array[ItemHolder] = []
	cadre.size = Vector2(column*34 + 2 + 96, row*34+ 2 + 96)
	
	for i in row:
		for j in column:
			var case: ItemHolder = item_holder_scene.instantiate()
			case.connect("data_dropped", data_dropped)
			case.connect("data_removed", data_removed)
			case.connect("clicked", _holder_clicked)
			case.vanish = vanish
			case.group = group
			case.remove = remove
			case.position = cadre.position + Vector2(48,48) + Vector2(2 + j*34, 2+i*34)
			add_child(case)
			cases.push_back(case)
	return cases

func _holder_clicked(item):
	if item:
		item_desc.visible = not item_desc.visible
		item_name.text =  item.item_name
		item_description.text = item.item_desc
		item_sprite.texture = item.get_texture()
		
		item_stats.text = ""
		for key in item.stats.keys():
			item_stats.text += key + " : " + str(item.stats[key]) + "      "
	
func data_dropped(item):
	items.push_back(item)

func data_removed(item):
	var index = items.find(item)
	if index != -1:
		items.remove_at(index)
	
func _data_dropped_equiped(item):
	equiped_items.push_back(item)

func _data_removed_equiped(item):
	var index = equiped_items.find(item)
	if index != -1:
		equiped_items.remove_at(index)
	
func _ready() -> void:
	holder_head.drop_condition = Callable(func (item : Item) : is_armor_type_compatible(item, "head"))
	holder_feets.drop_condition = Callable(func (item : Item) : is_armor_type_compatible(item,"feet"))
	holder_pants.drop_condition = Callable(func (item : Item) : return is_armor_type_compatible(item,"pants"))
	holder_belt.drop_condition = Callable(func (item : Item) : return is_armor_type_compatible(item,"belt"))
	holder_hands.drop_condition = Callable(func (item : Item) : return is_armor_type_compatible(item,"hands"))
	holder_torso.drop_condition = Callable(func (item : Item) : return is_armor_type_compatible(item,"torso"))

	cases1 = create_cadre(inventory, 4 ,7, "item")

func is_armor_type_compatible(item: Item, armor_type: String):
	return item.stats.has("armorType") && item.stats.armorType == armor_type
	
	
func update():
	for spell_index in items.size():
		if spell_index < cases1.size():
			cases1[spell_index].set_item(items[spell_index])
	
