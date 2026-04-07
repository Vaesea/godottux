extends BadGuy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bouncing = true
	freezable = false
	super()
