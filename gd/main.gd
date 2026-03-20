extends Node
@onready var center: Node2D = $Center
@onready var tiles: Sprite2D = $Center/Tiles

@onready var toolicon: TextureRect = $UI/RightBar/Container/Icon
@onready var line_thickness_slider: VSlider = $UI/RightBar/LineThicknessSlider
@onready var thickness_label: Label = $UI/RightBar/LineThicknessSlider/ThicknessLabel
@onready var art: Node2D = $Art
@onready var colorbutton: ColorPickerButton = $UI/RightBar/Container/ColorPickerButton
const DRAW = preload("res://svg/draw.svg")
const LINE = preload("res://svg/line.svg")
const POLY = preload("res://svg/poly.svg")
const RECT = preload("res://svg/rect.svg")
const ERASE = preload("res://svg/erase.svg")
const MOVE = preload("res://svg/move.svg")
const POLYTOLINE = preload("res://svg/polytoline.svg")
const LINETOPOLY = preload("res://svg/linetopoly.svg")
const EDIT = preload("res://svg/edit.svg")
var mode: int = 0
var line_thickness: float = 1
func _ready():
	art.position = art.get_viewport_rect().size / 2

func _process(_d):
	center.position = art.position
	tiles.scale = art.scale * 10
	match mode:
		-3:toolicon.texture = LINETOPOLY
		-2:toolicon.texture = POLYTOLINE
		-1:toolicon.texture = ERASE
		0:toolicon.texture = DRAW
		1:toolicon.texture = POLY
		2:toolicon.texture = LINE
		3:toolicon.texture = RECT
		4:toolicon.texture = MOVE
		5:toolicon.texture = EDIT

	thickness_label.text = str(line_thickness_slider.value as int)
	if mode == 0 or mode == 2:
		line_thickness_slider.editable = true
		line_thickness_slider.modulate = Color(1,1,1,1)
	else:
		line_thickness_slider.editable = false
		line_thickness_slider.modulate = Color(1,1,1,.5)
	
	line_thickness = line_thickness_slider.value

func drawbuttonpressed():mode = 0
func polybuttonpressed():mode = 1
func _on_erase_pressed():mode = -1
func _on_line_pressed():mode = 2
func _on_rect_pressed():mode = 3
func _on_move_pressed():mode = 4
func _on_edit_pressed():mode = 5
func _on_actions_index_pressed(index: int):
	match index:
		0:mode=-2
		1:mode=-3
