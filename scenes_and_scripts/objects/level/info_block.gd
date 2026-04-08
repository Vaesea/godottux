extends Block

# TODO: add this stuff to block.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info = true
	if not info_block_text.is_empty():
		$Message.text = info_block_text
	super()

func _on_tux_detector_body_entered(body):
	if body.is_in_group("Player") and body.velocity.y > 0 and infoblock_detects_tux:
		if not displaying_message:
			print("Display message")
			bump = true
			$AnimationTween.play("up_and_down")
			$MessageTween.play("display_message")
			displaying_message = true
		else:
			print("Close message")
			bump = true
			$AnimationTween.play("up_and_down")
			$MessageTween.play_backwards("display_message")
			displaying_message = false

func _on_enemy_detected_left(body):
	if body.is_in_group("Enemy") and not displaying_message:
		if body.kill_other_enemies:
			print("Enemy hit left side.")
			bump = true
			$AnimationTween.play("up_and_down")
			if infoblock_detects_tux:
				print("Display message")
				$MessageTween.play("display_message")
				displaying_message = true
	elif body.is_in_group("Enemy") and displaying_message:
		if body.kill_other_enemies: # TODO: redo this so it doesn't copy the above if statement. i'm really lazy right now, and i think this shortcut? might cost me 5 years.
			print("Close message")
			bump = true
			$AnimationTween.play("up_and_down")
			$MessageTween.play_backwards("display_message")
			displaying_message = false

func _on_enemy_detected_right(body):
	if body.is_in_group("Enemy") and not displaying_message:
		if body.kill_other_enemies and not body.current_iceblock_state == body.IceblockStates.Held:
			print("Enemy hit right side.")
			bump = true
			$AnimationTween.play("up_and_down")
			if infoblock_detects_tux:
				print("Display message")
				$MessageTween.play("display_message")
				displaying_message = true
	elif body.is_in_group("Enemy") and displaying_message:
		if body.kill_other_enemies and not body.current_iceblock_state == body.IceblockStates.Held: # TODO: redo this so it doesn't copy the above if statement. i'm really lazy right now, and i think this shortcut? might cost me 5 years.
			print("Close message")
			bump = true
			$AnimationTween.play("up_and_down")
			$MessageTween.play_backwards("display_message")
			displaying_message = false
