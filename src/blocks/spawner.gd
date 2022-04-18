class_name BlockSpawner
extends Node2D

const LayersConstants := preload('res://layers_constants.tres')
const MaxFallingBodies := 100

export(NodePath) var _spawn_node_path := NodePath()
export(bool) var active := false setget _active_set
func _active_set(value: bool) -> void:
	active = value
	set_physics_process(active)

onready var _spawn_node := NodE.get_node_with_error(self, _spawn_node_path, Node2D) as Node2D

var _bodies_falling := {}

func _ready() -> void:
	self.active = active

func spawn(width: int, height: int, speed: float) -> void:
	var block := BlockNxN.new()
	block.width =  width
	block.height = height
	block.texture = preload('res://assets/single_tile.png')
	
	
	var position_x := _spawn_node.global_position.x
	var position_y := _spawn_node.global_position.y
	
	var body := KinematicBody2D.new()
	body.collision_layer = LayersConstants.block_layer
	body.collision_mask = LayersConstants.block_mask
	
	var collision := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.extents = block.get_effective_size() / 2.0
	collision.shape = rect_shape
	body.add_child(collision)
	collision.position = block.get_effective_size() / 2.0
	
	var fall := BlockFall.new()
	fall.speed = speed
	
	body.add_child(block)
	body.add_child(fall)
	
	body.global_position = Vector2(position_x, position_y)
	
	get_parent().add_child(body)
	
	global_position.y -= block.get_effective_height()
	



