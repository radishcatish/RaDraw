extends Resource
class_name Clump

@export var clump_name: String = "Clump"
@export var strokes: Array[StrokeData] = []


static func from_nodes(nodes: Array, name: String = "Clump") -> Clump:
	var c := Clump.new()
	c.clump_name = name
	for node in nodes:
		if node is Line2D:
			c.strokes.append(StrokeData.from_line(node))
		elif node is Polygon2D:
			c.strokes.append(StrokeData.from_polygon(node))
	return c


func save(path: String) -> void:
	ResourceSaver.save(self, path)


static func load_from(path: String) -> Clump:
	return ResourceLoader.load(path, "Clump")
