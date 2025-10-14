extends Node
class_name World

@onready var current_map: Map = $Map1

func get_closest_enemy(pos: Vector3) -> Enemy:
	var closest = null
	var closest_dist = Vector3.INF
	for enemy: Enemy in current_map.get_enemies():
		if (enemy == null):
			continue
		
		var dist = 	enemy.global_position.distance_to(pos)
		if (closest == null || dist < closest_dist):
			closest = enemy
			closest_dist = dist
	
	return closest
