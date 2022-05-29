extends Path2D

export(Color) var color := Color.white

func _ready() -> void:
	var line := Line2D.new()
	line.width = 1.0
	line.default_color = color
	
	for i in curve.get_point_count():
		var position := curve.get_point_position(i)
		line.add_point(position)
	
	add_child(line)
	move_child(line, 0)
