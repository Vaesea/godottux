extends CharacterBody2D

class_name BadGuy

# TODO: Make the VisibleOnScreenEnabler2D always act like it's on screen when current_iceblock_state is MovingFlat
# TODO: Improve Spiky ground detection to be more like SuperTux.

# hi. anatolystev here.
# i might've, you know, made everything be like the haxeflixel version.
# because there were too much bugs before doing this.

# States for evey enemy.
enum EnemyStates {Alive, Dead}
var current_state = EnemyStates.Alive

# States for Iceblock Enemies
enum IceblockStates {Normal, Flat, MovingFlat, Held}

# Variables for Iceblock Enemies
var current_iceblock_state = IceblockStates.Normal
var wait_to_collide = 0
var held_by:CharacterBody2D = null

# Falling
var dieFall = false

# Movement
var speed = 80

# i have no idea how this managed to work but i think my brain might have grown
# nevermind my brain is still small and smooth. at least this works.
var was_on_wall = false

# How long does the corpse stay on screen?
var death_timer = 2

# For Iceblocks and probably bombs when I add those?
var kill_other_enemies = false

# For Iceblocks
var kill_self_on_touching_enemy = false

@export_category("Enemy")
## -1 = left, 1 = right, any other variable isn't tested.
@export var direction = -1
## Can the enemy be burned?
@export var flammable = true
## Can the enemy be frozen?
@export var freezable = true
## Can the enemy be killed? (Does nothing right now)
@export var killable = true

@export_category("Enemy Setup (Only Select One and Smart (if enemy is smart))")
## Is the enemy just a basic walking enemy (Goomba-like)? If you're making an enemy, it's best to change this in the enemy's script.
@export var basic_walking = false
## Is the enemy smart If you're making an enemy, it's best to change this in the enemy's script.
@export var smart = false
## Is the enemy just a basic walking enemy that can be held and thrown? (Koopa-like) If you're making an enemy, it's best to change this in the enemy's script.
@export var walking_and_holdable = false
## Is the enemy Snail-like? "Walking and Holdable" need to be true for this to work. If you're making an enemy, it's best to change this in the enemy's script.
@export var jump_when_hit_wall_or_thrown = false
## Is the enemy a bullet? (Bullet Bill-like). Not added yet. If you're making an enemy, it's best to change this in the enemy's script.
@export var bullet = false
## Is the enemy Spiky-like? If you're making an enemy, it's best to change this in the enemy's script.
@export var spiky = false
## Is the enemy Jumpy-like? If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
@export var jumpy = false
## Does the enemy fly? If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
@export var flying = false
## Is the enemy an explosion? Probably shouldn't have made this an export but whatever. If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
@export var explosion = false
## Can the enemy be hurt by stomping on it? If you're making an enemy, it's best to change this in the enemy's script.
@export var hurt_by_stomp = true

@export_category("Spiky variables")
## Is the Spiky sleeping?
@export var sleeping = false

@export_category("Jumpy variables")
## Jumpy jump height
@export var jump_height = 600

@export_category("Bouncing Enemy variables")
## Bounce height
@export var bounce_height = 512

@export_category("Iceblock variables")
## How fast the Iceblock moves when in MovingFlat state
@export var movingflat_speed = 500
## for snail enemies or something i really dont know anymore i'm going insane
@export var hit_wall_jump_height = 256

@export_category("Flying Enemy variables")
## How fast at flying is the flying enemy?
@export var fly_speed = 100

@export_category("Ground Detector X Position")
## X of Ground Detector when direction is left
@export var ground_detector_position_x_when_left = 5.0
## X of Ground Detector when direction is right
@export var ground_detector_position_x_when_right = 34.0

@export_category("Wake Up Area X Position")
## X of Wake Up Area when direction is left
@export var wake_up_shapecast_position_x_when_left = 0.0
## X of Wake Up Area when direction = right
@export var wake_up_shapecast_position_x_when_right = 32.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Enemy")
	$TuxDetector.add_to_group("StupidThing")
	$TuxDetector.area_entered.connect(_on_tux_detector_area_entered)
	$TuxDetector.body_entered.connect(_on_tux_detector_body_entered)
	if spiky and sleeping:
		$Image.connect("animation_finished", _on_wake_up_finished)
	if flying:
		$FlyingTimer.connect("timeout", _on_flying_timer_timeout)
	
	if spiky and not sleeping and not jumpy and not flying:
		$WakeUpShapecast.enabled = false
		$WakeUpShapecast.visible = false
		$Image.play("walk")
	elif spiky and sleeping and not jumpy and not flying:
		$Image.play("sleep")
	elif not spiky and not sleeping and not jumpy and not flying:
		$Image.play("walk")
	elif not spiky and not sleeping and not jumpy and flying:
		$Image.play("fly")
	
	if flying:
		velocity.y = -fly_speed
	
	current_state = EnemyStates.Alive

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if wait_to_collide > 0:
		wait_to_collide -= delta
	
	var dead_flying_snowball = flying and current_state == EnemyStates.Dead
	
	if basic_walking or walking_and_holdable or spiky or jumpy or explosion or dead_flying_snowball:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	move()
	
	if walking_and_holdable:
		if current_iceblock_state == IceblockStates.MovingFlat:
			kill_other_enemies = true
			kill_self_on_touching_enemy = false
		elif current_iceblock_state == IceblockStates.Held:
			kill_other_enemies = true
			kill_self_on_touching_enemy = true
		if current_iceblock_state == IceblockStates.Flat or current_iceblock_state == IceblockStates.MovingFlat or current_iceblock_state == IceblockStates.Held:
			$Image.play("flat")
		else:
			$Image.play("walk")
	elif explosion:
		kill_other_enemies = true
		kill_self_on_touching_enemy = true
	else:
		kill_other_enemies = false
		kill_self_on_touching_enemy = false
	
	if is_on_wall() and not was_on_wall:
		flip_direction()
	
	if direction == -1:
		$Image.flip_h = false
	else:
		$Image.flip_h = true
	
	if smart and not current_state == EnemyStates.Dead and is_on_floor():
		if not $GroundDetector.is_colliding() and current_iceblock_state == IceblockStates.Normal:
			flip_direction()
		
		if direction == -1:
			$GroundDetector.position.x = ground_detector_position_x_when_left
		else:
			$GroundDetector.position.x = ground_detector_position_x_when_right
	
	if sleeping and spiky:
		if direction == -1:
			$WakeUpShapecast.position.x = wake_up_shapecast_position_x_when_left
			$WakeUpShapecast.target_position.x = -512.0
		elif direction == 1:
			$WakeUpShapecast.position.x = wake_up_shapecast_position_x_when_right
			$WakeUpShapecast.target_position.x = 1024.0
		
		$WakeUpShapecast.force_shapecast_update()
		
		if $WakeUpShapecast.is_colliding():
			$WakeUpShapecast.target_position.x = $WakeUpShapecast.get_collision_point(0).x - $WakeUpShapecast.global_position.x
			if $WakeUpShapecast.get_collider(0):
				if $WakeUpShapecast.get_collider(0).is_in_group("Player"):
					wake_up()
	
	if walking_and_holdable:
		if current_iceblock_state == IceblockStates.Held and not held_by == null:
			direction = TuxManager.facing_direction
			if TuxManager.facing_direction == -1:
				global_position.x = held_by.global_position.x - 8
			else:
				global_position.x = held_by.global_position.x + 24
				
			global_position.y = held_by.global_position.y - 16
		
		if is_on_wall() and current_iceblock_state == IceblockStates.MovingFlat and not was_on_wall:
			$BumpSound.play()
	
	was_on_wall = is_on_wall()
	
	move_and_slide()

func flip_direction():
	direction = -direction

func move():
	var sleeping_spiky = spiky and sleeping
	
	if sleeping_spiky or current_state == EnemyStates.Dead:
		velocity.x = 0
		return
	elif spiky and not sleeping and not current_state == EnemyStates.Dead:
		velocity.x = direction * speed
	
	if not current_state == EnemyStates.Dead:
		if basic_walking and not walking_and_holdable:
			velocity.x = direction * speed
		elif walking_and_holdable:
			if current_iceblock_state == IceblockStates.Normal:
				velocity.x = direction * speed
			elif current_iceblock_state == IceblockStates.Flat or current_iceblock_state == IceblockStates.Held:
				velocity.x = 0
				if current_iceblock_state == IceblockStates.Held:
					velocity.y = 0
			elif current_iceblock_state == IceblockStates.MovingFlat:
				velocity.x = direction * movingflat_speed
		elif jumpy:
			if is_on_floor():
				velocity.y = -jump_height
				$Image.play("jump")

func death(fall:bool):
	current_state = EnemyStates.Dead
	$TuxDetector.set_deferred("monitoring", false)
	$TuxDetector.set_deferred("monitorable", false)
	
	if fall:
		held_by = null
		if walking_and_holdable:
			current_iceblock_state = IceblockStates.Flat
			print("iceblock died.")
		velocity.x = 0
		if jumpy or flying:
			velocity.y = 0
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

# TODO: Code can be improved. A lot. Needed to be improved ever since Iceblock code was added here.
func _on_tux_detector_area_entered(area) -> void:
	if area.is_in_group("Stomp") and not spiky and not jumpy:
		interact(area, null, null, null)
	
	if area.is_in_group("StupidThing") and not area.get_parent() == self:
		interact(null, null, null, area.get_parent())

func _on_tux_detector_body_entered(body) -> void:
	if body.is_in_group("Player") and current_iceblock_state == IceblockStates.Held:
		return
	
	if body.is_in_group("Player") and not current_state == EnemyStates.Dead and not wait_to_collide > 0:
		interact(null, body, null, null)
	elif body.is_in_group("FireBullet") and not current_state == EnemyStates.Dead:
		interact(null, null, body, null)
	elif body.is_in_group("Enemy") and not current_state == EnemyStates.Dead and kill_other_enemies and not body.get_parent() == self:
		interact(null, null, null, body)

func interact(stomp, tux, fireball, iceblock):
	if not stomp == null and tux == null and fireball == null and iceblock == null:
		var tux_stomp = stomp.get_parent().get_real_velocity().y > 0
		
		if current_state == EnemyStates.Dead:
			return
		
		if tux_stomp and hurt_by_stomp:
			stomp.get_parent().stomp_bounce()
			if not walking_and_holdable:
				death(false)
			else:
				if stomp.get_parent().get_real_velocity().y > 0 and wait_to_collide <= 0:
					if current_iceblock_state == IceblockStates.Normal or current_iceblock_state == IceblockStates.MovingFlat:
						current_iceblock_state = IceblockStates.Flat
						wait_to_collide = 0.25
						$SquishSound.play()
					elif current_iceblock_state == IceblockStates.Flat:
						current_iceblock_state = IceblockStates.MovingFlat
						direction = TuxManager.facing_direction
						wait_to_collide = 0.25
						$KickSound.play()
					print("Damaged enemy")
		elif tux_stomp and not hurt_by_stomp:
			print("Cannot hurt enemies that have hurt_by_stomp set to false.")
	if stomp == null and not tux == null and fireball == null and iceblock == null:
		if not walking_and_holdable or not hurt_by_stomp:
			tux.damage()
		elif walking_and_holdable:
			if wait_to_collide <= 0:
				if current_iceblock_state == IceblockStates.MovingFlat or current_iceblock_state == IceblockStates.Normal:
					tux.damage()
				elif current_iceblock_state == IceblockStates.Flat:
					if Input.is_action_pressed("player_action") and tux.held_object == null: # tux.held_object == null is needed here so the enemy can still be kicked by tux if tux is holding an object
						tux.hold_object(self)
					else: # TODO: code is copy and pasted from next else: thing. this needs to be fixed at some point, but it's ok to keep for now.
						$KickSound.play()
						direction = TuxManager.facing_direction
						current_iceblock_state = IceblockStates.MovingFlat
						wait_to_collide = 0.25
				else:
					$KickSound.play()
					direction = TuxManager.facing_direction
					current_iceblock_state = IceblockStates.MovingFlat
					wait_to_collide = 0.25
	if stomp == null and tux == null and not fireball == null and iceblock == null:
		fireball.queue_free()
		burn()
	if stomp == null and tux == null and fireball == null and not iceblock == null:
		if current_iceblock_state == IceblockStates.Held and kill_other_enemies and kill_self_on_touching_enemy and not iceblock == self: # the "checking name thing" is actually a hack. this file is so cursed.
			iceblock.death(true)
			death(true)
		elif current_iceblock_state == IceblockStates.MovingFlat:
			iceblock.death(true)

func wake_up():
	if spiky and sleeping:
		$WakeUpShapecast.enabled = false
		$WakeUpShapecast.visible = false
		print(name + " is waking up.")
		$Image.play("waking_up")
	else:
		push_warning("Tried to wake up an enemy that isn't a Spiky.")

func pick_up(tux: CharacterBody2D):
	current_iceblock_state = IceblockStates.Held
	held_by = tux

func throw(tux_direction:int):
	current_iceblock_state = IceblockStates.MovingFlat
	$KickSound.play()
	direction = tux_direction
	held_by = null
	wait_to_collide = 0.25

func burn():
	if flammable:
		death(true)

# For scripting block.
func set_scripted_spawn_direction(dir:bool):
	if not dir:
		direction = -1
	if dir:
		direction = 1

# For scripting block. May not work for an enemy that isn't Spiky, but if I try to make it not work for non-Spikys, it doesn't work for Spikys. At least when spawning them.
func set_sleeping():
	sleeping = true

func _on_wake_up_finished():
	if $Image.animation == "waking_up":
		print("Finished waking up!")
		$Image.play("walk")
		sleeping = false

func _on_flying_timer_timeout():
	if not current_state == EnemyStates.Dead:
		print("Flying timer timeout. Restarting...")
		if flying: 
			velocity.y = velocity.y * -1
			print(velocity.y * -1)
		else:
			print(name + " is not flying.")
