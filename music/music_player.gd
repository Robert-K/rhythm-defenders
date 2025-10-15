@tool
extends AudioStreamPlayer

@onready var sync_stream: AudioStreamSynchronized = stream

var sync_players: Array[SyncPlayer] = []

func play_clip(index: int, do_play: bool = true) -> void:
	if index < sync_stream.stream_count:
		var full_vol := 0.0
		if index == 8:
			full_vol = -6.0
		if index == 5:
			full_vol = 7.0
		sync_stream.set_sync_stream_volume(index, full_vol if do_play else -60.0)
	if do_play and not playing:
		play()

func get_time() -> float:
	if sync_stream and playing:
		return sync_stream.get_playback_position()
	return 0.0

@export_tool_button("Init animations") var button_init_animations := init_animations

@export_tool_button("Clean animations") var button_clean_animations := clean_animations

func _ready() -> void:
	for child in get_children():
		var sync_player := child as SyncPlayer
		if sync_player and not sync_players.has(sync_player):
			sync_players.append(sync_player)

func clean_animations() -> void:
	for player in sync_players:
		var animation_library := player.get_animation_library("")
		if animation_library:
			for anim_name in animation_library.get_animation_list():
				var anim := animation_library.get_animation(anim_name)
				if anim:
					for track_index in anim.get_track_count():
						if anim.track_get_type(track_index) == Animation.TYPE_AUDIO:
							anim.remove_track(track_index)

func init_animations() -> void:
	if sync_players.size() > 0:
		for player in sync_players:
			player.queue_free()
		sync_players.clear()
		await get_tree().process_frame
		await get_tree().process_frame
	if not sync_stream:
		return
	sync_players.resize(sync_stream.stream_count)
	for i in sync_stream.stream_count:
		var sub_stream := sync_stream.get_sync_stream(i)
		var stream_name := sub_stream.resource_path.split("/")[-1].split(".")[0]
		var sync_player := SyncPlayer.new()
		sync_player.name = "SyncPlayer_" + stream_name
		add_child(sync_player)
		sync_player.owner = self
		sync_players[i] = sync_player
		sync_player.init_animation(sub_stream, stream_name)

func _process(_delta: float) -> void:
	var playback_position := get_playback_position()
	if sync_stream and playing:
		for i in sync_stream.stream_count:
			var volume := sync_stream.get_sync_stream_volume(i)
			if volume > -30.0:
				var sync_player := sync_players[i]
				sync_player.current_animation = sync_player.animation_name
				var player_time := sync_player.current_animation_position
				var target_time := playback_position # fmod(playback_position, sub_stream.get_length())
				var time_diff := target_time - player_time
				if time_diff < 0.0:
					sync_player.active = true
					sync_player.seek(target_time)
					print("SyncPlayer %s time: %.3f (target: %.3f, diff: %.3f)" % [
						sync_player.name, player_time, target_time, time_diff
					])
				else:
					sync_player.active = false
					sync_player.advance(time_diff)
