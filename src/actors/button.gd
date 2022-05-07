extends StaticBody2D

signal pressed()
signal unpressed()

enum {
	Pressed,
	Unpressed
}

export(bool) var only_press := false

onready var _animation := $AnimationPlayer as AnimationPlayer
onready var _standing := $Standing as Area2D

var _state := -1

func _ready() -> void:
	_standing.connect('body_entered', self, '_on_body_entered')
	_standing.connect('body_exited', self, '_on_body_exited')
	
	yield(get_tree(), 'idle_frame')
	
	unpress()

func press() -> void:
	if _state == Pressed:
		return
	
	_state = Pressed
	_animation.play('press')
	
	emit_signal('pressed')

func unpress() -> void:
	var previous_state := _state
	_state = Unpressed
	
	if _standing.get_overlapping_bodies().empty():
		_animation.play('unpress')
	else:
		_animation.play('halfpress')
	
	if previous_state == _state:
		return
	
	emit_signal('unpressed')

func _on_body_entered(body: PhysicsBody2D) -> void:
	var hard_land := NodE.get_child(body, HardLand) as HardLand
	if hard_land and (OS.get_ticks_msec() - hard_land.get_last_hard_land_msec()) < 50:
		press()
		return
	
	if only_press and _state == Pressed:
		return
	
	unpress()

func _on_body_exited(body: PhysicsBody2D) -> void:
	if only_press and _state == Pressed:
		return
	
	unpress()
