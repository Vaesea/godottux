extends CharacterBody2D

# i combined foresttux / milestone mix's fire bullet 
# and a very old version of peppertux (before peppertux-haxe)'s fire bullet.

var speed = 600
var jump_height = 300.0 # float because of an error

var how_many_bounces = 3
var bounces = 0

var direction = 1

var previous_velocity_y = 0

var was_on_floor = false

# Do you want the fireball behavior to be more like Mario? Set this to true when spawning the fireball through Tux. (or just set tux's mario_fireballs to true)
var mario = false
# Do you want the fireball behavior to be more like new SuperTux versions? Set this to true when spawning the fireball through Tux. (or just set tux's new_fireballs to true)
var new_fireball_behavior = false

func _ready() -> void:
	add_to_group("FireBullet")
	$Image.play("default")
	velocity.x = speed * direction
	$EnemyDetector.connect("body_entered", _on_enemy_detected)
	velocity.y = 0

## Also sets speed but I'm too lazy to rename it.
func set_direction(direction2, who_sent_fireball:CharacterBody2D):
	direction = direction2
	if new_fireball_behavior:
		if direction2 == 1:
			if who_sent_fireball.velocity.x >= 105:
				speed = speed + who_sent_fireball.velocity.x
		elif direction2 == -1:
			if who_sent_fireball.velocity.x <= 105:
				speed = speed - who_sent_fireball.velocity.x

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor() and not was_on_floor:
		if mario:
			velocity.y = -jump_height
		else:
			velocity.y = -previous_velocity_y
		bounces += 1
		print(bounces)
		#velocity.y = -jump_height
	
	if velocity.y > 0:
		previous_velocity_y = velocity.y
	
	# similar to badguy was_on_wall but now it's floor
	was_on_floor = is_on_floor()
	
	if bounces >= how_many_bounces or is_on_wall() or is_on_ceiling() or not $Notifier.is_on_screen():
		queue_free()
	
	move_and_slide()

func _on_enemy_detected(body):
	if body.is_in_group("Enemy") and body.flammable:
		body.death(true)
		queue_free()
