extends Node
class_name World

@export var build_ui: Control
@export var start_button: Button
@export var tower_buttons: Array[Button]

@onready var drum = preload("res://game_world/towers/bass_drum/bass_drum_canon.tscn")
@onready var maracas = preload("res://game_world/towers/maracas/maracas.tscn")
@onready var tube = preload("res://game_world/towers/tube/tube.tscn")
@onready var flute = preload("res://game_world/towers/flute/flute.tscn")

@onready var path = $Map1/Path3D

@onready var current_map: Map = $Map1

enum GameMode {
	BUILD,
	PLAY
}

signal on_game_mode_changed

var game_mode: GameMode

var current_ghost_tower: Tower = null

func _ready() -> void:
	assert(build_ui != null)
	change_game_mode(GameMode.BUILD)

func change_game_mode(new_game_mode: GameMode):
	game_mode= new_game_mode
	if game_mode == GameMode.PLAY:
		play()
	elif game_mode == GameMode.BUILD:
		build()
	on_game_mode_changed.emit(game_mode)

func play():
	stop_build()
	current_map.start()

func build():
	build_ui.visible = true

func stop_build():
	build_ui.visible = false
	if (current_ghost_tower != null):
		cancel_tower()

func _on_start_button_pressed() -> void:
	change_game_mode(GameMode.PLAY)

func get_closest_enemy(pos: Vector3) -> Enemy:
	var closest = null
	var closest_dist = Vector3.INF
	for enemy: Enemy in current_map.get_enemies():
		if (enemy == null):
			continue
		
		var dist = 	enemy.global_position.distance_to(pos)
		if (closest == null || dist < closest_dist):
			closest = enemy
			closest_dist = dist
	
	return closest

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("click")):
		place_tower()
	
	if (Input.is_action_just_pressed("click_secondary")):
		cancel_tower()
	
	if (Input.is_action_just_pressed("scroll_down")):
		if (is_instance_valid(current_ghost_tower)):
			current_ghost_tower.rotate_y(-PI / 2)
	
	if (Input.is_action_just_pressed("scroll_up")):
		if (is_instance_valid(current_ghost_tower)):
			current_ghost_tower.rotate_y(PI / 2)
	
	update_tower()

func start_placing_tower(tower_scene: PackedScene):
	if (current_ghost_tower != null):
		cancel_tower()
	
	enter_placement()
	current_ghost_tower = tower_scene.instantiate()
	add_child(current_ghost_tower)

func update_tower():
	if (current_ghost_tower == null):
		return
	
	var viewport := get_viewport()
	var mouse_position := viewport.get_mouse_position()
	var camera := viewport.get_camera_3d()
	var origin := camera.project_ray_origin(mouse_position)
	var direction := camera.project_ray_normal(mouse_position)
	var ray_length := camera.far
	var end := origin + direction * ray_length
	var space_state := viewport.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	var result := space_state.intersect_ray(query)
	if (result.has("position")):
		print(result.position)
		var pos = find_closest_abs_pos(path, result.position)
		if (result.position.distance_to(pos) < 4):
			return
		var position: Vector3 = result.position;
		#current_ghost_tower.global_position = (Vector3i(position) / 3) * 3
		current_ghost_tower.global_position = result.position

func find_closest_abs_pos(path: Path3D, global_pos: Vector3):
	var curve: Curve3D = path.curve

	# transform the target position to local space
	#print(current_map.scale)
	var path_transform: Transform3D = path.global_transform#.scaled(Vector3(1/4, 1/4, 1/4))
	#print("path, transform", path_transform)
	var local_pos: Vector3 = (global_pos) * path_transform.scaled(Vector3(1,1,1)/16)

	# get the nearest offset on the curve
	return path_transform * curve.get_closest_point(local_pos)
	var offset: float = curve.get_closest_offset(local_pos)

	# get the local position at this offset
	var curve_pos: Vector3 = curve.sample_baked(offset, true)

	# transform it back to world space
	curve_pos = path_transform * curve_pos

	return curve_pos

func cancel_tower():
	if (current_ghost_tower == null):
		return
	
	leave_placement()
	current_ghost_tower.queue_free()

func place_tower():
	if (current_ghost_tower == null):
		return
	
	current_ghost_tower.collision.disabled = false
	current_ghost_tower = null
	leave_placement()

func enter_placement():
	start_button.disabled = true
	for button in tower_buttons:
		button.disabled = true

func leave_placement():
	start_button.disabled = false
	for button in tower_buttons:
		button.disabled = false

func _on_button_drum_pressed() -> void:
	print("drum")
	start_placing_tower(drum)

func _on_button_tube_pressed() -> void:
	start_placing_tower(tube)

func _on_button_maracas_pressed() -> void:
	start_placing_tower(maracas)

func _on_button_flute_pressed() -> void:
	start_placing_tower(flute)
