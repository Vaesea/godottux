extends BadGuy

# this was made by both vaesea and anatolystev
# anatolystev's little funny epic note: i know a lot more about haxeflixel so if this code looks bad, that's why.

# there was an attempt to make held iceblocks kill other enemies. it hasn't worked.

# TODO: move to enemy.gd (which should really be named badguy.gd)

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
		if held_by.facing_direction == -1:
			global_position.x = held_by.global_position.x - 8
		else:
			global_position.x = held_by.global_position.x + 24
		
		global_position.y = held_by.global_position.y - 4
		
		direction = held_by.facing_direction
		
		$Image.play("flat")
		
		if direction == -1:
			$Image.flip_h = false
		else:
			$Image.flip_h = true
	else:
		if not dead:
			$Collision.set_deferred("disabled", false)
		super(delta)
	
	# no waking up for you, iceblock! (this code works... sort of. it doesn't let the iceblock play the flat animation.
	#if current_state == IceblockStates.Flat:
		#await get_tree().create_timer(5).timeout
		#if current_state == IceblockStates.Flat:
			#current_state = IceblockStates.Normal
	
	if current_state == IceblockStates.Flat or current_state == IceblockStates.MovingFlat:
		$Image.play("flat")
	
	if current_state == IceblockStates.MovingFlat and current_state == IceblockStates.Held:
		kill_other_enemies = true
		if current_state == IceblockStates.MovingFlat:
			if is_on_wall():
				$BumpSound.play()
	else:
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
				direction = area.get_parent().facing_direction
				wait_to_collide = 0.25
				$KickSound.play()
			print(":3")
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
				direction = body.facing_direction
				current_state = IceblockStates.MovingFlat
				wait_to_collide = 0.25
		else:
			$KickSound.play()
			direction = body.facing_direction
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
