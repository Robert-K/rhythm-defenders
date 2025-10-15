extends Projectile
class_name TubeProjectile

@export var exist_time: float = 1.5

@export var move_back_time: float = 1.5

@onready var rigid_body: RigidBody3D = $"."

func _ready() -> void:
	await get_tree().create_timer(exist_time).timeout
	queue_free()

func apply(enemy: Enemy):
	super.apply(enemy)
	enemy.go_back_for(move_back_time)

func move_into_direction(dir: Vector3):
	rigid_body.apply_central_impulse(dir * projectile_speed)
