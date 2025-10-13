@tool
extends HBoxContainer

var ui_notes: Array[UINote]

@onready var lane_control: Control = %LaneControl

@export var notes_color: Color = Color.RED:
	set(value):
		notes_color = value
		update_ui_notes()

func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		update_ui_notes()
	elif what == NOTIFICATION_READY:
		update_ui_notes()

func update_ui_notes() -> void:
	if not is_inside_tree() or not lane_control:
		return
	ui_notes.clear()
	for child in lane_control.get_children():
		var ui_note := child as UINote
		if ui_note:
			ui_notes.append(ui_note)
			ui_note.color = notes_color