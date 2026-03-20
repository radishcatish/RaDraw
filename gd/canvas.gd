extends Control
@onready var main: Node = get_tree().current_scene
var current_stroke: Node = null
var stroke_list: Array = []
var stroke_position: Vector2 = Vector2.ZERO

const MODE_DRAW     =  0
const MODE_POLYGON  =  1
const MODE_LINE     =  2
const MODE_RECT    =  3
const MODE_ERASER   = -1

const ZOOM_STEP    = Vector2(0.1, 0.1)
const ZOOM_MIN     = Vector2(0.1, 0.1)
const ZOOM_MAX     = Vector2(10.0, 10.0)
const ERASER_RADIUS = 10.0


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				main.art.scale = clamp(main.art.scale + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				main.art.scale = clamp(main.art.scale - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				_begin_stroke(event.position)
			else:
				current_stroke = null


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		main.art.global_position += event.relative

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_continue_stroke(event)
	else:
		stroke_position = event.position


func _begin_stroke(pos: Vector2) -> void:
	var canvas_pos := to_canvas(pos)
	match main.mode:
		MODE_DRAW:
			var line := Line2D.new()
			line.end_cap_mode   = Line2D.LINE_CAP_ROUND
			line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			line.joint_mode     = Line2D.LINE_JOINT_ROUND
			line.default_color  = main.colorbutton.color
			line.width          = main.line_thickness
			line.add_point(canvas_pos)
			line.add_point(canvas_pos + Vector2(0, 0.0001))  # prevent zero-length line
			main.art.add_child(line)
			stroke_list.append(line)
			current_stroke = line

		MODE_POLYGON:
			var poly := Polygon2D.new()
			poly.polygon = PackedVector2Array([canvas_pos])
			poly.color   = main.colorbutton.color
			main.art.add_child(poly)
			stroke_list.append(poly)
			current_stroke = poly
		MODE_LINE:
			var line := Line2D.new()
			line.end_cap_mode   = Line2D.LINE_CAP_ROUND
			line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			line.joint_mode     = Line2D.LINE_JOINT_ROUND
			line.default_color  = main.colorbutton.color
			line.width          = main.line_thickness
			line.add_point(canvas_pos)
			line.add_point(canvas_pos + Vector2(0, 0.0001))  # prevent zero-length line
			main.art.add_child(line)
			stroke_list.append(line)
			current_stroke = line
		MODE_RECT:
			var poly := Polygon2D.new()
			poly.color = main.colorbutton.color
			poly.polygon = PackedVector2Array([canvas_pos, canvas_pos, canvas_pos, canvas_pos])
			main.art.add_child(poly)
			stroke_list.append(poly)
			current_stroke = poly


func _continue_stroke(event: InputEventMouseMotion) -> void:
	match main.mode:
		MODE_ERASER:
			var canvas_pos := to_canvas(event.position)
			for stroke in stroke_list:
				if stroke_contains_point(stroke, canvas_pos, ERASER_RADIUS):
					stroke.queue_free()
					stroke_list.erase(stroke)
					break

		MODE_DRAW:
			if current_stroke is Line2D:
				stroke_position = lerp(stroke_position, event.position, 0.5)
				current_stroke.add_point(to_canvas(stroke_position))

		MODE_POLYGON:
			if current_stroke is Polygon2D:
				current_stroke.polygon += PackedVector2Array([to_canvas(event.position)])
		MODE_LINE:
			if current_stroke is Line2D:
				current_stroke.set_point_position(1, to_canvas(event.position))
		MODE_RECT:
			if current_stroke is Polygon2D:
				var start = current_stroke.polygon[0]
				var end = to_canvas(event.position)
				current_stroke.polygon = PackedVector2Array([
					start,
					Vector2(end.x, start.y),
					end,
					Vector2(start.x, end.y),
				])


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.ctrl_pressed:
		if event.keycode == KEY_Z:
			_undo()


func _undo() -> void:
	if stroke_list.is_empty():
		return
	stroke_list.back().queue_free()
	stroke_list.pop_back()


## Convert a screen position to canvas-local space.
func to_canvas(screen_pos: Vector2) -> Vector2:
	return main.art.global_transform.affine_inverse() * screen_pos


func stroke_contains_point(stroke: Node, point: Vector2, tolerance: float) -> bool:
	if stroke is Line2D:
		for i in stroke.get_point_count():
			if stroke.get_point_position(i).distance_to(point) < tolerance:
				return true
	elif stroke is Polygon2D:
		for p in stroke.polygon:
			if p.distance_to(point) < tolerance:
				return true
	return false
