extends Node2D

class_name Level

# it's a surprise tool that will help me later
## Name of the level.[br]Shows up in the level intro (doesn't exist yet) but not the worldmap.
@export var level_name = "Unnamed"
## Your name goes here.[br][br]Shows up in the level intro.[br]Set this to blank if you don't want to be credited.
@export var level_creator = "Level Creator"
## The license for your level.[br][br]Doesn't show up anywhere.[br]You can use multiple licenes if you want.[br]I don't recommend changing this unless you know what you're doing.
@export var license = "CC-BY-SA 4.0"
## A note for your level.[br][br]Doesn't show up anywhere.[br]Useful for saying that your level is unfinished.
@export var level_note:String
## Width of the level in tiles.
@export var level_width:int = 50
## Height of the level in tiles.
@export var level_height:int = 35
@export var main_spawnpoint = "main"
## How many seconds should the game wait before putting the player back in the worldmap / level select? [br]
## Set this to how long your "finish level" song is, if you changed it.
var wait_to_end_level = 7.71

# needed for scripting block
@onready var tux = $Tux

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.width_of_level = level_width * 32
	Global.height_of_level = level_height * 32
	find_spawnpoint()
	$Tux/Camera.limit_top = -Global.height_of_level
	$Tux/Camera.limit_right = Global.width_of_level
	TuxManager.current_state = Global.tux_state
	tux.reload_player()
	print(TuxManager.current_state)
	$Goal.connect("level_finished", _on_level_finished)
	print("Useful level debugging info, possibly:")
	print("Width in pixels: " + str(Global.width_of_level) + ". If this is 0, and you didn't set Level Width to 0, there's most likely a bug you should report.")
	print("Height in pixels: " + str(Global.height_of_level) + ". If this is 0, and you didn't set Level Height to 0, there's most likely a bug you should report.")
	print("No more useful level debugging info.")

func _process(_delta: float) -> void:
	if Global.debug and Input.is_key_pressed(KEY_0):
		if scene_file_path not in Global.completed_levels:
			Global.completed_levels.append(scene_file_path)
		
		if Global.current_worldmap == "":
			get_tree().change_scene_to_file("res://scenes_and_scripts/menu/menu.tscn")
		else:
			get_tree().change_scene_to_file(Global.current_worldmap)

func _on_level_finished() -> void:
	$Misc/Music.stream = load("res://assets/music/leveldone.ogg")
	print($Misc/Music.stream) # helpful debug thing for myself, should probably remove this before release.
	$Misc/Music.play()
	await get_tree().create_timer(wait_to_end_level).timeout
	if scene_file_path not in Global.completed_levels:
		Global.completed_levels.append(scene_file_path)
	
	if Global.current_worldmap == "":
		get_tree().change_scene_to_file("res://scenes_and_scripts/menu/menu.tscn")
	else:
		get_tree().change_scene_to_file(Global.current_worldmap)

# TODO: Replace worldmap spawnpoint finding with this
func find_spawnpoint():
	for spawn in get_tree().get_nodes_in_group("LevelSpawnPoint"):
		if spawn.spawnpoint_name == main_spawnpoint:
			if TuxManager.current_state == TuxManager.powerup_states.Small:
				$Tux.global_position = spawn.global_position
			else:
				$Tux.global_position = spawn.global_position - Vector2(0, 23)
