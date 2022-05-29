extends Node2D

export(bool) var spawn_at_start := false

var _last_checkpoint_position := Vector2.ZERO

func _ready() -> void:
	var player := TrEe.get_single_node_in_group(get_tree(), 'player') as Node2D
	
	if spawn_at_start:
		var player_spawn := TrEe.get_single_node_in_group(get_tree(), 'player_spawn') as Node2D
		player.global_position = player_spawn.global_position
	
	_last_checkpoint_position = player.global_position
	
	var camera := TrEe.get_single_node_in_group(get_tree(), 'main_camera') as Camera2D
	
	var deather := NodE.get_child(player, Deather) as Deather
	
	deather.connect('deathed', self, '_on_deathed', [player, camera])
	
	for c in get_tree().get_nodes_in_group('checkpoint'):
		c.connect('checkpointed', self, '_on_checkpointed', [player])

func _on_deathed(player: Node2D, camera: Camera2D) -> void:
	
	var explosion := preload('res://src/vfx/explosion.tscn').instance() as CPUParticles2D
	explosion.position = player.global_position
	add_child(explosion)
	
	Transitioner.connect('screen_hidden', self, '_reset_player', [player, camera], CONNECT_ONESHOT)
	Transitioner.connect('finished', self, '_revive_player', [player], CONNECT_ONESHOT)
	Transitioner.transition()

func _reset_player(player: Node2D, camera: Camera2D) -> void:
	SoundManager.call_deferred('disable')
	player.global_position = _last_checkpoint_position
	camera.global_position = _last_checkpoint_position
	var limits := NodE.get_child(camera, CameraLimits) as CameraLimits
	limits.update_limits()
	camera.reset_smoothing()

func _revive_player(player: Node2D) -> void:
	var deather := NodE.get_child(player, Deather) as Deather
	deather.revive()
	SoundManager.enable()

func _on_checkpointed(player: Node2D) -> void:
	_last_checkpoint_position = player.global_position
