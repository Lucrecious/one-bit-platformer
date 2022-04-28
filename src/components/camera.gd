extends Camera2D


onready var _shake := NodE.get_child_with_error(self, CameraShake) as CameraShake
onready var _hard_land := NodE.get_sibling_with_error(self, HardLand) as HardLand

func _ready() -> void:
	_hard_land.connect('landed_hard', self, '_on_landed_hard')

func _on_landed_hard() -> void:
	_shake.add_trauma(1.0, 1.0)
