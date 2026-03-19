extends Node2D
func _ready() -> void:
	position = get_viewport_rect().size / 2
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				scale -= Vector2(.1, .1)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				scale += Vector2(.1, .1)
	scale = clamp(scale, Vector2(.1,.1), Vector2.INF)
