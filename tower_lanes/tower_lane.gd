@tool
extends HBoxContainer

var ui_notes: Array[UINote]

@export var ui_note_scene: PackedScene = preload("res://tower_lanes/ui_note.tscn")

@onready var lane_control: Control = %LaneControl
@onready var key_label: Label = %KeyLabel

@export var pixels_per_second: float = 100.0
var ticks_per_second: float = 188.0 / 96.0

@export var notes_color: Color = Color.RED:
	set(value):
		notes_color = value
		update_ui_notes()

@export var stream_index: int = 0

@export var key_label_text: String = "A":
	set(value):
		key_label_text = value
		if key_label:
			key_label.text = key_label_text

func _ready() -> void:
	if Engine.is_editor_hint():
		return	
	key_label.text = key_label_text
	key_label.modulate = notes_color
	update_ui_notes()
	MusicPlayer.play_clip(stream_index, true)
	var sync_player := MusicPlayer.sync_players[stream_index]
	var x_start := 0.0
	var repetition := 1
	for track_index in sync_player.animation.get_track_count():
		if sync_player.animation.track_get_type(track_index) == Animation.TYPE_METHOD:
			while repetition < 4:
				for key_index in sync_player.animation.track_get_key_count(track_index):
					var key_time := sync_player.animation.track_get_key_time(track_index, key_index)
					var method_name := sync_player.animation.method_track_get_name(track_index, key_index)
					var duration := 0.1
					if method_name == "dummy_hold" or method_name == "dummy_spam":
						duration = sync_player.animation.method_track_get_params(track_index, key_index)[0]
					var ui_note := ui_note_scene.instantiate() as UINote
					ui_note.pixels_per_second = pixels_per_second
					ui_note.position.x = x_start + key_time * pixels_per_second
					ui_note.color = notes_color
					ui_note.note_time = key_time + (repetition - 1) * sync_player.animation.length
					ui_note.duration = duration
					ui_note.track_length = sync_player.animation.length
					ui_note.spam = method_name == "dummy_spam"
					ui_note.sync_player = sync_player
					ui_note.repetition = repetition
					lane_control.add_child(ui_note)
				x_start += sync_player.animation.length * pixels_per_second
				repetition += 1

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

func update_ui_notes() -> void:
	if not is_inside_tree() or not lane_control:
		return
	ui_notes.clear()
	for child in lane_control.get_children():
		var ui_note := child as UINote
		if ui_note:
			ui_notes.append(ui_note)
			ui_note.color = notes_color
