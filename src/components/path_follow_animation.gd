extends Node

onready var _path_follow := NodE.get_sibling(self, PathFollow2D) as PathFollow2D

export(bool) var ping_pong := false
export(float) var loop_sec := 1.0
export(float) var initial_offset := 0.0

func _ready() -> void:
	var tween := Tween.new()
	
	if ping_pong:
		tween.interpolate_property(_path_follow, 'unit_offset',
			0.0, 1.0, loop_sec / 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(_path_follow, 'unit_offset',
			1.0, 0.0, loop_sec / 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,
			loop_sec / 2.0)
	else:
		tween.interpolate_property(_path_follow, 'unit_offset',
			0.0, 1.0, loop_sec, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	add_child(tween)
	
	tween.repeat = true
	tween.seek(initial_offset)
	tween.start()
