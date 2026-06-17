class_name Enemigo_1
extends Character

const EDGE_SCREEN_BUFFER = 100

@export var player : Player
@export var duracion_entre_ataques_melee : int
@export var duracion_preparando_ataque_melee : int
@export var duracion_entre_ataques_range : int
@export var duracion_preparando_ataque_range : int


var player_slot : EnemigoSlot = null 
var time_duracion_last_ataque_melee := Time.get_ticks_msec()
var time_duracion_prep_ataque_melee := Time.get_ticks_msec()	
var time_duracion_last_ataque_range := Time.get_ticks_msec()
var time_duracion_prep_ataque_range := Time.get_ticks_msec()	

func _ready() ->void:
	super._ready()
	anim_attack = ["plus_animacion/Golpe","plus_animacion/Golpe_2"]


func handle_input() -> void:
	if player != null and can_move() :
		if can_respawn_knife or has_knife or has_gun:
			go_to_range_position()
		else: 
			go_to_melee_position()

func go_to_range_position() -> void:
	var camera := get_viewport().get_camera_2d()
	var screen_width := get_viewport_rect().size.x
	var screen_left_edge := camera.position.x - screen_width/2
	var screen_right_edge := camera.position.x + screen_width/2
	var left_destination := Vector2(screen_right_edge - EDGE_SCREEN_BUFFER, player.position.y)
	var right_destination := Vector2(screen_left_edge + EDGE_SCREEN_BUFFER, player.position.y)
	var closest_destination := Vector2.ZERO
	if (left_destination - position).length() < (right_destination - position).length() :
		closest_destination = left_destination
	else:
		closest_destination = right_destination
		
	if (closest_destination - position).length() < 3:
		velocity = Vector2.ZERO
	else:
		velocity = (closest_destination - position).normalized() * move_speed
		
	if can_range_attack() and has_knife and proyectil_lanzable.is_colliding():
		state = State.Throw_lanza
		time_since_knife_dissmiss = Time.get_ticks_msec()
		time_duracion_last_ataque_range = Time.get_ticks_msec()
		
	if can_range_attack() and has_gun and proyectil_lanzable.is_colliding():
		state = State.Prep_shoot
		time_duracion_prep_ataque_range = Time.get_ticks_msec()

func handle_prep_shoot() -> void:
	if state == State.Prep_shoot and (Time.get_ticks_msec() - time_duracion_prep_ataque_range > duracion_preparando_ataque_range):
		shoot_gun()
		time_duracion_last_ataque_range = Time.get_ticks_msec()


func go_to_melee_position() -> void:
	if can_recogiendo_proyectil():
		state = State.Recogiendo
		if player_slot != null:
			player.free_slot(self)
	elif player_slot == null:
		player_slot = player.reserve_slot(self)
		
	if player_slot != null:
		var direction := (player_slot.global_position - position).normalized()
		if is_player_within_range():
			velocity = Vector2.ZERO
			if can_accion() :
				state = State.Preparar_Ataque
				duracion_preparando_ataque_melee = Time.get_ticks_msec()
		else:
			velocity = direction * move_speed 


func handle_prep_attack() -> void:
	if state == State.Preparar_Ataque and (Time.get_ticks_msec() - time_duracion_prep_ataque_melee > duracion_preparando_ataque_melee):
		state = State.Golpe
		time_duracion_last_ataque_melee  = Time.get_ticks_msec()
		anim_attack.shuffle()

func is_player_within_range():
	return (player_slot.global_position - global_position).length() < 3

func can_accion() -> bool:
	if Time.get_ticks_msec() - time_duracion_last_ataque_melee < duracion_entre_ataques_melee:
		return false
	return super.can_accion()

func can_range_attack()-> bool:
	if Time.get_ticks_msec() - time_duracion_last_ataque_range < duracion_entre_ataques_range:
		return false
	return super.can_accion()
	

func set_heading() -> void:
	if player == null or not can_move(): #Si no hay jugador o no se puede mover no volteara
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT

func on_receive_damage(amount: int, direccion: Vector2, hit_Type: ReceptorDamage.HitType) -> void:
	super.on_receive_damage(amount, direccion, hit_Type)
	if current_health == 0:
			player.free_slot(self)
