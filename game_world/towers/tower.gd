extends Node3D
class_name Tower

@export var damage: int = 10
@export var radius: float = 1000
@export var fire_interval: float = 1

@onready var world: World = find_parent('World')

var fire_delta: float = 0
var target_enemy: Enemy = null

func _ready() -> void:
	fire()

func turn_to_closest_enemy():
	target_enemy = world.get_closest_enemy(global_position)
	if (target_enemy == null):
		return
	
	var dist = global_position.distance_to(target_enemy.global_position)
	if (dist <= radius):
		var target_vector = global_position.direction_to(target_enemy.global_position)
		target_vector = Vector3(target_vector.x, 0, target_vector.z)
		basis = Basis.looking_at(target_vector)

func _process(_delta):
	fire_delta += _delta
	if (fire_delta > fire_interval):
		fire_delta = 0
		fire()

func fire() -> void:
	print("fire")
