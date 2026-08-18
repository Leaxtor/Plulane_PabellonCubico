class_name IgorBoss
extends Character

const GROUND_FRICTION := 250

@export var player: Player
@export var distance_from_player : int
@export var duration_between_attacks : int
@export var duration_vulnerable : int

var knockback_force := Vector2.ZERO
var time_last_attack := Time.get_ticks_msec()
var time_start_vulnerable := Time.get_ticks_msec()

func _process(delta: float) ->void:
	super._process(delta)
	knockback_force = knockback_force.move_toward(Vector2.ZERO, delta * GROUND_FRICTION)

func get_target_destination() -> Vector2:
	var target := Vector2.ZERO
	if position.x < player.position.x:
		target = player.position + Vector2.LEFT * distance_from_player
	else:
		target = player.position + Vector2.RIGHT * distance_from_player
	return target

func is_player_within_range() -> bool:
	var target := get_target_destination()
	return (target - position).length() < 10
	#AQUI HAY UN PROBLEMA A REALIZA SI CORRE MUY RAPIDO Y SE PASA SE PONE A CORRER POR SIEMPRE

func handle_grounded() ->void:
	if state == State.Suelo_Caida and current_health > 0:
		state = State.Recover #NO CONFUNDIR RECOVER CON PARANDOSE
		time_start_vulnerable = Time.get_ticks_msec()
	elif state == State.Recover and Time.get_ticks_msec() - time_start_vulnerable > duration_vulnerable:
		state = State.Reposo
		time_last_attack = Time.get_ticks_msec()


func handle_input() -> void:
	if player != null and can_move():
		if can_accion() and proyectil_lanzable.is_colliding():
			state = State.Fly
			velocity = heading * flight_speed
		else:
			if is_player_within_range():
				velocity = Vector2.ZERO
				state = State.Reposo
			else:
				var target_destination := get_target_destination()
				var direction := (target_destination - position).normalized()
				velocity = (direction + knockback_force) * move_speed  
				state = State.Caminar

#SOLUCION ALTERNATIVA
# position.distance_to(target) reemplaza a (target - position).length()

#func handle_input2(delta: float) -> void:
#	if player != null and can_move():
#		var target_destination := get_target_destination()
#		var distance_to_target := position.distance_to(target_destination)
#		
#		# Calculamos cuánto se movería el objeto este frame
#		var movement_this_frame := move_speed * delta
#		
#		# Si la distancia es menor de lo que nos vamos a mover, ya llegamos
#		if distance_to_target <= movement_this_frame:
#			position = target_destination # Teletransportamos justo al centro para evitar desfases
#			velocity = Vector2.ZERO
#		else:
#			var direction := (target_destination - position).normalized()
#			velocity = direction * move_speed

func ataque_completo() -> void:
	print("COMPLETO ATAQUE")
	if state == State.Hurt:
		state = State.Recover
		return
	super.ataque_completo()

func set_heading() -> void:
	if player == null or not can_move():
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT
	
func can_get_hurt() -> bool:
	return true

func can_accion() -> bool:
	if Time.get_ticks_msec() - time_last_attack < duration_between_attacks:
		return false
	return super.can_accion()
	
func is_vulnerable() -> bool:
	return state == State.Recover
	
func on_receive_damage(amount: int, direccion: Vector2, _hit_type: ReceptorDamage.HitType) -> void:
	ComboManager.register_hit.emit()
	if not is_vulnerable():
		knockback_force = direccion * knockback_intensidad/2 #sino divido sale mucho
		return 
	current_health = clamp(current_health - amount, 0, max_health)
	if current_health == 0:
		EntityManager.spawn_spark.emit(position)
		state = State.Caida
		height_speed = knockdown_intensidad
		EntityManager.death_enemy.emit(self)
	else:
		velocity = Vector2.ZERO
		state = State.Hurt
	
	#BOSS SOLO PUEDE HACER DAÑO ASI ANUMALOS LO DEMAS
func on_emit_damage(receiver: ReceptorDamage) -> void:
	receiver.damage_received.emit(damage, heading, ReceptorDamage.HitType.KNOCKDOWN)
	time_last_attack = Time.get_ticks_msec()
	state = State.Reposo

	#BOSS PUEDE HACER DAÑO EN ESTADO FLY
func is_attacking() -> bool:
	return state == State.Fly
