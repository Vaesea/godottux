extends CharacterBody2D

# code from adel time
# im too lazy to add comments right now
# still too lazy
# yet again, still too lazy

# Added Coyote Timer with help from this tutorial: https://www.youtube.com/watch?v=bJOpkFIEwCA

# TODO: Save Tux's max fire bullet amount or something idk
# TODO: Stop camera from following Tux when Tux dies

# AnatolyStev here. Added skidding
# AnatolyStev here. Made it so rocks don't softlock Tux.
# AnatolyStev here. Added backflipping and some extra cool stuff.
# TODO: Make it so Tux doesn't go down when hit on the head with a rock. As you can see, I tried.

# vaesea note: i have no idea what the above todo is about

# Movement
## Tux's speed. You should probably change acceleration and deceleration if you change this.
@export var speed:int = 320
@export_range(0, 0.1) var acceleration:float = 0.06
@export_range(0, 0.1) var deceleration:float = 0.06
## Maximum jump height variable. Should be larger than the Min Jump Height variable.
@export var max_jump_height:int = 576
## Minimum jump height variable. Should be smaller than the Max Jump Height variable.
@export var min_jump_height:float = 512.0 # this is a float just to avoid a warning
## Set this to something like 0.5 for a better variable jump height.
@export var decelerate_on_jump_release:int = 0
## How fast Tux goes when backflipping.
@export var backflip_speed:int = 100

# Cutscene / scripting variables.
var in_cutscene:bool = false
var auto_walk:bool = false
var auto_walk_speed:int = 0 # Don't change this. Scripting already does.

# this needs to be done due to scripting
@onready var camera = $Camera

# i'm just gonna use onready variables everywhere i guess idk
@onready var coyote_timer = $CoyoteTimer
@onready var tile_timer = $TileTimer

# Invincible variables
var inv_seconds:int = 1
var invincible:bool = false

# Holding objects variable
var held_object = null

# Skid variables
var skid:bool = false
@export var how_fast_to_skid:int = 200
@export_range(0, 0.1) var skid_deceleration:float = 0.01 # Doesn't seem to work?
@export var skid_speed:int = 35

# Powerup Bullet variables
var can_shoot_bullets:bool = true
var max_fireballs_allowed:int = 2

# Rock detecting variable
var rock_above:bool = false

# If the fireball Tux spawns will be more Mario-like or not.
@export var mario_fireballs:bool = false
# If the fireball Tux spawns will be more like new SuperTux versions (0.5+) or not.
@export var new_fireballs:bool = false

# Buttjump variable (buttjump is intentionally just a visual thing because 0.3.2)
var buttjump:bool = false

# Backflip variables
var backflip:bool = false
var was_on_floor:bool = false # Used literally just for the backflip... and now coyote time too???

# Duck variable
var duck:bool = false

# Jump buffering variables
@export var jump_buffer_time:float = 0.1
var jump_buffer_timer:float = 0.0

# Whether Tux is dead or not.
var dead:bool = false

# Dead variables
@export var dead_jump:int = 700
var restart_scene_timer:float = 3.0

# Whether Tux shows stars while not star_invincible or not
var show_stars:bool = false

## The sound that plays when getting the star.
@export_file("*.ogg", "*.wav") var get_star_sound = "res://assets/sounds/invincible_start.ogg"

## The music that plays when getting the star.
@export_file("*.ogg", "*.wav") var invincible_music = "res://assets/music/invincible.ogg"

func _ready() -> void:
	add_to_group("Player")
	$Stomp.add_to_group("Stomp")
	reload_player()
	$Stomp.connect("area_entered", _on_stompable_object_detected)
	$StarTimer.connect("timeout", _on_star_timer_done)
	$SmallStarsImage.play("default")
	$BigStarsImage.play("default")

func _physics_process(delta: float) -> void:
	if Global.debug:
		if Input.is_key_pressed(KEY_1):
			grow("egg")
		if Input.is_key_pressed(KEY_2):
			grow("fire_flower")
	
	if dead and Input.is_action_just_pressed("ui_cancel"):
		get_tree().call_deferred("reload_current_scene")
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if position.x < camera.limit_left:
		position.x = 0
	
	if position.y > camera.limit_bottom and not in_cutscene:
		die()
	
	for body in $RockDetector.get_overlapping_bodies():
		if body.is_in_group("Holdable"):
			var tux_under = body.global_position.y < global_position.y
			if tux_under and body.velocity.y > 0:
				global_position.y -= 2
				body.bounce()
	
	if position.x > camera.limit_right - $SmallCollision.shape.size.x:
		position.x = camera.limit_right - $SmallCollision.shape.size.x
	
	if not is_on_floor() and tile_timer.is_stopped():
		velocity += get_gravity() * delta
	
	if $RayCast2D.is_colliding():
		global_position.y -= 5
	
	if not in_cutscene:
		if dead:
			move_and_slide()
			return
		move()
		shoot()
	
	if auto_walk:
		velocity.x = TuxManager.facing_direction * auto_walk_speed
	
	if backflip:
		velocity.x = backflip_speed * -TuxManager.facing_direction
	
	if get_tree().get_nodes_in_group("FireBullet").size() >= max_fireballs_allowed:
		can_shoot_bullets = false
	else:
		can_shoot_bullets = true
	
	if not dead:
		animate()
	
	if Input.is_action_just_released("player_action") and not held_object == null and not held_object.held_by == null:
		throw_object()
	
	if in_cutscene and not held_object == null and not held_object.held_by == null:
		throw_object()
	
	move_and_slide()
	
	if was_on_floor and not is_on_floor() and not Input.is_action_pressed("player_jump"):
		coyote_timer.start()
		tile_timer.start()

func die():
	if not dead:
		dead = true
		if Global.tux_star_invincible:
			Music.stream = load(Global.sector_song)
			Music.play()
			Global.tux_star_invincible = false
		TuxManager.current_state = TuxManager.powerup_states.Small
		$FireImage.visible = false
		$BigImage.visible = false
		$SmallImage.visible = true
		set_collision_mask_value(1, false)
		set_collision_mask_value(9, false)
		set_collision_layer_value(32, true)
		set_collision_layer_value(2, false)
		$Stomp.set_deferred("monitorable", false)
		$Stomp.set_deferred("monitoring", false)
		$SmallImage.play("dead")
		$DeathSound.play(0.04)
		velocity.x = 0
		if Global.coins >= 25:
			Global.coins -= 25
		velocity.y = -dead_jump
		$FadeOut/AnimationTween.play("fade_out")
		await get_tree().create_timer(restart_scene_timer).timeout
		get_tree().call_deferred("reload_current_scene")

func move():
	if is_on_floor():
		if not was_on_floor:
			backflip = false
		buttjump = false
	
	was_on_floor = is_on_floor() # not sure if this is needed or not anymore? probably is.
	
	var direction := Input.get_axis("player_left", "player_right")
	var duck_on_floor = duck and is_on_floor()
	if backflip:
		return
	elif direction and not duck_on_floor and not backflip:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)

	if direction and not sign(velocity.x) == direction and abs(velocity.x) > how_fast_to_skid and not in_cutscene and is_on_floor() and not duck: # who the (bad fire place) starts a conversation like that, i just sat down!
		if not skid:
			if not $SkidSound.playing:
				$SkidSound.play()
			velocity.x += -direction * skid_speed
		
		skid = true
		velocity.x = move_toward(velocity.x, 0, speed * skid_deceleration)
	else:
		if skid and TuxManager.facing_direction == 1 and velocity.x >= 0:
			skid = false
		elif skid and TuxManager.facing_direction == -1 and velocity.x <= 0:
			skid = false
		if in_cutscene: # TODO: Is this needed?
			skid = false
	
	if in_cutscene:
		skid = false
	
	if not backflip:
		if direction == -1:
			TuxManager.facing_direction = -1
		elif direction == 1:
			TuxManager.facing_direction = 1
	
	if Input.is_action_just_pressed("player_jump"):
		jump_buffer_timer = jump_buffer_time
	
	# Tux Jumping stuff
	var player_jump = Input.is_action_just_pressed("player_jump") or jump_buffer_timer > 0
	var on_floor_or_coyote = is_on_floor() or not coyote_timer.is_stopped()
	if player_jump and on_floor_or_coyote:
		# Backflip
		if Input.is_action_pressed("player_down") and not backflip and not TuxManager.current_state == TuxManager.powerup_states.Small and was_on_floor and abs(velocity.x) < 100: # what...
			print("Backflipping!")
			velocity.y = -max_jump_height
			$FlipSound.play()
			backflip = true
		# Normal jump
		elif not backflip:
			if TuxManager.current_state == TuxManager.powerup_states.Small:
				$SmallJump.play()
			else:
				$BigJump.play()
			if abs(velocity.x) == speed:
				velocity.y = -max_jump_height
			else:
				velocity.y = -min_jump_height
		
		jump_buffer_timer = 0

	# Decelerate on jump release
	if Input.is_action_just_released("player_jump") and velocity.y < 0 and not backflip:
		velocity.y *= decelerate_on_jump_release
	
	if not is_on_floor() and not TuxManager.current_state == TuxManager.powerup_states.Small:
		if Input.is_action_just_pressed("player_down") and not backflip:
			print("Buttjumping!")
			buttjump = true
		var buttjump_but_not_buttjump = buttjump and Input.is_action_just_released("player_down") # this feels more like a HACK than anything else
		if buttjump_but_not_buttjump or backflip:
			buttjump = false
	else:
		buttjump = false
	
	if not TuxManager.current_state == TuxManager.powerup_states.Small:
		if Input.is_action_pressed("player_down") and is_on_floor():
			duck = true
		elif not Input.is_action_pressed("player_down") and not $CeilingRayCast.is_colliding():
			duck = false
		
		if duck:
			$SmallCollision.set_deferred("disabled", false)
			$BigCollision.set_deferred("disabled", true)
			$RockDetector/CollisionShape2D.position.y = -0.5
		else:
			$SmallCollision.set_deferred("disabled", true)
			$BigCollision.set_deferred("disabled", false)
			$RockDetector/CollisionShape2D.position.y = -24.5
	else:
		duck = false
	
	if TuxManager.current_state == TuxManager.powerup_states.Small:
		backflip = false

func animate():
	if Global.tux_star_invincible:
		if TuxManager.current_state == TuxManager.powerup_states.Small:
			$SmallStarsImage.visible = true
			$BigStarsImage.visible = false
		else:
			$SmallStarsImage.visible = false
			$BigStarsImage.visible = true
	else:
		$SmallStarsImage.visible = false
		$BigStarsImage.visible = false
	if backflip:
		if not $BigImage.animation == "backflip":
			print("Backflip animation started.")
			$BigImage.play("backflip")
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			$FireImage.visible = false
			$BigImage.visible = true
		return
	if TuxManager.current_state == TuxManager.powerup_states.Fire:
		$FireImage.visible = true
		$BigImage.visible = false
	
	if not is_on_floor() and not skid and not buttjump and not backflip:
		$SmallImage.play("jump")
		if not duck:
			$BigImage.play("jump")
			$FireImage.play("jump")
	elif is_on_floor() and skid and not in_cutscene and not buttjump and not backflip: # this code is so bad (why did i put this here?)
		$SmallImage.play("skid")
		if not duck:
			$BigImage.play("skid")
			$FireImage.play("skid")
	elif not abs(velocity.x) == 0 and not is_on_wall() and not skid and not buttjump and not backflip:
		$SmallImage.play("walk")
		if not duck:
			$BigImage.play("walk")
			$FireImage.play("walk")
	elif velocity.x == 0 and not skid and not buttjump and not backflip:
		$SmallImage.play("stand")
		if not duck:
			$BigImage.play("stand")
			$FireImage.play("stand")
	elif not is_on_floor() and buttjump and not duck and not backflip:
		$BigImage.play("buttjump")
		$FireImage.play("buttjump")

	if is_on_wall() and is_on_floor() and not duck and not backflip:
		$SmallImage.play("stand")
		$BigImage.play("stand")
		$FireImage.play("stand")
	
	if duck:
		$BigImage.play("duck")
		$FireImage.play("duck")
	
	if TuxManager.facing_direction == -1:
		$SmallImage.flip_h = true
		$BigImage.flip_h = true
		$FireImage.flip_h = true
	elif TuxManager.facing_direction == 1:
		$SmallImage.flip_h = false
		$BigImage.flip_h = false
		$FireImage.flip_h = false

func damage():
	if not invincible or Global.tux_star_invincible:
		invincible = true
		print("3:")
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			TuxManager.current_state = TuxManager.powerup_states.Big
			max_fireballs_allowed = 2
			$HurtSound.play()
		elif TuxManager.current_state == TuxManager.powerup_states.Big:
			TuxManager.current_state = TuxManager.powerup_states.Small
			backflip = false
			$HurtSound.play()
		elif TuxManager.current_state == TuxManager.powerup_states.Small:
			die()
		reload_player() # in case you're confused at what the hell this is, it came from peppertux-haxe.
		await get_tree().create_timer(inv_seconds).timeout
		invincible = false
	else:
		print("Tux is invincible.")
		print("If this is after touching the goal, Tux would usually be able to kill enemies.")
		print("If he is star invincible, he just killed that enemy you touched.")

func reload_player():
	print("Reloading player...")
	if TuxManager.current_state == TuxManager.powerup_states.Fire:
		Global.tux_state = TuxManager.current_state
		$SmallImage.visible = false
		$SmallCollision.set_deferred("disabled", true)
		$BigImage.visible = false
		$BigCollision.set_deferred("disabled", false)
		$FireImage.visible = true
		$RockDetector/CollisionShape2D.position.y = -24.5
	elif TuxManager.current_state == TuxManager.powerup_states.Big:
		Global.tux_state = TuxManager.current_state
		$SmallImage.visible = false
		$SmallCollision.set_deferred("disabled", true)
		$BigImage.visible = true
		$BigCollision.set_deferred("disabled", false)
		$FireImage.visible = false
		$RockDetector/CollisionShape2D.position.y = -24.5
	elif TuxManager.current_state == TuxManager.powerup_states.Small:
		Global.tux_state = TuxManager.current_state
		$SmallImage.visible = true
		$SmallCollision.set_deferred("disabled", false)
		$BigImage.visible = false
		$BigCollision.set_deferred("disabled", true)
		$FireImage.visible = false
		$RockDetector/CollisionShape2D.position.y = -0.5

func stomp_bounce():
	if Input.is_action_pressed("player_jump"):
		velocity.y = -min_jump_height
	else:
		velocity.y = -min_jump_height / 2
	
func hold_object(object):
	if held_object == null:
		held_object = object
		object.pick_up(self)

func throw_object():
	if not held_object == null:
		held_object.throw(TuxManager.facing_direction) # should probably remove the argument from throw()
		held_object = null

func grow(powerup:String):
	if powerup == "egg":
		TuxManager.current_state = TuxManager.powerup_states.Big
		$GrowSound.play()
		reload_player()
	elif powerup == "fire_flower":
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			max_fireballs_allowed += 1
		TuxManager.current_state = TuxManager.powerup_states.Fire
		$FlowerSound.play()
		reload_player()
	else: # so the game doesn't crash
		print("Tux: That is not a valid power-up. Not growing. I refuse to.")

func shoot():
	if TuxManager.current_state == TuxManager.powerup_states.Fire and Input.is_action_just_pressed("player_action") and can_shoot_bullets:
		var fire_bullet = load("uid://c0xvn5d7j0sdu").instantiate()
		get_tree().current_scene.call_deferred("add_child", fire_bullet)
		$BulletSound.play()
		if mario_fireballs:
			fire_bullet.mario = true
		if new_fireballs:
			fire_bullet.new_fireball_behavior = true
		fire_bullet.position = self.position + Vector2(16, 4)
		fire_bullet.set_direction(TuxManager.facing_direction, self)

func _on_stompable_object_detected(area):
	if area.is_in_group("BouncingEnemyTuxDetector") and area.get_parent():
		invincible = true
		await get_tree().create_timer(0.1).timeout
		invincible = false

func get_star():
	if not in_cutscene:
		Global.tux_star_invincible = true
		
		$InvincibleSound.play()
		Music.stream = load(invincible_music)
		Music.play()
		
		$StarTimer.start()

func _on_star_timer_done():
	if not in_cutscene: # NOTE: May cause problems later, but it's here because of the goal. TODO 2193824: Add a way to disable star_invincible in scripting blocks
		Global.tux_star_invincible = false
		Music.stream = load(Global.sector_song)
		Music.play()
