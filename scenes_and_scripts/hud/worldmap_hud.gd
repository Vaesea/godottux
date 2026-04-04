extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelName.text = str(Global.dot_level_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$LevelName.text = str(Global.dot_level_name)
