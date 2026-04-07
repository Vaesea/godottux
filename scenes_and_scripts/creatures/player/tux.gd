extends CharacterBody2D

# code from adel time
# im too lazy to add comments right now

# TODO: Save Tux's max fire bullet amount or something idk

# AnatolyStev here. Added skidding
# AnatolyStev here. Made it so rocks don't softlock Tux.
# TODO: Make it so Tux doesn't go down when hit on the head with a rock. As you can see, I tried.
# vaesea note: i have no idea what the above todo is about

# Movement
## Tux's speed. You should probably change acceleration and deceleration if you change this.
@export var speed = 320
@export_range(0, 0.1) var acceleration = 0.06
@export_range(0, 0.1) var deceleration = 0.06
## Maximum jump height variable. Should be larger than the Min Jump Height variable.
@export var max_jump_height = 576
## Minimum jump height variable. Should be smaller than the Max Jump Height variable.
@export var min_jump_height = 512.0 # this is a float just to avoid a warning
## Set this to something like 0.5 for a better variable jump height.
@export var decelerate_on_jump_release = 0

# Cutscene / scripting variables.
var in_cutscene = false
var auto_walk = false
var auto_walk_speed = 0

# this needs to be done due to scripting
@onready var camera = $Camera

# Invincible variables
var inv_seconds = 1
var invincible = false

# Holding objects variable
var held_object = null

# Skid variables
var skid = false
@export var how_fast_to_skid = 200
@export_range(0, 0.1) var skid_deceleration = 0.01
@export var skid_speed = 35

# Powerup Bullet variables
var can_shoot_bullets = true
var max_fireballs_allowed = 2

# Rock detecting variable
var rock_above = false

# If the fireball Tux spawns will be more Mario-like or not.
@export var mario_fireballs = false
# If the fireball Tux spawns will be more like new SuperTux versions (0.5+) or not.
@export var new_fireballs = false

# Buttjump variable (buttjump is intentionally just a visual thing because 0.3.2)
var buttjump = false

# Duck variable
var duck = false

func _ready() -> void:
	add_to_group("Player")
	$Stomp.add_to_group("Stomp")
	reload_player()
	$Stomp.connect("area_entered", _on_stompable_object_detected)

func _physics_process(delta: float) -> void:
	if Global.debug:
		if Input.is_key_pressed(KEY_1):
			grow("egg")
		if Input.is_key_pressed(KEY_2):
			grow("fire_flower")
	
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
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if $RayCast2D.is_colliding():
		global_position.y -= 5
	
	if not in_cutscene:
		move()
		shoot()
	
	if auto_walk:
		velocity.x = TuxManager.facing_direction * auto_walk_speed
	
	if get_tree().get_nodes_in_group("FireBullet").size() >= max_fireballs_allowed:
		can_shoot_bullets = false
	else:
		can_shoot_bullets = true
	
	animate()
	
	if Input.is_action_just_released("player_action") and not held_object == null and not held_object.held_by == null:
		throw_object()
	
	if in_cutscene and not held_object == null and not held_object.held_by == null:
		throw_object()
	
	move_and_slide()

func die():
	TuxManager.current_state = TuxManager.powerup_states.Small
	get_tree().call_deferred("reload_current_scene")

func move():
	var direction := Input.get_axis("player_left", "player_right")
	var duck_on_floor = duck and is_on_floor()
	if direction and not duck_on_floor:
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
		if in_cutscene:
			skid = false
	
	if in_cutscene:
		skid = false
	
	if direction == -1:
		TuxManager.facing_direction = -1
	elif direction == 1:
		TuxManager.facing_direction = 1

	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		if TuxManager.current_state == TuxManager.powerup_states.Small:
			$SmallJump.play()
		else:
			$BigJump.play()
		var current_speed = velocity.x
		if abs(current_speed) == speed:
			velocity.y = -max_jump_height
		else:
			velocity.y = -min_jump_height

	if Input.is_action_just_released("player_jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release
	
	if not is_on_floor() and not TuxManager.current_state == TuxManager.powerup_states.Small:
		if Input.is_action_just_pressed("player_down"):
			print("Buttjumping!")
			buttjump = true
		if buttjump and not Input.is_action_pressed("player_down"): # this feels more like a HACK than anything else
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
	
	if is_on_floor():
		buttjump = false

func animate():
	if not is_on_floor() and not skid and not buttjump:
		$SmallImage.play("jump")
		if not duck:
			$BigImage.play("jump")
			$FireImage.play("jump")
	elif is_on_floor() and skid and not in_cutscene and not buttjump: # this code is so bad (why did i put this here?)
		$SmallImage.play("skid")
		if not duck:
			$BigImage.play("skid")
			$FireImage.play("skid")
	elif not abs(velocity.x) == 0 and not is_on_wall() and not skid and not buttjump:
		$SmallImage.play("walk")
		if not duck:
			$BigImage.play("walk")
			$FireImage.play("walk")
	elif velocity.x == 0 and not skid and not buttjump:
		$SmallImage.play("stand")
		if not duck:
			$BigImage.play("stand")
			$FireImage.play("stand")
	elif not is_on_floor() and buttjump and not duck:
		$BigImage.play("buttjump")
		$FireImage.play("buttjump")

	if is_on_wall() and is_on_floor() and not duck:
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
	if not invincible:
		invincible = true
		print("3:")
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			TuxManager.current_state = TuxManager.powerup_states.Big
			max_fireballs_allowed = 2
			$HurtSound.play()
		elif TuxManager.current_state == TuxManager.powerup_states.Big:
			TuxManager.current_state = TuxManager.powerup_states.Small
			$HurtSound.play()
		elif TuxManager.current_state == TuxManager.powerup_states.Small:
			die()
		reload_player() # in case you're confused at what the hell this is, it came from peppertux-haxe.
		await get_tree().create_timer(inv_seconds).timeout
		invincible = false
	else:
		print("Tux is invincible.")
		print("If this is after touching the goal, Tux would usually be able to kill enemies.")

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
