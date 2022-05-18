extends Node

onready var _velocity := Components.velocity(get_parent())
onready var _animation := Components.priority_animation_player(get_parent())

onready var _freeze_timer := NodE.add_child(self, Timer.new()) as Timer

func _ready() -> void:
	_freeze_timer.one_shot = true

func freeze(sec: float) -> void:
	if not _freeze_timer.is_stopped():
		return
	
	_freeze_frame(true)
	_freeze_timer.connect('timeout', self, '_on_timeout', [], CONNECT_ONESHOT)
	_freeze_timer.start(sec)
	
func _on_timeout() -> void:
	_freeze_frame(false)

func _freeze_frame(freeze: bool) -> void:
	var enabled := not freeze
	_velocity.set_physics_process(enabled)
	
	if _animation.playback_process_mode == AnimationPlayer.ANIMATION_PROCESS_PHYSICS:
		_animation.set_physics_process_internal(enabled)
	elif _animation.playback_process_mode == AnimationPlayer.ANIMATION_PROCESS_IDLE:
		_animation.set_process_internal(enabled)
	
	_animation.replay_same_position_no_blend_no_changEd()
