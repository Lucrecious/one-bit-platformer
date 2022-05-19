extends Node2D

export(NodePath) var _canvas_layer_path := NodePath()
export(NodePath) var _viewport_path := NodePath()
export(NodePath) var _sprite_path := NodePath()


onready var _canvas_layer := NodE.get_node(self, _canvas_layer_path, CanvasLayer) as CanvasLayer
onready var _viewport := NodE.get_node(self, _viewport_path, Viewport) as Viewport
onready var _sprite := get_node(_sprite_path)

func _ready() -> void:
	_canvas_layer.custom_viewport = _viewport

func _process(delta) -> void:
	_sprite.global_transform = get_tree().root.canvas_transform.inverse()
	_canvas_layer.transform = get_tree().root.canvas_transform
