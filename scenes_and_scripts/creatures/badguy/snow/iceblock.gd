extends BadGuy

# the code that was here but is now in badguy.gdwas made by both vaesea and anatolystev
# anatolystev's little funny epic note: i know a lot more about haxeflixel so if this code looks bad, that's why.
# TODO: Make the VisibleOnScreenEnabler2D always act like it's on screen when current_state is MovingFlat

func _ready() -> void:
	walking_and_holdable = true
	freezable = false
	super()
