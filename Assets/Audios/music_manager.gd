class_name MusicManager
extends Node

enum Music {INTRO, MENU, STAGE1, STAGE2}

@onready var music_stream_play : AudioStreamPlayer = $MusicStreamPlayer

var autoplaymusic : AudioStream = null

const MUSIC_MAP : Dictionary = {
	Music.INTRO: preload("res://Assets/Audios/Musica/MP3/Ambient Vol10 Dreth Mirage Cut 30.wav"),
	Music.MENU: preload("res://Assets/Audios/Musica/MP3/kanpyo_2012_fairy_starsapphire.mp3"),
	Music.STAGE1: preload("res://Assets/Audios/Musica/MP3/menu.mp3"),
	Music.STAGE2: preload("res://Assets/Audios/Musica/MP3/Watatsuki's Spell Card~ Divine Sea Battle.mp3"),
}

func _ready() -> void:
	if autoplaymusic != null:
		music_stream_play.stream = autoplaymusic
		music_stream_play.play()

func play(music: Music) -> void:
	if music_stream_play.is_node_ready(): #Espera a que cargen todos los hijos del nodo
		music_stream_play.stream = MUSIC_MAP[music]
		music_stream_play.play()
	else:
		autoplaymusic = MUSIC_MAP[music]
