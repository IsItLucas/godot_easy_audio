extends Node


## Music AudioStreamPlayerPlus node.
@onready var MusicPlayer := AudioStreamPlayerPlus.new()


## Dictionary to store preloaded AudioStreamPlayerPlus instances by tag or path.
var loaded_sfx: Dictionary[StringName, AudioStreamPlayerPlus] = {}


## Enum defining different music fade transition types.
enum MusicFadeTypes {
	## Instantly switch music.
	NONE,
	
	## Smooth transition between tracks.
	CROSS_FADE,
	
	## Fade out the current music before switching.
	FADE_OUT
}


func _ready() -> void:
	# Music Player setup.
	MusicPlayer.name = "MusicPlayer"
	add_child(MusicPlayer)


## Cleans up temporary sounds when playback finishes.
func _on_audio_player_finished(audio_player: AudioStreamPlayerPlus, tag: StringName) -> void:
	# Free the player instance.
	audio_player.queue_free()
	
	# Get debug log state.
	var debug_log: bool = AudioHelper.get_setting("debug_log", true)
	if debug_log:
		print("Cleaning up %s (%s)" % [str(audio_player), tag])
	
	# Check if the audio tag is still loaded.
	if not loaded_sfx.has(tag):
		return
	
	# Check if the loaded audio is the same as the audio that just finished playing.
	if loaded_sfx[tag] != audio_player:
		return
	
	# Remove the player from the dictionary.
	loaded_sfx.erase(tag)


## Play a music track from the given path.
func play_music(path: String, from_position: float = 0.0) -> void:
	# Debug log.
	var debug_log: bool = AudioHelper.get_setting("debug_log", true)
	if debug_log:
		print("Loading and playing music \"%s\"." % path)
	
	# Load the music.
	load_music(path)
	MusicPlayer.play(from_position)
	
	# Update music playback bus.
	var default_bus: StringName = AudioHelper.get_setting("audio/default_music_bus", &"Music")
	if AudioServer.get_bus_index(default_bus) > -1:
		MusicPlayer.bus = default_bus
	else:
		push_error("Could not find bus named \"%s\". Using \"Master\" instead." % default_bus)


## Plays a sound effect by its path or tag.
func play_sfx(path_or_tag: String, settings: AudioSettings = null) -> void:
	# Get debug log state.
	var debug_log: bool = AudioHelper.get_setting("debug_log", true)
	
	# Check if the SFX is already loaded.
	if loaded_sfx.has(path_or_tag):
		# Play ig already loaded.
		loaded_sfx[path_or_tag].play()
		
		# Debug log.
		if debug_log:
			print("Playing preloaded SFX \"%s\"." % path_or_tag)
		
		# Stop the function here.
		return
	
	# Debug log.
	if debug_log:
		print("Playing and loading SFX \"%s\"." % path_or_tag)
	
	# Load audio player.
	var audio_player := load_sfx(path_or_tag, path_or_tag, settings)
	
	# Play after loading.
	if audio_player:
		audio_player.play()
	else:
		push_error("Failed to play audio with tag or path \"%s\"." % path_or_tag)


## Loads a music stream from the given path.
func load_music(path: String) -> void:
	MusicPlayer.stream = load(path)
	if MusicPlayer.stream == null:
		push_error("Could not load music stream \"%s\"." % path)


## Loads a sound effect and adds it to the loaded streams.
func load_sfx(tag: StringName, path: String, settings: AudioSettings = null) -> AudioStreamPlayerPlus:
	# Return if already loaded.
	if loaded_sfx.has(tag):
		push_warning("Tried to load an already loaded AudioStreamPlayerPlus with tag \"%s\"." % tag)
		return loaded_sfx[tag]
	
	var audio_player := AudioStreamPlayerPlus.new() # Create a new player.
	add_child(audio_player)
	
	# Apply audio settings.
	if settings:
		audio_player.apply_settings(settings)
	else:
		audio_player.bus = AudioHelper.get_setting("audio/default_sfx_bus")
	
	audio_player.name = tag
	
	# Load the audio stream.
	audio_player.stream = load(path)
	if not audio_player.stream:
		push_error("Failed to load audio at path \"%s\"." % path)
		return null
	
	# Store the audio stream player in the dictionary.
	loaded_sfx[tag] = audio_player
	
	# Clean up non-persistent sounds.
	if not settings.is_persistent:
		audio_player.finished.connect(_on_audio_player_finished.bind(audio_player, tag))
	
	# Debug log.
	var debug_log: bool = AudioHelper.get_setting("debug_log", true)
	if debug_log:
		print("Loaded SFX \"%s\" as \"%s\"." % [path, tag])
	
	# Return the recently loaded audio stream player.
	return audio_player


## Changes music with a specified fade transition.
func fade_music_to(path: String, fade_type: MusicFadeTypes, fade_duration: float) -> void:
	match fade_type:
		# Instantly switch music.
		MusicFadeTypes.NONE:
			play_music(path)
		
		# Smooth transition between tracks.
		MusicFadeTypes.CROSS_FADE:
			# Create a duplicate of the music player to crossfade to the new track.
			var dummy_player: AudioStreamPlayerPlus = MusicPlayer.duplicate()
			dummy_player.name = "DummyMusicPlayer"
			add_child(dummy_player)
			
			# Setup the dummy music player.
			dummy_player.stream = MusicPlayer.stream
			dummy_player.play(MusicPlayer.get_playback_position())
			dummy_player.fade_linear(0.0, fade_duration)
			
			# Load and play next music.
			load_music(path)
			MusicPlayer.play()
			
			MusicPlayer.volume_linear = 0.0
			MusicPlayer.fade_linear(1.0, fade_duration)
			
			# Clean up dummy music player.
			await MusicPlayer.fade_completed
			dummy_player.finished.connect(func _clean_up_dummy_music_player() -> void:
				dummy_player.queue_free()
			)
		
		# Fade out the current music before switching.
		MusicFadeTypes.FADE_OUT:
			# Fade out current music before switching.
			MusicPlayer.fade_linear(0.0, fade_duration / 2.0)
			await MusicPlayer.fade_completed
			
			# Load and play next music.
			load_music(path)
			
			MusicPlayer.play()
			MusicPlayer.fade_linear(1.0, fade_duration / 2.0)


## Unloads all loaded sound effects.
func unload_all_sfx() -> void:
	for tag: StringName in loaded_sfx:
		var audio_player := loaded_sfx[tag]
		audio_player.queue_free()
