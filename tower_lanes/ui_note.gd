@tool
class_name UINote
extends Control

@onready var note_panel: Panel = %NotePanel

@export var color: Color = Color.RED:
	set(value):
		color = value
		if not note_panel:
			return
		var stylebox := note_panel.get_theme_stylebox("panel")
		stylebox.bg_color = color