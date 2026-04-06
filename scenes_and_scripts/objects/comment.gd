@tool
extends Label

@export_enum("Comment", "TODO", "FIXME") var type = 0:
	set(value):
		type = value
		set_font_color()

func set_font_color():
	if type == 0:
		set("theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
	elif type == 1:
		set("theme_override_colors/font_color", Color(1.0, 0.5, 0.0, 1.0))
	elif type == 2:
		set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if not Global.debug:
			visible = false
		else:
			visible = true
