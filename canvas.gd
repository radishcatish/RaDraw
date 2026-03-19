extends Control
@onready var main: Node = get_tree().current_scene
var current_stroke: Line2D
var stroke_list: Array = []
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				current_stroke = Line2D.new()
				current_stroke.end_cap_mode = Line2D.LINE_CAP_ROUND
				current_stroke.begin_cap_mode = Line2D.LINE_CAP_ROUND
				current_stroke.joint_mode = Line2D.LINE_JOINT_BEVEL
				current_stroke.add_point(main.art.global_transform.affine_inverse() * event.position)
				current_stroke.add_point(main.art.global_transform.affine_inverse() * event.position + Vector2(0, 0.0001))
				main.art.add_child(current_stroke)
				stroke_list.append(current_stroke)
			else:
				current_stroke = null
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if current_stroke:
				current_stroke.add_point(main.art.global_transform.affine_inverse() * event.position)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			main.art.global_position += event.relative

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.ctrl_pressed and event.keycode == KEY_Z:
			if stroke_list.size() > 0:
				stroke_list.back().queue_free()
				stroke_list.pop_back()
