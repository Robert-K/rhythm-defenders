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
@export var music_speed_increase_every_x_rounds: int = 3
@export var music_speed_increase_percentage: float = 0.15

var enemy_count_total = 1
var enemy_count_spawned = 0

var round: int = 1

var timer: Timer

signal round_completed
signal enemey_defeated
signal lost

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)

func start(round: int) -> void:
	enemy_count_spawned = 0
	enemy_count_total = get_enemy_count(round)
	
	# Music speed
	var music_speed = 1.0 + music_speed_increase_percentage * (round / music_speed_increase_every_x_rounds)
	MusicPlayer.set_speed(music_speed)
	
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
	var speed_increase_compensation =  1 + 0.25 * (current_round / music_speed_increase_every_x_rounds)
	return (enemy_spawn_base + current_round * enemy_spawn_round_mult) * speed_increase_compensation

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
	enemy.enemy_defeated.connect(defeat_enemy)
	enemy.enemy_at_destination.connect(destination_reached)
	_enemies.append(enemy)
	enemy.speed *= 1 + round / 10
	enemy.health *= 1 + round / 5
	enemy_count_spawned += 1

func defeat_enemy(enemy: Enemy):
	enemey_defeated.emit(enemy)
	destroy_enemy(enemy)
	
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
	castle.reset_health()
	
	lost.emit()
