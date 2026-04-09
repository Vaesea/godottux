extends HoldableObject

@export var max_bounce:int = 900
@export var min_bounce:int = 500

func _ready() -> void:
	$Image.play("default")
	$StationaryImage.play("default")
	
	if portable:
		$Image.visible = true
		$StationaryImage.visible = false
	else:
		$Image.visible = false
		$StationaryImage.visible = true
	
	$TopTuxDetector.connect("body_entered", _on_tux_detected_top)
	
	super()

func _on_tux_detected_top(body):
	if body.is_in_group("Player"):
		$BounceSound.play()
		$Image.play("bounce")
		$StationaryImage.play("bounce")
		if Input.is_action_pressed("player_jump"):
			body.velocity.y = -max_bounce
		else:
			body.velocity.y = -min_bounce
