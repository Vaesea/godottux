extends HoldableEnemy

func _ready() -> void:
	smart = true
	jump_when_hit_wall_or_thrown = true
	ground_detector_position_x_when_left = 3.0
	ground_detector_position_x_when_right = 32.0
	image_offset_x_when_left = 16.0
	image_offset_x_when_right = 24.0
	super()

func _physics_process(delta: float) -> void:
	if direction == -1: # Left.
		collision.position.x = 17.5
		tux_detector_collision.position.x = 17.5
	else: # Right or any other number in direction.
		collision.position.x = 25.5
		tux_detector_collision.position.x = 25.5
	
	super(delta)
