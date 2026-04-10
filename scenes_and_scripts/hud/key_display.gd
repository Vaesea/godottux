extends CanvasLayer

# I just realized right after writing these onready variable things that I don't need them.
# Oh well, too late!
@onready var air_display = $AirDisplay
@onready var earth_display = $EarthDisplay
@onready var wood_display = $WoodDisplay
@onready var fire_display = $FireDisplay
@onready var water_display = $WaterDisplay

# Write Everything Five Times
func _ready() -> void:
	reload()

func reload():
	# If air key is collected, show air key.
	if Global.air_key_collected:
		air_display.play("display")
	else:
		air_display.play("outline")
	
	# If earth key is collected, show earth key.
	if Global.earth_key_collected:
		earth_display.play("display")
	else:
		earth_display.play("outline")
	
	# If wood key is collected, show wood key.
	if Global.wood_key_collected:
		wood_display.play("display")
	else:
		wood_display.play("outline")
	
	# If fire key is collected, show fire key.
	if Global.fire_key_collected:
		fire_display.play("display")
	else:
		fire_display.play("outline")
	
	# If water key is collected, show water key.
	if Global.water_key_collected:
		water_display.play("display")
	else:
		water_display.play("outline")
