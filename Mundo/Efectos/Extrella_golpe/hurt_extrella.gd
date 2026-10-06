extends Node2D

@onready var particula_a: GPUParticles2D = $ExtrellaInicio
#@onready var particula_b: GPUParticles2D = $ExtrellaFinal

func _ready() -> void:
	disparar_transformacion()
	

func disparar_transformacion() -> void:
	particula_a.restart()
	particula_a.emitting = true
	

	await get_tree().create_timer(particula_a.lifetime).timeout
	

	particula_a.emitting = false
