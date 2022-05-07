extends Node2D

export(int) var react_delay_msec := 200
export(bool) var start_open := false

onready var _door := $Clip/Door as Sprite
onready var _door_collision := $Door/Collision as CollisionShape2D
onready var _original_door_position_y := _door.position.y

onready var _tween := NodE.add_child(self, Tween.new()) as Tween

func _ready() -> void:
	if start_open:
		_door_collision.set_deferred('disabled', true)
		_door.position.y = _original_door_position_y - _door.texture.get_size().y
	else:
		_door_collision.set_deferred('disabled', false)
		_door.position.y = _original_door_position_y

func open() -> void:
	_door_collision.set_deferred('disabled', true)
	_tween.remove_all()
	
	_tween.interpolate_property(_door, 'position:y', _door.position.y, _original_door_position_y + _door.texture.get_size().y, .2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, react_delay_msec / 1000.0)
	_tween.start()

func close() -> void:
	_door_collision.set_deferred('disabled', false)
	_tween.remove_all()
	
	_tween.interpolate_property(_door, 'position:y', _door.position.y, _original_door_position_y, .2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, react_delay_msec / 1000.0)
	_tween.start()
