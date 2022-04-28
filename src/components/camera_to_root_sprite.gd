extends Node


func _ready() -> void:
	yield(get_tree(), 'idle_frame')
	var camera := NodE.get_sibling_with_error(self, Camera2D) as Camera2D
	camera.get_parent().remove_child(camera)
	Components.root_sprite(get_parent()).add_child(camera)
