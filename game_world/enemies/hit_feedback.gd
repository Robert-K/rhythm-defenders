extends Label3D

@export var random_names: Array[String]
@export var duration: float = 1
@export var fly_up: Vector3 = Vector3.UP
@export var color: Color = Color.RED
@export var size: float = 0.5

func _ready() -> void:
	text = random_names.pick_random()
	var tween = create_tween()
	tween.tween_property(self, "position", fly_up, duration)
	tween.tween_property(self, "modulate", color, duration)
	tween.tween_property(self, "scale", Vector3.ONE * size, duration)
	tween.tween_callback(self.queue_free)
