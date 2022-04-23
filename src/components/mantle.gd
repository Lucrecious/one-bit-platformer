class_name Mantle
extends Node2D

enum {
	NoMantle,
	LowMantle,
	HighMantle
}

export(String) var low_mantle_anim := ''
export(Vector2) var low_mantle_offset := Vector2.ZERO
export(NodePath) var _low_mantle_area_path := NodePath()
export(NodePath) var _low_mantle_hint_path := NodePath()
export(bool) var low_mantle_keep_x_speed := false
export(bool) var allow_jump := false

export(String) var high_mantle_anim := ''
export(Vector2) var high_mantle_offset := Vector2.ZERO
export(NodePath) var _high_mantle_area_path := NodePath()
export(NodePath) var _high_mantle_hint_path := NodePath()

export(NodePath) var _anim_priority_path := NodePath()

onready var low_mantle_area := get_node_or_null(_low_mantle_area_path) as Area2D
onready var low_mantle_hint := get_node_or_null(_low_mantle_hint_path) as Node2D
onready var high_mantle_area := get_node_or_null(_high_mantle_area_path) as Area2D
onready var high_mantle_hint := get_node_or_null(_high_mantle_hint_path) as Node2D
onready var anim_priority := get_node(_anim_priority_path)

onready var _body := get_parent() as KinematicBody2D
onready var _controller := Components.controller(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _velocity := Components.velocity(get_parent())
onready var _animation := Components.priority_animation_player(get_parent())
onready var _jump := NodE.get_sibling_with_error(self, PlatformerJump) as PlatformerJump
onready var _run := NodE.get_sibling_with_error(self, PlatformerRun) as PlatformerRun

var _enabled := false

var _is_mantling := false
var _mantle_type := NoMantle
var _current_mantle_point: Node2D = null
var _current_x_direction := 0

func _ready():
	set_physics_process(false)
	enable()

func _low_mantle_available() -> bool:
	return low_mantle_anim != '' and low_mantle_area and low_mantle_hint

func _high_mantle_available() -> bool:
	return high_mantle_anim != '' and high_mantle_area and high_mantle_hint

func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	if _low_mantle_available() or _high_mantle_available():
		_controller.connect('direction1_changed', self, '_on_direction1_changed')
		_controller.connect('jump_just_pressed', self, '_on_jump_just_pressed')
		_on_direction1_changed(_controller.get_direction(0))
	
	if _low_mantle_available():
		low_mantle_area.connect('area_entered', self, '_on_low_area_entered')
		var overlaps := low_mantle_area.get_overlapping_areas()
		if not overlaps.empty():
			_on_low_area_entered(overlaps[0])
		low_mantle_area.connect('area_exited', self, '_on_low_area_exited')
	
	if _high_mantle_available():
		high_mantle_area.connect('area_entered', self, '_on_high_area_entered')
		var overlaps := high_mantle_area.get_overlapping_areas()
		if not overlaps.empty():
			_on_high_area_entered(overlaps[0])
		high_mantle_area.connect('area_exited', self, '_on_high_area_exited')

func disable() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	
	if _low_mantle_available() or _high_mantle_available():
		_controller.disconnect('direction1_changed', self, '_on_direction1_changed')
		_controller.disconnect('jump_just_pressed', self, '_on_jump_just_pressed')
		
	if _low_mantle_available():
		low_mantle_area.disconnect('area_entered', self, '_on_low_area_entered')
		low_mantle_area.disconnect('area_exited', self, '_on_low_area_exited')
	
	if _high_mantle_available():
		high_mantle_area.disconnect('area_entered', self, '_on_high_area_entered')
		high_mantle_area.disconnect('area_exited', self, '_on_high_area_exited')
	
	_is_mantling = false
	_mantle_type = NoMantle
	_current_mantle_point = null
	_current_x_direction = 0
	_enabled = false
	
func _on_low_area_entered(area: Area2D) -> void:
	_current_mantle_point = area
	_mantle_type = LowMantle
	
	_mantle(low_mantle_anim, low_mantle_hint, low_mantle_offset)

func _on_low_area_exited(area: Area2D) -> void:
	if _current_mantle_point != area:
		return
	
	_mantle_type = NoMantle
	_current_mantle_point = null

func _on_high_area_entered(area: Area2D) -> void:
	_current_mantle_point = area
	_mantle_type = HighMantle
	
	_mantle(high_mantle_anim, high_mantle_hint, high_mantle_offset)

func _on_high_area_exited(area: Area2D) -> void:
	if _current_mantle_point != area:
		return
	
	_mantle_type = NoMantle
	_current_mantle_point = null

func _on_direction1_changed(direction: Vector2) -> void:
	if _is_mantling:
		return
	
	_current_x_direction = sign(direction.x)
	
	if _mantle_type == LowMantle:
		_mantle(low_mantle_anim, low_mantle_hint, low_mantle_offset)
	elif _mantle_type == HighMantle:
		_mantle(high_mantle_anim, high_mantle_hint, high_mantle_offset)

func _on_jump_just_pressed() -> void:
	if not _is_mantling:
		return
	
	if not allow_jump:
		return
	
	disable()
	enable()
	_jump.impulse()

func _physics_process(delta: float) -> void:
	_velocity.value.y = 1

func _mantle(mantle_anim: String, mantle_hint: Node2D, mantle_offset: Vector2) -> void:
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
	set_physics_process(true)
	
	var hint_offset := _body.to_local(mantle_hint.global_position)
	
	_body.global_position = _current_mantle_point.global_position - hint_offset + Vector2(mantle_offset.x * _current_x_direction, mantle_offset.y)
	
	_disabler.disable_below(self)
	
	if low_mantle_keep_x_speed and _mantle_type == LowMantle:
		_velocity.value.y = 0.0
		_run.enable()
	else:
		_velocity.value = Vector2.ZERO
	
	_animation.callback_on_finished(mantle_anim, anim_priority, self, '_on_mantle_finished')

func _on_mantle_finished() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	_is_mantling = false
	_disabler.enable_below(self)
