extends Node3D
class_name Tower

@export var damage: int = 10
@export var radius: float = 1000

@onready var world: World = find_parent('World')

func _ready() -> void:
	fire()

var delta: float = 0

func turn_to_closest_enemy(delta: float):
	var target_enemy = world.get_closest_enemy(position)
	if (target_enemy == null):
		return
	
	DebugDraw3D.draw_line(target_enemy.position, position)
	var dist = position.distance_to(target_enemy.position)
	print("Enemy is close", target_enemy, "dist", dist)
	var target_rotation = transform.looking_at(target_enemy.position, Vector3.UP).basis
	look_at(target_enemy.position, Vector3.UP, true)
	#transform.basis = target_rotation
	#if (dist <= radius):
		#var target_vector = position.direction_to(target_enemy.position)
		#var target_basis = Basis.looking_at(target_vector)
		#basis = target_basis

func _process(_delta):
	delta += _delta
	if (delta > 1):
		delta = 0
		fire()

func fire() -> void:
	print("fire")
