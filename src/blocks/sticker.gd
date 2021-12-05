class_name BlockSticker
extends Node

onready var _velocity := Components.velocity(get_parent())

func _ready() -> void:
	_velocity.connect('floor_hit', self, '_on_floor_hit')

func _on_floor_hit() -> void:
	var body := get_parent() as KinematicBody2D
	
	var other_body: PhysicsBody2D
	var collision := body.get_last_slide_collision()
	other_body = collision.collider as PhysicsBody2D
	if not collision or not other_body:
		return
	
	var collision_shape := NodE.get_child(body, CollisionShape2D) as CollisionShape2D
	var sprite := NodE.get_child(body, BlockNxN) as BlockNxN
	
	var collision_shape_position := collision_shape.global_position
	var sprite_position := sprite.global_position
	
	body.remove_child(collision_shape)
	body.remove_child(sprite)
	
	body.get_parent().remove_child(body)
	body.queue_free()
	
	other_body.add_child(collision_shape)
	other_body.add_child(sprite)
	
	collision_shape.global_position = collision_shape_position
	sprite.global_position = sprite_position
