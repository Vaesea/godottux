extends CharacterBody2D

# code from adel time but very modified (deity adel)

# Movement
@export var speed:float = 160.0 # Why is this a float?
@export var acceleration:int = 1500 # Huge number because it's handled differently I guess? I don't know, I wrote this code for Adel Time and forgot how it worked (not entirely forgot but still forgot)
@export var deceleration:int = 1600 # Huge number because it's handled differently I guess? I don't know, I wrote this code for Adel Time and forgot how it worked (not entirely forgot but still forgot)

var current_state:TuxManager.powerup_states

@onready var image = $Image
@onready var boat_image = $BoatImage

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
	if not direction == Vector2.ZERO: # Could this just use 0 instead of Vector2.ZERO?
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta) # Could this just use 0 instead of Vector2.ZERO?
	
	animate()

	move_and_slide()

func reload_player():
	if current_state == TuxManager.powerup_states.Fire:
		image.play("fire")
	else:
		image.play("normal")

func animate():
	if not get_real_velocity() == Vector2.ZERO: # Could a 0 be used instead of Vector2.ZERO?
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			image.play("fire_walk")
			boat_image.play("default_fire")
		else:
			image.play("normal_walk")
			boat_image.play("default")
	else:
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			image.play("fire")
			boat_image.play("default_fire")
		else:
			image.play("normal")
			boat_image.play("default")
	
	if Global.wm_tux_boat_visible:
		image.visible = false
		boat_image.visible = true
	else:
		image.visible = true
		boat_image.visible = false
