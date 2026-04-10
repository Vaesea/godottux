@tool
extends CharacterBody2D

## Sets the image of the unstable tile.
@export_enum("Snow", "Brick", "CastleBlock") var type = 0:
	set(value):
		type = value
		reload()

## Whether the Unstable Tile comes back or not. Disabled by default due to it not happening in SuperTux 0.3.2. [br]
## [br]
## Doesn't work for Bricks or CastleBlocks yet!
@export var come_back:bool = false
var stay_gone_time:float = 5.0

var crumbling:bool = false
var falling:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationTween.play("RESET")
	reload()
	$TuxDetector.connect("body_entered", _on_tux_detected)
	$IceImage.connect("animation_finished", _on_ice_image_finished_crumbling)
	$AnimationTween.connect("animation_finished", _on_brick_shake_finished)
	$CastleBlockImage.connect("animation_finished", _on_castle_block_image_finished_crumbling)

func _physics_process(delta: float) -> void:
	if falling:
		velocity += get_gravity() * delta
	
	move_and_slide()

func reload():
	match(type):
		0: # snow
			$IceImage.play("default")
			$CastleBlockImage.play("default")
			$IceImage.visible = true
			$BrickImage.visible = false
			$CastleBlockImage.visible = false
		1: # brick
			$IceImage.play("default")
			$CastleBlockImage.play("default")
			$IceImage.visible = false
			$BrickImage.visible = true
			$CastleBlockImage.visible = false
		2: # castleblock
			$IceImage.play("default")
			$CastleBlockImage.play("default")
			$IceImage.visible = false
			$BrickImage.visible = false
			$CastleBlockImage.visible = true

func _on_tux_detected(body):
	if body.is_in_group("Player") and not crumbling:
		crumbling = true
		dissolve()

func dissolve():
	match(type):
		0: # snow
			$IceImage.play("crumbling")
		1: # brick
			$AnimationTween.play("shake")
		2: # castleblock
			$CastleBlockImage.play("crumbling")

func _on_ice_image_finished_crumbling():
	if $IceImage.animation == "crumbling":
		$IceImage.visible = false
		$Collision.set_deferred("disabled", true)
		$TuxDetector.set_deferred("monitoring", false)
		if come_back:
			await get_tree().create_timer(stay_gone_time).timeout
			$IceImage.visible = true
			$IceImage.play("uncrumbling")
			$Collision.set_deferred("disabled", false)
		else:
			queue_free()
	elif $IceImage.animation == "uncrumbling":
		crumbling = false
		$TuxDetector.set_deferred("monitoring", true)

func _on_castle_block_image_finished_crumbling():
	if $CastleBlockImage.animation == "crumbling":
		fall()

func _on_brick_shake_finished(anim_name: StringName):
	if anim_name == "shake":
		fall()

func fall():
	$Collision.set_deferred("disabled", true)
	$TuxDetector.set_deferred("monitoring", false)
	falling = true
