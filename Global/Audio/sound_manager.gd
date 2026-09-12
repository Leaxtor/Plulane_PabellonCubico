class_name SoundManager
extends Node

@onready var soundTEST2: Array[AudioStreamPlayer] = [$SFXhit1,$SFXgrunt]

#MANTENER EL ORDEN EN LAS 2 LISTAS SINO SE DESCUADRA

@onready var sounds: Array[AudioStreamPlayer] = [
	$SFXclick,
	$SFXcFood,
	$SFXGogogo,
	$SFXgrunt,
	$SFXgunshot,
	$SFXhit1,
	$SFXhit2,
	$SFXknife,
	$SFXSwoosh
]

enum Sound {CLICK, FOOD, GOGOGO, GRUNT, GUNSHOT, HIT1, HIT2, KNIFE, SWOOSH}

func play(sfx: Sound, tweak_pitch : bool = false) -> void:
	var added_pitch := 0.0
	if tweak_pitch:
		added_pitch = randf_range(-0.3, 0.3)
	sounds[sfx as int].pitch_scale = 1 + added_pitch
	print(sfx as int)
	sounds[sfx as int].play()
	
	
