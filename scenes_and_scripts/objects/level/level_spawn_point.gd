extends Marker2D

@export var spawnpoint_name = "main"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("LevelSpawnPoint")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.debug:
		$Label.visible = true
		$EditorImage.visible = true
	else:
		$Label.visible = false
		$EditorImage.visible = false
