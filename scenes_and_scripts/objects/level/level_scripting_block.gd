extends Area2D

# You probably shouldn't set too many things true at the same time.

# Code here is so bad, but who cares?

# TODO: Add delays and stuff

@export_category("Script Settings")
## Whether the script only happens once or not.
@export var oneshot:bool = false

@export_category("Tux")
## If this is true, it sets Tux's in_cutscene variable to true. This is similar, if not the same as Tux.deactivate() in SuperTux.
@export var set_tux_cutscene_true:bool = false
## Sets Tux's speed to tux_speed
@export var set_tux_walk:bool = false
## Tux's speed for the Set Tux Walk variable.
@export var tux_speed:int = 320
## Sets Tux's velocity.y to tux_jump_height. This allows double jumping.
@export var set_tux_jump:bool = false
## Tux's jump height for the Set Tux Jump variable.
@export var tux_jump_height:int = 576
## Sets Tux's direction to 1 (right) if true.
@export var set_tux_direction_right:bool = false
## Sets Tux's direction to -1 (left) if ture.
@export var set_tux_direction_left:bool = false
## Sets whether Tux is skidding or not.
@export var tux_skid:bool = false
## Sets whether Tux gets hurt when touching the ScriptBlock.
@export var tux_hurt:bool = false
## Sets whether Tux dies when touching the ScriptBlock.
@export var tux_dies:bool = false
## Sets whether Tux's camera offset is changed.
@export var change_tux_camera_offset:bool = false
## If previous variable is true, this changes Tux's camera offset.
@export var tux_camera_offset:Vector2 = Vector2(0.0, 0.0)
## Sets whether Tux's camera zoom is changed.
@export var change_tux_camera_zoom:bool = false
## If previous variable is true, this changes Tux's camera zoom.
@export var tux_camera_zoom:Vector2 = Vector2(1.0, 1.0)
## Sets whether Tux teleports when touching the ScriptBlock.
@export var tux_teleports:bool = false
## If the previous variable is true, setting this will set the spawn point where Tux teleports.
## [br[[br]
## Leave this blank if you're gonna set the specific x / y position.
@export var tux_teleport_spawnpoint:String
## If the Tux Teleports variable is true and the Tux Teleport Spawnpoint variable is blank,
## setting this will set where Tux spawns.
@export var tux_teleport_location:Vector2 = Vector2(0.0, 0.0)

@export_category("Enemies")
## Set this to the node name of the enemy in your level scene.
@export var enemy_name:String
## If this is true, kills the enemy.
@export var kill_enemy:bool = false
## If this is true, kills all enemies no matter what the enemy_name is.
@export var kill_all_enemies:bool = false

@export_category("Object")
## Set this to the object name of the object in your level scene.
@export var object_name:String
## Type of argument to use for the function.
@export_enum("String", "Bool") var function_argument_type = 0
## Put the function of the object here. Make sure you know what you're doing or the game could crash.
## [br][br]
## The function to execute.
@export var function_to_execute:String
## String arugment for the function to execute.
@export var string_argument:String
# ## Int argument for the function to execute. Commented out because nothing takes an int argument yet.
# @export var int_argument = 0
# ## Float argument for the function to execute. Commented out because nothing takes a float argument yet.
# @export var float_argument = 0.0
@export var bool_argument:bool = false

@export_category("Function")
## If true, script block does a function.
@export var do_function:bool = false
## Type of argument to use for the function.
@export_enum("String", "Bool", "Int", "Float") var argument_type = 0
## Put the function you want to execute here.
@export var function:String
## The string argument for the function.
@export var function_string_argument:String
## The bool argument for the function.
@export var function_bool_argument:bool = false
## The int argument for the function.
@export var function_int_argument:int = 0
## The float argument for the function.
@export var function_float_argument:float = 0.0

@export_category("Spawn Object")
## If true, script block spawns an object.
@export var spawn_object:bool = false
## Set this to the object you want to spawn.
## [br][br]
## Can be used for enemies. Do not spawn another player, it won't end well.
@export_file("*.tscn") var object
## Position of the object you want to spawn.
@export var object_position:Vector2 = Vector2(0.0, 0.0)
## If set, executes spawn_function_to_execute.
@export var use_spawn_function:bool = false
## Type of argument to use for the function. For now, you can only use one argument.
@export_enum("String", "Bool") var spawn_function_argument_type = 0
## The function to execute for the spawned object.
@export var spawn_function_to_execute:String
## The string argument for the function.
@export var spawn_function_string_argument:String
## The bool argument for the function.
@export var spawn_function_bool_argument:bool = false

@export_category("Sound")
## Whether this script block plays music (will change the music already playing!)
@export var play_music:bool = false
## Whether this script block plays a sound.
@export var play_sound:bool = false
@export_file("*.ogg") var music_to_play
@export_file("*.wav", "*.ogg") var sound_to_play

# I probably shouldn't allow these.
@export_category("Trolling")
## If true, closes the game.
@export var close_game:bool = false
## If true, moves game window.
@export var move_game_window:bool = false
## If previous variable is true, where should the game window be moved?
@export var where_move_game_window:Vector2 = Vector2(0.0, 0.0)
## If true, sets game window to borderless.
@export var set_borderless:bool = false

var use_teleport_spawnpoint:bool = false
var use_teleport_location:bool = false

var happened:bool = false

func _ready() -> void:
	connect("body_entered", _on_tux_entered)

func _process(_delta: float) -> void:
	if Global.debug:
		$S.visible = true
	else:
		$S.visible = false

func _on_tux_entered(body):
	if oneshot and happened:
		return

	if body.is_in_group("Player"):
		happened = true
		if set_tux_cutscene_true:
			body.in_cutscene = true
		elif not set_tux_cutscene_true:
			body.in_cutscene = false
		if set_tux_walk:
			body.auto_walk = true
			body.auto_walk_speed = tux_speed
			if tux_speed == 0:
				print("tux_speed is 0. If you did this to stop Tux from walking, if you disable set_tux_walk for the 2nd script block, Tux will still stop walking.")
		elif not set_tux_walk:
			body.auto_walk = false
		if set_tux_direction_left and set_tux_direction_right:
			print("You can't have both of these true at the same time!")
		elif set_tux_direction_left:
			TuxManager.facing_direction = -1
		elif set_tux_direction_right:
			TuxManager.facing_direction = 1
		if tux_skid:
			body.skid = true
		else:
			body.skid = false
		if set_tux_jump:
			body.velocity.y = -tux_jump_height
		if tux_hurt:
			body.damage()
		if tux_dies:
			body.die()
		if change_tux_camera_offset:
			body.camera.offset = tux_camera_offset
		if change_tux_camera_zoom:
			body.camera.zoom = tux_camera_zoom
		if tux_teleports:
			if tux_teleport_spawnpoint.is_empty():
				use_teleport_location = true
				use_teleport_spawnpoint = false
			else:
				use_teleport_location = false
				use_teleport_spawnpoint = true
			if use_teleport_location:
				body.global_position = tux_teleport_location
			elif use_teleport_spawnpoint:
				find_the_spawnpoint()
		if kill_enemy and not enemy_name.is_empty():
			if not get_parent().find_child(enemy_name) == null:
				get_parent().find_child(enemy_name).death(true)
		if kill_all_enemies:
			for badguy in get_parent().get_tree().get_nodes_in_group("Enemy"):
				badguy.death(true)
		if not object_name.is_empty() and not function_to_execute.is_empty():
			var thing = get_parent().find_child(object_name)
			if thing:
				if thing.has_method(function_to_execute):
					if function_argument_type == 0:
						if not string_argument.is_empty():
							thing.call(function_to_execute, string_argument)
						else:
							thing.call(function_to_execute)
					elif function_argument_type == 1:
						thing.call(function_to_execute, bool_argument)
					else:
						print("How?")
				else:
					print("Oh no")
			else:
				print("Not good")
		if do_function:
			if not function.is_empty() and not function == "print":
				if argument_type == 0:
					if function_string_argument.is_empty():
						get_tree().current_scene.call(function)
					else:
						get_tree().current_scene.call(function, function_string_argument)
				elif argument_type == 1:
					get_tree().current_scene.call(function, function_bool_argument)
				elif argument_type == 2:
					get_tree().current_scene.call(function, function_int_argument)
				elif argument_type == 3:
					get_tree().current_scene.call(function, function_float_argument)
				else:
					print("How?")
			elif not function.is_empty() and function == "print":
				print("You can't use @GlobalScope functions here because Godot doesn't allow that.")
			elif function.is_empty():
				print("Function is empty!")
		if spawn_object:
			if not object == null:
				var obj = load(object).instantiate()
				get_tree().current_scene.call_deferred("add_child", obj)
				obj.position = object_position
				if use_spawn_function:
					if obj.has_method(spawn_function_to_execute):
						if spawn_function_argument_type == 0:
							if spawn_function_string_argument.is_empty():
								obj.call(spawn_function_to_execute)
							else:
								obj.call(spawn_function_to_execute, spawn_function_string_argument)
						elif spawn_function_argument_type == 1:
							obj.call(spawn_function_to_execute, spawn_function_bool_argument)
						else:
							print("How?")
					else:
						print("Oh no")
			else:
				print("Object is null!")
		if play_music:
			Music.stream = load(music_to_play)
			Music.play()
		if play_sound:
			if not sound_to_play == null:
				$Sound.stream = load(sound_to_play)
				$Sound.play()
			else:
				print("sound_to_play is null. Check whether you selected a sound or not.")
		if close_game:
			print("trolled")
			get_tree().quit()
		if move_game_window:
			get_window().position = where_move_game_window
		if set_borderless:
			get_window().borderless = true
		

func find_the_spawnpoint():
	for spawn in get_parent().get_tree().get_nodes_in_group("LevelSpawnPoint"):
		if spawn.spawnpoint_name == tux_teleport_spawnpoint:
			if TuxManager.current_state == TuxManager.powerup_states.Small:
				get_parent().tux.global_position = spawn.global_position
			else:
				get_parent().tux.global_position = spawn.global_position - Vector2(0, 23)
