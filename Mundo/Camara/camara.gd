class_name Camera
extends Camera2D

@export var jugador : CharacterBody2D
@export var camara_ancla : float
@export var duration_shake : int
@export var shake_intensity : int


@onready var timer := $Timer

var is_camera_locked := false
var is_shaking := false
var time_start_shaking := Time.get_ticks_msec()
var deadzone = 200.0
var target_y = position.y
var camara_libre := false

func _init() -> void:
	DamageManager.heavy_blow_received.connect(on_heavy_blow_received.bind())


func _ready() -> void:
	StageManager.checkpoint_start.connect(on_checkpoint_start.bind())
	StageManager.camara_modo.connect(on_camara_modo.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())


func _process(delta: float) -> void:
	if !camara_libre:
		position.y = camara_ancla
	
	if jugador != null:
		if not is_camera_locked and jugador.position.x > position.x:
			position.x = jugador.position.x
		
		#BAJA LA CAMARA PARA ABAJO
		if jugador.position.y > target_y + deadzone and camara_libre:
			target_y = jugador.position.y - deadzone
			timer_enderezar_camara()

		elif jugador.position.y < target_y - deadzone and camara_libre:
			target_y = jugador.position.y + deadzone
			timer_enderezar_camara()
			
		# Bajamos el multiplicador (de 20 a 5 o 10) para que sea más fluido
		position.y = lerp(position.y, target_y, delta * 5)
		#timer.timeout.connect(mover_camara)
		
		#MOVER CAMARA ANTE GOLPE
		if is_shaking and (Time.get_ticks_msec() - time_start_shaking < duration_shake):
			offset = Vector2(randi_range(-shake_intensity, shake_intensity),randi_range(-shake_intensity, shake_intensity) )

		else:
			offset = Vector2.ZERO
			is_shaking = false
	else:
		pass

	#Fija la camara
func _on_timer_timeout() -> void:
	if camara_ancla != null:
		print("CAMARA ANCLA")
		target_y = camara_ancla
	elif jugador != null:
		print("CAMARA JUGADOR")
		target_y = jugador.position.y - deadzone



func on_checkpoint_start() -> void:
	is_camera_locked = true

func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	is_camera_locked = false
	
func on_heavy_blow_received() -> void:
	if OptionsManager.is_screenshake_enabled:
		is_shaking = true
		time_start_shaking = Time.get_ticks_msec()

func timer_enderezar_camara() -> void:
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.start()

func on_camara_modo(modo: CamaraCambio.Modo) -> void:
	if modo == CamaraCambio.Modo.LIBRE:
		camara_libre = true
	if modo == CamaraCambio.Modo.FIJO:
		camara_libre = false
