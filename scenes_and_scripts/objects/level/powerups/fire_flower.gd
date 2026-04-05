extends CharacterBody2D

@export var affected_by_gravity = true

func _ready() -> void:
	$TuxDetector.connect("body_entered", _on_tux_detected)
	$AnimationTween.connect("animation_finished", _on_tween_finished)

func _physics_process(delta: float) -> void:
	if is_on_floor() and affected_by_gravity:
		velocity += get_gravity() * delta
	
	move_and_slide()

func spawn_from_block():
	$AnimationTween.play("go_up")

func _on_tux_detected(body):
	if body.is_in_group("Player"):
		body.grow("fire_flower")
		queue_free()

func _on_tween_finished(anim_name:StringName):
	if anim_name == "go_up":
		affected_by_gravity = true
