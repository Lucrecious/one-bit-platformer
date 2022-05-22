extends AnimatedSprite

signal checkpointed()

onready var _area := $Area as Area2D

func _ready() -> void:
	_area.connect('body_entered', self, '_on_body_entered', [], CONNECT_ONESHOT)

func _on_body_entered(_body) -> void:
	play('waving')
	emit_signal('checkpointed')
