extends Projectile
class_name FluteProjectile

@onready var rigid_body: RigidBody3D = $"."

@export var sleep_time: float = 1.5

func apply(enemy: Enemy):
	visible = false
	super.apply(enemy)
	if (is_instance_valid(enemy)):
		enemy.path_tween.pause()
	await get_tree().create_timer(sleep_time).timeout
	if (is_instance_valid(enemy)):
		enemy.path_tween.play()
	queue_free()

func move_into_direction(dir: Vector3):
	rigid_body.apply_central_impulse(dir * projectile_speed)
