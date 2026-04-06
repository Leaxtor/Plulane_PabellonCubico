extends Camera2D

@export var jugador : CharacterBody2D
var deadzone = 100.0
var target_y = position.y

func _process(delta: float) -> void:
	if jugador.position.x > position.x:
		position.x = jugador.position.x
		
	if jugador.position.y > target_y + deadzone:
		target_y = jugador.position.y - deadzone
	elif jugador.position.y < target_y - deadzone:
		target_y = jugador.position.y + deadzone
	
	# Bajamos el multiplicador (de 20 a 5 o 10) para que sea más fluido
	position.y = lerp(position.y, target_y, delta * 5)
	
	
#func _process(delta: float) -> void:
#position = position.lerp($Sprite2D.position, delta * 20)
