extends Control
@onready var main: Node = get_tree().current_scene
var current_stroke: Node
var stroke_list: Array = []
var stroke_position: Vector2 = Vector2.ZERO
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				main.art.scale -= Vector2(.1, .1)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				main.art.scale += Vector2(.1, .1)
		main.art.scale = clamp(main.art.scale, Vector2(.1,.1), Vector2(10, 10))
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if main.mode == 0:
					current_stroke = Line2D.new()
					current_stroke.end_cap_mode = Line2D.LINE_CAP_ROUND
					current_stroke.begin_cap_mode = Line2D.LINE_CAP_ROUND
					current_stroke.joint_mode = Line2D.LINE_JOINT_ROUND
					current_stroke.default_color = main.colorbutton.color
					current_stroke.width = main.line_thickness
					current_stroke.add_point(main.art.global_transform.affine_inverse() * event.position)
					current_stroke.add_point(main.art.global_transform.affine_inverse() * event.position + Vector2(0, 0.0001))
					main.art.add_child(current_stroke)
					stroke_list.append(current_stroke)
				elif main.mode == 1:
					current_stroke = Polygon2D.new()
					current_stroke.polygon = PackedVector2Array([main.art.global_transform.affine_inverse() * event.position])
					current_stroke.color = main.colorbutton.color
					main.art.add_child(current_stroke)
					stroke_list.append(current_stroke)
			else:
				current_stroke = null
				
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if main.mode == -1:  # Eraser mode
				var local_pos = main.art.global_transform.affine_inverse() * event.position
				for stroke in stroke_list:
					if stroke_contains_point(stroke, local_pos, 10):
						stroke.queue_free()
						stroke_list.erase(stroke)
						break
			elif current_stroke is Line2D:
				stroke_position = lerp(stroke_position, event.position, .5)
				current_stroke.add_point(main.art.global_transform.affine_inverse() * stroke_position)
			elif current_stroke:
				current_stroke.polygon = current_stroke.polygon + PackedVector2Array([main.art.global_transform.affine_inverse() * event.position])
		else:
			stroke_position = event.position
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			main.art.global_position += event.relative

func stroke_contains_point(stroke: Node, point: Vector2, tolerance: float) -> bool:
	if stroke is Line2D:
		for i in range(stroke.get_point_count()):
			if stroke.get_point_position(i).distance_to(point) < tolerance:
				return true
	elif stroke is Polygon2D:
		for p in stroke.polygon:
			if p.distance_to(point) < tolerance:
				return true
	return false

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.ctrl_pressed and event.keycode == KEY_Z:
			if stroke_list.size() > 0:
				stroke_list.back().queue_free()
				stroke_list.pop_back()
