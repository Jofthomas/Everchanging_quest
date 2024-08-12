extends Equipement
class_name SwordComponent

@onready var areaT = $AreaTop
@onready var areaR = $AreaRight
@onready var areaL = $AreaLeft
@onready var areaB = $AreaBottom

func get_texture() -> Texture:
	return $Sprite2D.texture
	
func attack(orientation, position: Vector2, damage):
	
	var area_atk
	if orientation%4 == 0: 
		area_atk = areaT		 
	elif orientation%4 == 1: 
		area_atk = areaB
	elif orientation%4 == 2: 
		area_atk = areaL 
	elif orientation%4 == 3:
		area_atk = areaR 
				

	for area : Area2D in area_atk.get_overlapping_areas():
		if area.is_in_group("hitbox") and not area.is_in_group("hitbox_player"):
			var hitbox : HitboxComponent = area as HitboxComponent
			var attack_info: AttackInfo = AttackInfo.new(1,(position+hitbox.get_body().position)/2,position,hitbox.get_body().position)
			print(attack_info)
			hitbox.damage(attack_info,attack_effects.map(func(scene: PackedScene): return scene.instantiate()))


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
