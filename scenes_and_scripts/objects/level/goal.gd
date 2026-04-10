extends Area2D

signal level_finished

var tux_walk_speed:int = 160

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		body.in_cutscene = true
		body.auto_walk = true
		body.auto_walk_speed = tux_walk_speed
		body.buttjump = false
		body.backflip = false
		body.skid = false
		body.invincible = true
		body.duck = false
		body.star_invincible = false
		TuxManager.facing_direction = 1
		beat_level()

# here for scripting blocks
func beat_level():
	TuxManager.facing_direction = 1
	level_finished.emit()
	Signals.level_actually_done.emit()
