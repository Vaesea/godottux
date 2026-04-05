extends Area2D

signal level_finished

func _ready() -> void:
	$".".connect("body_entered", _on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		body.in_cutscene = true
		body.skid = false
		body.velocity.x = 160
		body.invincible = true
		TuxManager.facing_direction = 1
		level_finished.emit()
		Signals.level_actually_done.emit()
