extends PathFollow3D
class_name Enemy

@export var damage: float = 10
@export var speed: float = 0.4
@export var max_health: float = 100
@export var health_gradient: Gradient = Gradient.new()

@export var point_reward: int = 5

var health: float = max_health

@onready var ear : MeshInstance3D = $"enemy_ear/metarig/Skeleton3D/ear"
@onready var hit_feedback = preload("res://game_world/enemies/hit_feedback.tscn")
@onready var hit_feedback_container : Node3D = $HitFeedbackContainer

signal enemy_defeated
signal enemy_at_destination

var path_tween: Tween

func _ready() -> void:
	# Start walking on path
	path_tween = create_tween()
	path_tween.tween_property(self, "progress_ratio", 1, 20 / speed)
	path_tween.tween_callback(on_destination_entered)
	
	# Ear animation
	$enemy_ear/AnimationPlayer.play("Walk")

func apply_damage(amount: float) -> void:
	health -= amount
	update_health_visuals()
	play_hit_feedback()
	if (health <= 0):
		enemy_defeated.emit(self)

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
	deal_damage(body)

func _on_enemy_area_3d_area_entered(area: Area3D) -> void:
	deal_damage(area)

func deal_damage(body: Node):
	var damage_dealer: DamageDealer = body as DamageDealer
	while (damage_dealer == null):
		body = body.get_parent()
		if (body == null):
			return
		damage_dealer = (body as DamageDealer)
	
	damage_dealer.apply(self)

func pause_for(time: float):
	path_tween.pause()
	await get_tree().create_timer(time).timeout
	path_tween.play()

func on_destination_entered():
	enemy_at_destination.emit(self)
