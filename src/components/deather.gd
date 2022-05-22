class_name Deather
extends Node2D

signal deathed()

onready var _disabler := Components.disabler(get_parent())
onready var _velocity := Components.velocity(get_parent())
onready var _animation := Components.priority_animation_player(get_parent())

var _dead := false

func _ready() -> void:
	connect('area_entered', self, '_on_area_entered')

func _on_area_entered(area: Area2D) -> void:
	if _dead:
		return
	
	_dead = true
	
	_disabler.disable_below(self)
	_velocity.value *= 0.0
	
	_animation.pause(true)
	
	emit_signal('deathed')

func revive() -> void:
	_animation.pause(false)
	_disabler.enable_below(self)
	_dead = false
