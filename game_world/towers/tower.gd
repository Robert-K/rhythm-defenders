extends Node3D
class_name Tower

const PLACEMENT_FORBIDDEN_INDICATOR_SCENE = preload("res://models/towers/placement_forbidden.tscn")
var placement_indicator = null

@export var damage: int = 10
@export var radius: float = 1000

@onready var collision: CollisionShape3D = find_child("TowerCollision")
@onready var world: World = find_parent('World')

var fire_delta: float = 0
var target_enemy: Enemy = null

func _ready() -> void:
	assert(collision != null)
	
	# For initial tower placement
	collision.disabled = true

func turn_to_closest_enemy():
	if not world:
		return

	target_enemy = world.get_closest_enemy(global_position)
	if (target_enemy == null):
		return
	
	var dist = global_position.distance_to(target_enemy.global_position)
	DebugDraw3D.draw_line(global_position, target_enemy.global_position)
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
	DebugDraw3D.draw_line(global_position, target_enemy.global_position)
	if (dist <= radius):
		var target_vector = global_position.direction_to(target_enemy.global_position)
		target_vector = Vector3(target_vector.x, 0, target_vector.z)
		basis = Basis.looking_at(target_vector)

func fire() -> void:
	print("fire")

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
	if (target_enemy == null || !is_instance_valid(target_enemy)):
		return
	
	var target_pos = target_enemy.global_position
	var dist = global_position.distance_to(target_pos)
	if (dist > radius):
		return
	
	await play_anim.call()
	var node: Projectile = projectile.instantiate()
	projectile_start.add_child(node)
	node.damage = damage
	node.global_position = projectile_start.global_position
	var target_vector = global_position.direction_to(target_pos)
	node.rotation = rotation + projectile_rotation
	node.move_into_direction(target_vector)
