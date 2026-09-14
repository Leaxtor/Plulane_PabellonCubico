class_name EnemigoSlot
extends Node2D

var occupant : Enemigo_1 = null

func is_free() -> bool:
	return occupant == null
	
func free_up() -> void:
	occupant = null

func occupy(enemy: Enemigo_1) -> void:
	occupant = enemy
