@icon("res://addons/easy_audio/audio_player_plus/icon.png")
class_name AudioStreamPlayerPlus extends AudioStreamPlayer


## An extended version of AudioStreamPlayer with additional properties, methods and functionalities.
## This node's functionalities and syntax was made thinking of the usage with the Audio autoload from GEA - Godot Easy Audio.


signal fade_completed


## Determines if the audio player can pause when the game is paused.
@export var is_pausable: bool = true : set = set_pausable

## Allows multiple instances of the same sound to play simultaneously.
@export var allow_clipping: bool = false : set = set_clipping


## Applies the given [param settings] to this [class AudioStreamPlayerPlus].
func apply_settings(settings: AudioSettings) -> void:
	# Apply built-in settings.
	if AudioServer.get_bus_index(settings.bus) > -1:
		bus = settings.bus
	else:
		push_error("Could not find bus named \"%s\". Using \"Master\" instead." % settings.bus)
	
	if settings.pitch_scale > 0:
		pitch_scale = settings.pitch_scale
	else:
		push_error("\"pitch_scale\" must be a positive number.")
	
	volume_db = settings.volume_db
	volume_linear = settings.volume_linear
	
	# Aplly custom settings.
	set_pausable(settings.is_pausable)
	set_clipping(settings.allow_clipping)


## Fades this [class AudioStreamPlayerPlus]' [member volume_linear] to [param target_linear] with a duration of [param duration_secs] seconds.
func fade_linear(target_linear: float, duration_secs: float) -> void:
	# Tween the volume.
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, ^"volume_linear", target_linear, duration_secs)
	
	# Emit a signal.
	await tween.finished
	fade_completed.emit()


## Fades this [class AudioStreamPlayerPlus]' [member volume_db] to [param target_linear] with a duration of [param duration_secs] seconds.
func fade_db(target_db: float, duration_secs: float) -> void:
	# Tween the volume.
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, ^"volume_db", target_db, duration_secs)
	
	# Emit a signal.
	await tween.finished
	fade_completed.emit()


## Sets whether this [class AudioStreamPlayerPlus] should be pausable.
func set_pausable(pausable: bool) -> void:
	# Update the pausable state.
	is_pausable = pausable
	
	# Adjust the process mode based on the pausable state.
	if is_pausable:
		process_mode = Node.PROCESS_MODE_PAUSABLE
	else:
		process_mode = Node.PROCESS_MODE_ALWAYS


## Sets whether this [class AudioStreamPlayerPlus] allows sound clipping.
func set_clipping(clipping: bool) -> void:
	# Update the clipping state.
	allow_clipping = clipping
	
	# Adjust the maximum polyphony based on the clipping state.
	if allow_clipping:
		# Allow up to the configured max overlapping sounds.
		var max_clipping: int = AudioHelper.get_setting("audio/max_clipping", 64)
		max_polyphony = max_clipping
	else:
		# Restrict to a single instance.
		max_polyphony = 1
