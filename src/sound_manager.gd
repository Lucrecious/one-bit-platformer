extends Node

const SOUND_BUS_NAME := 'Sound'

var sound_bus := AudioServer.get_bus_index(SOUND_BUS_NAME)

func enable() -> void:
	AudioServer.set_bus_mute(sound_bus, false)

func disable() -> void:
	AudioServer.set_bus_mute(sound_bus, true)
