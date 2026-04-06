extends BadGuy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spiky = true
	smart = true
	hurt_by_stomp = false
	super()
