@tool
class_name SyncPlayer
extends AnimationPlayer

@export var dummy_player: AudioStreamPlayer
@export var animation_library: AnimationLibrary
@export var animation: Animation

@export var animation_name: String

func init_animation(audio_stream: AudioStream, stream_name: String) -> void:
	if not audio_stream:
		return
	if has_animation_library(""):
		animation_library = get_animation_library("")
	else:
		animation_library = AnimationLibrary.new()
		add_animation_library("", animation_library)
	if animation_library.has_animation(stream_name):
		print("Animation already exists: ", stream_name)
		return
	var anim := Animation.new()
	anim.length = audio_stream.get_length()
	anim.loop = true
	var audio_track_index := anim.add_track(Animation.TYPE_AUDIO)
	var dummy_name := "dummy_" + stream_name
	if not dummy_player:
		dummy_player = AudioStreamPlayer.new()
		dummy_player.name = dummy_name
		dummy_player.stream = audio_stream
		add_child(dummy_player)
		dummy_player.owner = self.owner
	anim.track_set_path(audio_track_index, dummy_player.get_path())
	anim.audio_track_insert_key(audio_track_index, 0.0, audio_stream)
	var method_track_index := anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(method_track_index, get_path())
	animation_library.add_animation(stream_name, anim)
	animation_name = stream_name
	animation = anim

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if dummy_player:
		dummy_player.process_mode = Node.PROCESS_MODE_DISABLED

func dummy_hit() -> void:
	pass

func dummy_hold(duration: float) -> void:
	pass

func dummy_spam(duration: float) -> void:
	pass
