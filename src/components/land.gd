class_name HardLand
extends Node2D

signal landed_hard()

export(NodePath) var _priority_node_path := NodePath()
export(float) var terminal_velocity := 17.0
export(float) var terminal_velocity_msec := 100
export(float) var velocity_no_msec_check := 20.0

onready var _body := get_parent() as KinematicBody2D
onready var _velocity := Components.velocity(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _gravity := NodE.get_sibling(self, Gravity) as Gravity
onready var _animation := Components.priority_animation_player(get_parent())
onready var _priority_node := get_node(_priority_node_path)

var _enabled := false
var _msec_in_terminal_velocity := 0
var _no_msec_check := false
var _last_hard_land_msec := -1_000

func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	
	_msec_in_terminal_velocity = 0
	_velocity.connect('floor_left', self, '_on_floor_left')
	_velocity.connect('floor_hit', self, '_on_floor_hit')
	_velocity.connect('about_to_floor_hit', self, '_on_about_to_floor_hit')
	
	if not _body.is_on_floor():
		_on_floor_left()
	

func disabled() -> void:
	if not _enabled:
		return
		
	set_physics_process(false)
	
	_velocity.disconnect('floor_left', self, '_on_floor_left')
	_velocity.disconnect('floor_hit', self, '_on_floor_hit')
	_velocity.disconnect('about_to_floor_hit', self, '_on_about_to_floor_hit')
	
	_enabled = false

func get_last_hard_land_msec() -> int:
	return _last_hard_land_msec

func _ready() -> void:
	set_physics_process(false)
	enable()

func _physics_process(delta: float) -> void:
	if _velocity.value.y >= terminal_velocity:
		_msec_in_terminal_velocity += floor(delta * 1000)
	else:
		_msec_in_terminal_velocity = 0

func _on_about_to_floor_hit() -> void:
	_no_msec_check = _velocity.value.y >= velocity_no_msec_check

func _on_floor_hit() -> void:
	set_physics_process(false)
	
	if _msec_in_terminal_velocity < terminal_velocity_msec and not _no_msec_check:
		return
	
	_disabler.disable_below(self)
	_gravity.enable()
	_velocity.value.x = 0
	_velocity.value.y = 1
	
	_animation.callback_on_finished_by_node(_priority_node, self, '_on_land_finished')
	
	_last_hard_land_msec = OS.get_ticks_msec()
	
	emit_signal('landed_hard')

func _on_land_finished() -> void:
	if not _enabled:
		return
	
	_disabler.enable_below(self)

func _on_floor_left() -> void:
	_msec_in_terminal_velocity = 0
	_no_msec_check = false
	set_physics_process(true)
