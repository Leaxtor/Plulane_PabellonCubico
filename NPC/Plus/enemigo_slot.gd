class_name EnemigoSlot
extends Node2D

#@export var ubicacion : Ubicacion
#enum Ubicacion {ARRIBA, ABAJO}
@onready var area_2d: Area2D = $Area2D

var occupant : Enemigo_1 = null
var Desocupado : bool = true 


func _process(delta: float) ->void :
	var cuerpos_dentro = area_2d.get_overlapping_bodies()
	Desocupado = cuerpos_dentro.is_empty()


func is_free() -> bool:
	return occupant == null and Desocupado
	
func free_up() -> void:
	occupant = null

func occupy(enemy: Enemigo_1) -> void:
	occupant = enemy
