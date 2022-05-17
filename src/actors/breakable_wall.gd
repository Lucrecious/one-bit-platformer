class_name BreakableWall
extends Node2D

signal destroyed()

onready var _solid := $Solid as StaticBody2D
onready var _area_break := $AreaBreak as Area2D

var _destroyed := false

func destroy(velocity: Vector2) -> void:
	if _destroyed:
		return
	
	_destroyed = true

	_area_break.queue_free()
	_solid.queue_free()
	for rock in get_children():
		if not rock is RigidBody2D:
			continue
		rock.set_deferred('mode', RigidBody2D.MODE_CHARACTER)
		(rock as RigidBody2D).linear_velocity = velocity.rotated(deg2rad(rand_range(-20, 20)))
	
	var remove_physics_timer := Timer.new()
	remove_physics_timer.wait_time = 4.0
	remove_physics_timer.one_shot = true
	remove_physics_timer.autostart = true
	
	remove_physics_timer.connect('timeout', self, '_on_destroyed_timeout', [], CONNECT_ONESHOT)
	
	emit_signal('destroyed')
	
	add_child(remove_physics_timer)
	
	if get_parent() is get_script():
		get_parent().destroy(velocity / 2.0)
	
	for child in get_children():
		if not child is get_script():
			continue
		
		child.destroy(velocity / 2.0)

func _on_destroyed_timeout() -> void:
	for rock in get_children():
		if not rock is RigidBody2D:
			continue
		rock.set_deferred('mode', RigidBody2D.MODE_STATIC)
