class_name Enemigo_1
extends Character

@export var player : Player

func handle_input() -> void:
	if player != null and can_move() :
		var direction := (player.position - position).normalized()
		velocity = direction * move_speed 
