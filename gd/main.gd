extends Node
@onready var art: Node2D = $Art
@onready var colorbutton: ColorPickerButton = $UI/RightBar/Container/ColorPickerButton
@onready var line_thickness_slider: VSlider = $UI/RightBar/LineThicknessSlider
var mode: int = 0
var line_thickness: float = 1
func _process(delta: float) -> void:
	get_tree().root.content_scale_factor = DisplayServer.window_get_size().x / 1920.0 * 1.5
	line_thickness = line_thickness_slider.value

func drawbuttonpressed() -> void:mode = 0
func polybuttonpressed() -> void:mode = 1
func _on_erase_pressed() -> void:mode = -1
func _on_line_pressed() -> void:mode = 2
func _on_rect_pressed() -> void:mode = 3
func _on_move_pressed() -> void:mode = 4
func _on_edit_pressed() -> void:mode = 5

func _on_actions_index_pressed(index: int) -> void:
	match index:
		0:mode=-2
		1:mode=-3
