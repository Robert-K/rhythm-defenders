extends Projectile
class_name TubeProjectile

@export var exist_time: float = 0.4

@export var effect_time: float = 1

@onready var rigid_body: RigidBody3D = $"."

func _ready() -> void:
	await get_tree().create_timer(exist_time).timeout
	queue_free()

func apply(enemy: Enemy):
	super.apply(enemy)
	enemy.slow_down_for(effect_time)
