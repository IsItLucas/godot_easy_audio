extends Node


## The main [AudioStreamPlayer] used to play the music.
var main_player: AudioStreamPlayer

## The [AudioStreamPlayer] used to transition from one song to another
## simultaneously.
var transition_player: AudioStreamPlayer


## The tween used to fade the music.
var fade_tween: Tween


enum Transitions {
	## Instantly switch music.
	NONE,
	
	## Smooth transition between tracks.
	CROSS_FADE,
	
	## Fade out the current music before switching.
	FADE_OUT
}


func _ready() -> void:
	# Create the AudioStreamPlayers.
	main_player = AudioStreamPlayer.new()
	add_child(main_player)
	
	transition_player = AudioStreamPlayer.new()
	add_child(transition_player)


## Plays the song specified in [param settings].
func play(settings: MusicSettings, from: float = 0.0) -> void:
	# Setup the main AudioStreamPlayer.
	main_player.bus = settings.bus
	main_player.volume_linear = settings.volume
	main_player.pitch_scale = settings.pitch_scale
	main_player.mix_target = settings.mix_target
	main_player.playback_type = settings.playback_type
	
	# Debug log.
	if Audio.DEBUG_LOG:
		if settings.transition == Transitions.NONE:
			print("Playing music %s at bus \"%s\" with volume and pitch, %s and %s, respectively" % [
				settings.path,
				settings.bus,
				str(settings.volume * 100.0) + "%",
				str(settings.pitch_scale) + "x",
			])
		else:
			print("Transitioning to music %s at bus \"%s\" with volume and pitch, %s and %s, respectively with transition type %s" % [
				settings.path,
				settings.bus,
				str(settings.volume * 100.0) + "%",
				str(settings.pitch_scale) + "x",
				str(["None", "Crossfade", "Fadeout"][int(settings.transition)]),
			])
	
	# Check if a transition should be applied.
	if settings.transition == Transitions.NONE:
		# Instantly play the new song.
		main_player.stream = load(settings.path)
		main_player.play(from)
		
		# Stop the transition AudioStreamPlayer if necessary.
		if transition_player.playing:
			transition_player.stop()
		
		# Stop the code right here.
		return
	
	# Setup the secondary AudioStreamPlayer.
	transition_player.volume_db = main_player.volume_db
	transition_player.pitch_scale = main_player.pitch_scale
	transition_player.mix_target = main_player.mix_target
	transition_player.playback_type = main_player.playback_type
	
	# Store the target volume.
	var target_volume: float = settings.volume
	
	# Transition the song.
	match settings.transition:
		# Fade out the current music before playing the new one.
		Transitions.FADE_OUT:
			# Remove any existing tweens.
			if fade_tween:
				fade_tween.kill()
				fade_tween = null
			
			# Fade out the current song.
			if main_player.playing:
				fade_tween = get_tree().create_tween()
				fade_tween.tween_property(main_player, ^"volume_linear", 0.0, settings.duration)
			
				# Wait until the fade out is completed.
				await fade_tween.finished
			
			# Load the new music.
			main_player.stream = load(settings.path)
			transition_player.stream = main_player.stream
			
			# Play the new music.
			main_player.play(from)
			
			# Fade in the new song.
			fade_tween = get_tree().create_tween()
			fade_tween.tween_property(main_player, ^"volume_linear", target_volume, settings.duration)
		
		# Fade out the current music while the new one fades in.
		Transitions.CROSS_FADE:
			# Remove any existing tweens.
			if fade_tween:
				fade_tween.kill()
				fade_tween = null
			
			# Update the transition AudioStreamPlayer.
			if main_player.playing:
				# Use the transition player to continue playing whatever is
				# currently playing.
				transition_player.stream = main_player.stream
				transition_player.play(main_player.get_playback_position())
				
				# Stop the main audio player.
				main_player.stop()
			
			# Load the new music.
			main_player.volume_linear = 0.0
			
			main_player.stream = load(settings.path)
			main_player.play(from)
			
			# Crossfade.
			fade_tween = get_tree().create_tween().set_parallel(true)
			fade_tween.tween_property(main_player, ^"volume_linear", target_volume, settings.duration)
			fade_tween.tween_property(transition_player, ^"volume_linear", 0.0, settings.duration)
			
			# Stop the transition player.
			await fade_tween.finished
			transition_player.stop()


## Fades out the song that is currently playing using [param fade_duration] as the fade duration.
## A fade duration of 0 will instantly stop the song.
func stop(fade_duration: float = 0.0) -> void:
	if fade_duration <= 0.0:
		# Stop the song instantly.
		main_player.stop()
		transition_player.stop()
	else:
		# Tween the volume to 0.
		if fade_tween:
				fade_tween.kill()
				fade_tween = null
		
		fade_tween = get_tree().create_tween().set_parallel(true)
		fade_tween.tween_property(main_player, ^"volume_linear", 0.0, fade_duration)
		fade_tween.tween_property(transition_player, ^"volume_linear", 0.0, fade_duration)


## An object that stores all AudioStreamPlayer settings that are used by Music.play().
class MusicSettings:
	## The transition type that is going to be used to switch to the given song.
	var transition: Transitions = Music.Transitions.NONE : set = set_transition
	
	## The duration of the transition.
	var duration: float = 1.0 : set = set_duration
	
	## The path or UID to the [AudioStream] resource to be played. [br]
	## Setting this property stops all currently playing sounds. If left empty, the [AudioStreamPlayer] does not work.
	var path: String = "" : set = set_path
	
	## The target bus name. All sounds from this node will be playing on this bus. [br][br]
	## [b]Note:[/b] At runtime, if no bus with the given name exists, all sounds will fall back on "Master". See also [method AudioServer.get_bus_name].
	var bus: String = "Music" : set = set_bus
	
	## Volume of sound, as a linear value. [br][br]
	## [b]Note:[/b] This member modifies [member AudioStreamPlayer.volume_db] for convenience.
	## The returned value is equivalent to the result of [method @GlobalScope.db_to_linear] on [member AudioStreamPlayer.volume_db].
	## Setting this member is equivalent to setting [member AudioStreamPlayer.volume_db] to the result of [method @GlobalScope.linear_to_db] on a value.
	var volume: float = 1.0 : set = set_volume
	
	## The audio's pitch and tempo, as a multiplier of the [AudioStream]'s sample rate. [br][br]
	## A value of [code]2.0[/code] doubles the audio's pitch, while a value of [code]0.5[/code] halves the pitch.
	var pitch_scale: float = 1.0 : set = set_pitch_scale
	
	## The mix target channels, as one of the [member AudioStreamPlayer.MixTarget] constants. [br]
	## Has no effect when two speakers or less are detected (see [member AudioServer.SpeakerMode]).
	var mix_target: AudioStreamPlayer.MixTarget = AudioStreamPlayer.MixTarget.MIX_TARGET_STEREO : set = set_mix_target
	
	## @experimental
	## The playback type of the stream player. [br]
	## If set other than to the default value, it will force that playback type.
	var playback_type: AudioServer.PlaybackType = AudioServer.PlaybackType.PLAYBACK_TYPE_DEFAULT : set = set_playback_type
	
	
	## Updates the [AudioStream] resource path or UID and returns the updated [Music.MusicSettings] for convenience.
	func set_path(_path: String) -> MusicSettings:
		path = _path
		return self
	
	
	## Updates the target bus name and returns the updated [Music.MusicSettings] for convenience.
	func set_bus(_bus: String) -> MusicSettings:
		bus = _bus
		return self
	
	
	## Updates the linear volume and returns the updated [Music.MusicSettings] for convenience.
	func set_volume(_volume: float) -> MusicSettings:
		volume = _volume
		return self
	
	
	## Updates the pitch scale and returns the updated [Music.MusicSettings] for convenience.
	func set_pitch_scale(_pitch_scale: float) -> MusicSettings:
		pitch_scale = _pitch_scale
		return self
	
	
	## Updates the mix target and returns the updated [Music.MusicSettings] for convenience.
	func set_mix_target(_mix_target: AudioStreamPlayer.MixTarget) -> MusicSettings:
		mix_target = _mix_target
		return self
	
	
	## Updates the playback type and returns the updated [Music.MusicSettings] for convenience.
	func set_playback_type(_playback_type: AudioServer.PlaybackType) -> MusicSettings:
		playback_type = _playback_type
		return self
	
	
	## Updates the transition type of the song and returns the updated [Music.MusicSettings] for convenience.
	func set_transition(_transition: Transitions) -> MusicSettings:
		transition = _transition
		return self
	
	## Updates the duration of the transition and returns the updated [Music.MusicSettings] for convenience.
	func set_duration(_duration: float) -> MusicSettings:
		duration = _duration
		return self
