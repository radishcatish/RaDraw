extends Button
@onready var main: Node = get_tree().current_scene
const DRAW = preload("res://svg/draw.svg")
const LINE = preload("res://svg/line.svg")
const POLY = preload("res://svg/poly.svg")
const SHAPE = preload("res://svg/shape.svg")
const ERASE = preload("res://svg/erase.svg")
func _process(delta: float) -> void:
	match main.mode:
		-1:icon = ERASE
		0:icon = DRAW
		1:icon = POLY
		2:icon = LINE
		3:icon = SHAPE
