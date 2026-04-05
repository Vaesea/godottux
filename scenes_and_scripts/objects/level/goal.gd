extends Area2D

signal level_finished

var tux_walk_speed = 160

func _ready() -> void:
	$".".connect("body_entered", _on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		body.in_cutscene = true
		body.skid = false
		body.velocity.x = tux_walk_speed
		body.invincible = true
		beat_level()

# here for scripting blocks
func beat_level():
	TuxManager.facing_direction = 1
	level_finished.emit()
	Signals.level_actually_done.emit()
