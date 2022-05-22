extends CanvasLayer

export(NodePath) var _target_viewport_path := NodePath()
export(NodePath) var _render_sprite_path := NodePath()

onready var _target_viewport := NodE.get_node(self, _target_viewport_path, Viewport) as Viewport
onready var _render_sprite := NodE.get_node(self, _render_sprite_path, Sprite) as Sprite

func _ready() -> void:
	custom_viewport = _target_viewport

func _process(delta) -> void:
	_render_sprite.global_transform = get_tree().root.canvas_transform.inverse()
	transform = get_tree().root.canvas_transform
