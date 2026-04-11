@tool
extends HoldableObject

@export var light_color:Color = Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		light_color = value
		reload()

@onready var magic_tile_detector = $PointLight2D/MagicBlockDetector
@onready var light = $PointLight2D

func _ready() -> void:
	reload()
	magic_tile_detector.connect("body_entered", _on_magic_tile_detected)
	magic_tile_detector.connect("body_exited", _on_magic_tile_exited)
	if not Engine.is_editor_hint():
		super()

func reload():
	if not light == null: # This is here to prevent a crash and error that happens when you set the lantern's light_color.
		light.color = light_color

func _on_magic_tile_detected(body):
	if body.is_in_group("MagicTile"):
		print("Magic Tile detected!")
		body.show_tile(light_color)

func _on_magic_tile_exited(body):
	if body.is_in_group("MagicTile"):
		print("Magic Tile exited!")
		body.stop_show()
