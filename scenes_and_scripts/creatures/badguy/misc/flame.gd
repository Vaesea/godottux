@tool
extends Node2D

# Not in enemy script because I really, REALLY don't want to touch that right now.

@export_enum("Normal", "Slow", "Fast", "Faster") var speed = 0:
	set(value):
		speed = value
		reload()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload()
	$Image/TuxDetector.connect("body_entered", _on_thing_detected)

func reload():
	if Engine.is_editor_hint():
		$Image.modulate = Color(1.0, 1.0, 1.0, 0.5)
		$Center.visible = true
	else:
		$Image.modulate = Color(1.0, 1.0, 1.0, 1.0)
		$Center.visible = false
	
	match(speed):
		0: # normal
			$RotationTween.play("rotate")
		1: # slow
			$RotationTween.play("rotate_slow")
		2: # Fast
			$RotationTween.play("rotate_fast")
		3: # Faster
			$RotationTween.play("rotate_faster")

func _on_thing_detected(body):
	if body.is_in_group("Player") and not Global.tux_star_invincible:
		body.damage()
	
	if body.is_in_group("FireBullet"):
		body.queue_free()
