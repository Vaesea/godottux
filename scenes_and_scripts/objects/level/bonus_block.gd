extends StaticBody2D

## If Tux is small and content is fire flower, egg will be given instead.
@export_enum("Coin", "Fire Flower") var content = 0

var empty = false

const coin = preload("uid://bbo01c372in2k")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Image.play("default")
	$TuxDetector.connect("body_entered", _on_tux_detector_body_entered)
	$EnemyDetectorLeft.connect("body_entered", _on_enemy_detected_left)
	$EnemyDetectorRight.connect("body_entered", _on_enemy_detected_right)

func _on_tux_detector_body_entered(body):
	if body.is_in_group("Player") and not empty:
		turn_empty("up_and_down")
	elif body.is_in_group("Player") and empty:
		$BrickSound.play()

func _on_enemy_detected_left(body):
	if body.is_in_group("Enemy") and not empty:
		if body.kill_other_enemies:
			turn_empty("up_and_down") # TODO: Create right_to_normal animation
	elif body.is_in_group("Enemy") and empty:
		if body.kill_other_enemies: # TODO: redo this so it doesn't copy the above if statement. i'm really lazy right now, and i think this shortcut? might cost me 5 years.
			$BrickSound.play()

func _on_enemy_detected_right(body):
	if body.is_in_group("Enemy") and not empty:
		if body.kill_other_enemies:
			turn_empty("up_and_down") # TODO: Create left_to_normal animation
	elif body.is_in_group("Enemy") and empty:
		if body.kill_other_enemies: # TODO: redo this so it doesn't copy the above if statement. i'm really lazy right now, and i think this shortcut? might cost me 5 years.
			$BrickSound.play()

func turn_empty(animation_name:String):
	$AnimationTween.play(animation_name)
	empty = true
	$Image.play("empty")
	spawn_item()

func spawn_item():
	if content == 0:
		var coin2 = coin.instantiate()
		get_tree().current_scene.call_deferred("add_child", coin2)
		$CoinSound.play()
		coin2.position = self.position + Vector2(16, 16)
		coin2.set_from_block()
