extends Node2D

# Not entirely accurate.

var move_speed = 4
var bottom_particle_move_speed = 6

func _ready() -> void:
	$Timer.connect("timeout", _on_timer_stop)

func _process(_delta: float) -> void:
	$BrickParticle1.position.x -= move_speed
	$BrickParticle1.position.y -= move_speed
	
	$BrickParticle2.position.x += move_speed
	$BrickParticle2.position.y -= move_speed
	
	$BrickParticle3.position.x -= bottom_particle_move_speed
	$BrickParticle3.position.y -= move_speed
	
	$BrickParticle4.position.x += bottom_particle_move_speed
	$BrickParticle4.position.y -= move_speed

func _on_timer_stop():
	queue_free()
