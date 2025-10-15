extends Projectile
class_name Bomb

@onready var explosion_damage = preload("res://game_world/damage_dealer/explosion_damage/bomb_area_damage.tscn")

@onready var rigid_body: RigidBody3D = $"."
@onready var mesh: MeshInstance3D = $"MeshInstance3D"

func _on_ground_entered(body: Node3D) -> void:
	# Stop bomb
	rigid_body.linear_velocity = Vector3.ZERO
	rigid_body.angular_velocity = Vector3.ZERO
	mesh.visible = false
	rigid_body.freeze = true
	
	# Place explosion
	var node: ExplosionDamage = explosion_damage.instantiate()
	node.damage = damage
	add_child(node)
	await get_tree().create_timer(0.5).timeout
	remove_child(node)
