class_name ScoreIndicator
extends Label

@export var duration_score_update : float 
@export var points_per_life : int

var display_score := 0
var prior_score := 0
var real_score := 0
var time_start_update := Time.get_ticks_msec()

func _init() -> void:
	DamageManager.player_revive.connect(on_player_revive.bind())

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
	add_point(int((points * (points + 1)) / 2.0))

func start_update() -> void:
	#poner float si se quiere entero
	prior_score = display_score
	time_start_update = Time.get_ticks_msec()
	refresh()

func refresh() -> void:
	text = str(display_score)

func add_point(points: int) -> void:
	real_score = max(0, real_score + points)
	start_update()

func on_player_revive() -> void:
	add_point(-points_per_life)
