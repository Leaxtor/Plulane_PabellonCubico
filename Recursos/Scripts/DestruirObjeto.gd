extends StaticBody2D

const gravedad = 500

@onready var objeto_destruir := $"ReceptorDaño"
@export var knockball : float
@onready var sprite  := $Sprite2D
var velocity := Vector2.ZERO
var height := 0.0
var height_speed := 0.0


enum State {IDLE, DESTROY}
var state := State.IDLE

func _ready() -> void:
	objeto_destruir.damage_received.connect(on_receive_damage.bind())

func _process(delta: float) -> void:
	position += velocity * delta
	sprite.position = Vector2.UP * height
	handle_air_time(delta)

func on_receive_damage(damage: int, dirrecion: Vector2, _hit_Type: ReceptorDamage.HitType) -> void:
	if state == State.IDLE:
		height_speed = knockball
		velocity = dirrecion * knockball
		state = State.DESTROY

func handle_air_time(delta: float) -> void:
	if state == State.DESTROY:
		modulate.a -= delta 
		height +=  height_speed * delta
		if height < 0:
			height = 0
			queue_free()
		else:
			height_speed -= gravedad * delta
