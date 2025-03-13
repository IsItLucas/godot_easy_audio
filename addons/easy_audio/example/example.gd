extends CanvasLayer


## This script showcases all functionalities of the GEA - Godot Easy Audio addon.
## Feel free to play around with the example script and scene to get to understand
## the addon ;)
##
## _ IsItLucas?


@onready var SoundOptionButton: OptionButton = %SoundOptionButton
@onready var TransitionOptionButton: OptionButton = %TransitionOptionButton

@onready var PersistentCheckbox: CheckBox = %PersistentCheckbox

@onready var AudioPitchSlider: HSlider = %AudioPitchSlider
@onready var AudioVolumeSlider: HSlider = %AudioVolumeSlider

@onready var MusicPitchSlider: HSlider = %MusicPitchSlider
@onready var MusicVolumeSlider: HSlider = %MusicVolumeSlider


var music_id: int = 0


func _on_sound_button_pressed() -> void:
	# Decide which sound should be played.
	var path: String
	match SoundOptionButton.selected:
		0: path = "uid://3l2m88pbn87a" # Explosion.
		1: path = "uid://rif8vf75pc4d" # Hit.
		2: path = "uid://dhfdovs23evjv" # Jump.
		3: path = "uid://cx3toadkeb7yu" # Select.
	
	# Play the sound.
	Audio.play(Audio.AudioSettings.new()
		.set_path(path)
		.set_pitch_scale(AudioPitchSlider.value)
		.set_volume(AudioVolumeSlider.value)
		.set_persistance(PersistentCheckbox.button_pressed)
		.set_bus("SFX")
	)


func _on_clear_button_pressed() -> void:
	# Unload all loaded sounds.
	Audio.clean_up()


func _on_music_button_pressed() -> void:
	# Alternate music.
	if music_id == 0:
		music_id = 1
	else:
		music_id = 0
	
	# Get the music path.
	var songs: Array[String] = [
		"uid://choe0cqhr07st",
		"uid://b12xv5l80mq3b"
	]
	
	# Play the song.
	Music.play(Music.MusicSettings.new()
		.set_path(songs[music_id])
		.set_pitch_scale(MusicPitchSlider.value)
		.set_volume(MusicVolumeSlider.value)
		.set_transition(TransitionOptionButton.selected)
		.set_bus("Music")
	)
