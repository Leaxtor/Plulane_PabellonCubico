extends CharacterBody2D

@export var move_speed: float
@export var jump_speed: float
@onready var animated_sprite = $animatedSprite #Arrastro desde la scena

#Obtiene la referencia al player que vamos a controlar si estuviera en otro nodo.
#@onready var player:Player_generico = self.owner

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

"""
enum STATE {
	REPOSO,
	CORRER,
	SALTAR,
	CAER
}

var current_state:STATE = STATE.REPOSO
"""
func _physics_process(delta: float):
	"""
	match current_state:
		STATE.REPOSO:
			velocity.x = 0
			animated_sprite.play("QUIETO")
			if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
				current_state = STATE.CORRER
			#POR SI PRESIONA AMBAS TECLAS QUEDARSE QUUIETO SI SUELTA UNA COMIENZA A CORRER
			if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
				current_state = STATE.CORRER
			if not Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
				current_state = STATE.CORRER
			#SI SALTA
			elif Input.is_action_just_pressed("jump") and is_on_floor():
				jump(delta)
				current_state = STATE.SALTAR
			pass
		STATE.CORRER:
			moverse(delta)
			if velocity.x > 1: 
				animated_sprite.play("DERECHA")
			if velocity.x < -1: 
				animated_sprite.play("IZQUIERDA")
			#if velocity.x == 0: 
			#	current_state = STATE.REPOSO
			if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
				current_state = STATE.REPOSO
			if  Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
				current_state = STATE.REPOSO
			elif Input.is_action_just_pressed("jump") and is_on_floor():
				jump(delta)
				current_state = STATE.SALTAR
			pass
		STATE.SALTAR:
			moverse(delta)
			if velocity.x > 1: 
				animated_sprite.play("SALTOIDERECHA")
			if velocity.x < -1: 
				animated_sprite.play("SALTOIZQUIERDA")
			if velocity.y > -1: 
				current_state = STATE.CAER
			pass
		STATE.CAER:
			moverse(delta)
			if velocity.x > 1: 
				animated_sprite.play("CAYENDODERECHA")
			if velocity.x < -1: 
				animated_sprite.play("CAYENDOIZQUIERDA")
			if is_on_floor() and velocity.x == 0:
				current_state = STATE.REPOSO
			if is_on_floor() and velocity.x != 0:
				current_state = STATE.CORRER
			pass
	
"""
	gravedad(delta)
	move_and_slide()
	

#MANIPULAR LA VELOCIDAD
func _ready():
	Engine.time_scale = 1


func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y  = -jump_speed
		
func moverse(delta):
	var input_axis = Input.get_axis("move_left","move_right")
	velocity.x = input_axis * move_speed

func gravedad(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
