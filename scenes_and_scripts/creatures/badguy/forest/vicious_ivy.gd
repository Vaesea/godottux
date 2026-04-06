extends BadGuy

# UNFINISHED

func _ready() -> void:
	basic_walking = true
	super()

func _physics_process(delta: float) -> void:
	if direction == -1:
		$Collision.position.x = 18.5
		$TuxDetector/CollisionShape2D.position.x = 18.5
	elif direction == 1:
		$Collision.position.x = 31.5
		$TuxDetector/CollisionShape2D.position.x = 31.5
	
	super(delta)
