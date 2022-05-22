extends CPUParticles2D

func _ready() -> void:
	emitting = true
	yield(get_tree().create_timer(lifetime / speed_scale), 'timeout')
	queue_free()
