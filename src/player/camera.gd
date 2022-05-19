class_name PlayerCamera
extends Camera2D

func _ready() -> void:
	var velocity := NodE.get_sibling(self, Velocity, false) as Velocity
	
	if not velocity:
		return
	
	var collision := NodE.get_sibling(self, CollisionExtents, false) as CollisionExtents
	if not collision:
		return
	
	velocity.connect('floor_hit', self, '_on_floor_hit')

	
