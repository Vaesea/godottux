extends CharacterBody2D

var from_block = false
var direction = -1
var speed = 80
var was_on_wall = false

@export var affected_by_gravity = true

func _ready() -> void:
	$TuxDetector.connect("body_entered", _on_tux_detected)
	$AnimationTween.connect("animation_finished", _on_tween_finished)

func spawn_from_block(go_to_direction:int):
	$AnimationTween.play("go_up")
	affected_by_gravity = false
	direction = go_to_direction

func _on_tween_finished(anim_name:StringName):
	if anim_name == "go_up":
		from_block = true
		affected_by_gravity = true

func _physics_process(delta: float) -> void:
	if not is_on_floor() and affected_by_gravity:
		velocity += get_gravity() * delta
	
	if from_block:
		velocity.x = direction * speed
	
	if is_on_wall() and not was_on_wall and from_block:
		direction = -direction
	
	was_on_wall = is_on_wall()
	
	move_and_slide()

func _on_tux_detected(body):
	if body.is_in_group("Player"):
		body.grow("egg")
		queue_free()
