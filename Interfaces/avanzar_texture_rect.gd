class_name FlickeringTextureRect
extends TextureRect

@export var duration_flocker: int
@export var total_flickers: int


var flickers_left := 0
var image : Texture2D = null
var is_flickering := false
var time_last_flicker := Time.get_ticks_msec()

func _ready() -> void:
	image = texture
	texture = null
	
func start_flickering() -> void:
	flickers_left = total_flickers
	is_flickering = true
	time_last_flicker = Time.get_ticks_msec()
	
func _process(delta: float) -> void:
	if is_flickering and (Time.get_ticks_msec() - time_last_flicker > duration_flocker):
		if texture == null:
			if flickers_left == 0:
				is_flickering = false
			else:
				flickers_left -= 1
				texture = image
		else:
			texture = null
		time_last_flicker = Time.get_ticks_msec()
