extends CharacterBody2D
# Why? Because badguy.gd needs to be easy to maintain.
# Stalactite was breaking, so it's the first thing to be made separate.
# be in the file.
class_name Stalactite

# May seem stupid, but it's used for fireballs and Iceblocks.
var stalactite = true

enum States {Normal, Shaking, Falling, Dead}
var current_state:States = States.Normal

var crack_sound_played:bool = false

var kill_other_enemies:bool = true
var kill_self_on_touching_enemy:bool = false

@export var flammable:bool = true
@export var freezable:bool = false
@export var shake_timer:float = 0.5
@export var death_timer:int = 2

func _ready() -> void:
	add_to_group("Enemy")
	$Image.play("default")
	$AnimationTween.play("RESET")
	$TuxDetector.add_to_group("StupidThing")
	$TuxDetector.connect("body_entered", _on_tux_detector_body_entered)

func _physics_process(delta: float) -> void:
	match(current_state):
		0: # normal
			velocity.y = 0
		1: # shaking
			velocity.y = 0
		2: # falling
			velocity += get_gravity() * delta
		3: # dead
			velocity.y = 0
	
	if current_state == States.Normal:
		$FloorDetector.target_position.y = 512.0 # default number
		
		$FloorDetector.force_shapecast_update()
		
		if $FloorDetector.is_colliding():
			$FloorDetector.target_position.y = $FloorDetector.get_collision_point(0).y - $FloorDetector.global_position.y
			if $FloorDetector.get_collider(0):
				if $FloorDetector.get_collider(0).is_in_group("Player"):
					start_falling(false)
		
	if current_state == States.Falling:
		if is_on_floor():
			death()
	
	move_and_slide()
	
func _on_tux_detector_body_entered(body):
	if body.is_in_group("Enemy") and not body == self:
		body.death(true)
	
	if body.is_in_group("Player"):
		body.damage()
	
	if body.is_in_group("FireBullet"):
		body.queue_free()
		start_falling(true)

func start_falling(fireball:bool):
	if flammable:
		flammable = false
	
	if fireball:
		$MeltSound.play()
	
	if current_state == States.Normal:
		current_state = States.Shaking
		$FloorDetector.enabled = false
		$FloorDetector.visible = false # while it's not visible in-game, this should help with visible collision shapes being turned on.
		$AnimationTween.play("shake")
		if not $CrackSound.playing:
			$CrackSound.play()
		await get_tree().create_timer(shake_timer).timeout
		$AnimationTween.play("RESET")
		current_state = States.Falling

func death():
	set_collision_layer_value(4, true)
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)
	$TuxDetector.set_deferred("monitoring", false)
	$TuxDetector.set_deferred("monitorable", false)
	current_state = States.Dead
	$CrashSound.play(0.17)
	$Image.play("broken")
	await get_tree().create_timer(death_timer).timeout
	queue_free()
