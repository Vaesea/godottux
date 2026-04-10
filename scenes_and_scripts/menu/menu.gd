extends Node2D

@export_file("*.tscn") var credits_menu = "res://scenes_and_scripts/menu/credits.tscn"
@export_file("*.wav", "*.ogg") var song = "res://assets/music/theme.ogg"

func _ready() -> void:
	KeyDisplay.visible = false
	Music.stream = load(song)
	Music.play()
	Global.load_data()
	KeyDisplay.reload()

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

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file(credits_menu)
