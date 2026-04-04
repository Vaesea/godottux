extends CharacterBody2D

# code from adel time
# im too lazy to add comments right now

# AnatolyStev here. Added skidding.

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

var current_state:TuxManager.powerup_states

var in_cutscene = false

# this needs to be done because enemies
@onready var stomp = $Stomp

var inv_seconds = 1

var facing_direction = 1

var held_object = null

func _ready() -> void:
	add_to_group("Player")
	stomp.add_to_group("Stomp")
	reload_player()

func _physics_process(delta: float) -> void:
	if position.x < 0:
		position.x = 0
	
	if position.y > $Camera.limit_bottom and not in_cutscene:
		die()
	
	if position.x > $Camera.limit_right - $SmallCollision.shape.size.x:
		position.x = $Camera.limit_right - $SmallCollision.shape.size.x
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not in_cutscene:
		move()
	
	animate()
	
	if Input.is_action_just_released("player_action") and not held_object == null and not held_object.held_by == null:
		throw_enemy()
	
	if in_cutscene and not held_object == null and not held_object.held_by == null:
		throw_enemy()
	
	move_and_slide()

func die():
	get_tree().call_deferred("reload_current_scene")

func move():
	var direction := Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)

	if direction == -1:
		facing_direction = -1
	elif direction == 1:
		facing_direction = 1

	if not direction == 0:
		$SmallImage.flip_h = direction < 0
		$BigImage.flip_h = direction < 0

	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		if current_state == TuxManager.powerup_states.Small:
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

func animate():
	var direction := Input.get_axis("player_left", "player_right")
	
	if not is_on_floor():
		$SmallImage.play("jump")
		$BigImage.play("jump")
	elif not direction == 0 and not sign(velocity.x) == direction and abs(velocity.x) > 80 and not in_cutscene:
		$SmallImage.play("skid")
		$BigImage.play("skid")
		if abs(velocity.x) > 160 and $SkidSound.playing == false:
			$SkidSound.play()
	elif not abs(velocity.x) == 0 and not is_on_wall():
		$SmallImage.play("walk")
		$BigImage.play("walk")
	else:
		$SmallImage.play("stand")
		$BigImage.play("stand")

	if is_on_wall() and is_on_floor():
		$SmallImage.play("stand")
		$BigImage.play("stand")

func damage():
	if not in_cutscene:
		print("3:")
		if current_state == TuxManager.powerup_states.Fire:
			current_state = TuxManager.powerup_states.Big
			$HurtSound.play()
		elif current_state == TuxManager.powerup_states.Big:
			current_state = TuxManager.powerup_states.Small
			$HurtSound.play()
		elif current_state == TuxManager.powerup_states.Small:
			die()
		reload_player() # in case you're confused at what the hell this is, it came from peppertux-haxe i think
	else:
		print("Tux is in a cutscene and cannot be hurt!")
		print("Tux would usually be able to kill enemies here.")

func reload_player():
	if current_state == TuxManager.powerup_states.Fire:
		Global.tux_state = current_state
	elif current_state == TuxManager.powerup_states.Big:
		Global.tux_state = current_state
		$SmallImage.visible = false
		$SmallCollision.set_deferred("disabled", true)
		$BigImage.visible = true
		$BigCollision.set_deferred("disabled", false)
	elif current_state == TuxManager.powerup_states.Small:
		Global.tux_state = current_state
		$SmallImage.visible = true
		$SmallCollision.set_deferred("disabled", false)
		$BigImage.visible = false
		$BigCollision.set_deferred("disabled", true)

func stomp_bounce():
	if Input.is_action_pressed("player_jump"):
		velocity.y = -min_jump_height
	else:
		velocity.y = -min_jump_height / 2
	
func hold_enemy(enemy):
	if held_object == null:
		held_object = enemy
		enemy.pick_up(self)

func throw_enemy():
	if not held_object == null:
		held_object.throw(facing_direction)
		held_object = null

func grow(powerup:String):
	if powerup == "egg":
		current_state = TuxManager.powerup_states.Big
		$GrowSound.play()
		reload_player()
	elif powerup == "fire_flower":
		current_state = TuxManager.powerup_states.Fire
		$FlowerSound.play()
		reload_player()
