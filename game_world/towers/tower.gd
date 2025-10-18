extends Node3D
class_name Tower

const PLACEMENT_FORBIDDEN_INDICATOR_SCENE = preload("res://models/towers/placement_forbidden.tscn")
var placement_indicator = null

@export var radius: float = 1000

@onready var collision_area: Area3D = find_child("TowerArea")
@onready var world: World = find_parent('World')

var fire_delta: float = 0
var target_enemy: Enemy = null

func turn_to_closest_enemy():
	if not world:
		return

	target_enemy = world.get_closest_enemy(global_position)
	if (target_enemy == null):
		return
	
	var dist = global_position.distance_to(target_enemy.global_position)
	if (dist <= radius):
		var target_vector = global_position.direction_to(target_enemy.global_position)
		target_vector = Vector3(target_vector.x, 0, target_vector.z)
		basis = Basis.looking_at(target_vector)

func turn_to_last_enemy():
	if not world:
		return

	target_enemy = world.get_last_enemy(global_position, radius)
	if (target_enemy == null):
		return
	
	var dist = global_position.distance_to(target_enemy.global_position)
	if (dist <= radius):
		var target_vector = global_position.direction_to(target_enemy.global_position)
		target_vector = Vector3(target_vector.x, 0, target_vector.z)
		basis = Basis.looking_at(target_vector)

func fire() -> void:
	pass

func set_placement_preview(enabled: bool):
	if enabled and placement_indicator == null:
		placement_indicator = PLACEMENT_FORBIDDEN_INDICATOR_SCENE.instantiate()
		placement_indicator.visible = false
		add_child(placement_indicator)
	
	if not enabled and placement_indicator != null:
		placement_indicator.queue_free()

func set_placement_allowed(allowed: bool):
	if placement_indicator == null:
		return
	
	placement_indicator.visible = not allowed

func fire_at_target(
	play_anim: Callable,
	projectile: PackedScene,
	projectile_start: Node3D,
	projectile_rotation: Vector3 = Vector3.ZERO):
	
	await play_anim.call()
	var node: Projectile = projectile.instantiate()
	get_parent().add_child(node)
	node.global_position = projectile_start.global_position
	node.rotation = rotation + projectile_rotation
	node.move_into_direction(-transform.basis.z)
