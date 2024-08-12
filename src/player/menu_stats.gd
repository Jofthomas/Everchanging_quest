extends Control
class_name MenuStats

signal update_active_spells

var spells : Array[Equipement] = []
var active_spells : Array[Equipement] = []
var xp = Global.player_xp

@onready var xp_node = $xp_value

@onready var strength_node : StatHolder= $strength
@onready var energy_node : StatHolder= $energy
@onready var health_node : StatHolder = $health
@onready var magic_node : StatHolder= $magic

signal health_max(max)
signal magic_max(max)

var spell_nodes = []
var active_spell_nodes = []

var spells_len = 3 * 7
var active_spells_len = 7 

@onready var cadre2 = $active_spells
@onready var cadre3 = $spells

@onready var item_holder_scene : PackedScene = preload("res://src/player/item_holder.tscn")

func _ready() -> void:
	active_spell_nodes = create_cadre("active_spell", cadre2, 1 ,7, "equipement", true, true)
	spell_nodes = create_cadre("spells", cadre3, 3 ,7,"equipement", false)
	xp_node.text = str(xp)
	
func add_xp(number):
	xp += number
	print(xp)
	Global.set_xp(xp)
	xp_node.text = str(xp)
	
func add_spell(item: Equipement):
	if spells.size() < spells_len:
		spells.push_back(item)
	if active_spells.size() < active_spells_len:
		active_spells.push_back(item)
	update()

func create_cadre(id, cadre, row, column, group, remove = true, vanish = false):
	var cases = []
	cadre.size = Vector2(column*34 + 2 + 96, row*34+ 2 + 96)
	
	for i in row:
		for j in column:
			var case = item_holder_scene.instantiate()
			case.connect("data_dropped", func (data): data_dropped(data, id))
			case.connect("data_removed", func (data): data_removed(data, id))
			case.vanish = vanish
			case.group = group
			case.remove = remove
			case.position = cadre.position + Vector2(48,48) + Vector2(2 + j*34, 2+i*34)
			add_child(case)
			cases.push_back(case)
	return cases

func data_dropped(data, id):
	if id == "active_spell":
		active_spells.push_back(data)
		update_active_spells.emit()
	
func data_removed(data, id):
	var index = active_spells.find(data)
	if id == "active_spell" && index != -1:
		active_spells.remove_at(index)
		update_active_spells.emit()


func update():
	for spell_index in spells.size():
		print(spells)
		print(spell_nodes)
		if spell_index < spell_nodes.size():
			spell_nodes[spell_index].set_item(spells[spell_index])
	for spell_index in active_spells.size():
		if spell_index < active_spell_nodes.size():
			active_spell_nodes[spell_index].set_item(active_spells[spell_index])

func remove_based_on_xp(node: StatHolder):
	if node.level > 1:
		add_xp(node.cost)
		node.remove()

func add_based_on_xp(node : StatHolder):
	if node.cost <= xp && node.max_level != node.level:
		print(node.cost)
		add_xp(-node.cost)
		node.add()
		
		
func _on_health_minus() -> void:
	remove_based_on_xp(health_node)
	health_max.emit(health_node.level)


func _on_health_plus() -> void:
	add_based_on_xp(health_node)
	health_max.emit(health_node.level)


func _on_magic_minus() -> void:
	remove_based_on_xp(magic_node)
	magic_max.emit(magic_node.level)

func _on_magic_plus() -> void:
	add_based_on_xp(magic_node)
	magic_max.emit(magic_node.level)


func _on_energy_minus() -> void:
	remove_based_on_xp(energy_node)


func _on_energy_plus() -> void:
	add_based_on_xp(energy_node)



func _on_strength_minus() -> void:
	remove_based_on_xp(strength_node)


func _on_strength_plus() -> void:
	add_based_on_xp(strength_node)
