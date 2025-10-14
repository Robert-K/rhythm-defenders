extends Node
class_name Map

var _enemies: Array[Enemy] = []

@export var map_health: float = 100

@onready var enemy = preload("res://game_world/enemies/enemy.tscn")
@onready var path: Path3D = $Path3D
@onready var timer: Timer = Timer.new()

func _ready() -> void:
	# Create a timer node
	var timer: Timer = Timer.new()
	# Add it to the scene as a child of this node
	add_child(timer)
	# Configure the timer
	timer.wait_time = 5.0 # How long we're waiting
	timer.one_shot = false # trigger once or multiple times
	# Connect its timeout signal to a function we want called
	timer.timeout.connect(spawn_enemy)
	# Start the timer
	timer.start()
	
	# Already place first enemy
	spawn_enemy()

func spawn_enemy():
	var enemy : Enemy = enemy.instantiate()
	path.add_child(enemy)
	enemy.enemy_defeated.connect(destroy_enemy)
	enemy.enemy_at_destination.connect(destination_reached)
	_enemies.append(enemy)

func destroy_enemy(enemy: Enemy):
	_enemies.erase(enemy)
	enemy.queue_free()

func get_enemies() -> Array[Enemy]:
	for enemy in _enemies:
		if !is_instance_valid(enemy):
			_enemies.erase(enemy)
	
	return _enemies

func destination_reached(enemy: Enemy):
	map_health -= enemy.damage
	if (map_health <= 0):
		print("YOU LOST!")
