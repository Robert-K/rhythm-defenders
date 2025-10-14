extends PathFollow3D
class_name Enemy

@export var speed: float = 0.4
@export var max_health: float = 100
@export var health_gradient: Gradient = Gradient.new()

var health: float = max_health

@onready var ear : MeshInstance3D = $"enemy_ear/metarig/Skeleton3D/ear"
@onready var hit_feedback = preload("res://game_world/enemies/hit_feedback.tscn")
@onready var hit_feedback_container : Node3D = $HitFeedbackContainer


func _ready() -> void:
	# Start walking on path
	create_tween().tween_property(self, "progress_ratio", 1, 20 / speed)
	
	# Ear animation
	$enemy_ear/AnimationPlayer.play("Walk")

func hit(projectile: Projectile) -> void:
	health -= projectile.damage
	update_health_visuals()
	play_hit_feedback()
	print(health)
	if (health <= 0):
		queue_free()

func update_health_visuals():
	var offset = (max_health - health) / max_health
	var new_color = health_gradient.sample(offset)
	
	var material = ear.material_overlay
	material.albedo_color = new_color
	ear.material_overlay = material

func play_hit_feedback():
	var label = hit_feedback.instantiate()
	hit_feedback_container.add_child(label)

func _on_enemy_body_entered(body: Node3D) -> void:
	var projectile = (body as Projectile)
	hit(projectile)
