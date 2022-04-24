extends Node2D

const HARD_LAND_TERMINAL_MSEC := 500#1_000

export(String) var land_anim := 'land'
export(NodePath) var _priority_node_path := NodePath()
export(float) var terminal_velocity := 17.0

onready var _body := get_parent() as KinematicBody2D
onready var _velocity := Components.velocity(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _gravity := NodE.get_sibling_with_error(self, Gravity) as Gravity
onready var _animation := Components.priority_animation_player(get_parent())
onready var _priority_node := get_node(_priority_node_path)

var _enabled := false
var _msec_in_terminal_velocity := 0

func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	
	_msec_in_terminal_velocity = 0
	_velocity.connect('floor_left', self, '_on_floor_left')
	_velocity.connect('floor_hit', self, '_on_floor_hit')
	
	if not _body.is_on_floor():
		_on_floor_left()
	

func disabled() -> void:
	if not _enabled:
		return
		
	set_physics_process(false)
	
	_velocity.disconnect('floor_left', self, '_on_floor_left')
	_velocity.disconnect('floor_hit', self, '_on_floor_hit')
	
	_enabled = false

func _ready() -> void:
	set_physics_process(false)
	enable()

func _physics_process(delta: float) -> void:
	if _velocity.value.y >= terminal_velocity:
		_msec_in_terminal_velocity += floor(delta * 1000)
	else:
		_msec_in_terminal_velocity = 0
		

func _on_floor_hit() -> void:
	set_physics_process(false)
	
	if _msec_in_terminal_velocity < HARD_LAND_TERMINAL_MSEC:
		return
	
	_disabler.disable_below(self)
	_gravity.enable()
	_velocity.value.x = 0
	
	_animation.callback_on_finished(land_anim, _priority_node, self, '_on_land_finished')

func _on_land_finished() -> void:
	if not _enabled:
		return
	
	_disabler.enable_below(self)

func _on_floor_left() -> void:
	_msec_in_terminal_velocity = 0
	set_physics_process(true)
