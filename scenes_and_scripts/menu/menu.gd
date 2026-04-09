extends Node2D

@export_file("*.tscn") var selected_level = "res://scenes_and_scripts/levels/world1/cutscene_test.tscn"
@export_file("*.wav", "*.ogg") var song = "res://assets/music/theme.ogg"

func _ready() -> void:
	Music.stream = load(song)
	Music.play()
	Global.load_data()

func _process(_delta: float) -> void:
	if Global.debug and not selected_level == null and Input.is_key_pressed(KEY_P):
		get_tree().change_scene_to_file(selected_level)
	elif Global.debug and selected_level == null and Input.is_key_pressed(KEY_P):
		print("Change selected_level.")
	elif not Global.debug and Input.is_key_pressed(KEY_P):
		print("You must be in debug mode to change to selected_level.")

func _on_play_button_pressed() -> void:
	TuxManager.current_state = Global.tux_state
	if Global.current_worldmap == "":
		get_tree().change_scene_to_file(Global.first_worldmap)
	elif Global.current_worldmap == "res://scenes_and_scripts/levels/template/worldmap.tscn":
		OS.alert("Tried to load template worldmap.", "Loading Failed!")
	else:
		get_tree().change_scene_to_file(Global.current_worldmap)

func _on_delete_button_pressed() -> void:
	OS.alert("This will close the game and delete your save data.", "Warning")
	Global.delete_data()
