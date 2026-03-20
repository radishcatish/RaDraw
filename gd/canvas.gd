extends Control
@onready var main: Node = get_tree().current_scene
var current_stroke: Node = null
var current_layer: Node2D = null  # set by layers panel
var stroke_position: Vector2 = Vector2.ZERO
var selected_stroke: Node = null
var selected_strokes: Array = []
var prev_mouse_pos: Vector2 = Vector2.ZERO
var move_rotating := false
var edit_stroke: Node = null
var edit_point_index: int = -1

const EDIT_RADIUS = 12.0

const MODE_DRAW       =  0
const MODE_POLYGON    =  1
const MODE_LINE       =  2
const MODE_RECT       =  3
const MODE_MOVE       =  4
const MODE_EDIT       =  5 
const MODE_ERASER     = -1
const MODE_POLYTOLINE = -2
const MODE_LINETOPOLY = -3
 
const ZOOM_STEP    = Vector2(0.1, 0.1)
const ZOOM_MIN     = Vector2(0.1, 0.1)
const ZOOM_MAX     = Vector2(10.0, 10.0)
const ERASER_RADIUS = 10.0
const SELECT_RADIUS = 20.0
const SELECTED_TINT = Color(0.5, 0.8, 1.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				if not selected_stroke:
					main.art.scale = clamp(main.art.scale + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
				else:
					var idx := selected_stroke.get_index()
					main.art.move_child(selected_stroke, idx + 1) 
		MOUSE_BUTTON_WHEEL_DOWN:
			if not selected_stroke:
				main.art.scale = clamp(main.art.scale - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
			else:
				var idx := selected_stroke.get_index()
				main.art.move_child(selected_stroke, idx - 1) 
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				_begin_stroke(event.position)
			else:
				current_stroke = null
				if main.mode != MODE_MOVE:
					_set_selected(selected_stroke, false)
					for s in selected_strokes:
						_set_selected(s, false)
					selected_strokes.clear()
					selected_stroke = null
				if main.mode != MODE_EDIT:
					edit_point_index = -1


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		main.art.global_position += event.relative

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_continue_stroke(event)
	else:
		stroke_position = event.position

	if main.mode == MODE_MOVE and selected_stroke:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var center := get_stroke_center(selected_stroke)
			var prev_angle := (to_canvas(prev_mouse_pos) - center).angle()
			var curr_angle := (to_canvas(event.position) - center).angle()
			selected_stroke.rotation += curr_angle - prev_angle
			move_rotating = true
		else:
			move_rotating = false
	else:
		move_rotating = false
		
	prev_mouse_pos = event.position


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
			current_layer.add_child(line)
			current_stroke = line

		MODE_POLYGON:
			var poly := Polygon2D.new()
			poly.polygon = PackedVector2Array([canvas_pos])
			poly.color   = main.colorbutton.color
			current_layer.add_child(poly)
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
			current_layer.add_child(line)
			current_stroke = line
		MODE_RECT:
			var poly := Polygon2D.new()
			poly.color = main.colorbutton.color
			poly.polygon = PackedVector2Array([canvas_pos, canvas_pos, canvas_pos, canvas_pos])
			current_layer.add_child(poly)
			current_stroke = poly

		MODE_MOVE:
			var clicked := _find_closest_stroke(canvas_pos)
			if Input.is_key_pressed(KEY_SHIFT):
				if clicked and clicked in selected_strokes:
					selected_strokes.erase(clicked)
					_set_selected(clicked, false)
				elif clicked:
					selected_strokes.append(clicked)
					_set_selected(clicked, true)
				selected_stroke = null
			else:
				_set_selected(selected_stroke, false)
				for s in selected_strokes:
					_set_selected(s, false)
				selected_strokes.clear()
				selected_stroke = clicked
				_set_selected(selected_stroke, true)

		MODE_EDIT:
			var clicked_stroke := _find_closest_stroke(canvas_pos)
			if clicked_stroke != edit_stroke:
				edit_stroke = clicked_stroke
				edit_point_index = -1
			if edit_stroke:
				edit_point_index = _find_closest_point(edit_stroke, canvas_pos, EDIT_RADIUS)
		MODE_POLYTOLINE:
			var clicked_stroke := _find_closest_stroke(canvas_pos)
			if clicked_stroke is Line2D:
				var poly := Polygon2D.new()
				poly.color = main.colorbutton.color
				poly.polygon = clicked_stroke.points
				current_layer.add_child(poly)
				poly.position = clicked_stroke.position
				current_stroke = poly
				main.mode = MODE_MOVE
				selected_strokes = [poly, clicked_stroke]
				_group_selection()
		MODE_LINETOPOLY:
			var clicked_stroke := _find_closest_stroke(canvas_pos)
			if clicked_stroke is Polygon2D:
				var line := Line2D.new()
				line.end_cap_mode   = Line2D.LINE_CAP_ROUND
				line.begin_cap_mode = Line2D.LINE_CAP_ROUND
				line.joint_mode     = Line2D.LINE_JOINT_ROUND
				line.default_color  = main.colorbutton.color
				line.width          = main.line_thickness
				line.points = clicked_stroke.polygon
				line.closed = true
				current_layer.add_child(line)
				line.position = clicked_stroke.position
				current_stroke = line
				main.mode = MODE_MOVE
				selected_strokes = [line, clicked_stroke]
				_group_selection()

func _continue_stroke(event: InputEventMouseMotion) -> void:
	match main.mode:
		MODE_ERASER:
			var canvas_pos := to_canvas(event.position)
			for stroke in _all_strokes():
				if stroke_contains_point(stroke, canvas_pos, ERASER_RADIUS):
					stroke.queue_free()
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

		MODE_MOVE:
			if selected_stroke and not move_rotating:
				selected_stroke.position += event.relative / main.art.scale.x

		MODE_EDIT:
			if edit_stroke and edit_point_index >= 0:
				var new_pos = to_canvas(event.position) - edit_stroke.position
				if edit_stroke is Line2D:
					edit_stroke.set_point_position(edit_point_index, new_pos)
				elif edit_stroke is Polygon2D:
					edit_stroke.polygon[edit_point_index] = new_pos


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.ctrl_pressed:
		match event.keycode:
			KEY_Z:
				_undo()
			KEY_G:
				_group_selection()


func _set_selected(stroke: Node, on: bool) -> void:
	if stroke:
		stroke.modulate = SELECTED_TINT if on else Color.WHITE


func _undo() -> void:
	if not current_layer:
		return
	var children := current_layer.get_children()
	if children.is_empty():
		return
	children.back().queue_free()


## Convert a screen position to canvas-local space.
func to_canvas(screen_pos: Vector2) -> Vector2:
	return main.art.global_transform.affine_inverse() * screen_pos


func get_stroke_center(stroke: Node) -> Vector2:
	var pts: Array = []
	if stroke is Line2D:
		for i in stroke.get_point_count():
			pts.append(stroke.get_point_position(i))
	elif stroke is Polygon2D:
		pts = Array(stroke.polygon)
	if pts.is_empty():
		return stroke.position
	var avg := Vector2.ZERO
	for p in pts:
		avg += p
	return (avg / pts.size()) + stroke.position

## Returns all strokes across all visible layers.
func _all_strokes() -> Array:
	var result: Array = []
	for layer in main.art.get_children():
		if layer.visible:
			result.append_array(layer.get_children())
	return result


func _find_closest_stroke(canvas_pos: Vector2) -> Node:
	var best_dist := SELECT_RADIUS
	var result: Node = null
	for stroke in _all_strokes():
		var dist := stroke_min_distance(stroke, canvas_pos)
		if dist < best_dist:
			best_dist = dist
			result = stroke
	return result


func _find_closest_point(stroke: Node, canvas_pos: Vector2, tolerance: float) -> int:
	# canvas_pos is in art space; stroke points are local to the stroke node
	var local_pos = canvas_pos - stroke.position
	var best_dist := tolerance
	var best_index := -1
	if stroke is Line2D:
		for i in stroke.get_point_count():
			var d = stroke.get_point_position(i).distance_to(local_pos)
			if d < best_dist:
				best_dist = d
				best_index = i
	elif stroke is Polygon2D:
		for i in stroke.polygon.size():
			var d = stroke.polygon[i].distance_to(local_pos)
			if d < best_dist:
				best_dist = d
				best_index = i
	return best_index


func stroke_min_distance(stroke: Node, point: Vector2) -> float:
	if stroke is ClumpNode:
		var best := INF
		for child in stroke.get_strokes():
			best = min(best, stroke_min_distance(child, point - stroke.position))
		return best
	var best := INF
	if stroke is Line2D:
		for i in stroke.get_point_count():
			best = min(best, stroke.get_point_position(i).distance_to(point))
	elif stroke is Polygon2D:
		for p in stroke.polygon:
			best = min(best, p.distance_to(point))
	return best

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
	
func _group_selection() -> void:
	if selected_strokes.size() < 2:
		return
	var clump_data := Clump.from_nodes(selected_strokes, "Clump")
	var clump_node := ClumpNode.from_clump(clump_data)
	current_layer.add_child(clump_node)
	for stroke in selected_strokes:
		stroke.queue_free()
	selected_strokes.clear()
	selected_stroke = clump_node
