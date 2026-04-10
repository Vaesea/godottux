extends CharacterBody2D

@export var floating:bool = false
@export var jump_height_from_block:int = 400
@export var jump_height_normal:int = 300
@export var speed = 150

@export var direction:int = -1

var was_on_wall:bool = false

func _ready() -> void:
	$TuxDetector.connect("body_entered", _on_tux_detected)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and not floating:
		velocity += get_gravity() * delta
	
	if is_on_floor() and not floating:
		velocity.y = -jump_height_normal
	
	if not floating:
		velocity.x = direction * speed
	
	if is_on_wall() and not was_on_wall and not floating:
		direction = -direction
	
	was_on_wall = is_on_wall()
	
	move_and_slide()

func spawn_from_block(go_to_direction:int):
	velocity.y = -jump_height_from_block
	direction = go_to_direction

func _on_tux_detected(body):
	if body.is_in_group("Player") and not body.dead:
		body.get_star()
		queue_free()
