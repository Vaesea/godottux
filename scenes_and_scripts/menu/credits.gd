extends Node2D

## How fast the text moves.
@export var text_speed = 0.5

## The menu scene.
@export_file("*.tscn") var menu_scene = "res://scenes_and_scripts/menu/menu.tscn"

## The music file.
@export_file("*.wav", "*.ogg") var music_file = "res://assets/music/credits.ogg"

func _ready() -> void:
	Music.stream = load(music_file)
	Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Text.position.y -= text_speed

	if Input.is_action_just_pressed("ui_down"):
		text_speed += 0.5

	if Input.is_action_just_pressed("ui_up"):
		text_speed -= 0.5

	if Input.is_key_pressed(KEY_SPACE):
		get_tree().change_scene_to_file(menu_scene)
