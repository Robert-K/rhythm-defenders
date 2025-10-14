extends Node
class_name Map

var enemies: Array[Enemy] = []

@onready var enemy = preload("res://game_world/enemies/enemy.tscn")
@onready var path: Path3D = $Path3D

func _ready() -> void:
	get_tree().create_timer(2).timeout.connect(spawn_enemy)

func spawn_enemy():
	var enemy : Enemy = enemy.instantiate()
	path.add_child(enemy)
	enemies.append(enemy)
