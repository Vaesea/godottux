extends Marker2D

## Set this to the spawn point name you would like Tux to go to.
@export var spawn_name:String = "main"

func _ready() -> void:
	add_to_group("SpawnPoint")

func _process(_delta: float) -> void:
	if Global.debug:
		$Label.visible = true
		$EditorImage.visible = true
	else:
		$Label.visible = false
		$EditorImage.visible = false
