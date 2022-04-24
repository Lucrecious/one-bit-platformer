tool
class_name Block
extends CollisionShape2D

export(int, LAYERS_2D_PHYSICS) var mantle_collision_layer := 1 << 3
export(int) var mantle_size := 5.0
export(Color) var color := Color.whitesmoke

func _ready() -> void:
	update()
	
	if Engine.editor_hint:
		ObjEct.connect_once(shape, 'changed', self, '_on_shape_changed')
		return
	
	assert(shape is RectangleShape2D)
	var points := []
	
	points.push_back(-shape.extents)
	points.push_back(shape.extents * Vector2(1, -1))
	
	for p in points:
		var area := Area2D.new()
		var collision_shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = mantle_size / 2.0
		collision_shape.shape = circle
		area.add_child(collision_shape)
		add_child(area)
		
		area.position = p
		area.collision_layer = mantle_collision_layer
		area.collision_mask = 0

func _on_shape_changed() -> void:
	update()

func _draw() -> void:
	draw_rect(Rect2(-shape.extents, shape.extents * 2.0), color)
