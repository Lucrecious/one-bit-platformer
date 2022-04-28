extends Node2D

export(float) var check_units := 1.0
export(int) var margin_pixels := 1
export(float) var units_per_sec := 2.0

onready var _body := get_parent() as KinematicBody2D
onready var _velocity := Components.velocity(get_parent())
onready var _root_sprite := Components.root_sprite(get_parent())

onready var _tween := NodE.add_child(self, Tween.new()) as Tween

func _ready():
	_velocity.connect('about_to_floor_left', self, '_on_about_to_floor_left')

func _on_about_to_floor_left() -> void:
	if _velocity.value.y <= 0:
		return
	
	var delta := Vector2(0, check_units * _velocity.units + margin_pixels)
	var hit_floor := _body.move_and_collide(delta, true, true, true)
	if not hit_floor:
		return
	
	delta = hit_floor.travel
	
	_velocity.move_units(delta * 1.01)
	_velocity.y = max(_velocity.y, 1)
	_body.force_update_transform()
	
	_root_sprite.position -= delta
	
	_tween.remove_all()
	var sec := delta.length() / (units_per_sec * _velocity.units)
	
	_tween.interpolate_property(_root_sprite, 'position:y', null, 0.0, sec, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_tween.interpolate_property(_root_sprite, 'position:x', null, 0.0, sec, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, sec / 2.0)
	_tween.start()
	
