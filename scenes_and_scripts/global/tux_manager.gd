extends CharacterBody2D

enum powerup_states {Small, Big, Fire}

# Used for Iceblocks. No idea why I moved it here other than I thought Bonus Blocks needed this?
var facing_direction = 1

# This is the thing I actually needed to move here for Bonus Blocks.
var current_state:TuxManager.powerup_states = Global.tux_state
