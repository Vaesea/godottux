extends CharacterBody2D
class_name HoldableObject

# TODO: Make it so Tux doesn't go down when hit on the head with a rock.
# TODO: Fix placing on another holdable object.

enum States {Normal, Held}
var current_state:States = States.Normal

var tux_detected_left:bool = false
var tux_detected_right:bool = false

var held_by:CharacterBody2D = null

var throw_up:bool = false
var throw_side:bool = false
var place_rock:bool = false

var was_on_floor:bool = false

var collision_disabled:bool = false

@export var throw_up_height:int = 500
@export var throw_side_speed:int = 200
@export var throw_side_vertical_speed:int = 250
@export var how_much_speed_to_throw:int = 2
@export var portable:bool = true # May seem weird, but this is for trampolines.

func _ready() -> void:
	add_to_group("Holdable")
	$LeftTuxDetector.connect("body_entered", _on_tux_detected_left)
	$LeftTuxDetector.connect("body_exited", _on_tux_exited_left)
	$RightTuxDetector.connect("body_entered", _on_tux_detected_right)
	$RightTuxDetector.connect("body_exited", _on_tux_exited_right)
	$EnemyDetector.connect("body_entered", _on_enemy_detected)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if not is_on_floor() and current_state == States.Normal:
			velocity += get_gravity() * delta
		
		if is_on_floor() and portable:
			velocity = Vector2.ZERO # i forgot this existed... until now.
		
		if current_state == States.Held and not held_by == null and portable:
			if TuxManager.facing_direction == -1:
				global_position.x = held_by.global_position.x - 8
			else:
				global_position.x = held_by.global_position.x + 24
				
			global_position.y = held_by.global_position.y - 16
		
		if current_state == States.Normal and portable:
			if tux_detected_left and Input.is_action_pressed("player_action") and TuxManager.facing_direction == 1 and get_tree().get_first_node_in_group("Player").held_object == null:
				print("hello")
				get_tree().get_first_node_in_group("Player").hold_object(self)
			elif tux_detected_right and Input.is_action_pressed("player_action") and TuxManager.facing_direction == -1 and get_tree().get_first_node_in_group("Player").held_object == null:
				print("hello")
				get_tree().get_first_node_in_group("Player").hold_object(self)
		
		if current_state == States.Held or collision_disabled and portable:
			$Collision.set_deferred("disabled", true)
		else:
			$Collision.set_deferred("disabled", false)
		
		if not was_on_floor and is_on_floor() and current_state == States.Normal and not $BrickSound.playing and portable:
			print(name + ": Playing sound...")
			$BrickSound.play()
		
		if current_state == States.Held and portable:
			velocity.y = 0
		
		was_on_floor = is_on_floor()
		
		move_and_slide()

func throw(tux_direction:int):
	if portable:
		throw_side = false
		place_rock = false
		throw_up = false
		if tux_direction == -1 and held_by.get_real_velocity().x <= -how_much_speed_to_throw and not Input.is_action_pressed("player_up"):
			throw_side = true
		elif tux_direction == 1 and held_by.get_real_velocity().x >= how_much_speed_to_throw and not Input.is_action_pressed("player_up"):
			throw_side = true
		elif abs(held_by.get_real_velocity().x) < how_much_speed_to_throw and not Input.is_action_pressed("player_up") and not held_by.skid:
			place_rock = true
		elif tux_direction == -1 or tux_direction == 1 and held_by.skid:
			throw_side = true
		elif Input.is_action_pressed("player_up"):
			throw_side = false
			place_rock = false
			throw_up = true
		else:
			print("what")
		
		current_state = States.Normal
		
		if throw_side:
			print("Throwing rock to the side...")
			velocity.x = tux_direction * throw_side_speed
			velocity.y = -throw_side_vertical_speed
			if tux_direction == -1:
				global_position.x -= 16
			if tux_direction == 1:
				global_position.x += 16
			throw_side = false
		elif place_rock:
			print("Placing rock...")
			velocity.x = 0
			if tux_direction == -1:
				global_position.x -= 14
			if tux_direction == 1:
				global_position.x += 14
			place_rock = false
		elif throw_up:
			print("Throwing up rock...")
			velocity.x = 0
			if tux_direction == -1:
				global_position.x -= 14
			if tux_direction == 1:
				global_position.x += 14
			velocity.y = -throw_up_height
			throw_up = false

func pick_up(tux:CharacterBody2D):
	if portable:
		current_state = States.Held
		held_by = tux

func _on_tux_detected_left(body):
	if body.is_in_group("Player") and TuxManager.facing_direction == 1 and portable:
		tux_detected_left = true

func _on_tux_exited_left(body):
	if body.is_in_group("Player") and portable:
		tux_detected_left = false

func _on_tux_detected_right(body):
	if body.is_in_group("Player") and TuxManager.facing_direction == -1 and portable:
		tux_detected_right = true

func _on_tux_exited_right(body):
	if body.is_in_group("Player") and portable:
		tux_detected_right = false

# kind of a HACK fix but what isn't in this game base?
func bounce():
	collision_disabled = true
	velocity.y = -throw_side_vertical_speed
	await get_tree().create_timer(0.05).timeout
	collision_disabled = false

func _on_enemy_detected(body):
	if body.is_in_group("Enemy") and current_state == States.Normal:
		body.death(true)
