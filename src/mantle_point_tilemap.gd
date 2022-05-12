extends TileMap

export(int, LAYERS_2D_PHYSICS) var mantle_collision := 0

func _ready():
	var rect := get_used_rect()
	printt(get_path(), rect)
	TileMapGenerator.add_mantle_points(self, rect, 2, mantle_collision)
	
	LevelEditor.commands.connect('tilemap_changed', self, '_on_tilemap_changed')

func _on_tilemap_changed(tilemap: TileMap, region: Rect2) -> void:
	if tilemap != self:
		return
	region = region.grow(1)
	TileMapGenerator.remove_mantle_points(self, region, mantle_collision)
	TileMapGenerator.add_mantle_points(self, region, 2, mantle_collision)
