extends Area2D

## Make this empty to not fade a TileMapLayer. This must be the name of an actual TileMapLayer in the level or the game will crash.
@export var tile_map_layer_name:String

var detected_tux:bool = false

func _ready() -> void:
	connect("body_entered", _on_tux_entered)
	print(name + ": " + tile_map_layer_name + ", " + str(detected_tux))

func _on_tux_entered(body):
	if body.is_in_group("Player") and not detected_tux:
		print("Tux detected in secret area.")
		detected_tux = true
		var text = load("uid://teuke2m74j5h").instantiate()
		get_tree().current_scene.call_deferred("add_child", text)
		if not tile_map_layer_name.is_empty():
			get_parent().fade_tilemap(tile_map_layer_name)
