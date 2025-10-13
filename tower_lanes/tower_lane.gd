@tool
extends HBoxContainer

var ui_notes: Array[UINote]

@onready var lane_control: Control = %LaneControl
@onready var midi_player: MidiPlayer = %MidiPlayer
@onready var audio_player: AudioStreamPlayer = %AudioStreamPlayer

@export var notes_color: Color = Color.RED:
	set(value):
		notes_color = value
		update_ui_notes()

@export var music_clip: MusicClip:
	set(value):
		music_clip = value
		if audio_player:
			audio_player.stream = music_clip.audio_stream
		if midi_player:
			midi_player.midi = music_clip.midi_file

func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		update_ui_notes()
	elif what == NOTIFICATION_READY:
		update_ui_notes()
		if music_clip:
			if audio_player:
				audio_player.stream = music_clip.audio_stream
			if midi_player:
				midi_player.midi = music_clip.midi_file
				midi_player.note.connect(on_note_event)
		if audio_player and audio_player.stream and midi_player:
			midi_player.link_audio_stream_player([audio_player])
			if not Engine.is_editor_hint():
				midi_player.play()

func update_ui_notes() -> void:
	if not is_inside_tree() or not lane_control:
		return
	ui_notes.clear()
	for child in lane_control.get_children():
		var ui_note := child as UINote
		if ui_note:
			ui_notes.append(ui_note)
			ui_note.color = notes_color

func on_note_event(event, track):
	if (event['subtype'] == MIDI_MESSAGE_NOTE_ON): # note on
		pass
	elif (event['subtype'] == MIDI_MESSAGE_NOTE_OFF): # note off
		pass

	print("[Track: " + str(track) + "] Note played: " + str(event['note']))