extends CharacterBody2D

# Explanation for not being in BadGuy:
# This enemy is unique enough.

@export_category("Movement")
@export var speed:int = 64

@export_category("Teleport")
## Whether the WillOWisp uses the Spawn Point or the Spawn Location.[br]
## If true, it uses the spawn point.[br]
## If false, it uses the spawn location.
@export var use_spawn_point:bool = true
## The spawnpoint name.
@export var spawn_point:String = "main"
## The spawn sector.
@export var spawn_sector:String = "main"

var tux_in_track_range:bool = false
var tux_in_vanish_range:bool = false
var tux_was_in_vanish_range:bool = false
var tux:CharacterBody2D = null

@onready var image = $Image
@onready var tux_teleporter = $TuxTeleporter
@onready var track_range = $TrackRange
@onready var vanish_range = $VanishRange
@onready var warp_sound = $WarpSound

func _ready() -> void:
	image.play("idle")
	image.connect("animation_finished", _on_animation_finished)
	tux_teleporter.connect("body_entered", _on_tux_entered_teleporter)
	track_range.connect("body_entered", _on_tux_entered_track_range)
	track_range.connect("body_exited", _on_tux_exited_track_range)
	vanish_range.connect("body_entered", _on_tux_entered_vanish_range)
	vanish_range.connect("body_exited", _on_tux_exited_vanish_range)
	warp_sound.connect("finished", _on_warp_finished)

func _physics_process(_delta: float) -> void:
	if not tux == null and tux_in_track_range:
		velocity = global_position.direction_to(tux.global_position) * speed
	else:
		velocity = Vector2.ZERO # just making sure that velocity is 0
	
	move_and_slide()

func _on_tux_entered_track_range(body):
	if body.is_in_group("Player"):
		print("Tux detected in track range")
		tux_in_track_range = true
		tux = body

func _on_tux_exited_track_range(body):
	if body.is_in_group("Player") and tux_in_track_range:
		tux_in_track_range = false

func _on_tux_entered_vanish_range(body):
	if body.is_in_group("Player"):
		tux_in_vanish_range = true
		tux_was_in_vanish_range = true
		tux = body

func _on_tux_exited_vanish_range(body):
	if body.is_in_group("Player"):
		call_deferred("vanish_hack_fix")

func _on_animation_finished():
	if image.animation == "vanish":
		queue_free()
	elif image.animation == "warp":
		hide() # oh my god i just learned this exists holy shit

func _on_warp_finished():
	queue_free()

func _on_tux_entered_teleporter(body):
	if body.is_in_group("Player"):
		CertainSoundsHack.stream = warp_sound.stream
		print(CertainSoundsHack.stream)
		CertainSoundsHack.play()
		image.play("warp")
		get_tree().current_scene.switch_sector(spawn_sector, spawn_point)

func vanish_hack_fix():
	for body in vanish_range.get_overlapping_bodies():
		if body.is_in_group("Player"):
			return
	
	tux_in_vanish_range = false
	image.play("vanish")
