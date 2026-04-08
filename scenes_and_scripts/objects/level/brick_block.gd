extends Block

# TODO: add this stuff to block.
# Reason why I'm not doing it now: Because doing that is making me go insane. Not even joking at this point. 
# I hate debugging code that doesn't work for literally no fucking reason.
# Why did I choose to code? Why? If there's a god, I hope that god frees me from this suffering.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	brick = true
	super()

func _physics_process(_delta: float) -> void:
	if not empty_brick and how_many_hits <= 0:
		$Image.play("empty")

func _on_tux_detector_body_entered(body):
	if body.is_in_group("Player"):
		if empty_brick:
			print("A")
			$BrickSound.play()
			if not TuxManager.current_state == TuxManager.powerup_states.Small:
				$AnimationTween.play("up_to_gone")
				bump = true
			else:
				$AnimationTween.play("up_and_down")
				bump = true
		else:
			print("B")
			$BrickSound.play()
			if how_many_hits > 0:
				$AnimationTween.play("up_and_down")
				how_many_hits -= 1
				print("how_many_hits: " + str(how_many_hits))
				spawn_item("left") # even though coins can't go left or right.
				bump = true

func spawn_item(direction:String):
	if content == 0:
		spawn_coin()
	elif content == 1:
		print("Can not, and WILL NOT spawn an object that isn't coin.")
		print("Why? SuperTux 0.3.2 limitation, that's why!")
