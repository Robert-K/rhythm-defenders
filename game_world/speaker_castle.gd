extends Node3D
class_name Castle

const HARDCODED_BPM = 75.0

@onready var timer: Timer = $Timer

@onready var health_label: Label3D = $HealthLabel

@export var total_health: float = 100
var health: float = total_health

@export var vibration_duration_seconds: float = 1

func _ready() -> void:
	timer.wait_time = 60/HARDCODED_BPM / MusicPlayer.pitch_scale
	timer.timeout.connect(_on_timeout)
	update_health_label()

func _process(_delta: float) -> void:
	timer.wait_time = 60/HARDCODED_BPM / MusicPlayer.pitch_scale

func _on_timeout() -> void:
	$speaker_castle/AnimationPlayer.stop(false)
	$speaker_castle/AnimationPlayer.play("Loop")

func deal_damage(damage: float):
	health -= damage
	vibration()
	update_health_label()

func vibration():
	var strength = (total_health - health) / total_health
	print(strength)
	Input.vibrate_handheld((int) (1000 * vibration_duration_seconds), strength)
	for joypad_id in Input.get_connected_joypads():
		Input.start_joy_vibration(joypad_id, 1, strength, vibration_duration_seconds)

func update_health_label():
	health_label.text = str(health).pad_decimals(0)

func reset_health():
	health = total_health
