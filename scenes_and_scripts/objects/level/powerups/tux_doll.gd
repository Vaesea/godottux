extends CharacterBody2D

@export var floating = false
@export var jump_height = 400
@export var speed = 100
var direction = -1
var coin_amount_given = 0

func _ready() -> void:
	$TuxDetector.connect("body_entered", _on_tux_detected)
	$LifeSound.connect("finished", _on_sound_finished)
	
	if not floating:
		velocity.y -= jump_height

func spawn_from_block(go_to_direction:int):
	floating = false
	direction = go_to_direction

func _physics_process(delta: float) -> void:
	if not floating:
		velocity.x = direction * speed
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	move_and_slide()

func _on_tux_detected(body):
	if body.is_in_group("Player"):
		Global.coins += 100
		$Image.visible = false
		$LifeSound.play()

# TODO: make it so giving coins is like supertux. this function is supposed to do it but is unfinished.
#func give_coins(amount:int):
	#Global.coins += 1
	#coin_amount_given += 1
	#if coin_amount_given >= amount:
		#pass

func _on_sound_finished():
	queue_free()
