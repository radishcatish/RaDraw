extends PanelContainer
const LAYER_DRAWN = preload("res://svg/layer_drawn.svg")
const LAYER_EMPTY = preload("res://svg/layer_empty.svg")
const LAYER_EYECLOSED = preload("res://svg/layer_eyeclosed.svg")
const LAYER_EYEOPEN = preload("res://svg/layer_eyeopen.svg")
const LAYER_LOCKED = preload("res://svg/layer_locked.svg")
const LAYER_UNLOCKED = preload("res://svg/layer_unlocked.svg")


@onready var main: Node = get_tree().current_scene
@onready var canvas: Control = $"../Canvas"
@onready var add_button: Button = $"../AddLayerButton"
@onready var layer_list: VBoxContainer = $ScrollContainer/LayerList

var active_layer: Node2D = null
var layer_rows: Dictionary = {}
var _drag_layer: Node2D = null
var _drag_accum: float = 0.0


func _ready() -> void:
	add_button.pressed.connect(_add_layer)
	await main.ready
	_create_header()
	add_layer("Layer 1")


func _create_header() -> void:
	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var spacer := Button.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.text = "Layers"
	header.add_child(spacer)

	var frame_btn := Button.new()
	frame_btn.text = "1"
	frame_btn.custom_minimum_size = Vector2(24, 0)
	frame_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(frame_btn)

	layer_list.add_child(header)


func add_layer(layer_name: String = "Layer") -> Node2D:
	var layer := Node2D.new()
	layer.name = layer_name
	main.art.add_child(layer)
	_create_row(layer)
	set_active_layer(layer)
	return layer


func set_active_layer(layer: Node2D) -> void:
	active_layer = layer
	canvas.current_layer = layer
	_refresh_rows()


func _refresh_rows() -> void:
	for layer in layer_rows:
		var row: Control = layer_rows[layer]
		row.modulate = Color(1, 1, 1.0, 1) if layer == active_layer else Color(1, 1, 1, .5)
		var dot: Button = row.get_node("FrameDot")
		dot.icon = LAYER_DRAWN if layer.get_child_count() > 0 else LAYER_EMPTY


func _create_row(layer: Node2D) -> void:
	var row := HBoxContainer.new()
	row.name = "Row"
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# visibility toggle
	var vis := Button.new()
	vis.icon = LAYER_EYEOPEN
	vis.pressed.connect(func():
		layer.visible = !layer.visible
		vis.modulate = Color(1,1,1,1) if layer.visible else Color(1,1,1,0.3)
		vis.icon = LAYER_EYEOPEN if layer.visible else LAYER_EYECLOSED
	)
	row.add_child(vis)

	var up := Button.new()
	up.text = "▲"
	up.pressed.connect(func(): _move_layer(layer, -1))
	row.add_child(up)

	var dn := Button.new()
	dn.text = "▼"
	dn.pressed.connect(func(): _move_layer(layer, 1))
	row.add_child(dn)

	var label := LineEdit.new()
	label.name = "NameLabel"
	label.text = layer.name
	label.alignment = HORIZONTAL_ALIGNMENT_CENTER

	label.text_submitted.connect(func(new_name): layer.name = new_name)
	label.gui_input.connect(func(event):
		if event is InputEventMouseButton:
			if event.pressed:
				set_active_layer(layer)
				_drag_layer = layer
				_drag_accum = 0.0
			else:
				_drag_layer = null
				_drag_accum = 0.0
		elif event is InputEventMouseMotion and _drag_layer == layer:
			var row_height = layer_rows[layer].size.y if layer_rows[layer].size.y > 0 else 24.0
			_drag_accum += event.relative.y
			while _drag_accum > row_height:
				_move_layer(layer, 1)
				_drag_accum -= row_height
			while _drag_accum < -row_height:
				_move_layer(layer, -1)
				_drag_accum += row_height
	)
	row.add_child(label)

	var dot := Button.new()
	dot.name = "FrameDot"
	dot.icon = LAYER_EMPTY
	dot.focus_mode = Control.FOCUS_NONE
	row.add_child(dot)

	layer_list.add_child(row)
	layer_rows[layer] = row


func _move_layer(layer: Node2D, direction: int) -> void:
	var idx = layer_rows[layer].get_index()  # index in layer_list (header is 0)
	var new_idx = clamp(idx + direction, 1, layer_list.get_child_count() - 1)
	if new_idx == idx:
		return
	layer_list.move_child(layer_rows[layer], new_idx)
	# mirror in main.art (no header there, so subtract 1)
	main.art.move_child(layer, new_idx - 1)


func _add_layer() -> void:
	add_layer("Layer %d" % (main.art.get_child_count() + 1))


func _process(_d: float) -> void:
	_refresh_rows()
