extends TextureRect
@onready var main: Node = get_tree().current_scene
const DRAW = preload("res://svg/draw.svg")
const LINE = preload("res://svg/line.svg")
const POLY = preload("res://svg/poly.svg")
const RECT = preload("res://svg/rect.svg")
const ERASE = preload("res://svg/erase.svg")
const MOVE = preload("res://svg/move.svg")
const POLYTOLINE = preload("res://svg/polytoline.svg")
const LINETOPOLY = preload("res://svg/linetopoly.svg")
const EDIT = preload("res://svg/edit.svg")
func _process(_d):
	match main.mode:
		-3:texture = LINETOPOLY
		-2:texture = POLYTOLINE
		-1:texture = ERASE
		0:texture = DRAW
		1:texture = POLY
		2:texture = LINE
		3:texture = RECT
		4:texture = MOVE
		5:texture = EDIT
