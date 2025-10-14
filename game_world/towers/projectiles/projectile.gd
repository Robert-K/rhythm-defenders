extends RigidBody3D
class_name Projectile

@export var damage: float = 10

func _ready() -> void:
	# Destroy projectiles shortly after they are created
	await get_tree().create_timer(2).timeout
	queue_free()
