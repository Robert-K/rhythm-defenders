extends PathFollow3D
class_name Enemy

@export var damage: float = 10
@export var speed: float = 0.4
@export var slow_down_multiplier: float = 0.25
@export var speed_up_multiplier: float = 2
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

var is_defeated = false

func _ready() -> void:
	# Start walking on path
	path_tween = create_tween()
	path_tween.tween_property(self, "progress_ratio", 1, 20 / speed)
	path_tween.tween_callback(on_destination_entered)
	
	# Ear animation
	$enemy_ear/AnimationPlayer.play("Walk")
	
	if InputManager._is_paused:
		_pause_changed(true)
	
	InputManager.is_paused_changed.connect(_pause_changed)

func _pause_changed(pause: bool) -> void:
	if path_tween:
		if pause:
			path_tween.pause()
		else:
			path_tween.play()

func apply_damage(amount: float) -> void:
	if (is_defeated):
		return
	
	health -= amount
	update_health_visuals()
	play_hit_feedback()
	if (health <= 0):
		is_defeated = true
		enemy_defeated.emit(self)

func update_health_visuals():
	var offset = (max_health - health) / max_health 
	var new_color = health_gradient.sample(offset)
	
	var material = ear.material_overlay
	material.albedo_color = new_color
	ear.material_overlay = material

func play_hit_feedback():
	var label = hit_feedback.instantiate()
	if (hit_feedback_container.get_child_count() == 0):
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

func slow_down_for(time: float):
	path_tween.set_speed_scale(slow_down_multiplier)
	await get_tree().create_timer(time).timeout
	path_tween.set_speed_scale(1)

func speed_up_for(time: float):
	path_tween.play()
	path_tween.set_speed_scale(speed_up_multiplier)
	await get_tree().create_timer(time).timeout
	path_tween.set_speed_scale(1)

func on_destination_entered():
	enemy_at_destination.emit(self)
