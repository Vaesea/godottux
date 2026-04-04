extends Node2D

func _ready() -> void:
	Global.load_data()

func _on_play_button_pressed() -> void:
	if Global.current_worldmap == "":
		get_tree().change_scene_to_file(Global.first_worldmap)
	elif Global.current_worldmap == "res://scenes_and_scripts/levels/template/worldmap.tscn":
		OS.alert("Tried to load template worldmap.", "Loading Failed!")
	else:
		get_tree().change_scene_to_file(Global.current_worldmap)

func _on_delete_button_pressed() -> void:
	OS.alert("This will close the game and delete your save data.", "Warning")
	Global.delete_data()
