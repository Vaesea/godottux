extends AnimatedSprite2D


# made by vaesea and anatolystev

## Whether the telporter is invisible or not.
@export var invisible:bool = false
## If true, automatically telports Tux when he touches the teleporter.
@export var automatic:bool = false
## Make sure to set this to the worldmap you want! Different export thing than the worldmap level dot thing because Godot is weird.
@export_file_path("*.tscn") var worldmap_scene:String
## Message that displays when Tux touches the telporter (unless it's automatic)
@export var message:String = "Where do you want to go today?"
## Make sure to set this to the name of the spawn point you want Tux to go to.
@export var spawn_target:String = "main"

var tux_on_teleporter:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("default")
	
	if invisible:
		visible = false

func _process(_delta: float) -> void:
	if tux_on_teleporter and not automatic:
		if Input.is_action_just_pressed("ui_accept"):
			teleport()

func _on_tux_detector_body_entered(body) -> void:
	if body.is_in_group("TuxWorldmap"):
		if automatic:
			teleport()
		else:
			tux_on_teleporter = true
			Global.dot_level_name = message # probably a bit of a hack

func _on_tux_detector_body_exited(body) -> void:
	if body.is_in_group("TuxWorldmap") and not automatic:
		tux_on_teleporter = false
		Global.dot_level_name = ""

func teleport():
	Global.global_spawn_name = spawn_target
	Global.use_spawn_point = true
	print("Going to new scene: " + worldmap_scene)
	print("Also going to spawn_target: " + spawn_target)
	print("Also, just for fun, here's the Global spawn name. If it's not the same as spawn_target, something's wrong: " + Global.global_spawn_name)
	get_tree().change_scene_to_file(worldmap_scene)
