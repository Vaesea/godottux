extends CharacterBody2D

class_name BadGuy

# TODO: rename script file to badguy.gd

# Falling
var fall_force = 128
var dieFall = false

# Movement
var speed = 80
## -1 = left, 1 = right, don't set anything different or the badguy will kick you in real life
@export var direction = -1

# Gravity
var apply_gravity = true

# imagine if godot was good. i have no idea how this managed to work but i think my brain might have grown
var was_on_wall = false

# this is here to prevent enemies from damaging the player when the player stomps on the enemy 
# because godot said FUCK YOU when i added the death function and refused to let enemies work correctly
var dead = false

# How long does the corpse stay on screen?
var death_timer = 1

# For Iceblocks and probably bombs when I add those?
var kill_other_enemies = false

# For Iceblocks
var kill_self_on_touching_enemy = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Enemy")
	$TuxDetector.add_to_group("StupidThing")
	
	# here to prevent bugs
	if direction > 1:
		direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if apply_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
			
	move()
	
	if is_on_wall() and not was_on_wall:
		flip_direction()

	if direction == -1:
		$Image.flip_h = false
	else:
		$Image.flip_h = true
	
	# absolutely giant brain
	was_on_wall = is_on_wall()
	
	move_and_slide()

func flip_direction():
	direction = -direction
	
func move():
	pass

func death(fall:bool):
	dead = true
	$TuxDetector.set_deferred("monitoring", false)
	$TuxDetector.set_deferred("monitorable", false)
	
	if fall:
		velocity.x = 0
		$Collision.set_deferred("disabled", true)
		$Image.flip_v = true
		$FallSound.play()
	else:
		$".".set_collision_layer_value(4, true)
		$".".set_collision_layer_value(3, false)
		$".".set_collision_mask_value(3, false)
		$SquishSound.play()
		$Image.play("squished")
		await get_tree().create_timer(death_timer).timeout
		queue_free()
