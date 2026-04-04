extends BadGuy

func _ready() -> void:
	super()
	$Image.play("walk")
	$TuxDetector.area_entered.connect(_on_tux_detector_area_entered)
	$TuxDetector.body_entered.connect(_on_tux_detector_body_entered)
	kill_other_enemies = false
	
func _physics_process(delta: float) -> void:
	super(delta)

func _on_tux_detector_area_entered(area) -> void:
	if area.is_in_group("Stomp"):
		# TODO: Prevent player from being damaged by enemy below when on slope
		if area.get_parent().get_real_velocity().y > 0:
			death(false)
			print(":3")
			area.get_parent().stomp_bounce()
	 
	if area.is_in_group("StupidThing") and area.get_parent().kill_other_enemies:
		death(true)
	elif area.is_in_group("StupidThing") and area.get_parent().kill_self_on_touching_enemy:
		death(true)
		area.get_parent().death(true)

func _on_tux_detector_body_entered(body) -> void:
	if body.is_in_group("Player") and not dead:
		body.damage()

func move():
	if not dead:
		velocity.x = direction * speed
	else:
		velocity.x = 0
