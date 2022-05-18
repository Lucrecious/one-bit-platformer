extends Node

const BUFFER_LIMIT_MSEC := 200

enum Type {
	None,
	PostDodgeJump,
	PostDodgeDodge,
	PostLandJump,
	PostMantleJump,
}

onready var _controller := Components.controller(get_parent())
onready var _dodge := NodE.get_sibling_with_error(self, Dodge) as Dodge
onready var _jump := NodE.get_sibling_with_error(self, PlatformerJump) as PlatformerJump

var _current_buffer: int = Type.None
var _buffered_msec := -BUFFER_LIMIT_MSEC

var _last_dodge_start_physics_frame := -1

func _ready() -> void:
	_dodge.connect('started', self, '_on_dodge_started')
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')

func _on_dodge_started() -> void:
	_last_dodge_start_physics_frame = Engine.get_physics_frames()

func _on_action_just_pressed(action: String) -> void:
	# If the input causes the dodge, it doesn't count and does not buffer
	if _dodge.is_dodging() and Engine.get_physics_frames() != _last_dodge_start_physics_frame:
		if action == 'jump':
			_current_buffer = Type.PostDodgeJump
		elif action == _dodge.action_name:
			_current_buffer = Type.PostDodgeDodge
		
		if _current_buffer == Type.None:
			return
		
		_buffered_msec = OS.get_ticks_msec()
		if not _dodge.is_connected('ended', self, '_on_dodge_ended'):
			_dodge.connect('ended', self, '_on_dodge_ended', [], CONNECT_ONESHOT)
		return

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
		return
	
	if buffer_type == Type.PostDodgeDodge:
		_dodge._dodge(sign(_controller.get_direction(0).x))
