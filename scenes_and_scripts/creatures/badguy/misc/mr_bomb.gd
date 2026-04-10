extends BadGuy

func _ready() -> void:
	bomb = true
	smart = true
	ground_detector_position_x_when_right = 32.0
	super()
