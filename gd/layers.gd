extends PanelContainer
const LAYER_DRAWN = preload("res://svg/layer_drawn.svg")
const LAYER_EMPTY = preload("res://svg/layer_empty.svg")
const LAYER_EYECLOSED = preload("res://svg/layer_eyeclosed.svg")
const LAYER_EYEOPEN = preload("res://svg/layer_eyeopen.svg")
const LAYER_LOCKED = preload("res://svg/layer_locked.svg")
const LAYER_UNLOCKED = preload("res://svg/layer_unlocked.svg")


@onready var main: Node = get_tree().current_scene
@onready var canvas: Control = $"../Canvas"  # adjust to your scene path
@onready var add_button: Button = $"../AddLayerButton"
@onready var layer_list: VBoxContainer = $ScrollContainer/LayerList

var active_layer: Node2D = null
var layer_rows: Dictionary = {}  # layer Node2D -> row Control


func _ready() -> void:
	add_button.pressed.connect(_add_layer)
	await main.ready
	add_layer("Layer 1")


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

	# lock placeholder (greyed out until implemented)
	var lock := Button.new()
	lock.icon = LAYER_UNLOCKED
	lock.modulate = Color(1, 1, 1, 0.3)
	row.add_child(lock)

	# layer name
	var label := LineEdit.new()
	label.name = "NameLabel"
	label.text = layer.name
	label.alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(86, 0)
	label.text_submitted.connect(func(new_name): layer.name = new_name)
	label.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			set_active_layer(layer)
	)
	row.add_child(label)

	# frame dot
	var dot := Button.new()
	dot.name = "FrameDot"
	dot.icon = LAYER_EMPTY

	dot.focus_mode = Control.FOCUS_NONE
	row.add_child(dot)

	layer_list.add_child(row)
	layer_rows[layer] = row


func _add_layer() -> void:
	add_layer("Layer %d" % (main.art.get_child_count() + 1))


func _process(_d: float) -> void:
	_refresh_rows()
