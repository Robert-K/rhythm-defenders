extends PathFollow3D
class_name Enemy

@export var health: int = 100

@export var speed: float = 1

func _ready() -> void:
	create_tween().tween_property(self, "progress_ratio", 1, 20 * speed)

func hit(projectile: Projectile) -> void:
	queue_free()

func _on_enemy_body_entered(body: Node3D) -> void:
	print("entered", body)
	var projectile = (body as Projectile)
	hit(projectile)
