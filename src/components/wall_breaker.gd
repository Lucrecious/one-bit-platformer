extends Node2D

onready var _velocity := Components.velocity(get_parent())
onready var _dodge := NodE.get_sibling_with_error(self, Dodge) as Dodge
onready var _area := NodE.get_child_with_error(self, Area2D) as Area2D

var _current_wall: BreakableWall = null

func _ready() -> void:
	_dodge.connect('started', self, '_on_dodge_started')
	_area.connect('area_entered', self, '_on_area_entered')

func _on_dodge_started() -> void:
	for area in _area.get_overlapping_areas():
		if not area.get_parent() is BreakableWall:
			continue
		
		destroy_wall(area)

func _on_area_entered(area: Area2D) -> void:
	if not area.get_parent() is BreakableWall:
		return
	
	if not _dodge.is_dodging():
		return
	
	destroy_wall(area)

func destroy_wall(area: Area2D) -> void:
	if _velocity.value.is_equal_approx(Vector2.ZERO):
		area.get_parent().destroy(Vector2.ZERO)
		return
	
	area.get_parent().destroy(_velocity.value.normalized() * 300.0)
