class_name BlockSpawner
extends Node2D

const LayersConstants := preload('res://layers_constants.tres')

export(Rect2) var spawn_area := Rect2(0, 0, 100, 100)
export(float) var spawn_rate_per_sec := 1.0

export(float, 0.1, 20.0) var speed_variation_min := 8.0
export(float, 0.1, 20.0) var speed_variation_max := 24.0

export(int, 1, 10) var width_variation_min := 3
export(int, 1, 10) var width_variation_max := 5
export(int, 1, 10) var height_variation_min := 3
export(int, 1, 10) var height_variation_max := 5

var _previous_spawn_time := -1.0 / spawn_rate_per_sec * 2.0
func _physics_process(delta: float) -> void:
	var spawn_delta := OS.get_ticks_msec() - _previous_spawn_time
	if spawn_delta < (1.0 / spawn_rate_per_sec * 1000.0):
		return
	
	_previous_spawn_time = OS.get_ticks_msec()
	
	var block := BlockNxN.new()
	block.width =  width_variation_min +  randi() % (width_variation_max - width_variation_min + 1)
	block.height = height_variation_min + randi() % (height_variation_max - height_variation_min + 1)
	block.texture = preload('res://assets/single_tile.png')
	
	var rect := _get_effective_spawn_rect_global(block.get_effective_width(), block.get_effective_height())
	
	var position_x := rect.position.x + randf() * rect.size.x
	var position_y := rect.position.y + randf() * rect.size.y
	
	var body := KinematicBody2D.new()
	body.collision_layer = LayersConstants.block_layer
	body.collision_mask = LayersConstants.block_mask
	
	var collision := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.extents = block.get_effective_size() / 2.0
	collision.shape = rect_shape
	body.add_child(collision)
	collision.position = block.get_effective_size() / 2.0
	
	var fall := BlockFall.new()
	fall.speed = speed_variation_min + (speed_variation_max - speed_variation_min) * randf()
	
	body.add_child(block)
	body.add_child(fall)
	
	body.global_position = Vector2(position_x, position_y)
	
	get_parent().add_child(body)
	
	global_position.y -= block.get_effective_height()


func _get_effective_spawn_rect_global(width: int, height: int) -> Rect2:
	var rect := spawn_area
	
	rect.position = to_global(rect.position)
	
	rect.size.x -= width
	rect.size.y -= height
	
	return rect



