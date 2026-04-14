@tool
extends AnimatedSprite2D

# It's unique enough to not be in badguy.gd

## -1 = left, 1 = right, any other number is not good.
@export var direction:int = -1:
	set(value):
		direction = value
		reload()

@export var fire_delay:int = 2

@onready var screen_check = $ScreenCheck
@onready var dart_spawn = $DartSpawn
@onready var dart_sound = $DartSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("default")
	reload()
	spawning()
	connect("animation_finished", _on_animation_finished)

func reload():
	match(direction):
		-1:
			flip_h = false
			dart_spawn.position = Vector2(21.0, 24.0)
		1:
			flip_h = true
			$DartSpawn.position = Vector2(32.0, 24.0) # for some reason, this works but dart_spawn doesn't on this line? what?

func spawning():
	# loop the thing FOREVER and EVER and EVER...
	if not Engine.is_editor_hint():
		while true:
			if screen_check.is_on_screen():
				play("loading")
			
			await get_tree().create_timer(fire_delay).timeout

func create_object():
	var dart = load("uid://cyn6jc2i7e6ax").instantiate()
	get_parent().call_deferred("add_child", dart)
	dart.direction = self.direction
	dart.global_position = dart_spawn.global_position
	dart_sound.play()

func _on_animation_finished():
	if animation == "loading":
		play("default")
		create_object()
