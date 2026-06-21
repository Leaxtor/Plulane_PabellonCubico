class_name Character
extends CharacterBody2D

const GRAVEDAD := 600.0

@export var can_respawn : bool
@export var can_respawn_knife : bool
@export var damage : int
@export var damage_power : int
@export var damage_gunshot : int
@export var max_health : int
@export var duracion_suelo : float
@export var duracion_between_knife_respawn : float
@export var flight_speed : float
@export var has_knife : bool
@export var has_gun : bool
@export var salto_fuerza: float
@export var velocidad_subida: float #talvez deberia hacerlo global
@export var velocidad_bajada: float #talvez deberia hacerlo global
@export var move_speed: float
@export var knockback_intensidad: float
@export var knockdown_intensidad: float

@onready var heading := Vector2.RIGHT
@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $Sprite2D
@onready var collateral_damage_emmiter : Area2D = $CollateralEmitidorDaño
@onready var collectible_sensor : Area2D = $CollectibleSensor
@onready var collision_shape := $CollisionShape2D2
@onready var emitidor_daño := $"EmitidorDaño"
@onready var receptor_daño : ReceptorDamage = $"ReceptorDaño" 
@onready var knife_sprite := $"Cuchillo"
@onready var gun_sprite := $"GunSprite"
@onready var proyectil_lanzable : RayCast2D = $ProyectilLanzable #proyectil_aim
@onready var weapon_position : Node2D = $Cuchillo/WeaponPosition

#COMENTARIO RANDOMS


enum State {
	Reposo,
	Caminar,
	Golpe,
	Bloqueo,
	Salto_Inicio,
	Salto_Medio,
	Salto_Fin,
	Salto_Patada,
	Hurt,
	Caida,
	Suelo_Caida,
	Parandose,
	Death,
	Fly,
	Preparar_Ataque,
	Throw_lanza,
	Recogiendo,
	Shoot,
	Prep_shoot
}

var anim_attack := []

var animation_map := {
	State.Reposo: "plus_animacion/Reposo",
	State.Caminar: "plus_animacion/Caminar",
	State.Bloqueo: "plus_animacion/Bloqueo",
	State.Salto_Inicio: "plus_animacion/Salto_Inicio",
	State.Salto_Medio: "plus_animacion/Salto_Medio",
	State.Salto_Fin: "plus_animacion/Salto_Fin",
	State.Salto_Patada: "plus_animacion/Salto_Patada",
	State.Hurt: "plus_animacion/Hurt",
	State.Caida: "plus_animacion/Caida",
	State.Suelo_Caida: "plus_animacion/Suelo_Caida",
	State.Parandose: "plus_animacion/Parandose",
	State.Death: "plus_animacion/Suelo_Caida",
	State.Fly: "plus_animacion/Fly",
	State.Preparar_Ataque: "plus_animacion/Reposo", #PODRIA PONER OTRA ANIMACION
	State.Throw_lanza: "plus_animacion/Throw_lanza",
	State.Recogiendo: "plus_animacion/Recogiendo",
	State.Shoot: "plus_animacion/Shoot",
	State.Prep_shoot: "plus_animacion/Reposo",
}

var attack_combo_index := 0
var is_ultimo_hit_acertado := false
var current_health := 0
var height := 0.0
var height_speed := 0.0
var state = State.Reposo
var time_since_grounded := Time.get_ticks_msec()
var time_since_knife_dissmiss := Time.get_ticks_msec()

#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() ->void:
	emitidor_daño.area_entered.connect(on_emit_damage.bind())
	receptor_daño.damage_received.connect(on_receive_damage.bind())
	collateral_damage_emmiter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emmiter.body_entered.connect(on_wall_hit.bind())
	current_health = max_health

func _physics_process(delta: float) ->void :
	handle_input()
	handle_movement()
	handle_animation()
	handle_grounded()
	handle_death(delta)
	handle_airtime(delta)
	handle_prep_attack()
	handle_preb_shoot()
	handle_knife_respawn()
	set_heading()
	knife_sprite.visible = has_knife
	gun_sprite.visible = has_gun
	voltear_sprite() #talvez lo cambie
	character_sprite.position = Vector2.UP * height #IMPORTANTE EL SPRITE DEBE ESTAR EN X:0 Y:0 sino se descoloca
	knife_sprite.position = Vector2.UP * height
	gun_sprite.position = Vector2.UP * height
	collision_shape.disabled = is_collision_disable()
	emitidor_daño.monitoring = is_attacking()
	receptor_daño.monitorable = can_get_hurt()
	move_and_slide()
	
	
func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.Reposo
		else:
			state = State.Caminar
	elif state == State.Golpe:
		velocity = Vector2.ZERO
	
#GODOT NO ESPERA UNA RESPUESTA CON EL "TIPADO", POR ESO PONER VOID POR RENDIMIENTO
func handle_input() -> void:
	pass

func handle_prep_attack() -> void:
	pass

func handle_preb_shoot() -> void:
	pass

func handle_knife_respawn() ->void:
	if can_respawn_knife and not has_knife and (Time.get_ticks_msec() - time_since_knife_dissmiss > duracion_between_knife_respawn):
		has_knife = true

func handle_grounded() ->void:
	if state == State.Suelo_Caida and (Time.get_ticks_msec() - time_since_grounded > duracion_suelo):
		if current_health == 0:
			state = State.Death
		else:
			state = State.Parandose

func handle_death(delta: float) ->void:
	if state == State.Death and not can_respawn:
		modulate.a -= delta/2.0
		if modulate.a <= 0:
			queue_free()

func handle_animation() -> void:
	if state == State.Golpe:
		animation_player.play(anim_attack[attack_combo_index])
	#Reemplaza tener que hacer in elseif para cada estado
	elif animation_player.has_animation(animation_map[state]):
		animation_player.play(animation_map[state])

func set_heading() -> void:
	pass

func voltear_sprite() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
		knife_sprite.scale.x = 1
		gun_sprite.scale.x = 1
		proyectil_lanzable.scale.x = 1
		emitidor_daño.scale.x = 1
	else:
		character_sprite.flip_h = true
		knife_sprite.scale.x = -1
		gun_sprite.scale.x = -1
		proyectil_lanzable.scale.x = -1
		emitidor_daño.scale.x = -1
		
func can_accion() -> bool:
	return state == State.Reposo or state== State.Caminar

func can_move() -> bool:
	return state == State.Reposo or state == State.Caminar
	
func can_jump() -> bool:
	return state == State.Reposo or state == State.Caminar

func can_jump_patada() -> bool:
	return state == State.Salto_Medio

#LO QUE ESTA ACTIVADO ES CUANDO LO PUEDEN GOLPEAR
func can_get_hurt() ->bool:
	return [
	State.Golpe,
	State.Reposo,
	State.Caminar,
	State.Preparar_Ataque,
	#State.Bloqueo,
	#State.Salto_Medio,
	#State.Salto_Fin,
	#State.Salto_Patada,
	#State.Hurt,
	State.Caida,
	#State.Suelo_Caida,
	#State.Parandose,
	#State.Death
	].has(state)

func  is_attacking() -> bool:
	return [State.Golpe, State.Salto_Patada].has(state)


func shoot_gun() -> void:
	state = State.Shoot
	velocity = Vector2.ZERO
	var target_point := heading * (global_position.x + get_viewport_rect().size.x)
	var target := proyectil_lanzable.get_collider()
	if target != null:
		target_point = proyectil_lanzable.get_collision_point()
		target.on_receive_damage(damage_gunshot,heading, ReceptorDamage.HitType.KNOCKDOWN)
	var weapon_root_position := Vector2(weapon_position.global_position.x, position.y)
	var weapon_height := -weapon_position.position.y
	var distance := target_point.x - weapon_position.global_position.x
	EntityManager.spawn_shot.emit(weapon_root_position, distance, weapon_height)
 


func can_recogiendo_proyectil() ->bool:
	var collectible_areas := collectible_sensor.get_overlapping_areas()
	if collectible_areas.size() == 0:
		return false
	var collectible : Collectible = collectible_areas[0]
	if collectible.type == Collectible.Type.KNIFE and not has_knife:
		return true
	if collectible.type == Collectible.Type.GUN and not has_gun:
		return true
	return false

func recogiendo_proyectil() ->void:
	if can_recogiendo_proyectil():
		var collectible_areas := collectible_sensor.get_overlapping_areas()
		var collectible : Collectible = collectible_areas[0]
		if collectible.type == Collectible.Type.KNIFE and not has_knife:
			has_knife = true
		if collectible.type == Collectible.Type.GUN and not has_gun:
			has_gun = true
		collectible.queue_free()

func is_collision_disable() -> bool:
	return [State.Suelo_Caida, State.Death, State.Fly].has(state)

func salto_inicial_completo() -> void:
	state = State.Salto_Medio
	height_speed = salto_fuerza
	
func salto_final_completo() -> void:
	state = State.Reposo

func on_recogiendo_completo() -> void:
	state = State.Reposo
	recogiendo_proyectil()

#LLAMO LAS FUNCIONES CON EL ANIMATION PLAYER
func ataque_completo() -> void:
	state = State.Reposo

func on_throw_complete() -> void:
	state = State.Reposo
	has_knife = false
	var knife_global_position := Vector2(weapon_position.global_position.x, global_position.y)
	var knife_height := weapon_position.position.y 
	EntityManager.spawn_collectible.emit(Collectible.Type.KNIFE, Collectible.State.FLY, knife_global_position, heading, knife_height)

func bloque_completo() -> void:
	state = State.Reposo

#MODIFICAR
func handle_airtime(delta: float) -> void:
	#if state == State.Salto_Medio or state == State.Salto_Patada:
	if [State.Salto_Medio, State.Salto_Patada, State.Caida].has(state):
		height += height_speed * delta * velocidad_subida #Aumentar para velocidad de subida
		if height < 0:
			height = 0
			if state == State.Caida:
				state = State.Suelo_Caida
				time_since_grounded = Time.get_ticks_msec()
				
			else:
				state = State.Salto_Fin
			velocity = Vector2.ZERO
		else:
			height_speed -= GRAVEDAD * delta * velocidad_bajada #Aumentar para velocidad de bajada

func on_emit_damage(receiver: ReceptorDamage) -> void:
	var dirrecion := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	var hit_type := ReceptorDamage.HitType.NORMAL
	var current_damage = damage 
	if state == State.Salto_Patada:
		print("SALTO PATADA")
		hit_type = ReceptorDamage.HitType.KNOCKDOWN
	if attack_combo_index == anim_attack.size() -1: #HAY UN ERROR SI HAGO SALTO PATADA NO SE RESETEA
		hit_type = ReceptorDamage.HitType.POWER
		current_damage = damage_power
	receiver.damage_received.emit(damage, dirrecion, hit_type)
	is_ultimo_hit_acertado = true
	#print("DAÑO ENVIADO")
	
func on_emit_collateral_damage(receiver: ReceptorDamage) ->void:
	print("DAÑO COLATERAL")
	if receiver != receptor_daño:
		var dirrecion := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
		receiver.damage_received.emit(damage, dirrecion, ReceptorDamage.HitType.KNOCKDOWN)
	
func on_wall_hit(_wall: AnimatableBody2D) ->void:
	print("WALL")
	state = State.Caida
	height_speed = knockdown_intensidad
	velocity = -velocity / 2.0
	
	
func on_receive_damage(amount: int, direccion: Vector2, hit_type: ReceptorDamage.HitType) -> void:
	if can_get_hurt():
		can_respawn_knife = false #le quita el cuchillo al gople
		if has_knife:
			has_knife = false
			time_since_knife_dissmiss = Time.get_ticks_msec()
		if has_gun:
			has_gun = false
		current_health = clamp(current_health - amount, 0, max_health)
		print(current_health)
		## LO ULTIMO (STATE CAIDA) quitar del cage get hurt para combear en el aire
		if current_health == 0 or hit_type == ReceptorDamage.HitType.KNOCKDOWN or state == State.Caida:
			state = State.Caida
			
			height_speed = knockdown_intensidad
		elif hit_type == ReceptorDamage.HitType.POWER:
			state = State.Fly
			print("VOLANDO")
			velocity = direccion * flight_speed #No esta funcionando al velocidad
		else:
			state = State.Hurt
			velocity = direccion * knockback_intensidad
		


#ANIMACION CON ANIMATIONPLAYER: https://youtu.be/fuGiJdMrCAk?si=a5CSFPSm1-F9O4Wk&t=609
