extends Resource
class_name StrokeData

enum Type { LINE, POLYGON }

@export var type: Type
@export var points: PackedVector2Array
@export var color: Color
@export var width: float = 10.0  # only used for LINE type
@export var position: Vector2
@export var rotation: float
@export var z_index: int


static func from_line(line: Line2D) -> StrokeData:
	var d := StrokeData.new()
	d.type     = Type.LINE
	d.points   = line.points
	d.color    = line.default_color
	d.width    = line.width
	d.position = line.position
	d.rotation = line.rotation
	d.z_index  = line.z_index
	return d


static func from_polygon(poly: Polygon2D) -> StrokeData:
	var d := StrokeData.new()
	d.type     = Type.POLYGON
	d.points   = poly.polygon
	d.color    = poly.color
	d.position = poly.position
	d.rotation = poly.rotation
	d.z_index  = poly.z_index
	return d


func spawn() -> Node2D:
	match type:
		Type.LINE:
			var line := Line2D.new()
			line.points           = points
			line.default_color    = color
			line.width            = width
			line.position         = position
			line.rotation         = rotation
			line.z_index          = z_index
			line.end_cap_mode     = Line2D.LINE_CAP_ROUND
			line.begin_cap_mode   = Line2D.LINE_CAP_ROUND
			line.joint_mode       = Line2D.LINE_JOINT_ROUND
			return line
		Type.POLYGON:
			var poly := Polygon2D.new()
			poly.polygon  = points
			poly.color    = color
			poly.position = position
			poly.rotation = rotation
			poly.z_index  = z_index
			return poly
	return Node2D.new()
