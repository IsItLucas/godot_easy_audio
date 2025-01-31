class_name AudioSettings extends Resource


## A custom resource made to configure the AudioStreamPlayerPlus node dynamically.


@export_group("AudioStreamPlayer")

## Audio bus used for playback.
@export var bus: StringName = &"Master"

## Pitch multiplier for the audio.
@export var pitch_scale: float = 1.0

## Volume in decibels.
@export var volume_db: float = 0.0

## Volume in linear scale.
@export var volume_linear: float = 1.0

@export_group("AudioStreamPlayerPlus")

## Determines if the audio pauses when the game pauses.
@export var is_pausable: bool = true

## Defines whether the sound instance persists.
@export var is_persistent: bool = true

## Allows multiple instances of the same sound to overlap.
@export var allow_clipping: bool = false

## Sets the audio bus.
func set_bus(new_bus: StringName) -> AudioSettings:
	bus = new_bus
	return self


## Sets the pitch scale.
func set_pitch_scale(new_pitch_scale: float) -> AudioSettings:
	pitch_scale = new_pitch_scale
	return self


## Sets the volume in decibels and updates linear volume.
func set_volume_db(new_volume_db: float) -> AudioSettings:
	volume_db = new_volume_db
	volume_linear = db_to_linear(volume_db)
	return self


## Sets the volume in linear scale and updates decibel volume.
func set_volume_linear(new_volume_linear: float) -> AudioSettings:
	volume_linear = new_volume_linear
	volume_db = linear_to_db(volume_linear)
	return self


## Sets whether the audio should pause when the game pauses.
func set_is_pausable(new_is_pausable: bool) -> AudioSettings:
	is_pausable = new_is_pausable
	return self


## Sets whether multiple overlapping sounds are allowed.
func set_clipping(new_clipping: bool) -> AudioSettings:
	allow_clipping = new_clipping
	return self


## Sets whether the sound persists after playing.
func set_persistance(new_persistance: bool) -> AudioSettings:
	is_persistent = new_persistance
	return self
