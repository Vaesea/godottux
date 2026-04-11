@tool
extends StaticBody2D

@export var color:Color = Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		color = value
		reload()

@onready var image = $Image
@onready var collision = $Collision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("MagicTile")
	image.play("default")
	reload()

func reload():
	modulate = color

func show_tile(color_of_lantern:Color):
	if color_of_lantern == color or color_of_lantern == Color(1.0, 1.0, 1.0, 1.0):
		set_collision_layer_value(1, true)
		set_collision_layer_value(10, false)
		image.play("solid")

func stop_show():
	set_collision_layer_value(10, true)
	set_collision_layer_value(1, false)
	image.play("default")
