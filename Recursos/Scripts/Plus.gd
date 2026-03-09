extends CharacterBody2D
#FinalNivel.gd solo funciona si el simbolo de persona sigue llamandose SpritePlus
@export var damage : int
@export var move_speed: float
@onready var animation_player = $AnimationPlayer
@onready var character_sprite = $SpritesPlus
@onready var NodoPadre = $".."
@onready var emitidor_daño = $"EmitidorDaño"


#COMENTARIO RANDOMS
enum State {
	Reposo,
	Caminar,
	Golpe,
	Bloqueo
}

var state = State.Reposo

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() ->void:
	emitidor_daño.area_entered.connect(on_emit_damage.bind())


func _physics_process(_delta: float) ->void :
	handle_input()
	handle_movement()
	handle_animation()
	voltear_sprite() #talvez lo cambie
	move_and_slide()
	
func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.Reposo
		else:
			state = State.Caminar
	else:
		velocity = Vector2.ZERO
	
#GODOT NO ESPERA UNA RESPUESTA CON EL "TIPADO", POR ESO PONER VOID POR RENDIMIENTO
func handle_input() -> void:
	var direction := Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * move_speed
	if can_accion() and Input.is_action_just_pressed("ataque_golpear"):
		print(NodoPadre.position.y)
		state = State.Golpe
	if can_accion() and Input.is_action_just_pressed("move_bloqueo"):
		state = State.Bloqueo
	
func handle_animation() -> void:
	if state == State.Reposo:
		animation_player.play("Reposo")
	elif state == State.Caminar:
		animation_player.play("Caminar")
	elif state == State.Golpe:
		animation_player.play("Golpe")
	elif state == State.Bloqueo:
		animation_player.play("Bloqueo")

func voltear_sprite() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true
		
func can_accion() -> bool:
	return state == State.Reposo or state== State.Caminar

func can_move() -> bool:
	return state == State.Reposo or state == State.Caminar

#LLAMO LAS FUNCIONES CON EL ANIMATION PLAYER
func ataque_completo() -> void:
	state = State.Reposo
	
func bloque_completo() -> void:
	state = State.Reposo

func on_emit_damage(damage_receiver: ReceptorDaño) -> void:
	print(damage_receiver)
	#Es como un contector, salta uno arriba y llama a la funcion get_damage
	damage_receiver.damage_received.emit(damage)

#ANIMACION CON ANIMATIONPLAYER: https://youtu.be/fuGiJdMrCAk?si=a5CSFPSm1-F9O4Wk&t=609
