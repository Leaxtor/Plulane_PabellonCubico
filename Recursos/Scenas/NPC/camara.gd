extends Camera2D

@export var jugador : CharacterBody2D
@onready var timer := $Timer

var is_camera_locked := false

var deadzone = 100.0
var target_y = position.y

func _ready() -> void:
	StageManager.checkpoint_start.connect(on_checkpoint_start.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())

func _process(delta: float) -> void:
	if not is_camera_locked and jugador.position.x > position.x:
		position.x = jugador.position.x
		
	if jugador.position.y > target_y + deadzone:
		target_y = jugador.position.y - deadzone

	elif jugador.position.y < target_y - deadzone:
		target_y = jugador.position.y + deadzone
		timer.wait_time = 5.0
		timer.one_shot = true
		timer.start()
	# Bajamos el multiplicador (de 20 a 5 o 10) para que sea más fluido
	position.y = lerp(position.y, target_y, delta * 5)
	#timer.timeout.connect(mover_camara)

	#Fija la camara
func _on_timer_timeout() -> void:
	target_y = jugador.position.y - deadzone
	print("Alinear Camara")


func on_checkpoint_start() -> void:
	is_camera_locked = true

func on_checkpoint_complete() -> void:
	is_camera_locked = false
