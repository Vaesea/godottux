extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Number.text = str(Global.coins)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Number.text = str(Global.coins)
	if Global.coins > 999:
		$Number.text = "999+"
