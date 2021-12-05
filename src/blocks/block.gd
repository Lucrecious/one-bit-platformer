tool
class_name BlockNxN
extends Node2D

enum Type {
	Static,
	Kinematic,
}

export(int, 1, 100) var width := 1 setget _width_set
export(int, 1, 100) var height := 1 setget _height_set
export(Texture) var texture: Texture = null setget _texture_set

func _width_set(value: int) -> void:
	if value == width:
		return
	
	width = value
	_update()

func _height_set(value: int) -> void:
	if value == height:
		return
	
	height = value
	_update()

func _texture_set(value: Texture) -> void:
	if value == texture:
		return
	
	texture = value
	_update()

func get_effective_size() -> Vector2:
	return Vector2(get_effective_width(), get_effective_height())

func get_effective_width() -> int:
	if not texture:
		return 0
	return width * texture.get_width()

func get_effective_height() -> int:
	if not texture:
		return 0
	return height * texture.get_height()

func _update() -> void:
	update()

func _draw() -> void:
	if not texture:
		return
	
	var texture_width := texture.get_width()
	var texture_height := texture.get_height()
	
	for x in width:
		for y in height:
			draw_texture(texture, Vector2(x * texture_width, y * texture_height))
			

