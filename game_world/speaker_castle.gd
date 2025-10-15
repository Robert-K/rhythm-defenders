extends Node3D
class_name Castle

const HARDCODED_BPM = 75.0

@onready var timer: Timer = $Timer

@onready var health_label: Label3D = $HealthLabel

@export var total_health: float = 100
var health: float = total_health

func _ready() -> void:
	timer.wait_time = 60/HARDCODED_BPM
	timer.timeout.connect(_on_timeout)
	update_health_label()

func _on_timeout() -> void:
	$speaker_castle/AnimationPlayer.stop(false)
	$speaker_castle/AnimationPlayer.play("Loop")

func deal_damage(damage: float):
	health -= damage
	update_health_label()

func update_health_label():
	health_label.text = str(health).pad_decimals(0)

func reset_health():
	health = total_health
