class_name Player
extends Character


func handle_input() -> void:
	var direction := Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * move_speed
	if can_accion() and Input.is_action_just_pressed("ataque_golpear"):
		state = State.Golpe
	if can_accion() and Input.is_action_just_pressed("move_bloqueo"):
		state = State.Bloqueo
	if can_jump() and Input.is_action_just_pressed("move_saltar"):
		state = State.Salto_Inicio
	if can_jump_patada() and Input.is_action_just_pressed("ataque_golpear"):
		state = State.Salto_Patada
