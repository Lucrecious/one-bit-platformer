extends TileMap

export(int, LAYERS_2D_PHYSICS) var mantle_collision_layer := 0
export(int) var mantle_size := 5.0


func _ready() -> void:
	for cell in get_used_cells():
		var corners := _get_corners(cell)
		for point in corners:
			var area := Area2D.new()
			var collision_shape := CollisionShape2D.new()
			var circle := CircleShape2D.new()
			circle.radius = mantle_size / 2.0
			collision_shape.shape = circle
			area.add_child(collision_shape)
			add_child(area)
			
			area.position = point
			area.collision_layer = mantle_collision_layer
			area.collision_mask = 0

func _get_corners(cell: Vector2) -> Array:
	if _is_empty(cell):
		return []
	
	var corners := []
	
	# left corner
	if _is_empty(cell + Vector2.LEFT) and _is_empty(cell + Vector2.UP):
		corners.push_back(map_to_world(cell))
	
	if _is_empty(cell + Vector2.RIGHT) and _is_empty(cell + Vector2.UP):
		corners.push_back(map_to_world(cell) + Vector2.RIGHT * cell_size)
	
	return corners

func _is_empty(cell: Vector2) -> bool:
	return get_cellv(cell) < 0 
