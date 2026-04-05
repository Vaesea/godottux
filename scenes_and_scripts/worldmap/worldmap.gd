extends Node2D

class_name Worldmap

# Made by AnatolyStev, ported to Godot by Vaesea and AnatolyStev with support for teleporters

# note from anatolystev: "Play Supertux Free NOW Online Games for All Ages SuperTux Platforming Fun 2020"

# it's a surprise tool that will help me later
## Name of the level.[br]Shows up in the level intro (doesn't exist yet) but not the worldmap.
@export var worldmap_name = "Unnamed"
## Your name goes here.[br][br]Shows up in the level intro.[br]Set this to blank if you don't want to be credited.
@export var worldmap_creator = "Worldmap Creator"
## The license for your level.[br][br]Doesn't show up anywhere.[br]You can use multiple licenes if you want.[br]I don't recommend changing this unless you know what you're doing.
@export var license = "CC-BY-SA 4.0"
## A note for your level.[br][br]Doesn't show up anywhere.[br]Useful for saying that your level is unfinished.
@export var world_note:String
## Width of the level in tiles.
@export var worldmap_width:int = 100
## Height of the level in tiles.
@export var worldmap_height:int = 100

var levels = []
var rocks = []

@onready var tux = $WorldmapTux # for the level node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_worldmap = scene_file_path
	Global.width_of_worldmap = worldmap_width * 32
	Global.height_of_worldmap = worldmap_height * 32
	$WorldmapTux/Camera.limit_bottom = Global.height_of_worldmap
	$WorldmapTux/Camera.limit_right = Global.width_of_worldmap
	tux.current_state = Global.tux_state
	tux.reload_player()
	levels = get_tree().get_nodes_in_group("Level") # less typing
	rocks = get_tree().get_nodes_in_group("Rock") # less typing
	if Global.use_spawn_point:
		if get_spawn_point(Global.global_spawn_name):
			tux.position = get_spawn_point(Global.global_spawn_name).position
		Global.use_spawn_point = false
	else:
		if Global.tux_wm_x == 0 and Global.tux_wm_y == 0:
			tux.position = Vector2($MainWorldmapSpawnPoint.position.x, $MainWorldmapSpawnPoint.position.y)
		else:
			tux.position = Vector2(Global.tux_wm_x, Global.tux_wm_y)
	check_level_completeds()
	check_rock_unlocks()
	
	print("Useful worldmap debugging info, possibly:")
	print("Width in pixels: " + str(Global.width_of_worldmap))
	print("Height in pixels: " + str(Global.height_of_worldmap))
	print("Worldmap Path: " + scene_file_path)
	print("Global current_worldmap variable (If this is not the Worldmap Path, there's a bug): " + Global.current_worldmap)
	print("No more useful level debugging info.")

func section_completed(section:int):
	for level in levels:
		if level.level_section == section and not level.level_scene.resource_path in Global.completed_levels:
			return false
	
	return true

func check_rock_unlocks():
	for rock in rocks:
		if rock.gone:
			continue
		
		if section_completed(rock.rock_section):
			rock.remove_rock()

# wtf do i name this
func check_level_completeds():
	for level in levels:
		print("Level Path: " + level.level_scene.resource_path + ", Level section: " + str(level.level_section))
		print("Completed: " + str(Global.completed_levels))
		if level.level_scene.resource_path in Global.completed_levels:
			level.complete_level()

func get_spawn_point(name_of_spawn:String):
	for spawn in get_tree().get_nodes_in_group("SpawnPoint"):
		if spawn.spawn_name == name_of_spawn:
			return spawn
	return null

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.tux_wm_x = tux.position.x
		Global.tux_wm_y = tux.position.y
		Global.tux_state = TuxManager.current_state
		Global.save_data()
		get_tree().quit()
