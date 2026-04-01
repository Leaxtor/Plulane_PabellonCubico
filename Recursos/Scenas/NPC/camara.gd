extends Camera2D

@export var jugador : CharacterBody2D


func _process(delta: float) -> void:
	if jugador.position.x > position.x:
		position.x = jugador.position.x
	
	
