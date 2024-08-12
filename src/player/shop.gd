extends Control
class_name ShopInventory

@onready var inventory = $inventaire
var item_scene : PackedScene = preload("res://src/items/item.tscn")

var items : Array[Item] = []

var items_len = 4 * 7
var coins = 0
var keys = []


var cases1 : Array[ItemHolder] = []

# item description
@onready var item_desc = $item_description
@onready var item_name = $item_description/name
@onready var item_description = $item_description/desc
@onready var item_sprite : TextureRect = $item_description/TextureRect
@onready var item_stats = $item_description/stats

@onready var item_holder_scene : PackedScene = preload("res://src/player/item_holder.tscn")

var Clicked_item = null

var npc_type=null

func set_npc(name):
	npc_type=name

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
	cadre.size = Vector2(column * 34 + 2 + 96, row * 34 + 2 + 96)
	
	for i in range(row):
		for j in range(column):
			var case: ItemHolder = item_holder_scene.instantiate()
			case.connect("data_dropped", data_dropped)
			case.connect("data_removed", data_removed)
			case.connect("clicked", _holder_clicked)
			case.vanish = vanish
			case.group = group
			case.remove = remove
			case.position = cadre.position + Vector2(70, 70) + Vector2(2 + j * 34, 2 + i * 34)
			add_child(case)
			cases.push_back(case)
	return cases

func _holder_clicked(item):
	if item:
		Clicked_item = item
		item_desc.visible = not item_desc.visible
		item_name.text = item.item_name
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

func _ready() -> void:
	cases1 = create_cadre(inventory, 4, 7, "item")

func is_armor_type_compatible(item: Item, armor_type: String):
	return item.stats.has("armorType") and item.stats.armorType == armor_type

func update():
	for spell_index in range(items.size()):
		if spell_index < cases1.size():
			cases1[spell_index].set_item(items[spell_index])

func _on_button_pressed() -> void:
	if Clicked_item and item_desc.visible:
		
		print("buying : ", Clicked_item.item_name, "for : ", Clicked_item.cost, "type :",Clicked_item.stats.armorType)
		var player = Global.player
		if player:
			if Global.player_xp<Clicked_item.cost:
				return 
			if Clicked_item.stats.armorType=="Spell":
				# Assuming Clicked_item.item_name is "Holysword"
				var spell_name = str(Clicked_item.item_name)
				var spell_node = player.get_node("attacks/" + spell_name)
				player.add_spell(spell_node)
			else:
				player.add_item(Clicked_item)
			player.in_game_menu.menu_stats.add_xp(-Clicked_item.cost)
		

func load_items_for_npc(npc_name):
	var file = "res://assets/npc_items.json"
	if file:
	
		var json_as_text = FileAccess.get_file_as_string(file)
		var json_as_dict = JSON.parse_string(json_as_text)
		if json_as_dict:
			print(json_as_dict)
		if npc_name in json_as_dict:
			var items_data = json_as_dict[npc_name]
			for item_data in items_data:
				var texture = load(item_data["image"])
				var item = item_scene.instantiate()
				item.init(
					texture,
					item_data["name"],
					item_data["description"],
					item_data["cost"],
					item_data["stats"]
				)
				add_item(item)
		else:
			print("No items found for NPC: ", npc_name)
	else:
		print("npc_items.json file not found")
