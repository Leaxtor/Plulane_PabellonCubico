extends Node

var is_screenshake_enabled := true
var music_volumen := 3
var sfx_volumen := 5

func set_music_volumen(value: int) -> void:
	music_volumen = value
	AudioServer.set_bus_volume_db(1, linear_to_db(value/10.0)) #el volumen acepta un numero del 0.1 al 1.0

func set_sfx_volumen(value: int) -> void:
	sfx_volumen = value
	AudioServer.set_bus_volume_db(2, linear_to_db(value/10.0))
	
func set_screenshake(value: bool) -> void:
	is_screenshake_enabled = value
