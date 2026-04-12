extends BadGuy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spiky = true
	smart = true
	hurt_by_stomp = false
	ground_detector_position_x_when_left = 5.0
	ground_detector_position_x_when_right = 34.0
	super()
