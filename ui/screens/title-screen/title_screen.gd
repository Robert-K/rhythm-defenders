extends Control

signal start_game()
signal show_credits()
signal show_level_select()
signal show_settings_screen()
signal quit()

# When true, the running intro will be skipped on next frame
var _skip_requested: bool = false

func _on_start_pressed() -> void:
	$AnimationPlayer.play("start")
	$"3D World/enemy_ear/AnimationPlayer".play("Walk")

	# If a keyboard key is pressed while the animation is running, skip the
	# remainder of the intro, stop the animations, and start the game immediately.
	_skip_requested = false
	while $AnimationPlayer.is_playing():
		if _skip_requested:
			# Stop playing the animations so they don't continue after freeing
			$AnimationPlayer.stop()
			$"3D World/enemy_ear/AnimationPlayer".stop()
			break
		
		# wait one frame and check again
		await get_tree().process_frame
	
	# Start game
	start_game.emit()
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	# Handle inputs to skip intro
	if event is InputEventKey and event.pressed and not event.echo:
		_skip_requested = true

func _on_credit_pressed() -> void:
	show_credits.emit()
	queue_free()

func _on_level_select_pressed() -> void:
	show_level_select.emit()
	queue_free()
	
func _on_options_pressed() -> void:
	show_settings_screen.emit()
	queue_free()

func _on_quit_pressed():
	quit.emit()
	queue_free()

func show_levels(b: bool) -> void:
	$UI/CenterContainer2/VBoxContainer/LevelSelect.visible = b
