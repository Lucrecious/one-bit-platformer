extends Node2D

export(int) var chunk_offset_x := 0
export(int) var chunk_offset_y := 0
export(int) var chunk_width := 0
export(int) var chunk_height := 0
export(TileSet) var tileset: TileSet = null
export(int, LAYERS_2D_PHYSICS) var tilemap_collision := 0
export(int, LAYERS_2D_PHYSICS) var mantle_point_collision := 0
export(int) var mantle_size := 5.0
export(int) var outer_margin_size := 1
export(int) var min_width_space := 1
export(int) var min_height_space := 1
export(int) var min_block_size := 1
export(int) var max_block_size := 1

onready var _tilemap := NodE.add_child(self, TileMap.new()) as TileMap

func _ready() -> void:
	_tilemap.tile_set = tileset
	_tilemap.cell_size = Vector2.ONE * 8.0
	_tilemap.collision_layer = tilemap_collision
	
	for i in 10:
		var region := get_chunk_rect(Vector2(0, -i))
		if i == 0:
			box(_tilemap, region, outer_margin_size, 0, outer_margin_size, outer_margin_size)
			
			var block_region := region.grow_individual(-outer_margin_size, 0, -outer_margin_size, -outer_margin_size - 15)
			block(_tilemap, block_region)
			generate_chunk(_tilemap, block_region, 4)
			_add_mantle_points(_tilemap, block_region)
		else:
			box(_tilemap, region, outer_margin_size, 0, outer_margin_size, 0)
			var block_region := region.grow_individual(-outer_margin_size, -outer_margin_size, -outer_margin_size, -outer_margin_size)
			block(_tilemap, block_region)
			generate_chunk(_tilemap, block_region, 4)
			_add_mantle_points(_tilemap, block_region)
		
		_tilemap.update_bitmask_region(region.position, region.position + region.size)

func generate_chunk(map: TileMap, region: Rect2, levels: int, vertical := false) -> void:
	if levels == 0:
		return
	
	levels -= 1
	
	var left_top_rect := Rect2()
	var right_bottom_rect := Rect2()
	
	if vertical:
		var max_thickness := int(min(region.size.x, max_block_size))
		if max_thickness <= min_block_size:
			return
		
		var thickness := randi() % (max_thickness - min_block_size) + min_block_size
		
		var columns := range(min_block_size, region.size.x - min_width_space - thickness)
		columns.push_back(0)
		columns.push_back(region.size.x - thickness)
		
		var column := columns[randi() % columns.size()] as int
		
		strikev(map, region, column, thickness, -1)
		
		left_top_rect = region.grow_individual(0, 0, column - region.size.x, 0)
		right_bottom_rect = region.grow_individual(-(column + thickness), 0, 0, 0)
	else:
		var max_thickness := int(min(region.size.y, max_block_size))
		if max_thickness <= min_block_size:
			return
		
		var thickness := randi() % (max_thickness - min_block_size) + min_block_size
		
		var rows := range(min_block_size, region.size.y - min_height_space - thickness)
		rows.push_back(0)
		rows.push_back(region.size.y - thickness)
		
		var row := rows[randi() % rows.size()] as int
		
		strikeh(map, region, row, thickness, -1)
		
		left_top_rect = region.grow_individual(0, 0, 0, row - region.size.y)
		right_bottom_rect = region.grow_individual(0, -(row + thickness), 0, 0)
	
	generate_chunk(map, left_top_rect, levels, not vertical)
	generate_chunk(map, right_bottom_rect, levels, not vertical)
	

func splitv(rect: Rect2, column: int) -> Array:
	return [
			Rect2(rect.position, Vector2(column, rect.size.y)),
			Rect2(Vector2(rect.position.x + column, rect.position.y), Vector2(rect.size.x - column, rect.size.y))
		]

func splith(rect: Rect2, row: int) -> Array:
	return [
			Rect2(rect.position, Vector2(rect.size.x, row)),
			Rect2(Vector2(rect.position.x, rect.position.y + row), Vector2(rect.size.x, rect.size.y - row))
		]

func box(map: TileMap, region: Rect2, left := 0, top := 0, right := 0, bottom := 0) -> void:
	fill(map, region, 0)
	fill(map, region.grow_individual(-left, -top, -right, -bottom), -1)

func block(map: TileMap, region: Rect2) -> void:
	fill(map, region, 0)

func erase(map: TileMap, region: Rect2) -> void:
	fill(map, region, -1)

func strikev(map: TileMap, region: Rect2, column: int, width: int, id: int) -> void:
	for j in width:
		for y in region.size.y:
			map.set_cell(region.position.x + column + j, region.position.y + y, id)

func strikeh(map: TileMap, region: Rect2, row: int, height: int, id: int) -> void:
	for j in height:
		for x in region.size.x:
			map.set_cell(region.position.x + x, region.position.y + row + j, id)

func get_chunk_rect(position: Vector2) -> Rect2:
	return Rect2(position * Vector2(chunk_width, chunk_height) + Vector2(chunk_offset_x, chunk_offset_y), Vector2(chunk_width, chunk_height))

func get_chunk_coord(position: Vector2) -> Rect2:
	position -= Vector2(chunk_offset_x, chunk_offset_y)
	position = Vector2(floor(position.x / chunk_width) * chunk_width, floor(position.y / chunk_height) * chunk_height)
	
	return Rect2(position + Vector2(chunk_offset_x, chunk_offset_y), Vector2(chunk_width, chunk_height))

func fill(map: TileMap, region: Rect2, id := -1) -> void:
	for i in region.size.x:
		for j in region.size.y:
			map.set_cell(region.position.x + i, region.position.y + j, id)

func _add_mantle_points(map: TileMap, region: Rect2) -> void:
	for cell in map.get_used_cells():
		if not region.has_point(cell):
			continue
		
		var corners := _get_corners(map, cell)
		for point in corners:
			var area := Area2D.new()
			var collision_shape := CollisionShape2D.new()
			var circle := CircleShape2D.new()
			circle.radius = mantle_size / 2.0
			collision_shape.shape = circle
			area.add_child(collision_shape)
			add_child(area)
			
			area.position = point
			area.collision_layer = mantle_point_collision
			area.collision_mask = 0

func _get_corners(map: TileMap, cell: Vector2) -> Array:
	if _is_empty(map, cell):
		return []
	
	var corners := []
	
	# left corner
	if _is_empty(map, cell + Vector2.LEFT) and _is_empty(map, cell + Vector2.UP):
		corners.push_back(map.map_to_world(cell))
	
	if _is_empty(map, cell + Vector2.RIGHT) and _is_empty(map, cell + Vector2.UP):
		corners.push_back(map.map_to_world(cell) + Vector2.RIGHT * map.cell_size)
	
	return corners

func _is_empty(map: TileMap, cell: Vector2) -> bool:
	return map.get_cellv(cell) < 0 
