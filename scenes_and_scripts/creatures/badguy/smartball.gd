extends BadGuy

func _ready() -> void:
	super()
	$Image.play("walk")
	$TuxDetector.area_entered.connect(_on_tux_detector_area_entered)
	$TuxDetector.body_entered.connect(_on_tux_detector_body_entered)
	
func _physics_process(delta: float) -> void:
	super(delta)
	
	if not dead:
		if not $GroundDetector.is_colliding():
			flip_direction()
		
		if direction == -1:
			$GroundDetector.position.x = 5.0
		else:
			$GroundDetector.position.x = 34.0
	
func _on_tux_detector_area_entered(area) -> void:
	if area.is_in_group("Stomp"):
		# TODO: Prevent player from being damaged by enemy below when on slope
		if area.get_parent().get_real_velocity().y > 0:
			death(false)
			print(":3")
			area.get_parent().stomp_bounce()
	
	if area.is_in_group("StupidThing") and area.get_parent().kill_other_enemies:
		death(true)

func _on_tux_detector_body_entered(body) -> void:
	if body.is_in_group("Player") and not dead:
		body.damage()

func move():
	if not dead:
		velocity.x = direction * speed
	else:
		velocity.x = 0
