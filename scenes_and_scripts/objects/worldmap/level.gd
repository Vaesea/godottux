extends AnimatedSprite2D

# Made by AnatolyStev, ported to Godot by Vaesea and AnatolyStev.

## Scene for your level. Make sure you set this or the game will crash.[br]
## [br]
## If this causes problems, please tell me. May be due to the PackedScene thing. If it doesn't cause problems, then it's fine.
@export var level_scene:PackedScene

## Display name for the level. Can be different from the actual level.
@export var level_name = "Level"

## Make sure to set the section to 1 or more.
@export var level_section = 1

var completed = false
var tux_on_level = false

func _ready() -> void:
	add_to_group("Level")
	$LevelIntro/TweenAnimation.connect("animation_finished", _on_tween_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if tux_on_level and Input.is_action_just_pressed("ui_accept"):
		Global.tux_wm_x = get_parent().tux.position.x
		Global.tux_wm_y = get_parent().tux.position.y
		Global.save_data()
		Global.current_level = level_scene.resource_path
		$LevelIntro/TweenAnimation.play("transition")
		get_tree().paused = true
	
	if completed:
		$".".play("green")
	else:
		$".".play("red")

func complete_level():
	if not completed:
		completed = true
		print("Completed level with path: " + level_scene.resource_path)

func _on_tux_detector_body_entered(body) -> void:
	if body.is_in_group("TuxWorldmap"):
		tux_on_level = true
		Global.dot_level_name = level_name

func _on_tux_detector_body_exited(body) -> void:
	if body.is_in_group("TuxWorldmap"):
		tux_on_level = false
		Global.dot_level_name = ""

func _on_tween_finished(anim_name: StringName):
	if anim_name == "transition":
		await get_tree().create_timer(0.02).timeout # so the transition animation can finish
		get_tree().paused = false
		get_tree().change_scene_to_packed(level_scene)
