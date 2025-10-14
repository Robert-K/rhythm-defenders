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
	position.x -= delta * pixels_per_second
	if position.x < -duration * pixels_per_second:
		position.x += track_length * pixels_per_second * repetition