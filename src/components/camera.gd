extends Camera2D


onready var _shake := NodE.get_child(self, CameraShake) as CameraShake
onready var _hard_land := NodE.get_sibling(self, HardLand) as HardLand
onready var _wall_breaker := NodE.get_sibling(self, WallBreaker) as WallBreaker

func _ready() -> void:
	_hard_land.connect('landed_hard', self, '_on_landed_hard')
	_wall_breaker.connect('impacted_wall', self, '_on_impacted_wall')

func _on_landed_hard() -> void:
	_shake.add_trauma(1.0, 1.0)

func _on_impacted_wall() -> void:
	_shake.add_trauma(.5, .6)
