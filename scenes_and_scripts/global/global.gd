extends Node

# worldmap support by anatolystev

# Allows various debug stuff, like completing levels, changing whether Tux has a powerup or not and showing worldmap spawn points.
var debug:bool = false

# Change this to the worldmap that you want the player go to if there's no save file.
var first_worldmap = "res://scenes_and_scripts/levels/world1/worldmap.tscn"

var level_name:String
var level_creator:String
var width_of_level = 0
var height_of_level = 0

var coins = 100
var tux_state = TuxManager.powerup_states.Small

var worldmap_name:String
var width_of_worldmap = 0
var height_of_worldmap = 0

var dot_level_name = ""

var tux_wm_x = 0.0
var tux_wm_y = 0.0
var global_spawn_name = "main"
var use_spawn_point = false

var current_level:String
var current_worldmap:String
var completed_levels = []

var completed_worldmaps = []

var checkpoint_reached = false # It's a surprise tool that will help us later!

var save_version = 2
var save_file = "user://save"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("activate_debug") and not debug:
		debug = true
		OS.alert("Enjoy the debug mode!", "Debug Mode Activated!")
		OS.alert("Press 0 in a level to finish the level,\npress 1 or 2 in a level to change Tux's powerup state,\nnothing else yet...", "Instructions")
		save_data()

func save_data():
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_var(current_worldmap)
	file.store_var(coins)
	file.store_var(tux_state)
	file.store_var(tux_wm_x)
	file.store_var(tux_wm_y)
	file.store_var(completed_levels)
	file.store_var(completed_worldmaps)
	file.store_var(save_version)
	file.store_var(debug)

func load_data():
	if FileAccess.file_exists(save_file):
		print("Save file exists! Loading data...")
		var file = FileAccess.open(save_file, FileAccess.READ)
		current_worldmap = file.get_var()
		coins = file.get_var()
		tux_state = file.get_var()
		tux_wm_x = file.get_var()
		tux_wm_y = file.get_var()
		completed_levels = file.get_var()
		completed_worldmaps = file.get_var()
		save_version = file.get_var()
		if save_version == 2:
			debug = file.get_var()
		print("current_worldmap: ", current_worldmap)
		print("coins: ", coins)
		print("tux_state: ", tux_state)
		print("tux_wm_X: ", tux_wm_x)
		print("tux_wm_y: ", tux_wm_y)
		print("completed_worldmaps: ", completed_worldmaps)
		print("save_version: ", save_version)
		print("debug: ", str(debug))
	else:
		print("Save file doesn't exist, saving data...")
		print("current_worldmap: ", current_worldmap)
		print("coins: ", coins)
		print("tux_state: ", tux_state)
		print("tux_wm_X: ", tux_wm_x)
		print("tux_wm_y: ", tux_wm_y)
		print("completed_worldmaps: ", completed_worldmaps)
		print("save_version: ", save_version)
		print("debug: ", str(debug))
		save_data()

func delete_data():
	DirAccess.remove_absolute(save_file)
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
