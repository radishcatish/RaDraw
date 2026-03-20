extends Node2D
class_name ClumpNode

var clump: Clump


static func from_clump(c: Clump) -> ClumpNode:
	var n := ClumpNode.new()
	n.clump = c
	n.name  = c.clump_name
	for stroke_data in c.strokes:
		n.add_child(stroke_data.spawn())
	return n


func get_strokes() -> Array:
	return get_children()


## Sync any runtime edits back into the Clump resource.
func bake() -> void:
	clump = Clump.from_nodes(get_strokes(), clump.clump_name)
