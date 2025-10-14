extends Node
class_name World

@onready var current_map: Map = $Map1

func get_closest_enemy(pos: Vector3) -> Enemy:
	print(current_map.enemies)
	var closest = null
	var closest_dist = Vector3.INF
	for enemy: Enemy in current_map.enemies:	
		print(enemy.position)
		var dist = 	enemy.position.distance_to(pos)
		if (closest == null || dist < closest_dist):
			closest = enemy
			closest_dist = dist
	
	return closest
