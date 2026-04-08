extends AnimatedSprite2D

# Currently only supports getting to one checkpoint.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TuxDetector.connect("body_entered", _on_tux_reach)
	if not Global.checkpoint_reached:
		play("default")
	else:
		play("ringing")

func _on_tux_reach(body):
	if body.is_in_group("Player") and not Global.checkpoint_reached:
		print("Checkpoint reached!")
		play("ringing")
		Global.checkpoint_reached = true
		Global.checkpoint_position = position
