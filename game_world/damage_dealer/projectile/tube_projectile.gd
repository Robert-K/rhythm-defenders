extends Projectile
class_name TubeProjectile

@export var exist_time: float = 1.5

@export var move_back_time: float = 1.5

@onready var particles: GPUParticles3D = $CollisionShape3D/AirParticles

@onready var animatable_body: AnimatableBody3D = $"."

func _ready() -> void:
	particles.emitting = true
	await get_tree().create_timer(exist_time).timeout
	queue_free()

func apply(enemy: Enemy):
	super.apply(enemy)
	if (is_instance_valid(enemy)):
		enemy.path_tween.pause()
	await get_tree().create_timer(move_back_time).timeout
	if (is_instance_valid(enemy)):
		enemy.path_tween.play()

func move_into_direction(dir: Vector3):
	animatable_body.constant_linear_velocity = dir * projectile_speed
