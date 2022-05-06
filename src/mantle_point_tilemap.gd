extends TileMap

export(int, LAYERS_2D_PHYSICS) var mantle_collision := 0

func _ready():
	var rect := get_used_rect()
	TileMapGenerator.add_mantle_points(self, rect, 2, mantle_collision)
