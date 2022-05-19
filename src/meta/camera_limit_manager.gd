extends Area2D

const WALL_FLOOR_THRESHOLD_RADIANS := PI / 4.0

export(NodePath) var _player_path := NodePath()

onready var player := get_node(_player_path) as Node2D
onready var _camera := NodE.get_child(player, Camera2D) as Camera2D


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
	
	# I'm doing a manual xray
	var ray_start := player.global_position
	_camera.limit_bottom = 1_000_000
	while true:
		var bottom := space.intersect_ray(
			ray_start,
			player.global_position + Vector2.DOWN * viewport_size.y, [],
			collision_layer, false, true)
		
		if bottom.empty():
			break
		
		if abs(bottom.normal.angle_to(Vector2.UP)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = bottom.position + Vector2.DOWN * .01
			continue
		
		_camera.limit_bottom = bottom.position.y
		break
	
	ray_start = player.global_position
	_camera.limit_top = -1_000_000
	while true:
		var top := space.intersect_ray(
			ray_start,
			player.global_position + Vector2.UP * viewport_size.y, [],
			collision_layer, false, true)
		
		if top.empty():
			break
	
		if abs(top.normal.angle_to(Vector2.DOWN)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = top.position + Vector2.UP * .01
			continue
		
		# this ensures the bottom camera line has priority over the top one
		_camera.limit_top = min(top.position.y, _camera.limit_bottom - viewport_size.y)
		break
	
	ray_start = player.global_position
	_camera.limit_left = -1_000_000
	while true:
		var left := space.intersect_ray(
			ray_start,
			player.global_position + Vector2.LEFT * viewport_size.x, [],
			collision_layer, false, true)
	
		if left.empty():
			break
		 
		if abs(left.normal.angle_to(Vector2.RIGHT)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = left.position + Vector2.LEFT * .01
			continue
		
		_camera.limit_left = left.position.x
		break
	
	ray_start = player.global_position
	_camera.limit_right = 1_000_000
	while true:
		var right := space.intersect_ray(
			ray_start,
			player.global_position + Vector2.RIGHT * viewport_size.x, [],
			collision_layer, false, true)
		
		if right.empty():
			break
		
		if abs(right.normal.angle_to(Vector2.LEFT)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = right.position + Vector2.RIGHT * .01
			continue
		
		_camera.limit_right = right.position.x
		break
