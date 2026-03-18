extends StaticBody2D

const gravedad = 500

@onready var objeto_destruir := $"ReceptorDaño"
@export var knockball : float
@onready var sprite  := $Sprite2D
var velocity := Vector2.ZERO
var peso := 0.0
var peso_velocidad := 0.0


enum State {IDLE, DESTROY}
var state := State.IDLE

func _ready() -> void:
	objeto_destruir.damage_received.connect(on_receive_damage.bind())

func _process(delta: float) -> void:
	position += velocity * delta
	sprite.position = Vector2.UP * peso
	handle_air_time(delta)

func on_receive_damage(damage: int, dirrecion: Vector2) -> void:
	if state == State.IDLE:
		peso_velocidad = knockball
		velocity = dirrecion * knockball
		state = State.DESTROY

func handle_air_time(delta: float) -> void:
	if state == State.DESTROY:
		modulate.a -= delta 
		peso +=  peso_velocidad * delta
		if peso < 0:
			peso = 0
			queue_free()
		else:
			peso_velocidad -= gravedad * delta
