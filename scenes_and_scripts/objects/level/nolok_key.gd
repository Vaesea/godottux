extends Sprite2D

# I actually wrote comments for once. Now you, the reader or fangame maker, can know what to do.

# TODO: Add an "end level" option and a cutscene for ending the level.

## The type of Nolok Key that you want the key to be. [br]
## [br]
## I'd recommend setting the image to the key you want too.
@export_enum("Air", "Earth", "Wood", "Fire", "Water") var key = 0

# Whether the key has been collected or not.
var collected:bool = false

@onready var tux_detector = $TuxDetector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the body_entered signal so Tux can be detected.
	tux_detector.connect("body_entered", _on_tux_detected)

# When something is detected, check if it's "Player" (Tux) and if it is, add the key name to Global.collected_nolok_keys
# TODO: Find some way to make the match statement shorter. There has to be some sort of way, right? Perhaps making a separate function?
func _on_tux_detected(body):
	if body.is_in_group("Player") and not collected:
		print("Tux collected the key! If it has already been collected, nothing has changed.")
		collected = true
		visible = false
		match(key):
			0: # air
				if not Global.air_key_collected:
					Global.air_key_collected = true
					KeyDisplay.reload()
			1: # earth
				if not Global.earth_key_collected:
					Global.earth_key_collected = true
					KeyDisplay.reload()
			2: # wood
				if not Global.wood_key_collected:
					Global.wood_key_collected = true
					KeyDisplay.reload()
			3: # fire
				if not Global.fire_key_collected:
					Global.fire_key_collected = true
					KeyDisplay.reload()
			4: # water
				if not Global.water_key_collected:
					Global.water_key_collected = true
					KeyDisplay.reload()
