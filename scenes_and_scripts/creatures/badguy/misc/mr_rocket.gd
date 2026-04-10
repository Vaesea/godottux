extends BadGuy

func _ready() -> void:
	speed = 200
	bullet = true
	explode_on_hit_wall = true
	super()

func _physics_process(delta: float) -> void:
	if direction == -1:
		$TuxDetector/CollisionShape2D.position.x = collision_position_x_when_left
		$Collision.position.x = collision_position_x_when_left
	elif direction == 1:
		$TuxDetector/CollisionShape2D.position.x = collision_position_x_when_right
		$Collision.position.x = collision_position_x_when_right
	
	super(delta)
