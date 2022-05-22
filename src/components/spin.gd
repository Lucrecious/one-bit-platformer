extends Sprite


export(float) var degrees_per_sec := 180.0

func _process(delta: float) -> void:
	transform = transform.rotated(deg2rad(degrees_per_sec * delta))
