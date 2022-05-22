extends Node2D

signal landed()

export(float) var _instant_fall_speed := 1.0
export(String) var action := 'dodge'
export(NodePath) var _priority_node_path := NodePath()

onready var _body := get_parent() as KinematicBody2D
onready var _animation := Components.priority_animation_player(get_parent())
onready var _velocity := Components.velocity(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _controller := Components.controller(get_parent())
onready var _priority_node := get_node(_priority_node_path)

var _enabled := false
var _used_until_next_fall := false

func enable() -> void:
	if _enabled:
		return
	
	_used_until_next_fall = false
	_enabled = true
	
	_controller.connect('%s_just_pressed' % [action], self, '_on_hard_fall_just_pressed')
	_velocity.connect('floor_hit', self, '_on_floor_hit')

func disable() -> void:
	if not _enabled:
		return
	
	_controller.disconnect('%s_just_pressed' % [action], self, '_on_hard_fall_just_pressed')
	_velocity.disconnect('floor_hit', self, '_on_floor_hit')
	
	_enabled = false

func _ready() -> void:
	enable()

func _on_floor_hit() -> void:
	_used_until_next_fall = false

func _on_hard_fall_just_pressed() -> void:
	if _controller.get_direction(0).y <= 0:
		return
	
	if _used_until_next_fall:
		return
	
	_hard_fall()

func _hard_fall() -> void:
	if _body.is_on_floor():
		return
	
	_used_until_next_fall = true
	
	_disabler.disable_below(self)
	_velocity.value.x = 0
	_velocity.value.y = -1
	_animation.callback_on_finished_by_node(_priority_node, self, '_on_setup_anim_finished')

func _on_setup_anim_finished() -> void:
	_disabler.enable_below(self)
	_velocity.value.y = _instant_fall_speed
