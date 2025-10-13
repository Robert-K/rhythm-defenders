extends Node3D
class_name Tower

@export var damage: int = 10
@export var radius: float = 1000

func _ready() -> void:
	fire()

var delta: float = 0

func _process(_delta):
	delta += _delta
	if (delta > 1):
		delta = 0
		fire()

func fire() -> void:
	print("fire")
