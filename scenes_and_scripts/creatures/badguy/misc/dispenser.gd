@tool
extends StaticBody2D

# TODO: make this work for all enemies but like actually good

# AnatolyStev: fixes a crash with just one line!
# ...also fixes other bugs with spawning enemies with more than 1 one line.
# ...also adds get_spawn_info and stuff like that...

@export_enum("Canon", "RocketLauncher", "Dropper") var type = 0:
	set(value):
		type = value
		reload()

@export var wait_time:int = 5

## The object that the dispenser spawns. These are hardcoded right now.
@export_enum("Snowball", "BouncingSnowball", "MrBomb", "MrIceblock", "MrRocket", "ViciousIvy") var object_to_spawn = 0
var object_path:String

@export var canon_marker_position_x_left:float = 0.0
@export var canon_marker_position_x_right:float = 32.0
@export var rocket_launcher_marker_position_x_left:float = -9.0
@export var rocket_launcher_marker_position_x_right:float = 35.0
@export var dropper_position_x:float = 32.0

@export var direction:int = -1:
	set(value):
		direction = value
		reload()

@export var auto_direction:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload()
	$LeftDetector.connect("body_entered", _on_tux_detected_left)
	$RightDetector.connect("body_entered", _on_tux_detected_right)
	spawning()

func reload():
	# I forgot about match statements. I should use them more, looks better.
	match(type):
		0:
			$CanonImage.visible = true
			$RocketLauncherImage.visible = false
			$DropperImage.visible = false
			$CanonCollision.visible = true
			$RocketLauncherCollision.visible = false
			$DropperCollision.visible = false
			$CanonCollision.set_deferred("disabled", false)
			$RocketLauncherCollision.set_deferred("disabled", true)
			$DropperCollision.set_deferred("disabled", true)
			$CanonScreenCheck.visible = true
			$RocketLauncherScreenCheck.visible = false
			$DropperScreenCheck.visible = false
		1:
			$CanonImage.visible = false
			$RocketLauncherImage.visible = true
			$DropperImage.visible = false
			$CanonCollision.visible = false
			$RocketLauncherCollision.visible = true
			$DropperCollision.visible = false
			$CanonCollision.set_deferred("disabled", true)
			$RocketLauncherCollision.set_deferred("disabled", false)
			$DropperCollision.set_deferred("disabled", true)
			$CanonScreenCheck.visible = false
			$RocketLauncherScreenCheck.visible = true
			$DropperScreenCheck.visible = false
		2:
			$CanonImage.visible = false
			$RocketLauncherImage.visible = false
			$DropperImage.visible = true
			$CanonCollision.visible = false
			$RocketLauncherCollision.visible = false
			$DropperCollision.visible = true
			$CanonCollision.set_deferred("disabled", true)
			$RocketLauncherCollision.set_deferred("disabled", true)
			$DropperCollision.set_deferred("disabled", false)
			$CanonScreenCheck.visible = false
			$RocketLauncherScreenCheck.visible = false
			$DropperScreenCheck.visible = true
	
	var valid_direction = direction == 1 or direction == -1
	if direction == -1 and type == 1:
		$RocketLauncherImage.flip_h = false
	elif direction == 1 and type == 1:
		$RocketLauncherImage.flip_h = true
	elif not valid_direction and type == 1:
		push_warning("Setting Rocket Launcher to something that isn't -1 or 1 is no good idea.")
	
	match(object_to_spawn):
		0: # snowball
			object_path = "uid://cgljlk8a4oogu"
		1: # bouncing snowball (which i'm still angry about)
			object_path = "uid://l041x3y7g3v0"
		2: # mr bomb
			object_path = "uid://bi3s3l4fv1xp1"
		3: # mr iceblock
			object_path = "uid://cstyfqelcwsdf"
		4: # mr rocket (adding this will be fun! except no it won't)
			object_path = "uid://cd6ah8ye2u4c3"
		5:
			object_path = "uid://c7xxetrv6fxkk"
	
	match(direction):
		-1:
			$CanonMarker.position.x = canon_marker_position_x_left
			$RocketLauncherMarker.position.x = rocket_launcher_marker_position_x_left
		1:
			$CanonMarker.position.x = canon_marker_position_x_right
			$RocketLauncherMarker.position.x = rocket_launcher_marker_position_x_right

func spawning():
	# loop the thing FOREVER and EVER and EVER...
	if not Engine.is_editor_hint():
		while true:
			if $CanonScreenCheck.is_on_screen() or $RocketLauncherScreenCheck.is_on_screen() or $DropperScreenCheck.is_on_screen():
				create_object()
			
			await get_tree().create_timer(wait_time).timeout

func _on_tux_detected_left(body):
	if auto_direction:
		var types = type == 0 or type == 2
		if body.is_in_group("Player") and types:
			print(name + ": Left Detector Detected Tux")
			direction = -1

func _on_tux_detected_right(body):
	if auto_direction:
		var types = type == 0 or type == 2
		if body.is_in_group("Player") and types:
			print(name + ": Right Detector Detected Tux")
			direction = 1

func create_object():
	if not object_to_spawn == null:
		var object = load(object_path).instantiate()
		print(name + ": Just spawned " + str(object)) # Is str(object) needed? Probably not but I don't want to find out with the game crashing.
		get_parent().call_deferred("add_child", object)
		
		await object.ready
		
		# somewhat wet, somewhat dry. it's like a mix!
		match(object_to_spawn):
			0: # snowball
				if type == 0:
					object.global_position = $CanonMarker.global_position
					complete_create(object, 5, 29, direction)
				if type == 1:
					object.global_position = $RocketLauncherMarker.global_position
					complete_create(object, 5, 24, direction)
				if type == 2:
					object.global_position = $DropperMarker.global_position
					complete_create(object, 0, 16, direction)
			1: # as much as i hate it, bouncing snowball
				if type == 0:
					object.global_position = $CanonMarker.global_position
					complete_create(object, 5, 25, direction)
				elif type == 1:
					object.global_position = $RocketLauncherMarker.global_position
					complete_create(object, 5, 25, direction)
				elif type == 2:
					object.global_position = $DropperMarker.global_position
					complete_create(object, 0, 16, direction)
			2: # mr bomb
				if type == 0:
					object.global_position = $CanonMarker.global_position
					complete_create(object, 5, 27, direction)
				elif type == 1:
					object.global_position = $RocketLauncherMarker.global_position
					complete_create(object, 5, 27, direction)
				elif type == 2:
					object.global_position = $DropperMarker.global_position
					complete_create(object, 0, 16, direction)
			3: # mr iceblock
				if type == 0:
					object.global_position = $CanonMarker.global_position
					complete_create(object, 3, 29, direction)
				elif type == 1:
					object.global_position = $RocketLauncherMarker.global_position
					complete_create(object, 3, 29, direction)
				elif type == 2:
					object.global_position = $DropperMarker.global_position
					complete_create(object, 0, 16, direction)
			4: # mr rocket
				if type == 0:
					object.global_position = $CanonMarker.global_position
					complete_create(object, 1, 41, direction)
				elif type == 1:
					object.global_position = $RocketLauncherMarker.global_position
					complete_create(object, 1, 41, direction)
				elif type == 2:
					object.global_position = $DropperMarker.global_position
					complete_create(object, 0, 16, direction)
	else:
		push_warning("I'm not sure how you set object_to_spawn to null, but just don't do that. If you didn't, and this warning displayed, there's a bug.")

# TODO: is dir needed?
func complete_create(spawned_object:Node2D, left_offset:float, right_offset:float, dir:int):
	if dir == 1:
		spawned_object.global_position.x -= spawned_object.collision.shape.get_rect().size.x - right_offset
		spawned_object.set_scripted_spawn_direction(true)
	if dir == -1:
		spawned_object.global_position.x -= spawned_object.collision.shape.get_rect().size.x + left_offset
		spawned_object.set_scripted_spawn_direction(false)
