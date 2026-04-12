extends BadGuy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flying = true
	super()

func _physics_process(delta: float) -> void:
	if current_state == EnemyStates.Dead:
		$Image.offset.y = -17.0
	else:
		$Image.offset.y = 2.0
	
	super(delta)
