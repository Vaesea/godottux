extends CharacterBody2D
class_name BadGuy

# TODO: Make Iceblock enemy kill enemies that are off-screen.
# TODO: Improve Spiky ground detection to be more like SuperTux.
# TODO: Add Mr Tree stuff from Mr Tree
# TODO: Clean up. Entire code. Before release. It's literally over 600 lines.

# hi. anatolystev here.
# i might've, you know, made everything be like the haxeflixel version.
# because there were too much bugs before doing this.

# HACK because everything is a HACK
var stalactite = false

# States for evey enemy.
enum EnemyStates {Alive, Dead}
var current_state:EnemyStates = EnemyStates.Alive

# TODO: Add actual name
var lmao:bool = false

# States for Iceblock Enemies
enum IceblockStates {Normal, Flat, MovingFlat, Held}

# Variables for Iceblock Enemies
var current_iceblock_state:IceblockStates = IceblockStates.Normal
var wait_to_collide:float = 0
var held_by:CharacterBody2D = null

# Falling
var dieFall:bool = false

# Movement
@export var speed:int = 80

# i have no idea how this managed to work but i think my brain might have grown
# nevermind my brain is still small and smooth. at least this works.
var was_on_wall:bool = false

# How long does the corpse stay on screen?
var death_timer:int = 2

# For Iceblocks and explosions
var kill_other_enemies:bool = false

# For Iceblocks
var kill_self_on_touching_enemy:bool = false

@export_category("Enemy")
## -1 = left, 1 = right, any other variable isn't tested.
@export var direction:int = -1
## Can the enemy be burned?
@export var flammable:bool = true
## Can the enemy be frozen?
@export var freezable:bool = true
## Can the enemy be killed? (Does nothing right now)
@export var killable:bool = true

@export_category("Enemy Setup (Only Select One and Smart (if enemy is smart))")
## Is the enemy just a basic walking enemy (Goomba-like)? If you're making an enemy, it's best to change this in the enemy's script.
@export var basic_walking:bool = false
## Is the enemy smart If you're making an enemy, it's best to change this in the enemy's script.
@export var smart:bool = false
## Is the enemy just a basic walking enemy that can be held and thrown? (Koopa-like) If you're making an enemy, it's best to change this in the enemy's script.
@export var walking_and_holdable:bool = false
## Is the enemy Snail-like? "Walking and Holdable" need to be true for this to work. If you're making an enemy, it's best to change this in the enemy's script.
@export var jump_when_hit_wall_or_thrown:bool = false
## Is the enemy a bullet? (Bullet Bill-like). Not added yet. If you're making an enemy, it's best to change this in the enemy's script.
@export var bullet:bool = false
## Is the enemy Spiky-like? If you're making an enemy, it's best to change this in the enemy's script.
@export var spiky:bool = false
## Is the enemy Jumpy-like? If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
@export var jumpy:bool = false
## Does the enemy fly? If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
@export var flying:bool = false
## Is the enemy an explosion? Probably shouldn't have made this an export but whatever. If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
@export var explosion:bool = false
## Is the enemy a bouncing enemy? If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
## [br]
## Side note, Bouncing Snowballs can go to hell. It was not fun adding them.
@export var bouncing:bool = false
## Is the enemy a bomb? If you're making an enemy, it's best to change this in the enemy's script.
@export var bomb:bool = false
## Can the enemy be hurt by stomping on it? If you're making an enemy, it's best to change this in the enemy's script.
@export var hurt_by_stomp:bool = true

@export_category("Spiky variables")
## Is the Spiky sleeping?
@export var sleeping:bool = false

@export_category("Jumpy variables")
## Jumpy jump height
@export var jump_height:int = 600

@export_category("Bouncing Enemy variables")
## Bounce height
@export var bounce_height:int = 450

@export_category("Iceblock variables")
## How fast the Iceblock moves when in MovingFlat state
@export var movingflat_speed:int = 500
## for snail enemies or something i really dont know anymore i'm going insane
@export var hit_wall_jump_height:int = 256

@export_category("Flying Enemy variables")
## How fast at flying is the flying enemy?
@export var fly_speed:int = 100

@export_category("Bullet Variables")
## Does the bullet explode when hitting a wall? Also makes the enemy explode when hit by a fireball or an Iceblock because it's really only used for Mr Rockets.
@export var explode_on_hit_wall:bool = false
@export var wait_before_exploding_on_wall:float = 0.2

@export_category("Ground Detector X Position")
## X of Ground Detector when direction is left
@export var ground_detector_position_x_when_left:float = 5.0
## X of Ground Detector when direction is right
@export var ground_detector_position_x_when_right:float = 34.0

@export_category("Wake Up Area X Position")
## X of Wake Up Area when direction is left
@export var wake_up_shapecast_position_x_when_left:float = 0.0
## X of Wake Up Area when direction = right
@export var wake_up_shapecast_position_x_when_right:float = 32.0

@export_category("Collision X Position")
## X of Collision + Tux Detector when direction is left
@export var collision_position_x_when_left:float = 21.5
## X of Collision + Tux Detector when direction is right
@export var collision_position_x_when_right:float = 38.5

@onready var collision = $Collision

# Explosion variable
var explosion_spawned:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Adding things to group.
	add_to_group("Enemy")
	$TuxDetector.add_to_group("StupidThing")
	# Connecting signals.
	$TuxDetector.area_entered.connect(_on_tux_detector_area_entered)
	$TuxDetector.body_entered.connect(_on_tux_detector_body_entered)
	if spiky and sleeping: # If Spiky AND Sleeping, connect this.
		$Image.connect("animation_finished", _on_wake_up_finished)
	if bomb: # If Bomb, connect this.
		$Image.connect("animation_finished", _on_ticking_finished)
	if explosion: # If Explosin, connect this.
		$Image.connect("animation_finished", _on_explosion_animation_finished)
		$ExplosionSound.connect("finished", _on_explosion_sound_finished)
	if flying: # If Flying, connect this.
		$FlyingTimer.connect("timeout", _on_flying_timer_timeout)
	if bouncing or flying: # If Bouncing, connect these. I still hate Bouncing Snowballs, before you ask.
		$TuxDetector2.connect("area_entered", _on_tux_stomp_area_detected)
		$TuxDetector2.add_to_group("BouncingEnemyTuxDetector") # Now with a different name!
	if flying or jumpy: # If Flying or Jumpy, connect these.
		$LeftDetector.connect("body_entered", _on_tux_detected_left)
		$RightDetector.connect("body_entered", _on_tux_detected_right)
	if walking_and_holdable: # If Walking And Holdable, connect these.
		$ScreenCheck.connect("screen_entered", _on_iceblock_entered_screen)
		$ScreenCheck.connect("screen_exited", _on_iceblock_exited_screen)

	# Looks scary, let me explain it.
	# If Spiky but not sleeping, don't do shapecast wall / player detection.
	# If Spiky and sleeping, play sleeping animation. Shapecast stuff will be done.
	# If not Spiky, not Jumpy or not flying, play walk animation.
	# If not flying, play fly animation.
	# If explosion, play default animation.
	if spiky and not sleeping and not jumpy and not flying and not explosion and not bullet:
		$WakeUpShapecast.enabled = false
		$WakeUpShapecast.visible = false
		$Image.play("walk")
	elif spiky and sleeping and not jumpy and not flying and not explosion and not bullet:
		$Image.play("sleep")
	elif not spiky and not sleeping and not jumpy and not flying and not explosion and not bullet:
		$Image.play("walk")
	elif not spiky and not sleeping and not jumpy and flying and not explosion and not bullet:
		$Image.play("fly")
	elif not spiky and not sleeping and not jumpy and not flying and not explosion and not bullet:
		$Image.play("default")
	elif not spiky and not sleeping and not jumpy and not flying and explosion and not bullet:
		$Image.play("default")
	elif not spiky and not sleeping and not jumpy and not flying and not explosion and bullet:
		$Image.play("flying")
	
	# If flying, go up.
	if flying:
		velocity.y = -fly_speed

	# TODO: Is this needed?
	current_state = EnemyStates.Alive

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Iceblock wait_to_collide timer thing.
	if wait_to_collide > 0:
		wait_to_collide -= delta
	
	# If Walking And Holdable, and the current Iceblock state is normal, and not on screen, don't do physics_process.
	if walking_and_holdable and current_iceblock_state == IceblockStates.Normal and not $ScreenCheck.is_on_screen():
		set_physics_process(false)
	
	# If the enemy is flying and dead, it's considered "dead_flying"
	var dead_flying = flying and current_state == EnemyStates.Dead
	
	# If the enemy is bullet and dead (by being squished), it's considered "dead_bullet"
	var dead_bullet = bullet and current_state == EnemyStates.Dead
	
	# Adds gravity. Add any enemy that needs gravity here.
	if basic_walking or walking_and_holdable or spiky or jumpy or dead_flying or dead_bullet or bouncing or bomb:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	move()
	
	# If the enemy explodes on hitting a wall, and actually hits the wall, it dies.
	if explode_on_hit_wall and is_on_wall() and not was_on_wall and current_state == EnemyStates.Alive:
		if bullet:
			$Image.play("collision")
			await get_tree().create_timer(wait_before_exploding_on_wall).timeout
		death(true)
	
	# If the enemy is Walking And Holdable...
	if walking_and_holdable:
		# If Moving Flat, kill other enemies but don't kill self on touching enemy, also collide with walls.
		if current_iceblock_state == IceblockStates.MovingFlat:
			kill_other_enemies = true
			kill_self_on_touching_enemy = false
			set_collision_mask_value(1, true)
			set_collision_mask_value(9, true)
		# If held, kill other enemies, kill self on touching enemy, and don't collide with walls.
		elif current_iceblock_state == IceblockStates.Held:
			kill_other_enemies = true
			kill_self_on_touching_enemy = true
			set_collision_mask_value(1, false)
			set_collision_mask_value(9, false)
		# If none of these, don't kill other enemies, don't kill self on touching enemy and collide with walls.
		else:
			kill_other_enemies = false
			kill_self_on_touching_enemy = false
			set_collision_mask_value(1, true)
		# If Flat, MovingFlat or Held, play flat animation.
		if current_iceblock_state == IceblockStates.Flat or current_iceblock_state == IceblockStates.MovingFlat or current_iceblock_state == IceblockStates.Held:
			$Image.play("flat")
		# If Normal, play walk animation.
		else:
			$Image.play("walk")
	# If not walking and holdable, check for any of these other things.
	# If explosion, kill other enemies but don't kill self on touching enemy.
	elif explosion:
		kill_other_enemies = true
		kill_self_on_touching_enemy = false
	# If none of these, don't kill other enemies and don't kill self on touching enemy.
	else:
		kill_other_enemies = false
		kill_self_on_touching_enemy = false
	
	# If touching wall and was not touching a wall last frame, flip direction.
	if is_on_wall() and not was_on_wall and not explode_on_hit_wall:
		flip_direction()
	elif is_on_wall() and explode_on_hit_wall:
		death(true)
	
	# If direction is -1 (left), don't flip image.
	if direction == -1:
		$Image.flip_h = false
	# If direction is 1 (right) or any invalid direction, flip image.
	else:
		$Image.flip_h = true
	
	# If smart, not dead and on floor, do these things.
	if smart and not current_state == EnemyStates.Dead and is_on_floor():
		# If GroundDetector is not colliding with the ground and the current Iceblock state 
		# for this enemy is Normal, flip direction.
		if not $GroundDetector.is_colliding() and current_iceblock_state == IceblockStates.Normal:
			flip_direction()
		
		# If direction is -1 (left), set Ground Detector's x position to the variable here.
		if direction == -1:
			$GroundDetector.position.x = ground_detector_position_x_when_left
		# If direction is 1 (right) or any invalid direction, set Ground Detector's x position to the variable here.
		else:
			$GroundDetector.position.x = ground_detector_position_x_when_right
	
	# If the enemy is a Sleeping Spiky, do the Shapecast stuff.
	if sleeping and spiky:
		# If direction is left, set shapecast's position and default shapecast target position.
		if direction == -1:
			$WakeUpShapecast.position.x = wake_up_shapecast_position_x_when_left
			$WakeUpShapecast.target_position.x = -512.0
		# If direction is right, set shapecast's position and default shapecast target position.
		elif direction == 1:
			$WakeUpShapecast.position.x = wake_up_shapecast_position_x_when_right
			$WakeUpShapecast.target_position.x = 1024.0
		
		# Force the shapecast to update
		$WakeUpShapecast.force_shapecast_update()
		
		# If the shapecast is colliding, make it's target position be the nearest thing, and if the nearest thing is the player, wake up.
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
	
	# FIXME: badguy.gd:362 @ _physics_process(): Parameter "body->get_space()" is null. Might be something to do with Mr Rocket?
	move_and_slide()

func flip_direction():
	print(name + ": Flipping direction...")
	direction = -direction

func move():
	var sleeping_spiky = spiky and sleeping
	
	if sleeping_spiky or current_state == EnemyStates.Dead:
		velocity.x = 0
		return
	elif spiky and not sleeping and not current_state == EnemyStates.Dead:
		velocity.x = direction * speed
	
	# If the enemy isn't dead, continue with the if statement.
	if not current_state == EnemyStates.Dead:
		# Add any enemy that needs to move to the left / right to this variable except if it has special states that decide when it moves or not, like walking_and_holdable enemies.
		var basic_moving_enemy = basic_walking or bouncing or bomb or bullet
		# If the enemy is part of the variable above, do this. Don't know why "and not walking_and_holdable" is there, though. TODO: Find out whether that's needed.
		if basic_moving_enemy and not walking_and_holdable:
			velocity.x = direction * speed
			if bouncing:
				if is_on_floor():
					velocity.y = -bounce_height
		# If the enemy is walking and holdable, continue with this.
		elif walking_and_holdable:
			# If the current iceblock state is Normal, move like a basic moving enemy.
			if current_iceblock_state == IceblockStates.Normal:
				velocity.x = direction * speed
			# Or if the current iceblock state is Flat or Held, don't move.
			elif current_iceblock_state == IceblockStates.Flat or current_iceblock_state == IceblockStates.Held:
				velocity.x = 0
				# If the current iceblock state is Held, velocity.y should be set to 0.
				if current_iceblock_state == IceblockStates.Held:
					velocity.y = 0
			# Or if the current iceblock state is MovingFlat, move like a basic moving enemy but at movingflat speed.
			elif current_iceblock_state == IceblockStates.MovingFlat:
				velocity.x = direction * movingflat_speed
		# If the enemy is Jumpy and is on the floor, jump.
		elif jumpy:
			if is_on_floor(): # TODO: Can this be combined with the elif jumpy?
				velocity.y = -jump_height
				$Image.play("jump")

func death(fall:bool):
	print(name + " died.")
	current_state = EnemyStates.Dead
	$TuxDetector.set_deferred("monitoring", false)
	$TuxDetector.set_deferred("monitorable", false)
	if jumpy or flying or bouncing:
		velocity.y = 0
	
	if fall:
		if bomb or explode_on_hit_wall:
			spawn_explosion()
			return
		
		held_by = null
		if walking_and_holdable:
			current_iceblock_state = IceblockStates.Flat
			print("iceblock died.")
		velocity.x = 0
		$Collision.set_deferred("disabled", true)
		$Image.flip_v = true
		$FallSound.play()
	else:
		set_collision_layer_value(4, true)
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)
		if bomb:
			spawn_explosion()
			return
		$SquishSound.play()
		$Image.play("squished")
		await get_tree().create_timer(death_timer).timeout
		queue_free()

func _on_tux_detector_area_entered(area) -> void:
	if area.is_in_group("Stomp") and not spiky and not jumpy and not bouncing and not flying and not current_state == EnemyStates.Dead: # bouncing and flying snowballs handle it themselves because of a bug!!!
		interact(area, null, null, null)
	
	if area.is_in_group("StupidThing") and not area.get_parent() == self and not area.get_parent().stalactite:
		interact(null, null, null, area.get_parent())

func _on_tux_detector_body_entered(body) -> void:
	if body.is_in_group("Player") and current_iceblock_state == IceblockStates.Held:
		return
	
	if body.is_in_group("Player") and not current_state == EnemyStates.Dead and not wait_to_collide > 0 and not lmao: # wow.
		interact(null, body, null, null)
	elif body.is_in_group("FireBullet") and not current_state == EnemyStates.Dead:
		interact(null, null, body, null)
	elif body.is_in_group("Enemy") and not current_state == EnemyStates.Dead and kill_other_enemies and not body.get_parent() == self: # wow 2.
		interact(null, null, null, body)

func interact(stomp, tux, fireball, iceblock):
	if not stomp == null and tux == null and fireball == null and iceblock == null:
		var tux_stomp = stomp.get_parent().get_real_velocity().y > 0 # why is this "get_real_velocity"?
		
		if current_state == EnemyStates.Dead:
			return
		
		if tux_stomp and hurt_by_stomp:
			if not Global.tux_star_invincible:
				stomp.get_parent().stomp_bounce()
			else:
				death(true)
			if bomb:
				$SquishSound.play()
				$Image.play("ticking")
				$TuxDetector.set_deferred("monitoring", false)
				current_state = EnemyStates.Dead
				return
			if not walking_and_holdable:
				if not Global.tux_star_invincible:
					death(false)
				else:
					death(true)
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
	if stomp == null and not tux == null and fireball == null and iceblock == null: # when will i finally clean up this god damn code
		# I think I went insane writing this code when adding Bouncing Snowball... TODO: Add actual variable name.
		var wtf = basic_walking or flying or bomb or bullet
		var thing = bouncing or flying # TODO: Add actual variable name.
		if thing and not walking_and_holdable:
			print(lmao)
			await get_tree().create_timer(0.01).timeout # HACK: stupid bouncing snowball. i hate it.
			print(lmao)
			if not lmao:
				if not Global.tux_star_invincible:
					tux.damage()
				else:
					death(true)
		elif wtf and not walking_and_holdable:
			if hurt_by_stomp and not lmao:
				if not Global.tux_star_invincible:
					tux.damage()
				else:
					death(true)
		elif not hurt_by_stomp:
			if not Global.tux_star_invincible:
				tux.damage()
			else:
				death(true)
			
		elif walking_and_holdable:
			if wait_to_collide <= 0:
				if current_iceblock_state == IceblockStates.MovingFlat or current_iceblock_state == IceblockStates.Normal:
					if not Global.tux_star_invincible:
						tux.damage()
					else:
						death(true)
				elif current_iceblock_state == IceblockStates.Flat:
					if Input.is_action_pressed("player_action") and tux.held_object == null: # tux.held_object == null is needed here so the enemy can still be kicked by tux if tux is holding an object
						if not Global.tux_star_invincible:
							tux.hold_object(self)
						else:
							death(true)
					else: # TODO: code is copy and pasted from next else: thing. this needs to be fixed at some point, but it's ok to keep for now.
						if not Global.tux_star_invincible:
							$KickSound.play()
							direction = TuxManager.facing_direction
							current_iceblock_state = IceblockStates.MovingFlat
							wait_to_collide = 0.25
						else:
							death(true)
				else:
					if not Global.tux_star_invincible:
						$KickSound.play()
						direction = TuxManager.facing_direction
						current_iceblock_state = IceblockStates.MovingFlat
						wait_to_collide = 0.25
					else:
						death(true)
	if stomp == null and tux == null and not fireball == null and iceblock == null:
		fireball.queue_free()
		burn()
	if stomp == null and tux == null and fireball == null and not iceblock == null: # is "iceblock" misleading?
		if walking_and_holdable:
			if current_iceblock_state == IceblockStates.Held and kill_other_enemies and kill_self_on_touching_enemy and not iceblock == self: # the "checking name thing" is actually a HACK. this file is so cursed.
				iceblock.death(true)
				death(true)
			elif current_iceblock_state == IceblockStates.MovingFlat:
				if not iceblock.stalactite:
					iceblock.death(true)
		elif explosion:
			if kill_other_enemies and not iceblock == self:
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

func _on_ticking_finished():
	if $Image.animation == "ticking":
		print("Finished ticking, must explode.")
		death(false)

func _on_explosion_animation_finished():
	if $Image.animation == "default":
		print("Finished exploding animation, must set visible to false.")
		$Image.visible = false
		$TuxDetector.set_deferred("monitoring", false)

func _on_explosion_sound_finished():
	print("Finished exploding sound, must queue_free()")
	queue_free()

func _on_flying_timer_timeout():
	if not current_state == EnemyStates.Dead:
		print("Flying timer timeout. Restarting...")
		if flying: 
			velocity.y = velocity.y * -1
			print(velocity.y * -1)
		else:
			print(name + " is not flying.")

# HACK (possibly), Bouncing Snowballs are horrible. Same with Flying Snowballs.
func _on_tux_stomp_area_detected(area):
	if not current_state == EnemyStates.Dead:
		print("You Made It BIG TIME!")
		if area.is_in_group("Stomp"):
			if not Global.tux_star_invincible:
				area.get_parent().position.y -= 1 # TODO: Is this needed? Adding it seemed to do nothing. Also it seems pretty HACK-like. Also I swear this is human stupidity.
				lmao = true
				$TuxDetector.monitoring = false
				area.get_parent().stomp_bounce()
				death(false)
				lmao = false
			else:
				death(true)

func _on_tux_detected_left(body):
	if body.is_in_group("Player") and current_state == EnemyStates.Alive:
		print(name + ": Looking to the left...")
		direction = -1

func _on_tux_detected_right(body):
	if body.is_in_group("Player") and current_state == EnemyStates.Alive:
		print(name + ": Looking to the right...")
		direction = 1

func spawn_explosion():
	if not explosion_spawned: # Fixes a bug where Mr Rocket would spawn two explosion, because something has to go wrong every time I add a new enemy.
		explosion_spawned = true
		var explosion2 = load("uid://c4wavr8ykqj4p").instantiate()
		get_tree().current_scene.call_deferred("add_child", explosion2)
		explosion2.position = self.position
		queue_free()

func _on_iceblock_entered_screen():
	print(name + ": Entered screen")
	set_physics_process(true)
	print(name + str(process_mode))

func _on_iceblock_exited_screen():
	print(name + ": Exited screen")
	if not current_iceblock_state == IceblockStates.MovingFlat:
		set_physics_process(false)
		print(name + str(process_mode))
