extends Node3D

const HARDCODED_BPM = 75.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = 60/HARDCODED_BPM
	timer.timeout.connect(_on_timeout)

func _on_timeout() -> void:
	$speaker_castle/AnimationPlayer.stop(false)
	$speaker_castle/AnimationPlayer.play("Loop")
