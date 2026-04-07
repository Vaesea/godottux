extends StaticBody2D

class_name Block

# anatolystev: fixes the bonus block killing enemy thing!

# TODO: Fix bug where Tux can activate around 3 Bonus Blocks if he activates two then moves to the left / right but very quickly.

@export_category("Block Setup")
## Is the block a Bonus Block? Best to set this in a script.
@export var bonus = false
## Is the block a Brick Block? Best to set this in a script.
@export var brick = false
## If Tux is small and content is fire flower, egg will be given instead.
@export_enum("Coin", "Fire Flower") var content = 0

@export_category("Brick Block Setup")
@export var empty_brick = true
## How many times can the brick be hit if content is coin?
@export var how_many_hits = 5
## Does the brick block have snow on it?
@export var snow = false

var empty = false
var bump = false

var tux_on_left = false
var tux_on_right = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not brick and not snow:
		$Image.play("default")
	elif brick and not snow:
		$Image.play("default")
	elif brick and snow:
		$Image.play("snow")
	$TuxDetector.connect("body_entered", _on_tux_detector_body_entered)
	$EnemyDetectorLeft.connect("body_entered", _on_enemy_detected_left)
	$EnemyDetectorRight.connect("body_entered", _on_enemy_detected_right)
	$AnimationTween.connect("animation_finished", _on_bump_finished)

func _on_tux_detector_body_entered(body):
	if body.is_in_group("Player") and not empty and body.velocity.y > 1: # velocity check is an attempt to fix the bug
		print("A")
		turn_empty("up_and_down")
		if body.global_position.x < global_position.x:
			spawn_item("right")
			print("Tux hit left part of Bonus Block")
		elif body.global_position.x > global_position.x:
			spawn_item("left")
			print("Tux hit right part of Bonus Block")
		elif body.global_position.x == global_position.x:
			spawn_item("right")
			print("How")
	elif body.is_in_group("Player") and empty and body.velocity.y > 1:
		$BrickSound.play()

func _on_enemy_detected_left(body):
	if body.is_in_group("Enemy") and not empty:
		if body.kill_other_enemies:
			print("Enemy hit left side.")
			turn_empty("up_and_down")
			spawn_item("right")
	elif body.is_in_group("Enemy") and empty:
		if body.kill_other_enemies: # TODO: redo this so it doesn't copy the above if statement. i'm really lazy right now, and i think this shortcut? might cost me 5 years.
			$BrickSound.play()

func _on_enemy_detected_right(body):
	if body.is_in_group("Enemy") and not empty:
		if body.kill_other_enemies:
			print("Enemy hit right side.")
			turn_empty("up_and_down") # TODO: Create left_to_normal animation
			spawn_item("left")
	elif body.is_in_group("Enemy") and empty:
		if body.kill_other_enemies: # TODO: redo this so it doesn't copy the above if statement. i'm really lazy right now, and i think this shortcut? might cost me 5 years.
			$BrickSound.play()

func turn_empty(animation_name:String):
	bump = true
	$AnimationTween.play(animation_name)
	empty = true
	
	$Image.play("empty")
	
	for body in $EnemyDetectorTop.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			body.death(true)

func spawn_item(direction:String):
	if content == 0:
		spawn_coin()
	elif content == 1:
		if TuxManager.current_state == TuxManager.powerup_states.Small:
			var egg = load("uid://f2oqc5qvqu87").instantiate()
			get_tree().current_scene.call_deferred("add_child", egg)
			$PowerupSound.play()
			egg.position = self.position
			if direction == "left":
				egg.spawn_from_block(-1)
			if direction == "right":
				egg.spawn_from_block(1)
		else:
			spawn_fire_flower()

func _on_bump_finished(anim_name: StringName):
	if anim_name == "up_and_down":
		bump = false
	elif anim_name == "up_to_gone":
		spawn_brick_particles()
		queue_free()

func spawn_coin():
	var coin = load("uid://bbo01c372in2k").instantiate()
	get_tree().current_scene.call_deferred("add_child", coin)
	$CoinSound.play()
	coin.position = self.position + Vector2(16, 16)
	coin.set_from_block()

func spawn_fire_flower():
	var fire_flower = load("uid://cydy0jy77hcr3").instantiate()
	get_tree().current_scene.call_deferred("add_child", fire_flower)
	$PowerupSound.play()
	fire_flower.position = self.position
	fire_flower.spawn_from_block()

func spawn_brick_particles():
	var brick_particles = load("uid://dexnrlq8oby45").instantiate()
	get_tree().current_scene.call_deferred("add_child", brick_particles)
	brick_particles.position = self.position
