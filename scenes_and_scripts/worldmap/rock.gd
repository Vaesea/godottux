extends StaticBody2D

# Original made by AnatolyStev, ported to Godot by Vaesea and AnatolyStev                                      .

## This should be 1 or more than 1.[br]
## Nothing is stopping you from setting this and the level sections to 0 but I haven't tested that and it may cause issues.
@export var rock_section = 1

var gone = false

func _ready() -> void:
	add_to_group("Rock")

func remove_rock():
	if not gone:
		gone = true
		queue_free()
