@tool
extends CharacterBody2D

# I didn't add this to the Badguy script because Mr Tree is a unique enough enemy.
# TODO: Make every badguy use a thing like TuxDetectorTop (could be done after release?)
# (although if it isn't broke, don't fix it. actually, why didn't i follow that logic for this mr tree?)

# AnatolyStev: fixes the stomping the mr the tree.

enum TreeStates {Alive, Dead}

## The type that the Mr Tree starts as.
@export_enum("Mr Tree", "Stumpy") var type = 0:
	set(value):
		type = value
		reload()

@export var speed:int = 100
@export var stumpy_speed:int = 120

var dizzy:bool = false

# Direction of Mr Tree
@export var direction:int = -1

# If the Mr Tree was on a wall, this should be true. If not, this should be false.
var was_on_wall:bool = false

# Current state of Mr Tree (Alive or Dead)
var current_state:TreeStates = TreeStates.Alive

# How long does the corpse stay on screen?
var death_timer:int = 2

func _ready() -> void:
	reload()
	$TuxDetector.connect("body_entered", _on_tux_detector_body_detected)
	$TuxDetectorTop.connect("body_entered", _on_fireball_detected)
	$TuxDetectorTop.connect("area_entered", _on_tux_stomp_detected)
	$DizzyTimer.connect("timeout", _on_dizzy_timer_done)

func reload():
	match(type):
		0: # mr tree
			$TreeImage.visible = true
			$StumpyImage.visible = false
		1: # stumpy
			$TreeImage.visible = false
			$StumpyImage.visible = true

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if not is_on_floor():
			velocity += get_gravity() * delta
		if is_on_wall() and not was_on_wall:
			flip_direction()
		# If not dead and on floor, do these things.
		if not current_state == TreeStates.Dead and is_on_floor():
			# If GroundDetector is not colliding with the ground, flip direction.
			if not $GroundDetector.is_colliding():
				flip_direction()
	
	move()
	animate()
	
	# If direction is -1 (left), don't flip image.
	if direction == -1:
		$TreeImage.flip_h = false
		$StumpyImage.flip_h = false
		$GroundDetector.position.x = 21.0
	# If direction is 1 (right) or any invalid direction, flip image.
	else:
		$TreeImage.flip_h = true
		$StumpyImage.flip_h = true
		$GroundDetector.position.x = 61.0
	
	# Was_on_wall is now is_on_wall but a frame later I guess? I forgot.
	was_on_wall = is_on_wall()
	
	if not Engine.is_editor_hint():
		move_and_slide()

func move():
	if not Engine.is_editor_hint():
		if current_state == TreeStates.Alive:
			if not dizzy:
				if not type == 1:
					velocity.x = direction * speed
				else:
					velocity.x = direction * stumpy_speed
			else:
				velocity.x = 0
		else:
			velocity.x = 0
	else:
		velocity.x = 0

func animate():
	if current_state == TreeStates.Alive:
		if not dizzy:
			$TreeImage.play("walk")
			$StumpyImage.play("walk")
		else:
			$StumpyImage.play("dizzy")

func flip_direction():
	print(name + ": Flipping direction...")
	direction = -direction

func _on_tux_detector_body_detected(body):
	if current_state == TreeStates.Alive:
		if body.is_in_group("Player") and not dizzy:
			var collision_shape_thing = $Collision.shape.get_size().y / 3
			if not body.velocity.y > 0 and not body.global_position.y < global_position.y - collision_shape_thing:
				if not Global.tux_star_invincible:
					print("Mr Tree damage tux :(")
					body.damage()
				else:
					print("The SuperTux Himself")
					death(true)
			else:
				if not Global.tux_star_invincible:
					body.stomp_bounce()
					if type == 0 and not dizzy:
						print("SuperTux damage the bad tree!")
						type = 1
						reload()
						turn_dizzy()
						$TreeSound.play()
						$TreeHitSound.play()
					elif type == 1 and not dizzy:
						print("SuperTux kill the bad tree!")
						death(false)
				else:
					death(true)
		if body.is_in_group("FireBullet"):
			body.queue_free()
			death(true)

func _on_fireball_detected(body):
	if body.is_in_group("FireBullet"):
		body.queue_free()
		death(true)
	if body.is_in_group("Enemy") and body.kill_other_enemies:
		death(true)

func _on_tux_stomp_detected(area):
	if area.is_in_group("Stomp"):
		if not Global.tux_star_invincible:
			area.get_parent().stomp_bounce()
			if type == 0 and not dizzy:
				print("SuperTux damage the bad tree!")
				type = 1
				reload()
				turn_dizzy()
				$TreeSound.play()
				$TreeHitSound.play()
			elif type == 1 and not dizzy:
				print("SuperTux kill the bad tree!")
				death(false)
		else:
			death(true)

func death(fall:bool):
	print(name + " died.")
	current_state = TreeStates.Dead
	$TuxDetectorTop.set_deferred("monitoring", false)
	$TuxDetector.set_deferred("monitoring", false)
	
	if fall:
		velocity.x = 0
		$Collision.set_deferred("disabled", true)
		$TreeImage.flip_v = true
		$StumpyImage.flip_v = true
		$FallSound.play()
	else:
		set_collision_layer_value(4, true)
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)
		$StumpyImage.play("squished")
		$SquishSound.play()
		await get_tree().create_timer(death_timer).timeout
		queue_free()

func turn_dizzy():
	dizzy = true
	var vicious_ivy_1 = load("uid://c7xxetrv6fxkk").instantiate()
	var vicious_ivy_2 = load("uid://c7xxetrv6fxkk").instantiate()
	spawn_vicious_ivy(vicious_ivy_1, vicious_ivy_2)
	$DizzyTimer.start()

func _on_dizzy_timer_done():
	dizzy = false

func spawn_vicious_ivy(vi1, vi2):
	# Writing everything twice is bad but I did it anyways.
	get_parent().call_deferred("add_child", vi1)
	get_parent().call_deferred("add_child", vi2)
	await vi1.ready
	await vi2.ready
	vi1.global_position = $ViciousIvySpawn1.global_position
	vi2.global_position = $ViciousIvySpawn2.global_position
	vi1.set_scripted_spawn_direction(false)
	vi2.set_scripted_spawn_direction(true)
