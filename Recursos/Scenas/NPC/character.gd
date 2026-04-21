class_name Character
extends CharacterBody2D

const GRAVEDAD := 600.0

@export var damage : int
@export var max_health : int
@export var salto_fuerza: float
@export var velocidad_subida: float #talvez deberia hacerlo global
@export var velocidad_bajada: float #talvez deberia hacerlo global
@export var move_speed: float
@export var knockback_intensidad: float
@export var knockdown_intensidad: float

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $Sprite2D
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
	Suelo_Caida
}

var animation_map := {
	State.Reposo: "plus_animacion/Reposo",
	State.Caminar: "plus_animacion/Caminar",
	State.Golpe: "plus_animacion/Golpe",
	State.Bloqueo: "plus_animacion/Bloqueo",
	State.Salto_Inicio: "plus_animacion/Salto_Inicio",
	State.Salto_Medio: "plus_animacion/Salto_Medio",
	State.Salto_Fin: "plus_animacion/Salto_Fin",
	State.Salto_Patada: "plus_animacion/Salto_Patada",
	State.Hurt: "plus_animacion/Hurt",
	State.Caida: "plus_animacion/Caida",
	State.Suelo_Caida: "plus_animacion/Suelo_Caida",
}

var current_health := 0
var height := 0.0
var height_speed := 0.0
var state = State.Reposo

#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() ->void:
	emitidor_daño.area_entered.connect(on_emit_damage.bind())
	receptor_daño.damage_received.connect(on_receive_damage.bind())
	current_health = max_health

func _physics_process(delta: float) ->void :
	handle_input()
	handle_movement()
	handle_animation()
	handle_airtime(delta)
	voltear_sprite() #talvez lo cambie
	character_sprite.position = Vector2.UP * height #IMPORTANTE EL SPRITE DEBE ESTAR EN X:0 Y:0 sino se descoloca
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
	
func handle_animation() -> void:
	#Reemplaza tener que hacer in elseif para cada estado
	if animation_player.has_animation(animation_map[state]):
		animation_player.play(animation_map[state])

func voltear_sprite() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		emitidor_daño.scale.x = 1
	elif velocity.x < 0:
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
			else:
				state = State.Salto_Fin
		else:
			height_speed -= GRAVEDAD * delta * velocidad_bajada #Aumentar para velocidad de bajada

func on_emit_damage(receiver: ReceptorDamage) -> void:
	var dirrecion := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	var hit_type := ReceptorDamage.HitType.NORMAL
	if state == State.Salto_Patada:
		hit_type = ReceptorDamage.HitType.KNOCKDOWN
	receiver.damage_received.emit(damage, dirrecion, hit_type)
	print("DAÑO ENVIADO")
	
func on_receive_damage(amount: int, direccion: Vector2, hit_type: ReceptorDamage.HitType) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	if current_health == 0 or hit_type == ReceptorDamage.HitType.KNOCKDOWN:
		state = State.Salto_Fin
		print("EN CAIDA LIBRE")
		height_speed = knockdown_intensidad
	else:
		state = State.Hurt
	velocity = direccion * knockback_intensidad
	


#ANIMACION CON ANIMATIONPLAYER: https://youtu.be/fuGiJdMrCAk?si=a5CSFPSm1-F9O4Wk&t=609
