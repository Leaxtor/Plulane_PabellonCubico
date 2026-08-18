class_name ScoreIndicator
extends Label

@export var duration_score_update : float 

var display_score := 0
var prior_score := 0
var real_score := 0
var time_start_update := Time.get_ticks_msec()


func _ready() -> void:
	display_score = 0
	refresh()

func _process(delta: float) -> void:
	if real_score != display_score:
		var progress := (Time.get_ticks_msec() - time_start_update) / duration_score_update 
		if progress < 1:
			display_score = lerp(prior_score, real_score, progress)
		else:
			display_score = real_score
		refresh()

func add_combo(points: int) -> void:
	real_score += int((points * (points + 1)) / 2.0) #poner float si se quiere entero
	prior_score = display_score
	time_start_update = Time.get_ticks_msec()
	refresh()

func refresh() -> void:
	text = str(display_score)
