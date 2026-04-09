extends CharacterBody2D

# code from adel time but very modified (deity adel)

# Movement
var speed:float = 160.0 # Why is this a float?
var acceleration:int = 1500 # Huge number because it's handled differently I guess? I don't know, I wrote this code for Adel Time and forgot how it worked (not entirely forgot but still forgot)
var deceleration:int = 1600 # Huge number because it's handled differently I guess? I don't know, I wrote this code for Adel Time and forgot how it worked (not entirely forgot but still forgot)

var current_state:TuxManager.powerup_states

func _ready() -> void:
	add_to_group("TuxWorldmap")
	reload_player()

func _physics_process(delta: float) -> void:
	# If position.x is lower than 0, set position to 0.
	# Needed so the player doesn't go off-screen towards the left
	if position.x < 0:
		position.x = 0

	# thanks godot forum
	var direction = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	if not direction == Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	animate()

	move_and_slide()

func reload_player():
	if current_state == TuxManager.powerup_states.Fire:
		$Image.play("fire")
	else:
		$Image.play("normal")

func animate():
	if not get_real_velocity() == Vector2.ZERO:
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			$Image.play("fire_walk")
		else:
			$Image.play("normal_walk")
	else:
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			$Image.play("fire")
		else:
			$Image.play("normal")
