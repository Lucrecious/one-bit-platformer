class_name Mantle
extends Node2D

export(String) var animation := ''
export(NodePath) var _anim_priority_node_path := NodePath()
export(Vector2) var offset := Vector2.ZERO
export(NodePath) var _area_path := NodePath()
export(NodePath) var _hint_path := NodePath()
export(bool) var preserve_speed := false
export(bool) var allow_jump := false
export(float) var units_per_sec := 1.0

onready var area := get_node(_area_path) as Area2D
onready var hint := get_node(_hint_path) as Node2D
onready var anim_priority_node := get_node_or_null(_anim_priority_node_path)

onready var _body := get_parent() as KinematicBody2D
onready var _controller := Components.controller(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _velocity := Components.velocity(get_parent())
onready var _animation := Components.priority_animation_player(get_parent())
onready var _root_sprite := Components.root_sprite(get_parent())
onready var _jump := NodE.get_sibling_with_error(self, PlatformerJump) as PlatformerJump
onready var _run := NodE.get_sibling_with_error(self, PlatformerRun) as PlatformerRun
onready var _sync_tween := NodE.add_child(self, Tween.new()) as Tween

var _enabled := false

var _is_mantling := false
var _current_mantle_point: Node2D = null
var _current_x_direction := 0

func _ready():
	set_physics_process(false)
	enable()

func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	_controller.connect('direction1_changed', self, '_on_direction1_changed')
	_controller.connect('jump_just_pressed', self, '_on_jump_just_pressed')
	area.connect('area_entered', self, '_on_area_entered')
	area.connect('area_exited', self, '_on_area_exited')
	
	_on_direction1_changed(_controller.get_direction(0))
	
	var overlaps := area.get_overlapping_areas()
	if not overlaps.empty():
		_on_area_entered(overlaps[0])
	
func disable() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)

	_controller.disconnect('direction1_changed', self, '_on_direction1_changed')
	_controller.disconnect('jump_just_pressed', self, '_on_jump_just_pressed')
		
	area.disconnect('area_entered', self, '_on_area_entered')
	area.disconnect('area_exited', self, '_on_area_exited')
	
	_is_mantling = false
	_current_mantle_point = null
	_current_x_direction = 0
	_enabled = false
	
func _on_area_entered(area: Area2D) -> void:
	_current_mantle_point = area
	
	_mantle()

func _on_area_exited(area: Area2D) -> void:
	if _current_mantle_point != area:
		return
	
	_current_mantle_point = null

func _on_direction1_changed(direction: Vector2) -> void:
	if _is_mantling:
		return
	
	_current_x_direction = sign(direction.x)
	
	_mantle()

func _on_jump_just_pressed() -> void:
	if not _is_mantling:
		return
	
	if not allow_jump:
		return
	
	disable()
	_disabler.enable_below(self)
	enable()
	_jump.impulse()

func _physics_process(delta: float) -> void:
	_velocity.value.y = 1

func _use_animation() -> bool:
	return not animation.empty() and anim_priority_node

func _mantle() -> void:
	if _is_mantling:
		return
	
	if not _current_mantle_point:
		return
	
	if _current_x_direction == 0:
		return
	
	var mantle_point_direction := sign((_current_mantle_point.global_position - _body.global_position).x)
	if mantle_point_direction != _current_x_direction:
		return
	
	_is_mantling = true
	
	var hint_offset := _body.to_local(hint.global_position)
	
	var previous_position := _body.global_position
	_body.global_position = _current_mantle_point.global_position - hint_offset + Vector2(offset.x * _current_x_direction, offset.y)
	
	var delta := _body.global_position - previous_position
	
	_root_sprite.position -= delta
	var sec := delta.length() / (units_per_sec * _velocity.units)
	
	_sync_tween.remove_all()
	_sync_tween.interpolate_property(_root_sprite, 'position:y', null, 0.0, sec, Tween.TRANS_QUAD, Tween.EASE_OUT)
	_sync_tween.interpolate_property(_root_sprite, 'position:x', null, 0.0, sec, Tween.TRANS_QUAD, Tween.EASE_OUT, sec / 2.0)
	_sync_tween.start()
	
	if not preserve_speed:
		_velocity.value = Vector2.ZERO
	elif preserve_speed and _use_animation():
		assert(false, 'not supported')
	
	if _use_animation():
		_disabler.disable_below(self)
		set_physics_process(true)
		_animation.callback_on_finished(animation, anim_priority_node, self, '_on_mantle_finished')
	else:
		_on_mantle_finished()

func _on_mantle_finished() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	_is_mantling = false
	
	if not _use_animation():
		return
	
	_disabler.enable_below(self)
