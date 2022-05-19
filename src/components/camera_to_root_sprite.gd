extends Node

export(NodePath) var _remote_transform_path := NodePath()

onready var remote_transform := NodE.get_node(self, _remote_transform_path, RemoteTransform2D) as RemoteTransform2D


func _ready() -> void:
	var camera := NodE.get_sibling(self, Camera2D) as Camera2D
	remote_transform.remote_path = remote_transform.get_path_to(camera)
