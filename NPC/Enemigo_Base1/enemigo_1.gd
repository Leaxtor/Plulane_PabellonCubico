class_name Enemigo_1
extends Character

const EDGE_SCREEN_BUFFER = 100

@export var duration_appear : float
@export var duration_between_melee_attacks : int
@export var duration_between_range_attacks : int
@export var duration_prep_melee_attack : int
@export var duration_prep_range_attack : int
@export var player : Player


var assigned_door_index := -1
var player_slot : EnemigoSlot = null 
var time_since_last_melee_attack := Time.get_ticks_msec()
var time_since_prep_melee_attack := Time.get_ticks_msec()
var time_since_last_range_attack := Time.get_ticks_msec()
var time_since_prep_range_attack := Time.get_ticks_msec()
var time_since_start_appear := Time.get_ticks_msec()

#SI SE PUEDE GOLPEAR SU CADAVER AYUDA A QUE NO EMITA OTRAS SEÑALES
var is_death := false

func _ready() ->void:
	super._ready()
	anim_attack = ["Golpe","Golpe_2"]

func _process(delta: float) ->void:
	super._process(delta)
	process_appear()

func process_appear() -> void:
	if state == State.Appearing:
		var progress := (Time.get_ticks_msec() - time_since_start_appear) / duration_appear
		if progress < 1:
			modulate.a = progress
		else:
			modulate.a = 1
			state = State.Reposo

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
	var left_destination := Vector2(screen_right_edge - EDGE_SCREEN_BUFFER, player.position.y) #ARREGLAR ese -70
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
		time_since_last_range_attack = Time.get_ticks_msec()
		
	if can_range_attack() and has_gun and proyectil_lanzable.is_colliding():
		#shoot_gun()
		#time_since_knife_dissmiss = Time.get_ticks_msec()
		#time_since_last_range_attack = Time.get_ticks_msec()
		state = State.Prep_shoot
		time_since_prep_range_attack = Time.get_ticks_msec()




func handle_preb_shoot() -> void:
	if state == State.Prep_shoot and (Time.get_ticks_msec() - time_since_prep_range_attack > duration_prep_range_attack):
		shoot_gun()
		time_since_last_range_attack = Time.get_ticks_msec()

func assign_door(door: Door) -> void:
	if door.state != Door.State.OPENED:
		state = State.Wait 
		door.open()
		door.opened.connect(ataque_completo.bind())
	else: #si va a spawnear de una puerta estara invisible hasta que sea su turno
		state = State.Appearing
		modulate.a = 0
		time_since_start_appear = Time.get_ticks_msec()

func handle_prep_attack() -> void:
	if state == State.Preparar_Ataque and (Time.get_ticks_msec() - time_since_prep_melee_attack > duration_prep_melee_attack):
		state = State.Golpe
		time_since_last_melee_attack  = Time.get_ticks_msec()
		anim_attack.shuffle()


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
				time_since_prep_melee_attack = Time.get_ticks_msec()
		else:
			velocity = direction * move_speed 


func is_player_within_range():
	return (player_slot.global_position - global_position).length() < 3

func can_accion() -> bool:
	if Time.get_ticks_msec() - time_since_last_melee_attack < duration_between_melee_attacks:
		return false
	return super.can_accion()

func can_range_attack()-> bool:
	if Time.get_ticks_msec() - time_since_last_range_attack < duration_between_range_attacks:
		return false
	return super.can_accion()
	

func set_heading() -> void:
	if player == null or not can_move(): #Si no hay jugador o no se puede mover no volteara
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT

func on_receive_damage(amount: int, direccion: Vector2, hit_Type: ReceptorDamage.HitType) -> void:
	super.on_receive_damage(amount, direccion, hit_Type)
	ComboManager.register_hit.emit()
	if current_health == 0 or hit_Type == ReceptorDamage.HitType.POWER:
		EntityManager.spawn_spark.emit(position)
	if current_health == 0:
			player.free_slot(self)
			if not is_death:
				EntityManager.death_enemy.emit(self)
			is_death = true
