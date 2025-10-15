extends Node3D
class_name Map

var _enemies: Array[Enemy] = []

@onready var enemy_scene = preload("res://game_world/enemies/enemy.tscn")
@onready var path: Path3D = $Path3D
@onready var castle: Castle = $SpeakerCastle

@export var enemy_spawn_interval: float = 0.75
@export var enemy_spawn_base: int = 6
@export var enemy_spawn_round_mult: float = 2
@export var enemy_spawn_group_size: int = 10
@export var time_between_groups: float = 4

var enemy_count_total = 1
var enemy_count_spawned = 0

var round: int = 1

var timer: Timer

signal round_completed
signal lost

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)

func start(round: int) -> void:
	enemy_count_spawned = 0
	enemy_count_total = get_enemy_count(round)
	
	spawn_enemy()
	start_timer()

func start_timer():
	timer.wait_time = enemy_spawn_interval
	timer.one_shot = false
	timer.timeout.connect(spawn_enemy)
	timer.start()

func stop_timer():
	timer.stop()
	timer.timeout.disconnect(spawn_enemy)

func get_enemy_count(current_round: int) -> int:
	return enemy_spawn_base + current_round * enemy_spawn_round_mult

func spawn_enemy():
	if (enemy_count_spawned >= enemy_count_total):#
		stop_timer()
		return
	
	if (enemy_count_spawned != 0 && (enemy_count_spawned % enemy_spawn_group_size) == 0):
		timer.paused = true
		await get_tree().create_timer(time_between_groups).timeout
		timer.paused = false
	
	var enemy : Enemy = enemy_scene.instantiate()
	path.add_child(enemy)
	enemy.enemy_defeated.connect(destroy_enemy)
	enemy.enemy_at_destination.connect(destination_reached)
	_enemies.append(enemy)
	enemy_count_spawned += 1

func destroy_enemy(enemy: Enemy):
	_enemies.erase(enemy)
	enemy.queue_free()
	
	if (enemy_count_spawned == enemy_count_total && _enemies.size() == 0):
		round_completed.emit()

func get_enemies() -> Array[Enemy]:
	for enemy in _enemies:
		if !is_instance_valid(enemy):
			_enemies.erase(enemy)
	
	return _enemies.duplicate()

func destination_reached(enemy: Enemy):
	castle.deal_damage(enemy.damage)
	destroy_enemy(enemy)
	if (castle.health <= 0):
		loose()

func loose():
	stop_timer()
	for enemy in get_enemies():
		destroy_enemy(enemy)
	
	lost.emit()
