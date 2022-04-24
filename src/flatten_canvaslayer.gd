extends CanvasLayer

export(NodePath) var _viewport_path := NodePath()

onready var _viewport := NodE.get_node_with_error(self, _viewport_path,  Viewport) as Viewport

func _ready() -> void:
	custom_viewport = _viewport
