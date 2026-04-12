extends CharacterBody2D
class_name HoldableEnemy

# TODO: Add slowing down
# TODO: Add slowing down (Snail version)
# TODO: Add a way to change the x offset of the image when held by using a variable. (Snail needs this)

# HACK: Check badguy.gd
var stalactite = false

enum States {Alive, Dead}
var current_state:States = States.Alive

enum IceblockStates {Normal, Flat, MovingFlat, Held}
var current_iceblock_state:IceblockStates = IceblockStates.Normal

var was_on_wall:bool = false
var death_timer:int = 2

var wait_to_collide:float = 0.0
var held_by:CharacterBody2D = null

var kill_other_enemies:bool = false
var kill_self_on_touching_enemy:bool = false

var previous_velocity_x = 0

@export_category("Iceblock And Snail")
@export var speed:int = 80
@export var direction:int = -1
@export var smart:bool = false
@export var movingflat_speed:int = 500
@export var flammable:bool = true

@export_category("Snail")
@export var jump_when_hit_wall_or_thrown:bool = false
@export var throw_height:int = 500

@export_category("Ground Detector X Position")
## X of Ground Detector when direction is left
@export var ground_detector_position_x_when_left:float = 5.0
## X of Ground Detector when direction is right
@export var ground_detector_position_x_when_right:float = 34.0

@onready var image = $Image
@onready var collision = $Collision
@onready var tux_detector = $TuxDetector
@onready var ground_detector = $GroundDetector
@onready var squish_sound = $SquishSound
@onready var kick_sound = $KickSound
@onready var fall_sound = $FallSound
@onready var stomp_sound = $StompSound
@onready var bump_sound = $BumpSound
@onready var screen_check = $ScreenCheck

func _ready() -> void:
	add_to_group("Enemy")
	tux_detector.add_to_group("StupidThing")
	tux_detector.connect("area_entered", _on_tux_detector_area_entered)
	tux_detector.connect("body_entered", _on_tux_detector_body_entered)
	screen_check.connect("screen_entered", _on_screen_entered)
	screen_check.connect("screen_exited", _on_screen_exited)

func _physics_process(delta: float) -> void:
	if wait_to_collide > 0:
		wait_to_collide -= delta
	
	if not is_on_floor() and not current_iceblock_state == IceblockStates.Held:
		velocity += get_gravity() * delta
	
	if current_iceblock_state == IceblockStates.Normal and not screen_check.is_on_screen(): # TODO: Is this needed?
		set_physics_process(false)
	
	if current_iceblock_state == IceblockStates.MovingFlat:
		kill_other_enemies = true
		kill_self_on_touching_enemy = false
		set_collision_mask_value(1, true)
		set_collision_mask_value(9, true)
	elif current_iceblock_state == IceblockStates.Held:
		kill_other_enemies = true
		kill_self_on_touching_enemy = true
		set_collision_mask_value(1, false)
		set_collision_mask_value(9, false)
	else:
		kill_other_enemies = false
		kill_self_on_touching_enemy = false
		set_collision_mask_value(1, true)
		set_collision_mask_value(9, true)
	
	if is_on_wall() and not was_on_wall:
		flip_direction()
		if jump_when_hit_wall_or_thrown:
			velocity.y = -abs(previous_velocity_x)
	
	if smart and not current_state == States.Dead and is_on_floor():
		# If GroundDetector is not colliding with the ground and the current Iceblock state 
		# for this enemy is Normal, flip direction.
		if not ground_detector.is_colliding() and current_iceblock_state == IceblockStates.Normal:
			flip_direction()
		
		# If direction is -1 (left), set Ground Detector's x position to the variable here.
		if direction == -1:
			ground_detector.position.x = ground_detector_position_x_when_left
		# If direction is 1 (right) or any invalid direction, set Ground Detector's x position to the variable here.
		else:
			ground_detector.position.x = ground_detector_position_x_when_right
	
	if current_iceblock_state == IceblockStates.Held and not held_by == null:
		if TuxManager.facing_direction == -1:
			direction = -1
			global_position.x = held_by.global_position.x - 8
		else:
			direction = 1
			global_position.x = held_by.global_position.x + 24
		
		global_position.y = held_by.global_position.y - 16
	
	if current_iceblock_state == IceblockStates.MovingFlat and is_on_wall() and not was_on_wall:
		bump_sound.play()
	
	animate()
	
	move()
	
	was_on_wall = is_on_wall()
	
	previous_velocity_x = velocity.x
	
	move_and_slide()

func animate():
	if current_iceblock_state == IceblockStates.Normal:
		if current_state == States.Alive:
			image.play("walk")
		else:
			image.play("flat")
	else:
		image.play("flat")
	
	if direction == -1:
		image.flip_h = false
	else:
		image.flip_h = true

func flip_direction():
	direction = -direction

func move():
	if not current_state == States.Dead:
		if current_iceblock_state == IceblockStates.Normal:
			velocity.x = direction * speed
		elif current_iceblock_state == IceblockStates.Flat or current_iceblock_state == IceblockStates.Held:
			velocity.x = 0
			if current_iceblock_state == IceblockStates.Held:
				velocity.y = 0
		elif current_iceblock_state == IceblockStates.MovingFlat:
			velocity.x = direction * movingflat_speed

func death(fall:bool):
	print(name + " died.")
	current_state = States.Dead
	tux_detector.set_deferred("monitoring", false)
	tux_detector.set_deferred("monitorable", false)
	if fall:
		held_by = null
		current_iceblock_state = IceblockStates.Flat
		velocity.x = 0
		collision.set_deferred("disabled", true)
		image.flip_v = true
		fall_sound.play()
	else:
		set_collision_layer_value(4, true)
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)
		squish_sound.play()
		image.play("squished")
		await get_tree().create_timer(death_timer).timeout
		queue_free()

func _on_tux_detector_area_entered(area):
	if area.is_in_group("Stomp") and not current_state == States.Dead:
		interact(area, null, null, null)
	if area.is_in_group("StupidThing") and not area.get_parent() == self and not area.get_parent().stalactite:
		interact(null, null, null, area.get_parent())

func _on_tux_detector_body_entered(body):
	if body.is_in_group("Player") and current_iceblock_state == IceblockStates.Held:
		return
	
	if current_state == States.Dead:
		return
	
	if body.is_in_group("Player") and not wait_to_collide > 0:
		interact(null, body, null, null)
	elif body.is_in_group("FireBullet"):
		interact(null, null, body, null)
	elif body.is_in_group("Enemy") and kill_other_enemies and not body.get_parent() == self:
		interact(null, null, null, body)

func interact(stomp, tux, fireball, iceblock):
	if not stomp == null and tux == null and fireball == null and iceblock == null:
		var tux_stomp = stomp.get_parent().get_real_velocity().y > 0 # well this was get_real_velocity in the badguy file so i'm not changing it here
		
		if current_state == States.Dead:
			return
		
		if tux_stomp:
			if not Global.tux_star_invincible:
				stomp.get_parent().stomp_bounce()
			else:
				death(true)
				return
			
			if wait_to_collide <= 0:
				if current_iceblock_state == IceblockStates.Normal or current_iceblock_state == IceblockStates.MovingFlat:
					current_iceblock_state = IceblockStates.Flat
					wait_to_collide = 0.25
					stomp_sound.play()
				elif current_iceblock_state == IceblockStates.Flat:
					current_iceblock_state = IceblockStates.MovingFlat
					direction = TuxManager.facing_direction
					wait_to_collide = 0.25
					kick_sound.play()
	if stomp == null and not tux == null and fireball == null and iceblock == null:
		if wait_to_collide <= 0:
			if current_iceblock_state == IceblockStates.MovingFlat or current_iceblock_state == IceblockStates.Normal:
				if not Global.tux_star_invincible:
					tux.damage()
				else:
					death(true)
			elif current_iceblock_state == IceblockStates.Flat:
				if Input.is_action_pressed("player_action") and tux.held_object == null:
					if not Global.tux_star_invincible:
						tux.hold_object(self)
					else:
						death(true)
				else:
					if not Global.tux_star_invincible:
						kick_sound.play()
						direction = TuxManager.facing_direction
						current_iceblock_state = IceblockStates.MovingFlat
						wait_to_collide = 0.25
					else:
						death(true)
			else:
				if not Global.tux_star_invincible:
					kick_sound.play()
					direction = TuxManager.facing_direction
					current_iceblock_state = IceblockStates.MovingFlat
					wait_to_collide = 0.25
				else:
					death(true)
	if stomp == null and tux == null and not fireball == null and iceblock == null:
		fireball.queue_free()
		burn()
	if stomp == null and tux == null and fireball == null and not iceblock == null:
		if current_iceblock_state == IceblockStates.Held and kill_other_enemies and kill_self_on_touching_enemy and not iceblock == self:
			iceblock.death(true)
			death(true)
		elif current_iceblock_state == IceblockStates.MovingFlat:
			if not iceblock.stalactite:
				iceblock.death(true)

func pick_up(tux: CharacterBody2D):
	current_iceblock_state = IceblockStates.Held
	held_by = tux

func throw(tux_direction:int):
	current_iceblock_state = IceblockStates.MovingFlat
	kick_sound.play()
	direction = tux_direction
	held_by = null
	wait_to_collide = 0.25
	if jump_when_hit_wall_or_thrown:
		velocity.y = -throw_height

func burn():
	if flammable:
		death(true)

func _on_screen_entered():
	print(name + ": Entered screen")
	set_physics_process(true)
	print(name + str(process_mode))

func _on_screen_exited():
	print(name + ": Exited screen")
	if not current_iceblock_state == IceblockStates.MovingFlat:
		set_physics_process(false)
		print(name + str(process_mode))
