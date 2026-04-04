extends Area2D

signal level_finished

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		body.in_cutscene = true
		body.velocity.x = 160
		level_finished.emit()
		Signals.level_actually_done.emit()
