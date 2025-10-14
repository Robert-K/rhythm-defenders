extends DamageDealer
class_name AreaDamage

@export var interval: float = 1

@onready var area3d: Area3D = $"."

func apply(enemy: Enemy):
	while (is_instance_valid(enemy) && contains_enemy(enemy)):
		enemy.apply_damage(damage)
		await get_tree().create_timer(interval).timeout

func contains_enemy(enemy: Enemy) -> bool:
	for body in area3d.get_overlapping_areas():
		var current = body
		while (current != null):
			if (current == enemy):
				return true
			
			current = current.get_parent()
	
	return false
