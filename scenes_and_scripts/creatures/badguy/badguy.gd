extends CharacterBody2D

class_name BadGuy

# TODO: Make Iceblock enemy kill enemies that are off-screen.
# TODO: Improve Spiky ground detection to be more like SuperTux.
# TODO: Clean up. Entire code. Before release.

# hi. anatolystev here.
# i might've, you know, made everything be like the haxeflixel version.
# because there were too much bugs before doing this.

# States for evey enemy.
enum EnemyStates {Alive, Dead}
var current_state = EnemyStates.Alive

var lmao = false

# States for Iceblock Enemies
enum IceblockStates {Normal, Flat, MovingFlat, Held}

# Variables for Iceblock Enemies
var current_iceblock_state = IceblockStates.Normal
var wait_to_collide = 0
var held_by:CharacterBody2D = null

# Variables for stalactites
var crash_sound_played = false
var cracking = false

# Falling
var dieFall = false

# Movement
@export var speed = 80

# i have no idea how this managed to work but i think my brain might have grown
# nevermind my brain is still small and smooth. at least this works.
var was_on_wall = false

# How long does the corpse stay on screen?
var death_timer = 2

# For Iceblocks and explosions
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
## Is the enemy a bouncing enemy? If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
## [br]
## Side note, Bouncing Snowballs can go to hell. It was not fun adding them.
@export var bouncing = false
## Is the enemy a stalactite? If you're making an enemy, it's best to change this in the enemy's script. If you set this to true, don't set smart to true.
@export var stalactite = false
## Is the enemy a bomb? If you're making an enemy, it's best to change this in the enemy's script.
@export var bomb = false
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
@export var bounce_height = 450

@export_category("Iceblock variables")
## How fast the Iceblock moves when in MovingFlat state
@export var movingflat_speed = 500
## for snail enemies or something i really dont know anymore i'm going insane
@export var hit_wall_jump_height = 256

@export_category("Flying Enemy variables")
## How fast at flying is the flying enemy?
@export var fly_speed = 100

@export_category("Stalactite Variables")
## How long should the stalactite shake for before falling?
@export var shake_timer = 1
var falling = false

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
	if bomb:
		$Image.connect("animation_finished", _on_ticking_finished)
	if explosion:
		$Image.connect("animation_finished", _on_explosion_animation_finished)
		$ExplosionSound.connect("finished", _on_explosion_sound_finished)
	if flying:
		$FlyingTimer.connect("timeout", _on_flying_timer_timeout)
	if bouncing:
		$TuxDetector2.connect("area_entered", _on_tux_stomp_area_detected)
		$TuxDetector2.add_to_group("BouncingEnemyTuxDetector") # Now with a different name!
	if flying or jumpy:
		$LeftDetector.connect("body_entered", _on_tux_detected_left)
		$RightDetector.connect("body_entered", _on_tux_detected_right)
	if walking_and_holdable:
		$ScreenCheck.connect("screen_entered", _on_iceblock_entered_screen)
		$ScreenCheck.connect("screen_exited", _on_iceblock_exited_screen)

	# Looks scary, let me explain it.
	# If Spiky but not sleeping, don't do shapecast wall / player detection.
	# If Spiky and sleeping, play sleeping animation. Shapecast stuff will be done.
	# If not Spiky, not Jumpy, not flying or stalactite, play walk.
	# If not flying, play fly.
	# If stalactite, play default.
	# If explosion, play default.
	if spiky and not sleeping and not jumpy and not flying and not stalactite and not explosion:
		$WakeUpShapecast.enabled = false
		$WakeUpShapecast.visible = false
		$Image.play("walk")
	elif spiky and sleeping and not jumpy and not flying and not stalactite and not explosion:
		$Image.play("sleep")
	elif not spiky and not sleeping and not jumpy and not flying and not stalactite and not explosion:
		$Image.play("walk")
	elif not spiky and not sleeping and not jumpy and flying and not stalactite and not explosion:
		$Image.play("fly")
	elif not spiky and not sleeping and not jumpy and not flying and stalactite and not explosion:
		$Image.play("default")
	elif not spiky and not sleeping and not jumpy and not flying and not stalactite and explosion:
		$Image.play("default")
	
	# If flying, go up.
	if flying:
		velocity.y = -fly_speed
	
	current_state = EnemyStates.Alive
	
	# Debugging thing.
	if stalactite:
		print("OH GOD NO THERE'S A STALACTITE IN THE LEVEL RUN, NAME OF IT IS: " + name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Iceblock thing.
	if wait_to_collide > 0:
		wait_to_collide -= delta
	
	if walking_and_holdable and current_iceblock_state == IceblockStates.Normal and not $ScreenCheck.is_on_screen():
		set_physics_process(false)
	
	# If the enemy is flying and dead, it's considered "dead_flying"
	var dead_flying = flying and current_state == EnemyStates.Dead
	
	# Adds gravity. Add any enemy that needs gravity here.
	if basic_walking or walking_and_holdable or spiky or jumpy or dead_flying or bouncing or stalactite or bomb:
		if stalactite and current_state == EnemyStates.Alive:
			if not is_on_floor() and falling:
				velocity += get_gravity() * delta
			elif is_on_floor() and falling:
				velocity.y = 0
				current_state = EnemyStates.Dead
		else:
			if not is_on_floor():
				velocity += get_gravity() * delta
	
	# If the enemy is not a stalactite, it does the move function.
	if not stalactite:
		move()
	
	# If the enemy is a stalactite, it's falling and it's on the floor, it dies.
	if stalactite and falling:
		if is_on_floor():
			death(false)
	
	if walking_and_holdable:
		if current_iceblock_state == IceblockStates.MovingFlat:
			kill_other_enemies = true
			kill_self_on_touching_enemy = false
			set_collision_mask_value(1, true)
		elif current_iceblock_state == IceblockStates.Held:
			kill_other_enemies = true
			kill_self_on_touching_enemy = true
			set_collision_mask_value(1, false)
		else:
			kill_other_enemies = false
			kill_self_on_touching_enemy = false
			set_collision_mask_value(1, true)
		if current_iceblock_state == IceblockStates.Flat or current_iceblock_state == IceblockStates.MovingFlat or current_iceblock_state == IceblockStates.Held:
			$Image.play("flat")
		else:
			$Image.play("walk")
	elif explosion:
		kill_other_enemies = true
		kill_self_on_touching_enemy = false
	elif stalactite:
		kill_other_enemies = true
		kill_self_on_touching_enemy = false
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
	
	if stalactite and not falling:
		$FloorDetector.target_position.y = 512.0
		$FloorDetector.force_shapecast_update()
		
		if $FloorDetector.is_colliding():
			for collision in range($FloorDetector.get_collision_count()):
				$FloorDetector.target_position.y = $FloorDetector.get_collision_point(collision).y - $FloorDetector.global_position.y
				if $FloorDetector.get_collider(collision) and $FloorDetector.get_collider(collision).is_in_group("Player"):
					print(name + ": Player detected!")
					start_fall()
			
	
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
		var basic_moving_enemy = basic_walking or bouncing or bomb
		if basic_moving_enemy and not walking_and_holdable:
			velocity.x = direction * speed
			if bouncing:
				if is_on_floor():
					velocity.y = -bounce_height
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
	print(name + " died.")
	current_state = EnemyStates.Dead
	$TuxDetector.set_deferred("monitoring", false)
	$TuxDetector.set_deferred("monitorable", false)
	if jumpy or flying or bouncing:
		velocity.y = 0
	
	if fall:
		if stalactite: # Literally nothing else worked. You can probably see where I've tried other stuff for this.
			$MeltSound.play()
			start_fall()
			return
		if bomb:
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
		if not stalactite:
			$SquishSound.play()
			$Image.play("squished")
		if stalactite:
			if not crash_sound_played:
				$CrashSound.play(0.17)
			crash_sound_played = true
			$Image.play("broken")
		await get_tree().create_timer(death_timer).timeout
		queue_free()

func _on_tux_detector_area_entered(area) -> void:
	if area.is_in_group("Stomp") and not spiky and not jumpy and not bouncing and not current_state == EnemyStates.Dead: # bouncing snowballs handle it themselves because of a bug!!!
		print("if bouncing snowball and this happened and you hit the stomp area, bug happened!")
		interact(area, null, null, null)
	
	if area.is_in_group("StupidThing") and not area.get_parent() == self:
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
		var tux_stomp = stomp.get_parent().get_real_velocity().y > 0
		
		if current_state == EnemyStates.Dead:
			return
		
		if tux_stomp and hurt_by_stomp:
			stomp.get_parent().stomp_bounce()
			if bomb:
				$SquishSound.play()
				$Image.play("ticking")
				$TuxDetector.set_deferred("monitoring", false)
				current_state = EnemyStates.Dead
				return
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
	if stomp == null and not tux == null and fireball == null and iceblock == null: # when will i finally clean up this god damn code
		var wtf = basic_walking or flying or bomb
		if bouncing and not walking_and_holdable:
			print(lmao)
			await get_tree().create_timer(0.01).timeout # HACK: stupid bouncing snowball. i hate it.
			print(lmao)
			if not lmao:
				tux.damage()
		elif wtf and not walking_and_holdable:
			if hurt_by_stomp and not lmao:
				tux.damage()
		elif not hurt_by_stomp:
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
		if walking_and_holdable:
			if current_iceblock_state == IceblockStates.Held and kill_other_enemies and kill_self_on_touching_enemy and not iceblock == self: # the "checking name thing" is actually a HACK. this file is so cursed.
				iceblock.death(true)
				death(true)
			elif current_iceblock_state == IceblockStates.MovingFlat:
				iceblock.death(true)
		elif stalactite or explosion:
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
	if flammable and not stalactite:
		print("if stalactite, something went wrong.")
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

func start_fall():
	if flammable:
		flammable = false
	
	if stalactite and not cracking:
		cracking = true
		$FloorDetector.enabled = false
		$FloorDetector.visible = false
		$AnimationTween.play("shake")
		if not $CrackSound.playing:
			$CrackSound.play()
		await get_tree().create_timer(shake_timer).timeout
		$AnimationTween.play("RESET")
		falling = true
		print(falling)

func _on_tux_stomp_area_detected(area):
	if not current_state == EnemyStates.Dead:
		print("You Made It BIG TIME!")
		if area.is_in_group("Stomp"):
			area.get_parent().position.y -= 1
			lmao = true
			$TuxDetector.monitoring = false
			area.get_parent().stomp_bounce()
			death(false)
			lmao = false

func _on_tux_detected_left(body):
	if body.is_in_group("Player") and current_state == EnemyStates.Alive:
		print(name + ": Looking to the left...")
		direction = -1

func _on_tux_detected_right(body):
	if body.is_in_group("Player") and current_state == EnemyStates.Alive:
		print(name + ": Looking to the right...")
		direction = 1

func spawn_explosion():
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
