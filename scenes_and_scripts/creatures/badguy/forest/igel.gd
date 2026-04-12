extends BadGuy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spiky = true
	smart = true
	hurt_by_stomp = false
	ground_detector_position_x_when_left = 7.0
	ground_detector_position_x_when_right = 42.0
	super()
