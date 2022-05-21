extends Area2D

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
