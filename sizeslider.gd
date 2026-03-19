extends VSlider
@onready var main: Node = get_tree().current_scene
@onready var label: Label = $Label
func _process(_delta: float) -> void:
	label.text = str(value as int)
	if main.mode == 0 or main.mode == 2:
		visible = true
	else:
		visible = false
