extends TextureRect
@onready var main: Node = get_tree().current_scene
const DRAW = preload("res://svg/draw.svg")
const LINE = preload("res://svg/line.svg")
const POLY = preload("res://svg/poly.svg")
const RECT = preload("res://svg/rect.svg")
const ERASE = preload("res://svg/erase.svg")
func _process(delta: float) -> void:
	match main.mode:
		-1:texture = ERASE
		0:texture = DRAW
		1:texture = POLY
		2:texture = LINE
		3:texture = RECT
