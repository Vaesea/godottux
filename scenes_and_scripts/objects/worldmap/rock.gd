extends StaticBody2D

# Original made by AnatolyStev, ported to Godot by Vaesea and AnatolyStev                                      .

@export_category("Key Rock")
## Whether the rock is a key rock or not.
@export var key_rock:bool = false
## If the rock is a key rock, what key type unlocks it?
@export_enum("Air", "Earth", "Wood", "Fire", "Water") var what_key_unlocks_rock = 0

@export_category("Normal Rock")
## This should be 1 or more than 1.[br]
## Nothing is stopping you from setting this and the level sections to 0 but I haven't tested that and it may cause issues.[br]
## If you set key_rock to true, this variable doesn't matter and you should ignore it.
@export var rock_section:int = 1

var gone:bool = false

func _ready() -> void:
	add_to_group("Rock")

func remove_rock():
	if not gone:
		gone = true
		queue_free()
