class_name BlockFall
extends Node

signal fell()

export(float, 0, 1_000_000) var speed := 100.0

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D

func _physics_process(delta: float) -> void:
	var collide := _body.move_and_collide(Vector2(0, speed * delta))
	if not collide or not collide.collider:
		return
	
	var collider := collide.collider
	if collider is StaticBody2D or collider is TileMap:
		set_physics_process(false)
		_convert_to_static_body()

func _convert_to_static_body() -> void:
	var static_body := StaticBody2D.new()
	
	var collision := NodE.get_child(_body, CollisionShape2D)
	var sprite := NodE.get_child(_body, BlockNxN)
	
	_body.remove_child(collision)
	_body.remove_child(sprite)
	
	static_body.add_child(collision)
	static_body.add_child(sprite)
	
	_body.get_parent().add_child(static_body)
	static_body.global_position = _body.global_position
	
	_body.get_parent().remove_child(_body)
	_body.queue_free()
	
	emit_signal('fell')
