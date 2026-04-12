extends HoldableEnemy

# TODO: Make the collision position change when Snail's image is flipped

func _ready() -> void:
	smart = true
	jump_when_hit_wall_or_thrown = true
	ground_detector_position_x_when_left = 3.0
	ground_detector_position_x_when_right = 32.0
	super()
