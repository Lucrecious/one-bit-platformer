extends Node

const BUFFER_LIMIT_MSEC := 200

enum Type {
	None,
	PostDodgeJump,
	PostDodgeDodge,
	PostLandJump,
}

onready var _controller := Components.controller(get_parent())
onready var _body := get_parent() as KinematicBody2D
onready var _velocity := Components.velocity(get_parent())
onready var _dodge := NodE.get_sibling(self, Dodge) as Dodge
onready var _jump := NodE.get_sibling(self, PlatformerJump) as PlatformerJump
onready var _turner := NodE.get_sibling(self, PlatformerTurner) as PlatformerTurner
onready var _wall_grip := NodE.get_sibling(self, PlatformerWallGrip) as PlatformerWallGrip
onready var _wall_jump := NodE.get_sibling(self, PlatformerWallJump) as PlatformerWallJump

var _current_buffer: int = Type.None
var _buffered_msec := -BUFFER_LIMIT_MSEC

var _last_dodge_start_physics_frame := -1
var _last_wall_released_physics_frame := -1

func _ready() -> void:
	_dodge.connect('started', self, '_on_dodge_started')
	_wall_grip.connect('released', self, '_on_wall_released')
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')

func _on_dodge_started() -> void:
	_last_dodge_start_physics_frame = Engine.get_physics_frames()

func _on_wall_released() -> void:
	_last_wall_released_physics_frame = Engine.get_physics_frames()

func _on_action_just_pressed(action: String) -> void:
	# If the input causes the dodge, it doesn't count and does not buffer
	if _dodge.is_dodging() and Engine.get_physics_frames() != _last_dodge_start_physics_frame:
		if action == 'jump':
			_current_buffer = Type.PostDodgeJump
		elif action == _dodge.action_name:
			_current_buffer = Type.PostDodgeDodge
	elif not _body.is_on_floor()\
		and not _wall_grip.is_gripping()\
		and Engine.get_physics_frames() != _last_wall_released_physics_frame:
		if action == 'jump':
			_current_buffer = Type.PostLandJump
	
	if _current_buffer == Type.None:
		return
	
	_buffered_msec = OS.get_ticks_msec()
	
	ObjEct.disconnect_once(_velocity, 'floor_hit', self, '_on_floor_hit')
	ObjEct.disconnect_once(_wall_grip, 'gripped', self, '_on_wall_gripped')
	ObjEct.disconnect_once(_dodge, 'ended', self, '_on_dodge_ended')
	
	# a deferred call is required so that ending signals can finish
	match _current_buffer:
		Type.PostLandJump:
			_velocity.connect('floor_hit', self, '_on_floor_hit', [], CONNECT_ONESHOT | CONNECT_DEFERRED)
			_wall_grip.connect('gripped', self, '_on_wall_gripped', [], CONNECT_ONESHOT | CONNECT_DEFERRED)
		Type.PostDodgeDodge, Type.PostDodgeJump:
			_dodge.connect('ended', self, '_on_dodge_ended', [], CONNECT_ONESHOT | CONNECT_DEFERRED)
		_:
			assert(false, 'other buffers not handled yet')

func _on_wall_gripped() -> void:
	var buffer_type := _current_buffer
	_current_buffer = Type.None
	
	_velocity.disconnect('floor_hit', self, '_on_floor_hit')
	
	if not _wall_jump.enabled():
		return
	
	if OS.get_ticks_msec() - _buffered_msec >= BUFFER_LIMIT_MSEC:
		return
	
	if buffer_type == Type.PostLandJump:
		_wall_jump._on_jump_just_pressed()
	else:
		assert(false)

func _on_floor_hit() -> void:
	var buffer_type := _current_buffer
	_current_buffer = Type.None
	
	_wall_grip.disconnect('gripped', self, '_on_wall_gripped')
	
	if not _jump.enabled():
		return
	
	if OS.get_ticks_msec() - _buffered_msec >= BUFFER_LIMIT_MSEC:
		return
	
	if buffer_type == Type.PostLandJump:
		if not _jump._can_jump():
			return
		
		_jump._jump_pressed('jump')
		if _controller.is_pressed('jump'):
			return
		
		_velocity.value.y /= 1.5
	else:
		assert(false)
	
func _on_dodge_ended() -> void:
	var buffer_type := _current_buffer
	_current_buffer = Type.None
	
	if not _dodge.enabled():
		return
	
	if OS.get_ticks_msec() - _buffered_msec >= BUFFER_LIMIT_MSEC:
		return
	
	if buffer_type == Type.PostDodgeJump:
		if not _jump._can_jump():
			return
		
		_jump._jump_pressed('jump')
		if _controller.is_pressed('jump'):
			return
		
		_velocity.value.y /= 1.5
		return
	
	if buffer_type == Type.PostDodgeDodge:
		_dodge._dodge(sign(_controller.get_direction(0).x))
		return
