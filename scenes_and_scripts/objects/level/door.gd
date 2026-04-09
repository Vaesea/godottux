extends AnimatedSprite2D

# AnatolyStev: adds doors!!

@export var sector_to_switch_to:String = "main"
@export var spawnpoint_to_switch_to:String = "main"

func _ready() -> void:
	play("default")
	$DoorSound.connect("finished", _on_sound_finished)

func _process(_delta: float) -> void:
	for body in $TuxDetector.get_overlapping_bodies():
		if body.is_in_group("Player") and Input.is_action_just_pressed("player_up"):
			body.in_cutscene = true
			body.velocity.x = 0
			play("opening")
			$DoorSound.play()

func _on_sound_finished():
	print("Door has opened.")
	get_tree().current_scene.switch_sector(sector_to_switch_to, spawnpoint_to_switch_to)
	play("closing")
