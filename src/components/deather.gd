class_name Deather
extends Node2D

signal deathed()

onready var _disabler := Components.disabler(get_parent())
onready var _velocity := Components.velocity(get_parent())
onready var _animation := Components.priority_animation_player(get_parent())
onready var _dodge := NodE.get_sibling(self, Dodge) as Dodge

onready var _dodge_collision := $CollisionDodge as CollisionShape2D
onready var _collision := $Collision as CollisionShape2D

var _dead := false

func _ready() -> void:
	_dodge_collision.set_deferred('disabled', true)
	_collision.set_deferred('disabled', false)
	
	connect('area_entered', self, '_on_area_entered')
	_dodge.connect('started', self, '_on_dodge_started')
	_dodge.connect('ended', self, '_on_dodge_ended')

func _on_dodge_started() -> void:
	_dodge_collision.set_deferred('disabled', false)
	_collision.set_deferred('disabled', true)

func _on_dodge_ended() -> void:
	_dodge_collision.set_deferred('disabled', true)
	_collision.set_deferred('disabled', false)
	
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
