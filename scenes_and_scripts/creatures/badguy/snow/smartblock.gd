extends BadGuy

# this was made by both vaesea and anatolystev
# anatolystev's little funny epic note: i know a lot more about haxeflixel so if this code looks bad, that's why.

func _ready() -> void:
	walking_and_holdable = true
	smart = true
	ground_detector_position_x_when_left = 3.0
	ground_detector_position_x_when_right = 32.0
	freezable = false
	super()
