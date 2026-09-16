extends Area2D
@onready var ParallaXVagon = $"../Parallax2D"

func _process(_delta: float) -> void:
	pass


func _on_body_entered(body):
	if body.name == "Jugador_Plus":
		cambio_parallax()

func cambio_parallax():
	print("X")
	print(ParallaXVagon.scroll_scale.x)
	print("Y")
	print(ParallaXVagon.scroll_scale.y)
	if ParallaXVagon.scroll_scale.x == 1.0:
		print("ACELERAR")
		var tween = get_tree().create_tween()
		#En vez de cambiarlo a ParallaXVagon.scroll_scale.x = 10, lo hago fluido
		#.set_trans(Tween.TRANS_SINE) poner al final para suavidad
		tween.tween_property(ParallaXVagon, "scroll_scale", Vector2(4.0,1.0), 1.0).set_ease(Tween.EASE_IN) 
	elif ParallaXVagon.scroll_scale.x == 4.0:
		print("DESACELERAR")
		var tween = get_tree().create_tween()
		tween.tween_property(ParallaXVagon, "scroll_scale", Vector2(1.0,1.0), 1.0).set_ease(Tween.EASE_OUT)
