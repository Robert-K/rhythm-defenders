extends Node
class_name World

@export var build_ui: Control
@export var round_label: Label
@export var round_container: Container
@export var lost_screen: Control
@export var start_button: Button
@export var points_label: Label
@export var enemies_count_label: Label
var tower_buttons: Array[Button] # Filled with the buttons from button_ui

@export var drum_lane: TowerLane
@export var tube_lane: TowerLane
@export var maracas_lane: TowerLane
@export var flute_lane: TowerLane

@export var drum_points_label: Label
@export var tube_points_label: Label
@export var maracas_points_label: Label
@export var flute_points_label: Label

@onready var drum = preload("res://game_world/towers/drum/drum.tscn")
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

@export var points_per_round: int = 50
@export var starting_points: int = 50
var points: int = starting_points

var current_round: int = 1

var placed_towers: Array[Tower]

var game_mode: GameMode

var current_ghost_tower: Tower = null
var current_ghost_tower_placement_allowed = false

@export var joystick_sensitivity: float = 0.1

func _ready() -> void:
	assert(build_ui != null)
	for child in build_ui.get_children():
		assert(child is Button)
		tower_buttons.append(child)
	change_game_mode(GameMode.BUILD)
	new_level()

func change_game_mode(new_game_mode: GameMode):
	game_mode = new_game_mode
	if game_mode == GameMode.PLAY:
		$"../BuildModeOverlay".visible = false
		play()
	elif game_mode == GameMode.BUILD:
		$"../BuildModeOverlay".visible = true
		build()
	on_game_mode_changed.emit(game_mode)

func loose():
	update_points(starting_points)
	update_round(1)
	change_game_mode(GameMode.BUILD)#
	new_level()
	lost_screen.visible = true
	await get_tree().create_timer(3).timeout
	Global.game_manager._return_to_title_screen()

func round_completed():
	if (game_mode == GameMode.BUILD):
		return
	
	update_round(current_round + 1)
	change_game_mode(GameMode.BUILD)
	update_points(points + points_per_round)

func enemy_spawned(_enemy: Enemy):
	update_enemies_count()

func enemy_defeated(_enemy: Enemy):
	update_points(points + _enemy.point_reward)
	update_enemies_count()

func play():
	stop_build()
	
	current_map.lost.connect(loose)
	current_map.enemy_spawned.connect(enemy_spawned)
	current_map.enemy_defeated.connect(enemy_defeated)
	current_map.round_completed.connect(round_completed)
	current_map.start(current_round)
	update_enemies_count()

func new_level():
	# only set start visible when first tower is placed
	start_button.visible = false
	update_points(starting_points)
	for tower in placed_towers:
		tower.queue_free()
	placed_towers.clear()

func update_round(new_round: int):
	current_round = new_round
	round_label.text = str(new_round)

func update_points(new_points: int):
	points = new_points
	points_label.text = str(new_points)

func update_enemies_count():
	enemies_count_label.text = str(current_map.enemy_count_total - current_map.enemy_count_defeated - current_map.enemy_count_reached) + "/" + str(current_map.enemy_count_total)

func build():
	round_container.visible = false
	enemies_count_label.visible = false
	build_ui.visible = true
	start_button.visible = true

func stop_build():
	round_container.visible = true
	enemies_count_label.visible = true
	build_ui.visible = false
	start_button.visible = false
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

func get_last_enemy(pos: Vector3, max_dist: float) -> Enemy:
	var closest = null
	var min_ratio = 0
	for enemy: Enemy in current_map.get_enemies():
		if (enemy == null):
			continue
		
		var dist = 	enemy.global_position.distance_to(pos)
		if (dist > max_dist):
			continue
		
		if (closest == null || min_ratio > enemy.path_tween.get_loops_left()):
			closest = enemy
			min_ratio = enemy.path_tween.get_loops_left()
	
	return closest

func _process(_delta: float) -> void:
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
	
	if is_instance_valid(current_ghost_tower):
		if (Input.get_connected_joypads().size() == 0):
			move_tower_to_mouse()
		else:
			var x = Vector3(1, 0, 0) * joystick_sensitivity * Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
			var y = Vector3(0, 0, 1) * joystick_sensitivity * Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
			if (x.length() < 0.05):
				x = Vector3.ZERO
			if (y.length() < 0.05):
				y = Vector3.ZERO
			
			var new_pos = current_ghost_tower.global_position + x + y
			update_ghost_tower_position(new_pos)
	else:
		current_ghost_tower_placement_allowed = false

func start_placing_tower(tower_scene: PackedScene):
	if (current_ghost_tower != null):
		cancel_tower()
	
	current_ghost_tower = tower_scene.instantiate()
	
	if (is_instance_of(current_ghost_tower, Drum)):
		if (points < int(drum_points_label.text)):
			current_ghost_tower.queue_free()
			return
	
	if (is_instance_of(current_ghost_tower, Tube)):
		if (points < int(tube_points_label.text)):
			current_ghost_tower.queue_free()
			return
	
	if (is_instance_of(current_ghost_tower, Maracas)):
		if (points < int(maracas_points_label.text)):
			current_ghost_tower.queue_free()
			return
	
	if (is_instance_of(current_ghost_tower, Flute)):
		if (points < int(flute_points_label.text)):
			current_ghost_tower.queue_free()
			return
	
	current_ghost_tower.set_placement_preview(true)
	add_child(current_ghost_tower)
	enter_placement()

func move_tower_to_mouse():
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
		current_ghost_tower.visible = true
		update_ghost_tower_position(result.position)
	else:
		current_ghost_tower.visible = false

func find_closest_abs_pos(path3d: Path3D, global_pos: Vector3):
	var curve: Curve3D = path3d.curve

	# transform the target position to local space
	var path_transform: Transform3D = path3d.global_transform
	var local_pos: Vector3 = global_pos * path_transform.affine_inverse()

	# get the nearest offset on the curve
	return path_transform * curve.get_closest_point(local_pos)

func update_ghost_tower_position(new_pos: Vector3):
	var pos = find_closest_abs_pos(path, new_pos)
	
	# Collides with path
	if (new_pos.distance_to(pos) < 3):
		current_ghost_tower.global_position = new_pos
		current_ghost_tower_placement_allowed = false
		current_ghost_tower.set_placement_allowed(false)
		return
	
	# Collides with other tower
	if (current_ghost_tower.collision_area.get_overlapping_areas().is_empty() == false):
		current_ghost_tower.global_position = new_pos
		current_ghost_tower_placement_allowed = false
		current_ghost_tower.set_placement_allowed(false)
		return
	
	current_ghost_tower_placement_allowed = true
	current_ghost_tower.set_placement_allowed(true)
	current_ghost_tower.global_position = new_pos

func cancel_tower():
	if (current_ghost_tower == null):
		return
	
	leave_placement()
	current_ghost_tower.queue_free()

func place_tower():
	if (current_ghost_tower == null):
		return
	
	if (current_ghost_tower_placement_allowed == false):
		return
	
	if (is_instance_of(current_ghost_tower, Drum)):
		drum_lane.active = true
		var tower_points = int(drum_points_label.text)
		update_points(points - tower_points)
		drum_points_label.text = str(tower_points * 2)
	
	if (is_instance_of(current_ghost_tower, Tube)):
		tube_lane.active = true
		var tower_points = int(tube_points_label.text)
		update_points(points - tower_points)
		tube_points_label.text = str(tower_points * 2)
	
	if (is_instance_of(current_ghost_tower, Maracas)):
		maracas_lane.active = true
		var tower_points = int(maracas_points_label.text)
		update_points(points - tower_points)
		maracas_points_label.text = str(tower_points * 2)
	
	if (is_instance_of(current_ghost_tower, Flute)):
		flute_lane.active = true
		var tower_points = int(flute_points_label.text)
		update_points(points - tower_points)
		flute_points_label.text = str(tower_points * 2)
	
	current_ghost_tower.set_placement_preview(false)
	placed_towers.append(current_ghost_tower)
	if (placed_towers.size() > 0):
		start_button.visible = true
	
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
	start_placing_tower(drum)

func _on_button_tube_pressed() -> void:
	start_placing_tower(tube)

func _on_button_maracas_pressed() -> void:
	start_placing_tower(maracas)

func _on_button_flute_pressed() -> void:
	start_placing_tower(flute)

func _get_tower_of_type(type):
	var array: Array = []
	for tower in placed_towers:
		if is_instance_of(tower, type):
			array.append(tower)
	return array

func _on_drum_lane_fire() -> void:
	for tower in _get_tower_of_type(Drum):
		tower.fire()

func _on_drum_lane_miss() -> void:
	miss_note()

func _on_tube_lane_fire() -> void:
	for tower in _get_tower_of_type(Tube):
		tower.fire()


func _on_tube_lane_miss() -> void:
	miss_note()


func _on_maracas_lane_fire() -> void:
	for tower in _get_tower_of_type(Maracas):
		tower.fire()


func _on_maracas_lane_release() -> void:
	for tower in _get_tower_of_type(Maracas):
		tower.stop_firing()

func _on_maracas_lane_miss() -> void:
	miss_note()


func _on_flute_lane_fire() -> void:
	for tower in _get_tower_of_type(Flute):
		tower.fire()

func _on_flute_lane_miss() -> void:
	miss_note()

func miss_note():
	var enemies = current_map.get_enemies()
	if enemies.is_empty():
		return
	
	var enemy = enemies.pick_random()
	if (is_instance_valid(enemy)):
		enemy.speed_up_for(2.0)
