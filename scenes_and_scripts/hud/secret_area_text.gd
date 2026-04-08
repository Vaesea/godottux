extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.connect("timeout", _on_timer_done)

func _on_timer_done():
	queue_free()
