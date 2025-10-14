extends DamageDealer
class_name Projectile

func _ready() -> void:
	# Destroy projectiles shortly after they are created
	await get_tree().create_timer(2).timeout
	queue_free()
