extends BadGuy

# this was made by both vaesea and anatolystev
# anatolystev's little funny epic note: i know a lot more about haxeflixel so if this code looks bad, that's why.

# TODO: move to badguy.gd
# TODO: Make the VisibleOnScreenEnabler2D always act like it's on screen when current_state is MovingFlat

# TODO: Fix bug where if this enemy is being held by Tux, and Tux falls fast on another enemy, 
# this enemy and the other enemy dies just like is Tux walked into the other enemy while holding this enemy.

func _ready() -> void:
	walking_and_holdable = true
	freezable = false
	super()
