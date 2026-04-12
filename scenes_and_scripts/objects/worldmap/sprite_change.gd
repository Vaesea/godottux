extends Sprite2D

## If this is false, it will change Tux to normal images instead.
@export var change_to_boat:bool = true

func _ready() -> void:
	visible = false
	$TuxDetector.connect("body_entered", _on_tux_detected)

func _on_tux_detected(body):
	if body.is_in_group("TuxWorldmap"):
		if change_to_boat:
			Global.wm_tux_boat_visible = true
		else:
			Global.wm_tux_boat_visible = false
