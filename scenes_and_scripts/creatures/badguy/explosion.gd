extends BadGuy

func _ready() -> void:
	flammable = false
	freezable = false
	killable = false
	explosion = true
	hurt_by_stomp = false
	kill_other_enemies = true
	super()
