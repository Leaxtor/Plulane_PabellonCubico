extends Camera2D

@export var jugador : CharacterBody2D
@onready var timer := $Timer

var deadzone = 100.0
var target_y = position.y

func _process(delta: float) -> void:
	if jugador.position.x > position.x:
		position.x = jugador.position.x
		
	if jugador.position.y > target_y + deadzone:
		target_y = jugador.position.y - deadzone

	elif jugador.position.y < target_y - deadzone:
		target_y = jugador.position.y + deadzone
		timer.wait_time = 5.0
		timer.one_shot = true
		timer.start()
		print(timer.time_left)
	# Bajamos el multiplicador (de 20 a 5 o 10) para que sea más fluido
	position.y = lerp(position.y, target_y, delta * 5)
	#timer.timeout.connect(mover_camara)

	#Fija la camara
func _on_timer_timeout() -> void:
	target_y = jugador.position.y - deadzone
	print("Alinear Camara")
