@tool
class_name UINote
extends Control

@onready var note_panel: Panel = %NotePanel
@onready var spam_overlay: Control = %SpamOverlay

@export var spam: bool = false:
	set(value):
		spam = value
		if spam_overlay:
			spam_overlay.visible = spam

var expended: bool = false
var hold_me: bool = false
var holding: bool = false

@export var pixels_per_second: float = 100.0

@export var sync_player: SyncPlayer

@export var track_length: float = 1000.0

@export var repetition: int = 1

@export var duration: float = 0.5:
	set(value):
		duration = value
		if not note_panel:
			return
		note_panel.size.x = duration * pixels_per_second
		spam_overlay.size.x = duration * pixels_per_second

@export var color: Color = Color.RED:
	set(value):
		color = value
		if not note_panel:
			return
		var stylebox := note_panel.get_theme_stylebox("panel")
		stylebox.bg_color = color

var note_time: float = 0.0
var original_x: float

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if note_panel:
		var stylebox := note_panel.get_theme_stylebox("panel")
		stylebox.bg_color = color
		note_panel.size.x = duration * pixels_per_second
		spam_overlay.size.x = duration * pixels_per_second
	if spam_overlay:
		spam_overlay.visible = spam
	original_x = position.x

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var target_time := fposmod(note_time - sync_player.current_animation_position + duration, sync_player.animation.length) - duration
	var target_x := target_time * pixels_per_second
	position.x = target_x
	if position.x > 600.0:
		expended = false