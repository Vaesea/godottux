extends BadGuy

# this was made by both vaesea and anatolystev
# anatolystev's little funny epic note: i know a lot more about haxeflixel so if this code looks bad, that's why.

# TODO: move to enemy.gd (which should really be named badguy.gd)
# TODO: Make the VisibleOnScreenEnabler2D always act like it's on screen when current_state is MovingFlat

# TODO: Fix bug where if this enemy is being held by Tux, and Tux falls fast on another enemy, 
# this enemy and the other enemy dies just like is Tux walked into the other enemy while holding this enemy.

enum IceblockStates {Normal, Flat, MovingFlat, Held}

var current_state = IceblockStates.Normal

var wait_to_collide = 0
var held_by:CharacterBody2D = null

var movingflat_speed = 500

func _ready() -> void:
	super()
	$Image.play("walk")
	$TuxDetector.area_entered.connect(_on_tux_detector_area_entered)
	$TuxDetector.body_entered.connect(_on_tux_detector_body_entered)

func _physics_process(delta: float) -> void:
	if wait_to_collide > 0:
		wait_to_collide -= delta
	
	if current_state == IceblockStates.Held:
		if TuxManager.facing_direction == -1:
			global_position.x = held_by.global_position.x - 8
		else:
			global_position.x = held_by.global_position.x + 24
		
		global_position.y = held_by.global_position.y - 16
		
		direction = TuxManager.facing_direction
		
		$Image.play("flat")
		
		if direction == -1:
			$Image.flip_h = false
		else:
			$Image.flip_h = true
	else:
		if not dead:
			$Collision.set_deferred("disabled", false)
		super(delta)
	
	# no waking up for you, iceblock! (this code works... sort of. it doesn't let the iceblock play the flat animation)
	#if current_state == IceblockStates.Flat:
		#await get_tree().create_timer(5).timeout
		#if current_state == IceblockStates.Flat:
			#current_state = IceblockStates.Normal
	
	if current_state == IceblockStates.Flat or current_state == IceblockStates.MovingFlat:
		$Image.play("flat")
	
	if current_state == IceblockStates.MovingFlat: # accidentally put "and" instead of "or"
		kill_self_on_touching_enemy = false
		kill_other_enemies = true
		if current_state == IceblockStates.MovingFlat:
			if is_on_wall() and not was_on_wall:
				$BumpSound.play()
	elif current_state == IceblockStates.Held:
		kill_self_on_touching_enemy = true
		kill_other_enemies = false
	else:
		kill_self_on_touching_enemy = false
		kill_other_enemies = false

func pick_up(tux: CharacterBody2D):
	current_state = IceblockStates.Held
	held_by = tux

func throw(tux_direction:int):
	current_state = IceblockStates.MovingFlat
	$KickSound.play()
	direction = tux_direction
	held_by = null
	wait_to_collide = 0.25

func _on_tux_detector_area_entered(area) -> void:
	if area.is_in_group("Stomp") and wait_to_collide <= 0:
		# TODO: Prevent player from being damaged by enemy below when on slope
		if area.get_parent().get_real_velocity().y > 0:
			if current_state == IceblockStates.Normal or current_state == IceblockStates.MovingFlat:
				current_state = IceblockStates.Flat
				wait_to_collide = 0.25
				$SquishSound.play()
			elif current_state == IceblockStates.Flat:
				current_state = IceblockStates.MovingFlat
				direction = TuxManager.facing_direction
				wait_to_collide = 0.25
				$KickSound.play()
			print("Damaged enemy")
			area.get_parent().stomp_bounce()
	
	if area.is_in_group("StupidThing") and area.get_parent().kill_other_enemies:
		death(true)

func _on_tux_detector_body_entered(body) -> void:
	if body.is_in_group("Player") and not dead and wait_to_collide <= 0:
		if current_state == IceblockStates.MovingFlat or current_state == IceblockStates.Normal:
			body.damage()
		elif current_state == IceblockStates.Flat:
			if Input.is_action_pressed("player_action") and body.held_object == null: # body.held_object == null is needed here so the enemy can still be kicked by tux if tux is holding an object:
				body.hold_enemy(self)
			else: # TODO: code is copy and pasted from next else: thing. this needs to be fixed at some point, but it's ok to keep for now.
				$KickSound.play()
				direction = TuxManager.facing_direction
				current_state = IceblockStates.MovingFlat
				wait_to_collide = 0.25
		else:
			$KickSound.play()
			direction = TuxManager.facing_direction
			current_state = IceblockStates.MovingFlat
			wait_to_collide = 0.25

func move():
	if not dead:
		if current_state == IceblockStates.Normal:
			velocity.x = direction * speed
		elif current_state == IceblockStates.Flat or current_state == IceblockStates.Held:
			velocity.x = 0
			if current_state == IceblockStates.Held:
				velocity.y = 0
		elif current_state == IceblockStates.MovingFlat:
			velocity.x = direction * movingflat_speed
	else:
		velocity.x = 0

func death(fall:bool):
	dead = true
	$TuxDetector.set_deferred("monitoring", false)
	$TuxDetector.set_deferred("monitorable", false)
	
	if fall:
		held_by = null
		current_state = IceblockStates.Flat
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
