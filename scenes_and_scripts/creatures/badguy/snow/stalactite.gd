extends BadGuy

func _ready() -> void:
	stalactite = true
	hurt_by_stomp = false
	freezable = false
	kill_other_enemies = true
	super()

func _physics_process(delta: float) -> void:
	if current_state == EnemyStates.Alive:
		$Image.offset.y = 0.0
	elif current_state == EnemyStates.Dead:
		$Image.offset.y = -4.0
	super(delta)
