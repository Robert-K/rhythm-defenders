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
	DebugDraw3D.draw_line(global_position, target_enemy.global_position)
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

func fire_at_target(play_anim: Callable, projectile: PackedScene, projectile_start: Node3D, projectile_speed: float):
	if (target_enemy == null || !is_instance_valid(target_enemy)):
		return
	
	var target_pos = target_enemy.global_position
	var dist = global_position.distance_to(target_pos)
	if (dist > radius):
		return
	
	play_anim.call()
	var node : Projectile = projectile.instantiate()
	projectile_start.add_child(node)
	node.damage = damage
	node.global_position = projectile_start.global_position
	var target_vector = global_position.direction_to(target_pos)
	node.apply_central_impulse(target_vector * projectile_speed)
