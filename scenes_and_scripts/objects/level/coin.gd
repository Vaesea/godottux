extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Image.play("default")
	$TuxDetector.connect("body_entered", _on_tux_detector_body_entered) # i just realized this is a much better way of doing signals
	$CoinSound.connect("finished", _on_coin_sound_finished)

func _on_tux_detector_body_entered(body):
	if body.is_in_group("Player") and not body.dead:
		$TuxDetector.set_deferred("monitoring", false)
		$AnimationTween.play("collect")
		$CoinSound.play()
		Global.coins += 1

func _on_coin_sound_finished():
	queue_free()

func set_from_block():
	print("Coin is going up from Bonus / Brick Block...") # i put this here for debugging purposes. i guess it could be useful later?
	$TuxDetector.set_deferred("monitoring", false)
	$AnimationTween.play("set_from_block")
	Global.coins += 1
