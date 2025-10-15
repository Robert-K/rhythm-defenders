@tool
extends HBoxContainer

var ui_notes: Array[UINote]

signal fire
signal release
signal miss

@export var input_name: String = "drum_trigger"

var tolerance: float = 0.2

@export var ui_note_scene: PackedScene = preload("res://tower_lanes/ui_note.tscn")

@onready var lane_control: Control = %LaneControl
@onready var key_label: Label = %KeyLabel

@export var pixels_per_second: float = 100.0
var ticks_per_second: float = 188.0 / 96.0

@export var notes_color: Color = Color.RED

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
	MusicPlayer.play_clip(stream_index, true)
	var sync_player := MusicPlayer.sync_players[stream_index]
	var x_start := 0.0
	var repetition := 1
	for track_index in sync_player.animation.get_track_count():
		if sync_player.animation.track_get_type(track_index) == Animation.TYPE_METHOD:
			for key_index in sync_player.animation.track_get_key_count(track_index):
				var key_time := sync_player.animation.track_get_key_time(track_index, key_index)
				var method_name := sync_player.animation.method_track_get_name(track_index, key_index)
				var duration := 0.1
				var ui_note := ui_note_scene.instantiate() as UINote
				if method_name == "dummy_hold" or method_name == "dummy_spam":
					duration = sync_player.animation.method_track_get_params(track_index, key_index)[0]
					ui_note.hold_me = true
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
				ui_notes.push_back(ui_note)
			# x_start += sync_player.animation.length * pixels_per_second
			# repetition += 1

var held_note: UINote = null

func _process(_delta: float) -> void:
	if ui_notes.size() == 0:
		return
	if Input.is_action_just_pressed(input_name):
		var hit_one: bool = false
		for ui_note in ui_notes:
			if absf(ui_note.position.x) < tolerance * pixels_per_second and not ui_note.expended:
				emit_signal("fire")
				ui_note.expended = true
				if ui_note.hold_me:
					ui_note.holding = true
					held_note = ui_note
				hit_one = true
				break
			elif ui_note.hold_me and not ui_note.expended and ui_note.position.x < 0.0 and ui_note.position.x + ui_note.duration * pixels_per_second > 0.0:
				emit_signal("fire")
				ui_note.holding = true
				held_note = ui_note
				ui_note.expended = true
				hit_one = true
				break
		if not hit_one:
			$AudioStreamPlayer.play()
			emit_signal("miss")
	if Input.is_action_just_released(input_name):
		for ui_note in ui_notes:
			if ui_note.holding:
				ui_note.holding = false
				held_note = null
				emit_signal("release")
				break
	if held_note and held_note.holding:
		if held_note.position.x < - held_note.duration * pixels_per_second:
			held_note.holding = false
			held_note = null
			emit_signal("release")