extends PathFollow3D
class_name Enemy

@export var max_health: float = 100

var health: float = max_health

@export var speed: float = 1

@export var health_gradient: Gradient = Gradient.new()

@onready var mesh = $Area3D/MeshInstance3D

func _ready() -> void:
	create_tween().tween_property(self, "progress_ratio", 1, 20 * speed)

func hit(projectile: Projectile) -> void:
	health -= projectile.damage
	update_health_visuals()
	if (health <= 0):
		queue_free()

func update_health_visuals():
	var offset = (max_health - health) / max_health
	var new_color = health_gradient.sample(offset)
	var material = mesh.get_surface_override_material(0)
	material.albedo_color = new_color
	mesh.material_override = material

func _on_enemy_body_entered(body: Node3D) -> void:
	print("entered", body)
	var projectile = (body as Projectile)
	hit(projectile)
