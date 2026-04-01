extends CharacterBody2D

const GRAVEDAD := 600.0

@export var damage : int
@export var health : int
@export var salto_fuerza: float
@export var velocidad_subida: float #talvez deberia hacerlo global
@export var velocidad_bajada: float #talvez deberia hacerlo global
@export var move_speed: float
@onready var animation_player = $AnimationPlayer
@onready var character_sprite = $Sprite2D
@onready var NodoPadre = $".."
@onready var emitidor_daño = $"EmitidorDaño"



#COMENTARIO RANDOMS
enum State {
	Reposo,
	Caminar,
	Golpe,
	Bloqueo,
	Salto_Inicio,
	Salto_Medio,
	Salto_Fin,
	Salto_Patada
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
}

#var height := 22.0
var height := 0.0
var height_speed := 0.0
var state = State.Reposo

#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() ->void:
	emitidor_daño.area_entered.connect(emitir_damage.bind())


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
	if state == State.Salto_Medio or state == State.Salto_Patada:
		height += height_speed * delta * velocidad_subida #Aumentar para velocidad de subida
		if height < 0:
			height = 0
			state = State.Salto_Fin
		else:
			height_speed -= GRAVEDAD * delta * velocidad_bajada #Aumentar para velocidad de bajada

func emitir_damage(damage_receiver: ReceptorDamage) -> void:
	var dirrecion := Vector2.LEFT if damage_receiver.global_position.x < global_position.x else Vector2.RIGHT
	#Se conecta a la funcion damage_received del receptor
	damage_receiver.damage_received.emit(damage, dirrecion)

#ANIMACION CON ANIMATIONPLAYER: https://youtu.be/fuGiJdMrCAk?si=a5CSFPSm1-F9O4Wk&t=609
