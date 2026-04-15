extends CharacterBody2D

# TODO: Add interacting with other darts and Tux when Tux is invincible because of a star (currently just uses pass)

var direction:int = -1
var speed:int = 200

var was_on_wall:bool = false

@onready var image = $Image
@onready var detector = $Detector
@onready var flame_sound = $FlameSound
@onready var hit_sound = $HitSound

func _ready() -> void:
	flame_sound.play() # Could probably replace this by making flame_sound autoplay. Whatever!
	detector.connect("body_entered", _on_something_detected)
	hit_sound.connect("finished", _on_hit_sound_finished)
	flame_sound.connect("finished", _on_flame_sound_finished)
	velocity.x = direction * speed

func _physics_process(_delta: float) -> void:
	if is_on_wall():
		hide()
		if not was_on_wall: # Prevent it from spamming. Seriously. That would sound terrible.
			hit_sound.play()
	
	was_on_wall = is_on_wall()
	
	move_and_slide()

func _on_something_detected(body):
	if body.is_in_group("Player"):
		if not Global.tux_star_invincible:
			body.damage()
		else:
			pass
	if body.is_in_group("FireBullet"):
		body.queue_free()
	if body.is_in_group("Enemy"):
		body.death(true)

# Flame sound can't loop by itself for some reason (godot). So it has to be done here.
func _on_flame_sound_finished():
	flame_sound.play()

# Dart literally dies I guess
func _on_hit_sound_finished():
	queue_free()
