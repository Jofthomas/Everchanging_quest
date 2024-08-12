extends CharacterBody2D
class_name MainPlayer

@onready var _animated_sprite = $AnimatedSprite2D
@onready var in_game_menu : InGameMenu = $InGameMenu
@onready var minimap =$Minimap
@onready var attacks = $attacks
@onready var attack_selection : AttackSelection = $HUD/AttackSelection
@onready var health_bar : StatBar = $HUD/HealthBar
@onready var magic_bar : StatBar = $HUD/MagicBar
@onready var health_comp : HealthComponent = $HealthComponent
@onready var screen_manager : ScreenManager = get_node("/root/Main/ScreenManager")
@onready var log_manager : LogManager = get_node("/root/Main/LogManager")

var attack_animation_speed = 1.0
var dash_animation_speed = 4.0
var dash_speed = 100
var interact_targets : Array[InteractComponent] = []
var to_loop


@export var stats: PlayerStat

const global = preload("res://global.gd")

var orientation = global.ORIENTATION.DOWN
var target_orientation = global.ORIENTATION.DOWN
var interactMode = false
var magic

enum {
	IDLE, RUNNING, WALKING, 
	DASHING, 
	ATTACKING,
	BOW,
	SPELL,
	LOOP_ATTACK
};
var state = IDLE
var target_state = IDLE

var input_direction : Vector2

func _ready():

	health_comp.set_max(in_game_menu.menu_stats.health_node.level * 2)
	health_bar.set_max(in_game_menu.menu_stats.health_node.level * 2)
	magic = in_game_menu.menu_stats.magic_node.level + 2
	magic_bar.set_max(in_game_menu.menu_stats.magic_node.level + 2)
	
func set_map(rooms, interest_rooms):
	in_game_menu.menu_logs.set_map(rooms,interest_rooms)
	minimap.set_map(rooms,interest_rooms)
	
func reset_map():
	in_game_menu.menu_logs.remove_map()
	minimap.remove_map()
	
func add_spell(spell:Equipement):
	in_game_menu.menu_stats.add_spell(spell)
	var spell_name = str(spell).split(":")[0]
	log_manager.add_entry("Player obtained spell: " + spell_name)
	set_hud_icons()

func add_item(item):
	log_manager.add_entry("Player obtained item:  "+str(item.item_name))
	in_game_menu.menu_inventory.add_item(item)

func add_objective(objective):
	in_game_menu.menu_quests.set_quest(objective)
	

func set_hud_icons():
	var icons : Array[Texture]= []
	for spell in in_game_menu.get_active_spell():
		icons.push_back(spell.get_texture())
	attack_selection.set_icons(icons)
	
func add_xp(amount):
	in_game_menu.menu_stats.add_xp(amount)
	
func _process(_delta):
	play_animation()
	
	if Input.is_action_just_pressed("switch_spell"):
		var next_index = attack_selection.selected + 1 if attack_selection.selected < attack_selection.slot_number-1 else 0
		attack_selection.set_selected(next_index)
		
	if Input.is_action_just_pressed("inventory"):
		if in_game_menu.is_open:
			in_game_menu.close()
		else:
			in_game_menu.open()
	
	if Input.is_action_just_pressed("attack") and interactMode:
		var index = 0
		var distance = position.distance_to(interact_targets[0].position)
		for i in interact_targets.size():
			var dist =  position.distance_to(interact_targets[i].position)
			if dist < distance:
				distance = dist
				index = i
		interact_targets[index].interact()

func _physics_process(delta):
	if Global.player_interracting==true:
		return
	velocity = Vector2(0,0)
	
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	update_target_state() # from input what to do
	var updated = update_state()
	var spells = in_game_menu.get_active_spell()
	
	if updated && state in [SPELL] && attack_selection.selected < spells.size():
		spells[attack_selection.selected].attack(orientation, position, 0)
		
	if updated && state in [ATTACKING]:
		$attacks/SwordComponent.attack(orientation, position, 2)
		
	if updated && state in [BOW]:
		$attacks/BowComponent.attack(orientation, position, 0)
		
	if state == RUNNING:
		velocity = input_direction * delta * stats.speed * 2 * 100
	elif state == WALKING:
		velocity = input_direction * delta * stats.speed * 100
	elif state == DASHING:
		velocity = global.orientation_to_direction(orientation) * 100 * delta * dash_speed
	
	apply_effects()
	if not in_game_menu.is_open and not in_game_menu.busy:
		move_and_slide()
	
func play_oriented_animation(animation_name, speed = 1.0):
	if orientation == global.ORIENTATION.DOWN:
		_animated_sprite.play("Front_" + animation_name, speed, )
	elif orientation == global.ORIENTATION.TOP:
		_animated_sprite.play("Back_" + animation_name, speed)
	elif orientation == global.ORIENTATION.LEFT or orientation == global.ORIENTATION.RIGHT:
		_animated_sprite.flip_h = orientation == global.ORIENTATION.LEFT
		_animated_sprite.play("Side_" + animation_name, speed)
	elif orientation == global.ORIENTATION.TOPLEFT or orientation == global.ORIENTATION.TOPRIGHT:
		_animated_sprite.flip_h = orientation == global.ORIENTATION.TOPLEFT
		_animated_sprite.play("Back_Side_" + animation_name, speed)
	elif orientation == global.ORIENTATION.DOWNLEFT or orientation == global.ORIENTATION.DOWNRIGHT:
		_animated_sprite.flip_h = orientation == global.ORIENTATION.DOWNLEFT
		_animated_sprite.play("Front_Side_" + animation_name, speed)

		


func update_target_state():
	if input_direction != Vector2(0,0):
		target_orientation = global.direction_to_orientation(input_direction)
	if Input.is_action_just_pressed("attack") and not interactMode:
		target_state = ATTACKING
	elif Input.is_action_just_pressed("bow") and not interactMode:
		target_state = BOW
	elif Input.is_action_just_pressed("spell") and not interactMode and can_use_spell():
		target_state = SPELL
	elif Input.is_action_just_pressed("dash"):
		target_state = DASHING
	elif input_direction.x != 0 || input_direction.y != 0:
		if Input.is_action_pressed("run"):
			target_state = RUNNING
		else:
			target_state = WALKING
	else:
		target_state = IDLE

func can_use_spell():
	if magic > 0:
		magic -= 1
		print(magic,magic_bar.max_value)
		magic_bar.draw(magic)
		return true
	return false
	
func update_state():
	if state in [IDLE, WALKING, RUNNING]:
		state = target_state
		orientation = target_orientation
		return true
	elif state == LOOP_ATTACK:
		state = to_loop
		orientation = target_orientation
		return true
	return false
	
func play_animation():
	match state:
		BOW:
			play_oriented_animation("bow", attack_animation_speed)
		SPELL:
			play_oriented_animation("throw", attack_animation_speed)
		ATTACKING:
			play_oriented_animation("attack", attack_animation_speed)
		DASHING:
			play_oriented_animation("dash", dash_animation_speed)
		RUNNING:
			play_oriented_animation("run", attack_animation_speed)
		WALKING:
			play_oriented_animation("walk", attack_animation_speed)
		IDLE:
			play_oriented_animation("idle", attack_animation_speed)

func _on_animated_sprite_2d_animation_finished():
	if Input.is_action_pressed("attack"):
		state = LOOP_ATTACK
		to_loop = ATTACKING
	elif Input.is_action_pressed("bow"):
		state = LOOP_ATTACK
		to_loop = BOW
	elif Input.is_action_pressed("spell") and can_use_spell():
		state = LOOP_ATTACK
		to_loop = SPELL
	else:
		state = IDLE


func _on_interact_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("interact"):
		interactMode = true
		interact_targets.push_back(area)
	

func _on_interact_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("interact"):
		var i = interact_targets.find(area)
		if i == -1:
			print("can't find interact")
		else:
			interact_targets.remove_at(i)
			if interact_targets.size() == 0:
				interactMode = false
			


func _on_collect_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("collectable"):
		var collectable = area as Collectable
		get_parent().remove_child(area)
		match collectable.type:
			Collectable.chest1:
				collectable.play_sound()
				var item=collectable.generate_item()
				in_game_menu.menu_inventory.add_item(item)
				log_manager.add_entry("player has opened a treasure chest and obtained : " + collectable.item.item_name)
			Collectable.coin:
				in_game_menu.menu_inventory.add_coin(1)
				log_manager.add_entry("player has picked up a coin")
			Collectable.key1:
				in_game_menu.menu_inventory.add_key(1)
				log_manager.add_entry("player has picked up a key")
			Collectable.key2:
				in_game_menu.menu_inventory.add_key(2)
				log_manager.add_entry("player has picked up a key")


func _on_in_game_menu_update_active_spells() -> void:
	set_hud_icons()


func _on_update_map_timer_timeout() -> void:
	if screen_manager.current_screen == screen_manager.screen.DUNGEON:
		var dj = screen_manager.current_node as Dungeon
		var pos = (position / (dj.tile_size * dj.real_room_lenght)).floor()
		in_game_menu.menu_logs.set_player_icon(pos)
	
var effects = []

func add_effects(arr):
	for effect in arr:
		add_child(effect)
	effects += arr
		
func apply_effects():
	var ended_effects = []
	for i in range(effects.size()):
		var effect = effects[i]
		if effect && not effect.apply_effect(self):
			ended_effects.push_front(i)

	for index in ended_effects:
		remove_child(effects[index])
		effects[index].queue_free()
		effects.remove_at(index)


func _on_health_component_die() -> void:
	log_manager.add_entry("player died")
	screen_manager.set_screen(screen_manager.screen.DEATH)


func _on_health_component_hit() -> void:
	health_bar.draw(health_comp.health)
	
func heal()-> void:
	if health_comp.health < health_comp.max_health:
		health_comp.health=health_comp.max_health
		health_bar.draw(health_comp.health)

func _on_in_game_menu_update_max_health(max: Variant) -> void:
	health_bar.set_max(max*2)
	health_comp.set_max(max*2)


func _on_in_game_menu_update_max_magic(max: Variant) -> void:
	magic_bar.set_max(max+2)
	magic = max+2


func _on_magix_regen_timeout() -> void:
	if magic < in_game_menu.menu_stats.magic_node.level + 2:
		magic += 1
		magic_bar.draw(magic)
