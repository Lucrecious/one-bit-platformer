extends Area2D

export(NodePath) var _player_path := NodePath()

onready var player := get_node(_player_path) as Node2D
onready var _camera := NodE.get_child_with_error(player, Camera2D) as Camera2D


func _ready() -> void:
	var lines := NodE.get_children(self, Line2D)
	
	for l in lines:
		var line := l as Line2D
		for i in range(1, line.points.size()):
			var a := line.points[i - 1]
			var b := line.points[i]
			
			var collision := CollisionShape2D.new()
			var segment := SegmentShape2D.new()
			segment.a = a
			segment.b = b
			collision.shape = segment
			collision.position = line.position
			add_child(collision)
	
	for l in lines:
		l.queue_free()

func _physics_process(delta: float) -> void:
	var space := get_world_2d().direct_space_state
	
	var viewport_size := get_viewport_rect().size
	
	var bottom := space.intersect_ray(
		player.global_position,
		player.global_position + Vector2.DOWN * viewport_size.y, [],
		collision_layer, false, true)
	
	if not bottom.empty() and abs(bottom.normal.angle_to(Vector2.UP)) < PI / 4.0:
		_camera.limit_bottom = bottom.position.y
	else:
		_camera.limit_bottom = 1_000_000
	
	var top := space.intersect_ray(
		player.global_position,
		player.global_position + Vector2.UP * viewport_size.y, [],
		collision_layer, false, true)
	
	if not top.empty() and abs(top.normal.angle_to(Vector2.DOWN)) < PI / 4.0:
		# this ensures the bottom camera line has priority over the top one
		_camera.limit_top = min(top.position.y, _camera.limit_bottom - viewport_size.y)
	else:
		_camera.limit_top = -1_000_000
	
	
	var left := space.intersect_ray(
		player.global_position,
		player.global_position + Vector2.LEFT * viewport_size.x, [],
		collision_layer, false, true)
	
	if not left.empty() and abs(left.normal.angle_to(Vector2.RIGHT)) < PI / 4.0:
		_camera.limit_left = left.position.x
	else:
		_camera.limit_left = -1_000_000
	
	
	var right := space.intersect_ray(
		player.global_position,
		player.global_position + Vector2.RIGHT * viewport_size.x, [],
		collision_layer, false, true)
	
	if not right.empty() and abs(right.normal.angle_to(Vector2.LEFT)) < PI / 4.0:
		_camera.limit_right = right.position.x
	else:
		_camera.limit_right = 1_000_000
