class_name Character
extends CharacterBody2D

const GRAVEDAD := 600.0

@export var can_respawn : bool
@export var damage : int
@export var damage_power : int
@export var max_health : int
@export var duracion_suelo : float
@export var flight_speed : float
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
@onready var collision_shape := $CollisionShape2D2
@onready var emitidor_daño := $"EmitidorDaño"
@onready var receptor_daño : ReceptorDamage = $"ReceptorDaño" 

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
	Preparar_Ataque
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
}

var attack_combo_index := 0
var is_ultimo_hit_acertado := false
var current_health := 0
var height := 0.0
var height_speed := 0.0
var state = State.Reposo
var time_since_grounded = Time.get_ticks_msec()

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
	set_heading()
	voltear_sprite() #talvez lo cambie
	character_sprite.position = Vector2.UP * height #IMPORTANTE EL SPRITE DEBE ESTAR EN X:0 Y:0 sino se descoloca
	collision_shape.disabled = is_collision_disable()
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
		emitidor_daño.scale.x = 1
	else:
		character_sprite.flip_h = true
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
	State.Reposo,
	State.Caminar,
	#State.Bloqueo,
	State.Salto_Medio,
	State.Salto_Fin,
	State.Salto_Patada,
	#State.Hurt,
	State.Caida,
	#State.Suelo_Caida,
	#State.Parandose,
	#State.Death
	].has(state)

func is_collision_disable() -> bool:
	return [State.Suelo_Caida, State.Death, State.Fly].has(state)

func salto_inicial_completo() -> void:
	state = State.Salto_Medio
	height_speed = salto_fuerza
	
func salto_final_completo() -> void:
	state = State.Reposo

#LLAMO LAS FUNCIONES CON EL ANIMATION PLAYER
func ataque_completo() -> void:
	state = State.Reposo
	
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
