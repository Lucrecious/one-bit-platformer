extends CanvasLayer

signal finished()
signal screen_hidden()

onready var _animation := $Animation as AnimationPlayer

var _transitioning := false

func transition() -> bool:
	if _transitioning:
		return false
	
	_transitioning = true
	_animation.connect('animation_finished', self, '_on_transition_finished',
		[], CONNECT_ONESHOT)
	_animation.play('diagonal')
	return true

func animation_player_emit_screen_hidden() -> void:
	emit_signal('screen_hidden')

func _on_transition_finished(_animation: String) -> void:
	_transitioning = false
	emit_signal('finished')
