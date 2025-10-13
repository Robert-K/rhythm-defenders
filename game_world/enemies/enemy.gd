extends PathFollow3D
class_name Enemy

@export var health: int = 100

@export var speed: float = 100

func _ready() -> void:
	create_tween().tween_property(self, "progress_ratio", 1, 1000 / speed)
