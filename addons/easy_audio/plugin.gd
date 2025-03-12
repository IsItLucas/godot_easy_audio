@tool extends EditorPlugin


## This script is responsible for setting up the plugin and its autoload.


## The name of the autoload that is going to be added by this plugin.
const AUTOLOAD_NAMES := ["Audio", "Music"]

## Where the autoload script / scene is located.
const FOLDER_NAME := "easy_audio"

## The autoload file name and extension.
const FILE_NAMES := ["audio.gd", "music.gd"]


func _enter_tree() -> void:
	# Add autoload.
	for i: int in range(AUTOLOAD_NAMES.size()):
		add_autoload_singleton(AUTOLOAD_NAMES[i], "res://addons/" + FOLDER_NAME + "/" + FILE_NAMES[i])


func _exit_tree() -> void:
	# Remove autoload.
	for i: int in range(AUTOLOAD_NAMES.size()):
		remove_autoload_singleton(AUTOLOAD_NAMES[i])
