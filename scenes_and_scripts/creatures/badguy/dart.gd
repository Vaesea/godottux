extends CharacterBody2D

# TODO: Add interacting with other darts

var direction:int = -1
var speed:int = 200

@onready var image = $Image
@onready var detector = $Detector
@onready var flame_sound = $FlameSound

func _ready() -> void:
	detector.connect("body_entered", _on_something_detected)
	velocity.x = direction * speed

func _physics_process(_delta: float) -> void:
	if is_on_wall():
		queue_free()
	
	move_and_slide()

func _on_something_detected(body):
	if body.is_in_group("Player"):
		body.damage()
	if body.is_in_group("FireBullet"):
		body.queue_free()
	if body.is_in_group("Enemy"):
		body.death(true)
