class_name Roedor
extends Character

const GROUND_FRICTION := 250
const EDGE_SCREEN_BUFFER = 100

@export var duration_between_melee_attacks : int
@export var duration_between_range_attacks : int
@export var duration_prep_melee_attack : int
@export var duration_prep_range_attack : int
@export var player : Player


var time_since_last_melee_attack := Time.get_ticks_msec()
var time_since_prep_melee_attack := Time.get_ticks_msec()
var time_since_last_range_attack := Time.get_ticks_msec()
var time_since_prep_range_attack := Time.get_ticks_msec()
var time_since_start_appear := Time.get_ticks_msec()
var player_slot : EnemigoSlot = null 
var assigned_door_index := -1
var knockback_force := Vector2.ZERO
var time_last_attack := Time.get_ticks_msec()
var time_start_vulnerable := Time.get_ticks_msec()

func _ready() ->void:
	super._ready()
	anim_attack = ["Golpe"]

func handle_input(delta: float) -> void:
	if player != null and can_move() :
		if can_respawn_knife or has_knife or has_gun:
			go_to_range_position(delta)
		else: 
			go_to_melee_position(delta)

func go_to_melee_position(delta: float) -> void:
	var collectible_areas := collectible_sensor.get_overlapping_areas()
	if collectible_areas.size() > 0:
		var collectible : Collectible = collectible_areas[0]
		if can_recogiendo_proyectil(collectible):
			state = State.Recogiendo
			if player_slot != null:
				player.free_slot_laterales(self)
	#elif player_slot == null:
		#player_slot = player.reserve_slot(self)
	
	if player_slot != null:
		var to_target := player_slot.global_position - global_position
		var distance := to_target.length()
		
		#DESOCUPA EN CASO QUEDE OBSTRUIDO
		if !player_slot.Desocupado:
			player.free_slot_laterales(self)
			#player_slot = player.reserve_slot(self)
			
	
		if distance < 1.0:
			velocity = Vector2.ZERO
			global_position = player_slot.global_position
			if can_accion():
				state = State.Preparar_Ataque
				#time_since_prep_melee_attack = Time.get_ticks_msec()
		else:
			var step := minf(move_speed * delta, distance)
			velocity = to_target.normalized() * (step / delta)


func go_to_range_position(delta: float) -> void:
	var camera := get_viewport().get_camera_2d()
	var screen_width := get_viewport_rect().size.x
	var screen_left_edge := camera.position.x - screen_width/2
	var screen_right_edge := camera.position.x + screen_width/2
	var left_destination := Vector2(screen_right_edge - EDGE_SCREEN_BUFFER, player.position.y) #ARREGLAR ese -70
	var right_destination := Vector2(screen_left_edge + EDGE_SCREEN_BUFFER, player.position.y)
	var closest_destination := Vector2.ZERO
	if (left_destination - position).length() < (right_destination - position).length() :
		closest_destination = left_destination
	else:
		closest_destination = right_destination
		
	#DESTINO
	var to_target := closest_destination - global_position
	var distance := to_target.length()
	
	if distance < 1:
		velocity = Vector2.ZERO
		global_position = closest_destination
	else:
		var step := minf(move_speed * delta, distance)
		velocity = to_target.normalized() * (step / delta)
		
	if can_range_attack() and has_knife and proyectil_lanzable.is_colliding():
		state = State.Throw_lanza
		velocity = Vector2.ZERO
		time_since_knife_dissmiss = Time.get_ticks_msec()
		time_since_last_range_attack = Time.get_ticks_msec()
		

func can_range_attack()-> bool:
	if Time.get_ticks_msec() - time_since_last_range_attack < duration_between_range_attacks:
		return false
	return super.can_accion()


func get_target_destination() -> Vector2:
	var target := Vector2.ZERO
	#if position.x < player.position.x:
	#	target = player.position + Vector2.LEFT * distance_from_player
	#else:
	#	target = player.position + Vector2.RIGHT * distance_from_player
	return target

func is_player_within_range() -> bool:
	var target := get_target_destination()
	return (target - position).length() < 10
	#AQUI HAY UN PROBLEMA A REALIZA SI CORRE MUY RAPIDO Y SE PASA SE PONE A CORRER POR SIEMPRE

func handle_grounded() ->void:
	if state == State.Suelo_Caida and current_health > 0:
		state = State.Recover #NO CONFUNDIR RECOVER CON PARANDOSE
		time_start_vulnerable = Time.get_ticks_msec()
	#elif state == State.Recover and Time.get_ticks_msec() - time_start_vulnerable > duration_vulnerable:
	#	state = State.Reposo
	#	time_last_attack = Time.get_ticks_msec()



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
	if Time.get_ticks_msec() - time_since_last_melee_attack < duration_between_melee_attacks:
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
		SoundPlayer.play(SoundManager.Sound.GRUNT)
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
